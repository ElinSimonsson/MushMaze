//
//  UserModel.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-02.
//

import Foundation
import Firebase
import FirebaseAuth

class UserModel : ObservableObject {
    let db = Firestore.firestore()
    @Published var user : User?
    @Published var signedIn = false
    @Published var signedOut = false
    
    func fetchUserImageURL(userID: String, completion: @escaping (_ imageURL: String?, _ error: Error?) -> Void) {
            let userRef = db.collection("users").document(userID)
            userRef.getDocument { (document, error) in
                if let error = error {
                    completion(nil, error)
                } else if let document = document, let data = document.data() {
                    let imageURL = data["imageURL"] as? String
                    completion(imageURL, nil)
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

    func fetchUserData () {
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        
        let docRef = db.collection("users").document(userUID)
        
        docRef.getDocument { (document, error ) in
            guard error == nil else {
                print("error", error ?? "")
                return
            }
            if let document = document, document.exists {
                let data = document.data()
                if let data = data {
                    let fullName = data["fullName"] as? String ?? ""
                    let email = document.get("emailAddress") as? String ?? ""
                    let imageURL = document.get("imageURL") as? String ?? ""
                    self.user = User(fullName: fullName, emailAddress: email, userId: userUID, imageURL: imageURL)
                }
            }
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
        
        func updateUserDataToFirestore (user: User) {
            
        }
        
        func saveUserDataToFirestore (fullName: String, emailAddress : String) {
            guard let userUID = Auth.auth().currentUser?.uid else {return}
            let user = User(fullName: fullName, emailAddress: emailAddress, userId: userUID, imageURL: "")
            do {
                _ = try
                db.collection("users").document(userUID).setData(from: user)
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
                    self.saveUserDataToFirestore(fullName: fullName, emailAddress: emailAddress)
                }
            }
        }
}



