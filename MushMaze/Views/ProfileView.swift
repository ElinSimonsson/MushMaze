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
    let db = Firestore.firestore()
    @State private var sourceType : UIImagePickerController.SourceType = .photoLibrary
    @Environment(\.presentationMode) var presentationMode
    @State var firstName = ""
    @State var lastName = ""
    @State var email = ""
    @State var imageURL = ""
    @State var showSourceAlert = false
    @State var openCameraRoll = false
    @State var selectedImage : UIImage? = nil
    @State private var keyboardHeight: CGFloat = 0
    @State var unSavedChanges = false
    
    var isButtonDisabled: Bool {
        firstName == userModel.user?.firstName && lastName == userModel.user?.lastName && selectedImage == nil ||
        firstName == "" || lastName == ""
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if firstName != userModel.user?.firstName || lastName != userModel.user?.lastName || selectedImage != nil {
                        unSavedChanges = true
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(systemName: "arrow.left")
                }
                .alert(isPresented: $unSavedChanges) {
                    Alert(title: Text("Unsaved Changes"),
                          message: Text("You have unsaved changes. Are you sure you want to leave?"),
                          primaryButton: .cancel(),
                          secondaryButton: .destructive(Text("Discard")) {
                        presentationMode.wrappedValue.dismiss()
                    })
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
            .onChange(of: userModel.successSavedData, perform: { tag in
                if userModel.successSavedData {
                    selectedImage = nil
                    userModel.successSavedData = false
                }
            })
            
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
                
                NameTextField(hintText: "First Name", name: $firstName)
                    .padding(.bottom, 20)
                NameTextField(hintText: "Last Name", name: $lastName)
                    .onAppear() {
                        firstName = user.firstName
                        lastName = user.lastName
                    }
                Spacer()
                Button(action: {
                    saveToFirestore()
                }) {
                    SaveButtonContent(isButtonDisabled: isButtonDisabled)
                }
                .disabled(isButtonDisabled)
                
                Spacer()
            }
        }
        .padding()
        .padding(.bottom, keyboardHeight)
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
                self.keyboardHeight = keyboardFrame.height
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                self.keyboardHeight = 0
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }

    func saveToFirestore () {
        if userModel.user?.imageURL == "" && selectedImage != nil {
            userModel.uploadPhotoAndSaveToFirestore(selectedImage: selectedImage, firstName: $firstName.wrappedValue, lastName: $lastName.wrappedValue)
        } else if userModel.user?.imageURL != "" && selectedImage != nil {
            if let image = selectedImage {
                userModel.deletePictureStorageAndSaveNewData(newImage: image, firstName: $firstName.wrappedValue, lastName: $lastName.wrappedValue)
            }
        } else if userModel.user?.imageURL != "" && selectedImage == nil {
            if let user = userModel.user {
                userModel.updateUserDataToFirestore(imageURL: user.imageURL, firstName: $firstName.wrappedValue, lastName: $lastName.wrappedValue)
            }
        }
    }
}

struct SaveButtonContent : View {
    var isButtonDisabled : Bool
    let darkTurquoise = Color(UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1))
    let disabledGray = Color.gray.opacity(0.5)
    var body: some View {
        Text("Save")
            .font(.title3)
            .foregroundColor(.black)
            .padding()
            .frame(width: 220, height: 60)
            .background(isButtonDisabled ? disabledGray : darkTurquoise)
            .cornerRadius(15.0)
    }
}

struct SelectedImageView : View {
    let selectedImage : UIImage
    var body: some View {
        ZStack {
            Image(uiImage: selectedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaledToFill()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .padding(.bottom, 40)
                .padding(.top, 20)
            
            Image(systemName: "camera")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.gray)
                .clipShape(Circle())
                .opacity(0.7)
                .offset(x: 70, y: 70)
        }
    }
}

struct ProfileImage : View {
    var imageURL : String
    
    var body: some View {
        ZStack {
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
            .padding(.bottom, 40)
            .padding(.top, 20)
            
            
            Image(systemName: "camera")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.gray)
                .clipShape(Circle())
                .opacity(0.7)
                .offset(x: 70, y: 70)
        }
    }
}

struct DefaultProfilePicture : View {
    var body: some View {
        ZStack {
            Image(systemName: "person")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .padding(.bottom, 40)
                .padding(.top, 20)
            
            Image(systemName: "camera")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.gray)
                .clipShape(Circle())
                .opacity(0.7)
                .offset(x: 70, y: 70)
        }
    }
}

struct YourProfileText : View {
    var body : some View {
        Text("Your Profile")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.top, 30)
    }
}

struct NameTextField : View {
    let hintText : String
    @Binding var name : String
    
    var body: some View {
        TextField(hintText, text: $name)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}
