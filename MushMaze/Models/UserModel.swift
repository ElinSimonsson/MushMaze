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
    @Published var friendRequests = [FriendRequest]()
    @Published var signedIn = false
    @Published var signedOut = false
    @Published var saved = false
    
    
    func acceptFriendRequest (friendRequest : FriendRequest) {
        guard let currentUser = Auth.auth().currentUser else {return}
        guard let friendRequestID = friendRequest.id else {return}
        

        do {
            try db.collection("users")
                .document(friendRequest.senderId)
                .collection("friendRequest")
                .document(friendRequestID)
                .updateData(["status" : "accepted"])
            print("friendRequest sender ID \(friendRequest.senderId)")

            try db.collection("users")
                .document(friendRequest.recipientId)
                .collection("friendRequest")
                .document(friendRequestID)
                .updateData(["status" : "accepted"])
            print("currentUser id \(currentUser.uid)")


        } catch {
            print("Error updating status: \(error)")
        }
        
        
    }
    
    func sendRequestToFriend (recipientId : String) {
        guard let currentUser = Auth.auth().currentUser else {return}
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        let dateString = dateFormatter.string(from: Date())
//
////        let date = Date()
////        let timeStamp = Timestamp(date: date)
//
//        let date : Date = Date()
//        let timestamp = Timestamp(date: date)
        
        //let friendRequest = FriendRequest(senderId: currentUser.uid, recipientId: recipientId, status: .pending)

        var ref: DocumentReference? = nil // error Cannot find type DocumentReference in scope
        ref = db.collection("users").document(currentUser.uid).collection("friendRequest").addDocument(data: [
//            "date": timestamp,
            "senderId": currentUser.uid,
            "recipientId" : recipientId,
            "status" : "pending"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                
                //let data = FriendRequest(id: ref!.documentID , senderId: currentUser.uid, recipientId: recipientId, status: .pending)
                
                
                self.db.collection("users").document(recipientId).collection("friendRequest").document(ref!.documentID).setData([
//                        "date": date,
                        "senderId": currentUser.uid,
                        "recipientId" : recipientId,
                        "status" : "pending"
                    ])
                
            }
        }
        
//        do {
//            try db.collection("users").document(currentUser.uid).collection("friendRequest").addDocument(from: friendRequest)
//            try db.collection("users").document(recipientId).collection("friendRequest").addDocument(from: friendRequest)
//        } catch {
//            print("failed to send request to recipient ")
//        }
    }
    
    func listenFriendRequestFirestore () {
        guard let user = Auth.auth().currentUser else {return}
        
        db.collection("users").document(user.uid).collection("friendRequest").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else {return}
            if let err = err {
                print("failed getting documents \(err)")
            } else {
                self.friendRequests.removeAll()
                for document in snapshot.documents {
                    let result = Result {
                        try document.data(as: FriendRequest.self)
                    }
                    switch result {
                    case .success(let friendRequest) :
                        self.friendRequests.append(friendRequest)
                        print("friendRequest: \(friendRequest)")
                    case .failure(let error) :
                        print("Error decoding friendRequest \(err)")
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
            self.saved = true
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
                //db.collection("users").document(userUID)
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
                let email = document.get("emailAddress") as? String ?? ""
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



