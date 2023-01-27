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
    //var coordinate : CLLocationCoordinate2D
    var coordinate = CLLocationCoordinate2D(latitude: 37.33047116, longitude: -122.02885783) // tillfälligt
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
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
    
    
    var body: some View {
        VStack {
            //ZStack(alignment: .bottomTrailing) {
            Button(action: {
                showingAlert = true
                
            }, label: {
                    if let image = selectedImage {
                    Image(uiImage: image)
                        .imageMod()
                } else {
                    Image(systemName: "person")
                        .imageMod()
                }
            }).alert(isPresented: $showingAlert) {
                Alert(title: Text("Select"),
                      primaryButton: .default(Text("Camera")) {
                    sourceType = .camera
                    changeProfileImage = true
                    openCameraRoll = true
                    print("camera pressed \(sourceType)")
                }, secondaryButton: .default(Text("Photo")) {
                    sourceType = .photoLibrary
                    changeProfileImage = true
                    openCameraRoll = true
                    print("photo pressed \(sourceType)")
                })
            }
            
            Spacer()
            PlaceTextField(placeName: $placeName, lightGreyColor: lightGreyColor)
            PlaceDescriptionField(description: $description, lightGreyColor: lightGreyColor)
            List {
                MushroomSpeciesTitle()
                ForEach(mushrooms, id: \.self) { mushroom in
                    Text("* \(mushroom)")
                }
                if isAddingNewMushroom {
                    HStack {
                        TextField("Mushroom speices you founded", text: $newMushroomName, onCommit: {
                            mushrooms.append(newMushroomName)
                            
                            self.isAddingNewMushroom = false
                        })
                        .onAppear() {
                            self.newMushroomName = ""
                        }
                    }
                }
            }
            .frame(height: 200)
            .scrollContentBackground(.hidden)
            Button(action: {
                //savePlaceToFirestore()
                uploadPhoto()
                
            }) {
                SaveButtonContent()
            }
        }
        .sheet(isPresented: $openCameraRoll) {
            ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
        }
        .onAppear() {
            
        }
        .padding()
        .onTapGesture {
            isAddingNewMushroom = true
        }
        
    }
    
    
    
    func savePlaceToFirestore() {
        places.addPlaceWithMushrooms(latitude: coordinate.latitude,
                                     longitude: coordinate.longitude,
                                     name: $placeName.wrappedValue,
                                     description: $description.wrappedValue,
                                     mushrooms: mushrooms)
        presentationMode.wrappedValue.dismiss()
    }
    
    func uploadPhoto() {
        
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
                }
            }

        }
    }
}

struct MushroomSpeciesTitle : View {
    var body : some View {
        Text("Mushrooms found here:")
            .font(.headline)
            .fontWeight(.semibold)
    }
}

struct PlaceTextField : View {
    @Binding var placeName : String
    let lightGreyColor : Color
    
    var body: some View {
        TextField("Place Name", text: $placeName)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}

struct PlaceDescriptionField : View {
    @Binding var description : String
    let lightGreyColor : Color
    
    var body: some View {
        TextEditor(text: $description)
            .frame(height: 80)
            .padding()
            .scrollContentBackground(.hidden)
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)

    }
}

struct SaveButtonContent : View {
  let darkTurquoise = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    var body: some View {
        Text("Save")
            .font(.title3)
            .foregroundColor(.black)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color(darkTurquoise))
            .cornerRadius(15.0)
    }
}

//struct AddPlaceView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddPlaceView()
//    }
//}
