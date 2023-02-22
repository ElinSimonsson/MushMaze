//
//  PlaceDetailsView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-31.
//

import SwiftUI



struct PlaceDetailsView: View {
    
    var place : Place
    @Environment(\.presentationMode) var presentationMode
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
    @State var showErrorMushroom = false
    @State var showFriendTaggingSheet = false
    @State var showIsSentPopUp = false
    @Binding var isHeaderVisible : Bool

    var body: some View {
        ZStack {
            ScrollView {
                    CreaterRowView(place: place, fullName: $createrFullName, imageURL: $createrImageURL)
                    PlaceName(placeName: place.name, isEditing: isEditing, editingPlaceName: $editingPlaceName)
                    
                    PlaceImage(imageURL: place.imageURL)
                    if let user = userModel.user {
                        if user.userId == place.createrUID {
                            EllipsisButton(showChoicePopUp: $showChoicePopUp, place: place)
                                .sheet(isPresented: $showChoicePopUp) {
                                    ActionSheet(showChoicePopUp: $showChoicePopUp, isEditing: $isEditing, isHeaderVisible: $isHeaderVisible, place: place)
                                        .presentationDetents([.fraction(0.35), .fraction(0.36)])
                                }
                        }
                    }
                    
                    if let description = place.description {
                        DescriptionContent(description: description,
                                           isEditing: isEditing,
                                           editingDescription: $editingDescription)
                    }
                if isEditing {
                    HStack {
                        Text("Edit mushroom types")
                            .fontWeight(.semibold)
                    }
                    .padding(.bottom, 10)
                    .padding(.top, 20)
                    MushroomPickerRowView(selectedMushrooms: $editingMushrooms)
                }
                
                    MushroomSubTitle(isEditing: isEditing)
                    
                    if let mushrooms = place.mushrooms {
                        if isEditing {
                            ForEach(editingMushrooms, id: \.self) { mushroom in
                                EditingMushroomRowView(mushroom: mushroom) {
                                    deleteMushroom(mushroom)
                                }
                            }
                            HStack {
                            }
                            .padding(.bottom, 100)
                        } else {
                            ForEach(mushrooms, id: \.self) { mushroom in
                                MushroomSpeciesRowView(mushroom: mushroom)
                            }
                        }
                }
            }
            .padding()
            
            if showIsSentPopUp {
                SuccessSentPopUp()
                    .onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showIsSentPopUp = false
                                }
                    }
            }
        }
        .onTapGesture {
            dismissKeyBoard()
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
            } else {
                if let user = userModel.user {
                    if user.userId == place.createrUID {
                        ToolbarItem (placement: .navigationBarTrailing) {
                            Button(action: {
                                showFriendTaggingSheet = true
                            }) {
                                Image(systemName: "paperplane")
                            }
                            .sheet(isPresented: $showFriendTaggingSheet) {
                                FriendTaggingSheet(showIsSentPopUp: $showIsSentPopUp, place: place)
                                    .presentationDetents([.fraction(0.8), .large])
                            }
                        }
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
        
        userModel.fetchUserInfo(userID: id) {(url, firstName, lastName, error) in
            if let error = error {
                print("error fetching creater info \(error)")
            }
            if let url = url {
                createrImageURL = url
            }
            if let firstName = firstName, let lastName = lastName {
                createrFullName = "\(firstName) \(lastName)"
            }
        }
    }
}

struct SuccessSentPopUp : View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack {
          Text("Sent")
                .bold()
        }
        .frame(width: 100, height: 50)
        .background(colorScheme == .light ? .white : .black)
        .cornerRadius(10)
        .shadow(
            color: Color.gray.opacity(0.7),
            radius: 8,
            x: 0,
            y: 0
        )
    }
}

struct EditingMushroomRowView : View {
    var mushroom : String
    var closure : () -> Void
    
    var body : some View {
        HStack {
            Spacer().frame(maxWidth: 15)
            Text("✦ \(mushroom)")
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
            Text("✦ \(mushroom)")
                .padding(.bottom, 5)
            Spacer()
        }
    }
}

struct MushroomSubTitle : View {
    var isEditing: Bool
    
    var body: some View {
        HStack {
            Spacer().frame(maxWidth: 15)
            Text(isEditing ? "Selected mushroom types" : "Mushroom founded here:")
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
            if isEditing {
                    TextField("brief description of the location", text: $editingDescription, axis: .vertical)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(5.0)
                        .padding(.bottom, 10)
                        .simultaneousGesture(TapGesture().onEnded { _ in
                            // to onTapGesture not triggers on this view
                        })
                    .onAppear() {
                        editingDescription = description
                    }
            } else {
                Spacer().frame(maxWidth: 15)
                Text(description)
                Spacer().frame(maxWidth: 15)
            }
        }
        .padding(.top, 20)
    }
}

struct EllipsisButton : View {
    @Binding var showChoicePopUp: Bool
    let place : Place
    
    var body: some View {
        HStack {
            Spacer().frame(maxWidth: 15)
            Image(systemName: place.sharedPlace ? "person.2" : "person.2.slash")
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
                    .scaledToFill()

            },
                       placeholder: {ProgressView()}
            )
            .aspectRatio(contentMode: .fit)
            .frame(width: UIScreen.main.bounds.size.width - 40, height: .none) // 250
            .cornerRadius(10)
        }
    }
}

struct PlaceName : View {
    let placeName : String
    var isEditing : Bool
    @Binding var editingPlaceName : String
    
    var body: some View {
        HStack {
            if isEditing {
                TextField("Place Name", text: $editingPlaceName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 10)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .simultaneousGesture(TapGesture().onEnded { _ in
                        // tapGesture in other struct wont triggers in this view
                    })
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
        if imageURL != "" {
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
        } else {
            DefaultProfileImage()
        }
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


