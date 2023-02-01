//
//  ProfileView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-26.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage

struct ProfileView: View {
    @Binding var signedOut : Bool
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    let db = Firestore.firestore()
    @Environment(\.presentationMode) var presentationMode
    @State var fullName = ""
    @State var email = ""
    @State var imageURL = ""
    
    var body: some View {
        VStack {
            HStack{
                Button(action: {
                   
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                }
                Spacer()
                Button(action: {
                    signOut()
                    signedOut = true
                    presentationMode.wrappedValue.dismiss()
                    
                }) {
                    Text("Sign out")
                }
            }

            YourProfileText()

            ProfileImage(imageURL: $imageURL)
            
            Button(action: {
               print("the user want to edit profile picture")
            }) {
                Text("Edit")
            }
            .padding(.bottom, 60)

            HStack {
                Text("Full name:")
                Spacer()
            }
            FullNameTextField(fullName: $fullName, lightGreyColor: lightGreyColor)
            
            Spacer()
        }
        .padding()
        .onAppear() {
            
            getUserInformation()
           // getAllUsers()
        }
    }
    
    func getUserInformation () {
        guard let user = Auth.auth().currentUser else {return}
        
       // print("user.id är \(user.uid)")
        
        let docRef = db.collection("users").document(user.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
               // let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                print("Document data: \(dataDescription)")
                fullName = document.get("fullName") as? String ?? ""
                email = document.get("emailAddress") as? String ?? ""
                imageURL = document.get("imageURL") as? String ?? ""
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getAllUsers () {
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func signOut () {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

struct ProfileImage : View {
    @Binding var imageURL : String
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL),
                   content:  { image in
            image
                .resizable()
                .scaledToFit()
            
        },
                   placeholder: {ProgressView()}
        )
        .aspectRatio(contentMode: .fill)
        .frame(width: 200, height: 200)
        .clipShape(Circle())
        .padding(.bottom, 20)
        .padding(.top, 30)
    }
}

struct YourProfileText : View {
    var body : some View {
        Text("Your Profile")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.top, 50)
    }
}

struct FullNameTextField : View {
    @Binding var fullName : String
    let lightGreyColor : Color
    
    var body: some View {
        TextField("", text: $fullName)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}

struct UserImageView : View {
    var body: some View {
        Image(systemName: "person")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150, height: 150)
            .clipped()
            .cornerRadius(150)
            .padding(.bottom, 75)
            .padding(.top, 30)
        
    }
}



//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}
