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
    let db = Firestore.firestore()
    @EnvironmentObject var envUserModel : UserModel
    @EnvironmentObject var places : Places
    
    @State var placeName = ""
    @State var description = ""
    @State var isAddingNewMushroom = true
    @State var mushrooms : [String] = []
    @State var newMushroomName = ""
    @State private var sourceType : UIImagePickerController.SourceType = .photoLibrary
    @State var openCameraRoll = false
    @State var selectedImage : UIImage? = nil
    @State var showingAlert = false
    @State var textIsCleared = false
    @State var isSaving = false
    @State var placeNameIsMissing = false
    @State var mushroomsAreMissing = false
    @State var showErrorImage = false
    
    enum PrivacySetting: String, CaseIterable {
        case privateSetting = "Keep it private"
        case sharedSetting = "Share with friends"
    }
    
    @State var selectedPrivacy = PrivacySetting.privateSetting
    
    var body: some View {
        ZStack {
            ScrollView {
                ToolBarView(showErrorImage: $showErrorImage, cancelAction: {
                    presentationMode.wrappedValue.dismiss()
                }, saveAction: {
                    uploadPhotoAndSaveToFirestore()
                })
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
                        openCameraRoll = true
                    }, secondaryButton: .default(Text("Photo")) {
                        sourceType = .photoLibrary
                        openCameraRoll = true
                    })
                }
                PlaceTextField(placeName: $placeName, placeNameMissing: $placeNameIsMissing)
                PlaceDescriptionField(description: $description)
                PickerView(selectedPrivacy: $selectedPrivacy)
                MushroomSpeciesSubTitle()
                
                ForEach(mushrooms, id: \.self) { mushroom in
                    MushroomRowView(mushroom: mushroom) {
                        deleteMushroom(mushroom)
                    }
                }
                if isAddingNewMushroom {
                    AddMushroomTextField(mushrooms: $mushrooms,
                                         newMushroomName: $newMushroomName,
                                         mushroomsAreMissing: mushroomsAreMissing,
                                         isAddingNewMushroom: $isAddingNewMushroom)
                }
            }
            .simultaneousGesture(
                   DragGesture().onChanged({ gesture in
                       if (gesture.location.y < gesture.predictedEndLocation.y){
                                  dismissKeyBoard()
                                 }
                   }))
            
            .padding()
            .fullScreenCover(isPresented: $openCameraRoll) {
                ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
            }
            
            if isSaving {
                FirestoreSavingCircularProgressIndicator()
            }
        }
    }
    
    func dismissKeyBoard () {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        keyWindow!.endEditing(true)
    }
    
    func deleteMushroom(_ mushroom: String) {
        mushrooms.removeAll(where: { $0 == mushroom })
        if mushrooms.isEmpty {
            isAddingNewMushroom = true
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
        var isSharedPlace = false
        if selectedPrivacy == .sharedSetting {
            isSharedPlace = true
        }
      
        places.addPlaceWithMushrooms(latitude: coordinate.latitude,
                                     longitude: coordinate.longitude,
                                     name: $placeName.wrappedValue,
                                     description: $description.wrappedValue,
                                     mushrooms: mushrooms,
                                     imageURL: imageURL,
                                     sharedPlace: isSharedPlace)
    }
    
    func uploadPhotoAndSaveToFirestore() {
        if selectedImage == nil {
            showErrorImage = true
        }
        else if placeName == "" {
            placeNameIsMissing = true
        } else if mushrooms.count == 0 {
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

struct PickerView : View {
    @Binding var selectedPrivacy : AddPlaceView.PrivacySetting
    var body: some View {
        HStack {
                Picker(selection: $selectedPrivacy, label: Text("Välj ett alternativ")) {
                    ForEach(AddPlaceView.PrivacySetting.allCases, id: \.self) { privacy in
                        Text(privacy.rawValue).tag(privacy)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.bottom, 20)
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

struct AddMushroomTextField : View {
    @Binding var mushrooms : [String]
    @Binding var newMushroomName : String
    var mushroomsAreMissing : Bool
    @Binding var isAddingNewMushroom : Bool
    
    var body: some View {
        HStack {
            ZStack {
                TextField("Add mushroom species", text: $newMushroomName, onCommit: {
                    mushrooms.append(newMushroomName)
                    self.isAddingNewMushroom = false
                })
                .simultaneousGesture(TapGesture().onEnded { _ in
                    // to onTapGesture not triggers on this view
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

struct ToolBarView : View {
    @Binding var showErrorImage : Bool
    var cancelAction : () -> Void
    var saveAction : () -> Void
    
    var body : some View {
        HStack {
            Button(action: cancelAction) {
                Text("< Back")
            }
            Spacer()
            Button(action: saveAction) {
                Text("Save")
            }
            .alert(isPresented: $showErrorImage) {
                Alert(title: Text("Image is missing"), dismissButton: .default(Text("Ok")))
            }
        }
    }
}

struct MushroomRowView : View {
    var mushroom : String
    var closure : () -> Void
    
    var body: some View {
        HStack {
            Spacer().frame(maxWidth: 15)
            Text("* \(mushroom)")
            Spacer()
            Button(action: {
                closure()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            Spacer().frame(maxWidth: 15)
        }
        .padding(.bottom, 5)
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
                .simultaneousGesture(TapGesture().onEnded { _ in
                    // to onTapGesture not triggers on this view
                })
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
        
        TextField("brief description of the location", text: $description, axis: .vertical)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(5.0)
            .padding(.bottom, 10)
            .simultaneousGesture(TapGesture().onEnded { _ in
                // to onTapGesture not triggers on this view
            })
    }
}

//struct AddPlaceView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddPlaceView()
//    }
//}
