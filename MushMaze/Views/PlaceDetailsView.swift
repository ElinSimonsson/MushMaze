//
//  PlaceDetailsView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-31.
//

import SwiftUI



struct PlaceDetailsView: View {
    
    var place : Place
    @EnvironmentObject var userModel : UserModel
    @EnvironmentObject var places : Places
    @State var createrFullName = ""
    @State var createrImageURL = ""
    @State var showChoicePopUp = false
    @State var isEditing = false
    @State var editingMushrooms = [String]()
    @State var editingDescription = ""
    @State var editingPlaceName = ""
    @State var newMushroomName = ""
    @State var isAddingMushroom = false
    @State var showErrorMushroom = false
    @Binding var isHeaderVisible : Bool
    
    
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        ZStack {
           
            ScrollView {
                    CreaterRowView(place: place, fullName: $createrFullName, imageURL: $createrImageURL)
                    PlaceName(placeName: place.name, isEditing: isEditing, editingPlaceName: $editingPlaceName)
                    
                    PlaceImage(imageURL: place.imageURL)
                    if let user = userModel.user {
                        if user.userId == place.createrUID {
                            EllipsisButton(showChoicePopUp: $showChoicePopUp)
                                .sheet(isPresented: $showChoicePopUp) {
                                    ChoicePopUp(showChoicePopUp: $showChoicePopUp, isEditing: $isEditing, isHeaderVisible: $isHeaderVisible, place: place)
                                        .presentationDetents([.fraction(0.35), .fraction(0.36)])
                                }
                        }
                    }
                    
                    if let description = place.description {
                        DescriptionContent(description: description,
                                           isEditing: isEditing,
                                           editingDescription: $editingDescription)
                    }
                    MushroomSubTitle()
                    
                    if let mushrooms = place.mushrooms {
                        if isEditing {
                            ForEach(editingMushrooms, id: \.self) { mushroom in
                                EditingMushroomRowView(mushroom: mushroom) {
                                    deleteMushroom(mushroom)
                                }
                            }
                            AddMushroomSpeciesTextField(mushrooms: $editingMushrooms,
                                                        newMushroomName: $newMushroomName,
                                                        showErrorMushroom: $showErrorMushroom,
                                                        isAddingNewMushroom: $isAddingMushroom)
                        } else {
                            ForEach(mushrooms, id: \.self) { mushroom in
                                MushroomSpeciesRowView(mushroom: mushroom)
                            }
                        }
                }
            }
            .padding()
            //.disabled(showChoicePopUp)
            
//            if showChoicePopUp {
//                ChoicePopUp(showChoicePopUp: $showChoicePopUp, isEditing: $isEditing, isHeaderVisible: $isHeaderVisible, place: place)
//            }
//            if showChoicePopUp {
//                            Color.black.opacity(0.4)
//                                .edgesIgnoringSafeArea(.all)
//                                .onTapGesture {
//                                    if showChoicePopUp {
//                                        self.showChoicePopUp.toggle()
//                                    }
//                                }
//        }
            
        }
        
        .onTapGesture {
            dismissKeyBoard()
            if isEditing {
                isAddingMushroom = true
            }
//            if showChoicePopUp {
//                self.showChoicePopUp.toggle()
//            }
        }
        .onAppear() {
            isHeaderVisible = false
            fetchCreaterInfo(place: place)
            if let mushrooms = place.mushrooms {
                editingMushrooms = mushrooms
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if isEditing {
                        isEditing = false
                    } else {
                        isHeaderVisible = true
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    if isEditing {
                        Text("Cancel")
                    } else {
                        Image(systemName: "arrow.left")
                    }
                }
            }
            if isEditing {
                ToolbarItem (placement: .navigationBarTrailing) {
                    Button(action: {
                        updatePlace()

                    }) {
                        Text("Save")
                    }
                }
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
    
    func updatePlace () {
        if editingMushrooms.count == 0 {
            showErrorMushroom = true
        } else {
            places.updatePlaceToFirestore(place: place, placeName: $editingPlaceName.wrappedValue,
                                          description: $editingDescription.wrappedValue,
                                          mushrooms: editingMushrooms)
            isEditing = false
        }
    }
    
    func deleteMushroom(_ mushroom: String) {
        editingMushrooms.removeAll(where: { $0 == mushroom })
    }
    
    func fetchCreaterInfo (place : Place) {
        let id = place.createrUID
        
        userModel.fetchUserInfo(userID: id) {(url, name, error) in
            if let error = error {
                print("error fetching creater info \(error)")
            }
            if let url = url {
                createrImageURL = url
            }
            if let name = name {
                createrFullName = name
            }
        }
    }
}

struct AddMushroomSpeciesTextField : View {
    @Binding var mushrooms : [String]
    @Binding var newMushroomName : String
    @Binding var showErrorMushroom : Bool
    @Binding var isAddingNewMushroom : Bool
    @State var returButtonPressed = false
    
    
    var body: some View {
        HStack {
            TextField(" Add mushroom species", text: $newMushroomName, onCommit: {
                mushrooms.append(newMushroomName)
                self.isAddingNewMushroom = false
                newMushroomName = ""
                returButtonPressed = true
            })
            .submitLabel(.go)
            .simultaneousGesture(TapGesture().onEnded { _ in
                // tapGesture wont triggers in this view
            })
            .onChange(of: returButtonPressed) { newvalue in
                if returButtonPressed {
                    self.newMushroomName = ""
                    returButtonPressed = false
                }
            }
            .alert(isPresented: $showErrorMushroom) {
                Alert(title: Text("you must have entered at least one mushroom species"), dismissButton: .default(Text("Ok")))
            }
            .onAppear() {
                self.newMushroomName = ""
            }
        }
    }
}

struct EditingMushroomRowView : View {
    var mushroom : String
    var closure : () -> Void
    
    var body : some View {
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

struct MushroomSpeciesRowView : View {
    let mushroom : String
    
    var body: some View {
        HStack {
            Spacer().frame(maxWidth: 15)
            Text("* \(mushroom)")
                .padding(.bottom, 5)
            Spacer()
        }
    }
}

struct MushroomSubTitle : View {
    var body: some View {
        HStack {
            Spacer().frame(maxWidth: 15)
            Text("Mushroom founded here:")
                .fontWeight(.bold)
            
            Spacer()
        }
        .padding(.top, 15)
        .padding(.bottom, 10)
    }
}

struct DescriptionContent : View {
    let description : String
    var isEditing : Bool
    @Binding var editingDescription : String
    @State var value : CGFloat = 0
    
    var body: some View {
        HStack {
            Spacer().frame(maxWidth: 15)
            if isEditing {
                TextField("description of the place", text: $editingDescription, axis: .vertical)
                    .simultaneousGesture(TapGesture().onEnded { _ in
                        // tapGesture wont triggers in this view
                    })
                    .onAppear() {
                        editingDescription = description
                    }
            } else {
                Text(description)
            }
            Spacer().frame(maxWidth: 15)
        }
        .padding(.top, 20)
    }
}

struct EllipsisButton : View {
    @Binding var showChoicePopUp: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                showChoicePopUp = true
            }) {
                Image(systemName: "ellipsis")
            }
            Spacer().frame(maxWidth: 15)
        }
        .padding(.top, 5)
    }
}

struct PlaceImage : View {
    let imageURL : String
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: imageURL),
                       content:  { image in
                image
                    .resizable()
                    .scaledToFit()
            },
                       placeholder: {ProgressView()}
            )
            .aspectRatio(contentMode: .fit)
            .frame(width: UIScreen.main.bounds.size.width - 10, height: .none) // 250
        }
        .padding(.top, 10)
    }
}

struct PlaceName : View {
    let placeName : String
    var isEditing : Bool
    @Binding var editingPlaceName : String
    //@FocusState var focus: PlaceDetailsView.FocusedField?
    
    var body: some View {
        HStack {
            if isEditing {
                TextField("Place Name", text: $editingPlaceName)
                    .simultaneousGesture(TapGesture().onEnded { _ in
                        // tapGesture in other struct wont triggers in this view
                    })
                
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                    .onAppear() {
                        editingPlaceName = placeName
                    }
            } else {
                Text(placeName)
                    .font(.title)
                    .fontWeight(.semibold)
            }
        }
        .padding(.top, 20)
    }
}

struct SmallCreaterImage : View {
    @EnvironmentObject var userModel : UserModel
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
        .frame(width: 50, height: 50)
        .clipShape(Circle())
    }
}

struct CreaterRowView : View {
    var place : Place
    @Binding var fullName : String
    @Binding var imageURL : String
    
    var date : String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: place.date)
    }
    
    var body : some View {
        HStack {
            Spacer().frame(maxWidth: 10)
            SmallCreaterImage(imageURL: $imageURL)
            Spacer().frame(maxWidth: 10)
            Text(fullName)
            Spacer()
            Text(date)
            Spacer().frame(maxWidth: 10)
        }
        .padding(.top, 20)
    }
}


