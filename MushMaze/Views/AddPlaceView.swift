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
    @State var mushrooms : [String] = []
    @State var newMushroomName = ""
    @State private var sourceType : UIImagePickerController.SourceType = .photoLibrary
    @State var openCameraRoll = false
    @State var selectedImage : UIImage? = nil
    @State var showingAlert = false
    @State var isSaving = false
    @State var placeNameIsMissing = false
    @State var mushroomsAreMissing = false
    @State var showErrorImage = false
    @State var lastElement = false
    @State var disabledButton = false

    
    enum PrivacySetting: String, CaseIterable {
        case privateSetting = "Keep it private"
        case sharedSetting = "Share with friends"
    }
    
    @State var selectedPrivacy = PrivacySetting.privateSetting
    
    var body: some View {
        ZStack {
            VStack {
                ToolBarView(showErrorImage: $showErrorImage, showErrorMushrooms: $mushroomsAreMissing, disabledButton: disabledButton, cancelAction: {
                    presentationMode.wrappedValue.dismiss()
                }, saveAction: {
                    uploadPhotoAndSaveToFirestore()
                })
                
                ScrollView {
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
                    PrivacySettingPickerView(selectedPrivacy: $selectedPrivacy)
                    
                    Text("Add types you found at this place:")
                        .fontWeight(.semibold)
                        .padding(.bottom, 10)
                    MushroomPickerRowView(selectedMushrooms: $mushrooms)
                    
                    if !mushrooms.isEmpty {
                        MushroomSpeciesSubTitle()
                        ForEach(mushrooms, id: \.self) { mushroom in
                            MushroomRowView(mushroom: mushroom) {
                                deleteMushroom(mushroom)
                            }
                        }
                    }
                    
                    HStack { // to create empty space below the forEach
                        Text("")
                    }
                    .padding(.bottom, 100)
                    
                }
                .onChange(of: places.placeSuccessfullySaved, perform: { tag in
                    if places.placeSuccessfullySaved {
                        presentationMode.wrappedValue.dismiss()
                        places.placeSuccessfullySaved = false
                    }
                })
                
                .simultaneousGesture(
                    DragGesture().onChanged({ gesture in
                        if (gesture.location.y < gesture.predictedEndLocation.y){
                            dismissKeyBoard()
                        }
                    }))
                .fullScreenCover(isPresented: $openCameraRoll) {
                    ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
                }
            }
            .padding()
            
            if places.savingPlace {
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
            disabledButton = true
            var isSharedPlace = false
            if selectedPrivacy == .sharedSetting {
                isSharedPlace = true
            }
            places.uploadImageAndSaveToFirestore(selectedImage: selectedImage,
                                                 latitude: coordinate.latitude,
                                                 longitude: coordinate.longitude,
                                                 name: $placeName.wrappedValue,
                                                 description: $description.wrappedValue,
                                                 mushrooms: mushrooms,
                                                 isShared: isSharedPlace)
        }
    }
}

struct PrivacySettingPickerView : View {
    @Binding var selectedPrivacy : AddPlaceView.PrivacySetting
    var body: some View {
        HStack {
            Picker(selection: $selectedPrivacy, label: Text("V??lj ett alternativ")) {
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
    @Environment (\.colorScheme) var colorScheme
    
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
        .background(colorScheme == . light ? Color.white : Color.black)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct ToolBarView : View {
    @Binding var showErrorImage : Bool
    @Binding var showErrorMushrooms : Bool
    let disabledButton : Bool
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
            .disabled(disabledButton)
            .alert(isPresented: $showErrorImage) {
                Alert(title: Text("Image is missing"), dismissButton: .default(Text("Ok")))
            }
            .alert(isPresented: $showErrorMushrooms) {
                Alert(title: Text("The list of mushrooms is empty"),
                      message: Text("To save this place, you need to add some mushroom you found at this place"),
                      dismissButton: .default(Text("Ok")))
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
            Text("??? \(mushroom)")
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
            Text("Selected mushroom types: ")
                .fontWeight(.semibold)
                .padding(.bottom, 5)
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
