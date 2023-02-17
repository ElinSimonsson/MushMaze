//
//  UserModel.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-02.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestoreSwift
import UIKit

class UserModel : ObservableObject {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    @Published var user : User?
    @Published var notifications = [Notification]()
    @Published var signedIn = false
    @Published var signedOut = false
    var listener : ListenerRegistration?
    
    
    func listenNotificationsFromFirestore () {
        guard let currentUser = Auth.auth().currentUser else {return}
        
       listener = db.collection("users").document(currentUser.uid).collection("notifications").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else {return}
            if let err = err {
                print("error getting notifications from firestore \(err)")
            } else {
                self.notifications.removeAll()
                for document in snapshot.documents {
                    let result = Result {
                        try document.data(as: Notification.self)
                    }
                    switch result {
                    case .success(let notification) :
                        self.notifications.append(notification)
                        print("successfully decoding notification")
                    case . failure(let error) :
                        print("Error decoding notification: \(error)")
                    }
                }
            }
        }
        
    }

    func fetchUserInfo(userID: String, completion: @escaping (_ imageURL: String?, _ name: String?, _ error: Error?) -> Void) {
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(nil, nil, error)
            } else if let document = document, let data = document.data() {
                let imageURL = data["imageURL"] as? String
                let name = data["fullName"] as? String
                completion(imageURL, name, nil)
            }
        }
    }
    
    func logOut () {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            signedOut = true
            signedIn = false
            user = nil
            listener?.remove()
            listener = nil
            notifications.removeAll()
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func logIn (email: String, password:  String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("error signing in \(error)")
            } else {
                self.signedIn = true
                self.signedOut = false
                // if the user have logged out, and then logged in again - we need to change the signedOut
                // to false to show DestinationView
            }
        }
    }
    
    func updateUserDataToFirestore (imageURL: String, fullName: String) {
        guard let currentUser = Auth.auth().currentUser else {return}
        let user = User(fullName: fullName, userId: currentUser.uid, imageURL: imageURL)
        
        do {
            let document = db.collection("users").document(currentUser.uid)
            try document.setData(from: user)
            document.updateData(["keywordsForLookup" : user.keywordsForLookup])
        } catch {
            print("Error updating: \(error)")
        }
    }
    
    func saveUserDataToFirestore (fullName: String) {
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        let user = User(fullName: fullName, userId: userUID, imageURL: "")
        do {
            
            let document = db.collection("users").document(userUID) // ny rad
            _ = try
            document.setData(from: user)
            document.updateData(["keywordsForLookup" : user.keywordsForLookup])
            
            print("successed to save")
            signedIn = true
            signedOut = false
        } catch {
            print("Error saving to Firebase")
        }
    }
    
    func createUserAndSaveToFirestore (fullName: String, emailAddress: String, password: String) {
        Auth.auth().createUser(withEmail: emailAddress, password: password) { authResult, error in
            if let error = error {
                print("error signing up \(error.localizedDescription)")
            } else {
                print("account created successfully")
                self.saveUserDataToFirestore(fullName: fullName)
            }
        }
    }
    
    func loadUserInformation () {
        guard let user = Auth.auth().currentUser else {return}
        let docRef = db.collection("users").document(user.uid)
        
        docRef.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            let data = document.data()
            if let data = data {
                let fullName = data["fullName"] as? String ?? ""
                let imageURL = document.get("imageURL") as? String ?? ""
                self.user = User(fullName: fullName, userId: user.uid, imageURL: imageURL)
            }
        }
    }
    
    func uploadPhotoAndSaveToFirestore (selectedImage : UIImage?, fullName: String) {
        let fileName = "\(UUID().uuidString).jpg"
        let ref = Storage.storage().reference(withPath: fileName)
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.5) else {return}
        ref.putData(imageData ,metadata: nil) { metadata, err in
            if let err = err {
                print("failed to push image to Storage\(err)")
                return
            }
            ref.downloadURL { url, err in
                if let err = err {
                    print("failed to retrieve downloadURL \(err)")
                    return
                } else {
                    print("successfully stored image with url : \(url?.absoluteString ?? "")")
                    guard let imageURL = url?.absoluteString else {return}
                    self.updateUserDataToFirestore(imageURL: imageURL, fullName: fullName)
                }
            }
        }
    }
    
    func deletePictureStorageAndSaveNewData(newImage: UIImage, fullName: String) {
        if let user = user {
            let storageRef = storage.reference(forURL: user.imageURL)
            
            //Removes image from storage
            storageRef.delete { error in
                if let error = error {
                    print(error)
                } else {
                    print("successfully deleted image")
                    self.uploadPhotoAndSaveToFirestore(selectedImage: newImage, fullName: fullName)
                }
            }
        }
    }
}



