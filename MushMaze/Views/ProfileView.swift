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
    @EnvironmentObject var userModel : UserModel
    @EnvironmentObject var places : Places
    @EnvironmentObject var friends : Friends
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    let db = Firestore.firestore()
    @State private var sourceType : UIImagePickerController.SourceType = .photoLibrary
    @Environment(\.presentationMode) var presentationMode
    @State var fullName = ""
    @State var email = ""
    @State var imageURL = ""
    @State var showSourceAlert = false
    @State var openCameraRoll = false
    @State var selectedImage : UIImage? = nil
    
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
                    userModel.logOut()
                    places.clearAllPlaces()
                    friends.clearAllFriendList()
                    friends.stopListening()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Sign out")
                }
            }
            YourProfileText()
            
            if let user = userModel.user {
                Button(action: {
                    showSourceAlert = true
                }, label: {
                    if let image = selectedImage {
                        SelectedImageView(selectedImage: image)
                    } else if user.imageURL == "" {
                        DefaultProfilePicture()
                    } else {
                        ProfileImage(imageURL: user.imageURL)
                    }
                }).alert(isPresented: $showSourceAlert) {
                    Alert(title: Text("Choose Source"),
                          primaryButton: .default(Text("Camera")) {
                        sourceType = .camera
                        openCameraRoll = true
                    }, secondaryButton: .default(Text("Photo")) {
                        sourceType = .photoLibrary
                        openCameraRoll = true
                    })
                }
                .fullScreenCover(isPresented: $openCameraRoll) {
                    ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
                }
                
                Button(action: {
                    showSourceAlert = true
                }) {
                    Text("Edit")
                }
                .padding(.bottom, 60)
                
                HStack {
                    Text("Full name:")
                    Spacer()
                }
                FullNameTextField(fullName: $fullName, lightGreyColor: lightGreyColor)
                    .onAppear() {
                        fullName = user.fullName
                    }
                
                Spacer()
            Button(action: {
                print("userName: \(fullName)")
                saveToFirestore()
            }) {
                Text("Save")
            }
                Spacer()
        }
    }
        .padding()
        .onAppear() {
            userModel.loadUserInformation()
    }
}

    func signOut () {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            userModel.signedOut = true
            userModel.signedIn = false
            userModel.user = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
   
    func saveToFirestore () {
        if userModel.user?.imageURL == "" && selectedImage != nil {
            //uploadPhotoAndSaveToFirestore()
            userModel.uploadPhotoAndSaveToFirestore(selectedImage: selectedImage, fullName: $fullName.wrappedValue)
        } else if userModel.user?.imageURL != "" && selectedImage != nil {
            if let image = selectedImage {
                userModel.deletePictureStorageAndSaveNewData(newImage: image, fullName: $fullName.wrappedValue)
                //deleteImageFromStorageAndSaveNew()
            }
        } else if userModel.user?.imageURL != "" && selectedImage == nil {
            if let user = userModel.user {
                userModel.updateUserDataToFirestore(imageURL: user.imageURL, fullName: $fullName.wrappedValue)
            }
        }
    }
    
    func uploadPhotoAndSaveToFirestore() {
      //  guard let user = userModel.user else {return}
//        if selectedImage == nil && user.imageURL == "" {
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
                        userModel.updateUserDataToFirestore(imageURL: imageURL, fullName: $fullName.wrappedValue)
                      
                       // presentationMode.wrappedValue.dismiss()
                    }
                }
            }
//        }
    }
    
    func deleteImageFromStorageAndSaveNew () {
        let storage = Storage.storage()
        
        if let user = userModel.user {
            let storageRef = storage.reference(forURL: user.imageURL)

            //Removes image from storage
            storageRef.delete { error in
                if let error = error {
                    print(error)
                } else {
                   print("successfully deleted image")
                    uploadPhotoAndSaveToFirestore()
                }
            }
            
        }
    }
}

struct SelectedImageView : View {
    let selectedImage : UIImage
    var body: some View {
        Image(uiImage: selectedImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaledToFill()
            .frame(width: 200, height: 200)
            .clipShape(Circle())
            //.cornerRadius(10)
            .padding(.bottom, 20)
            .padding(.top, 30)
    }
}

struct ProfileImage : View {
     var imageURL : String
    
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

struct DefaultProfilePicture : View {
    var body: some View {
        Image(systemName: "person")
            .resizable()
            .aspectRatio(contentMode: .fit)
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
