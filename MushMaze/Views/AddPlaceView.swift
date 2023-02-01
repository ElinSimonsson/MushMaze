//
//  AddPlaceView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-26.
//

import SwiftUI
import Firebase
import FirebaseAuth
import CoreLocation
import FirebaseStorage

struct AddPlaceView: View {
    @Environment(\.presentationMode) var presentationMode
    var coordinate : CLLocationCoordinate2D
    //let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    let db = Firestore.firestore()
    let places = Places()
    
    @State var placeName = ""
    @State var description = "brief description of the location"
    @State var isAddingNewMushroom = true
    @State var mushrooms : [String] = []
    @State var newMushroomName = ""
    @State private var sourceType : UIImagePickerController.SourceType = .photoLibrary
    @State var changeProfileImage = false
    @State var openCameraRoll = false
    @State var selectedImage : UIImage? = nil
    @State var showingAlert = false
    @State var textIsCleared = false
    @State var isSaving = false
    @State var placeNameIsMissing = false
    @State var mushroomsAreMissing = false
    @State var imageIsNil = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("< Back")
                        }
                        Spacer()
                        Button(action: {
                            uploadPhotoAndSaveToFirestore()
                        }) {
                            Text("Save")
                        }
                        .alert(isPresented: $imageIsNil) {
                            Alert(title: Text("Image is missing"), dismissButton: .default(Text("Ok")))
                        }
                    }
                    Button(action: {
                        showingAlert = true
                    }, label: {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .imageMod()
                        } else {
                            Image(systemName: "photo")
                                .imageMod()
                                .foregroundColor(Color(.systemGray3))
                        }
                    }).alert(isPresented: $showingAlert) {
                        Alert(title: Text("Choose Source"),
                              primaryButton: .default(Text("Camera")) {
                            sourceType = .camera
                            changeProfileImage = true
                            openCameraRoll = true
                        }, secondaryButton: .default(Text("Photo")) {
                            sourceType = .photoLibrary
                            changeProfileImage = true
                            openCameraRoll = true
                        })
                    }
                    PlaceTextField(placeName: $placeName, placeNameMissing: $placeNameIsMissing)
                    PlaceDescriptionField(description: $description)
                        .onTapGesture {
                            clearText()
                        }
                    MushroomSpeciesSubTitle()
                    
                    ForEach(mushrooms, id: \.self) { mushroom in
                        HStack {
                            Text("* \(mushroom)")
                                .padding(.bottom, 10)
                            Spacer()
                        }
                    }
                    if isAddingNewMushroom {
                        HStack {
                            ZStack {
                                TextField("Add mushroom species", text: $newMushroomName, onCommit: {
                                    mushrooms.append(newMushroomName)
                                    self.isAddingNewMushroom = false
                                })
                                .onAppear() {
                                    self.newMushroomName = ""
                                }
                                if mushroomsAreMissing {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.red, lineWidth: 1)
                                        .frame(width: UIScreen.main.bounds.width - 30, height: 50)
                                        
                                }
                            }
                            
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $openCameraRoll) {
                ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
            }
            .padding()
            .onTapGesture {
                isAddingNewMushroom = true
            }
            if isSaving {
                FirestoreSavingCircularProgressIndicator()
            }
        }
        
    }
    
    func clearText () {
        if !textIsCleared {
            description = ""
            print("funktionen clearText körs")
            textIsCleared = true
        }
    }
    
    func savePlaceToFirestore(imageURL : String) {
        places.addPlaceWithMushrooms(latitude: coordinate.latitude,
                                     longitude: coordinate.longitude,
                                     name: $placeName.wrappedValue,
                                     description: $description.wrappedValue,
                                     mushrooms: mushrooms,
                                     imageURL: imageURL)
    }
    
    func uploadPhotoAndSaveToFirestore() {
        if selectedImage == nil {
            imageIsNil = true
        }
        else if placeName == "" && mushrooms.count == 0 {
            placeNameIsMissing = true
            mushroomsAreMissing = true
        } else {
            isSaving = true
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
                        savePlaceToFirestore(imageURL: imageURL)
                        isSaving = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct FirestoreSavingCircularProgressIndicator : View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(3)
                .frame(width: 50, height: 50)
            Text("Saving...")
                .padding(.top, 25)
        }
        .frame(width: 150, height: 150)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct MushroomSpeciesSubTitle : View {
    var body : some View {
        HStack {
            Text("Mushrooms found here:")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.bottom)
            Spacer()
        }
    }
}

struct PlaceTextField : View {
    @Binding var placeName : String
    @Binding var placeNameMissing : Bool
    
    var body: some View {
        ZStack {
            TextField("Place Name", text: $placeName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            if placeNameMissing {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.red, lineWidth: 1)
                    .frame(width: UIScreen.main.bounds.width - 30, height: 50)
                    .padding(.bottom, 20)
            }
        }
    }
}

struct PlaceDescriptionField : View {
    @Binding var description : String
    
    var body: some View {
        TextEditor(text: $description)
            .frame(height: 80)
            .padding()
            .scrollContentBackground(.hidden)
            .background(Color(.systemGray6))
            .cornerRadius(5.0)
            .padding(.bottom, 20)
        
    }
}

//struct AddPlaceView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddPlaceView()
//    }
//}
