//
//  ListOfPlacesView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-31.
//

import SwiftUI
import Firebase

struct ListOfPlacesView: View {
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    @EnvironmentObject var places : Places
    @Binding var signedOut : Bool
    @State var showProfile = false
    @State var isHeaderVisible = true
    @State private var searchText = ""
    @State var showFavorite = true
    
    enum FilterSetting: String, CaseIterable {
        case all = "All places"
        case favorite = "My favorites"
    }
    
    @State var selectedFilter = FilterSetting.all
    
    
    var filteredPlaces: [Place] {
        return places.places.filter { place in
            guard let mushrooms = place.mushrooms else { return false }
            return mushrooms.contains(where: {$0.lowercased().contains(searchText.lowercased())})
        }
    }
    
    var body: some View {
        if isHeaderVisible {
            VStack {
                HStack {
                    VStack {
                        HStack {
                            SearchBar(text: $searchText)
                            Spacer()
                            Button(action: {
                                showProfile = true
                            }) {
                                SmallUserImage()
                            }.fullScreenCover(isPresented: $showProfile, content: {
                                ProfileView(signedOut: $signedOut)
                            })
                        }
                        HStack {
                            Picker(selection: $selectedFilter, label: Text("Välj ett alternativ")) {
                                ForEach(FilterSetting.allCases, id: \.self) { selected in
                                    Text(selected.rawValue).tag(selected)
                                }
                            }
                            .onChange(of: selectedFilter, perform:  { tag in
                                print("test \(tag)")
                            })
                        }
                    }
                }
                MushroomTitle()
            }
            .padding(.leading, 10)
        }
        NavigationView  {
            List () {
                if searchText == "" {
                    ForEach(places.places) { place in
                        if selectedFilter == .favorite {
                            if place.favorite {
                                NavigationLink(destination: PlaceDetailsView(place: place, isHeaderVisible: $isHeaderVisible)) {
                                    Button(action : {}) { // to avoid navigationLink to be triggered when star is pressed
                                        RowView(place: place)
                                    }
                                }
                            }
                        } else if selectedFilter == .all {
                            NavigationLink(destination: PlaceDetailsView(place: place, isHeaderVisible: $isHeaderVisible)) {
                                Button(action : {}) { // to avoid navigationLink to be triggered when star is pressed
                                    RowView(place: place)
                                }
                            }
                        }
                    }
                } else {
                    ForEach(filteredPlaces) { place in
                        if selectedFilter == .favorite {
                            if place.favorite {
                                NavigationLink(destination: PlaceDetailsView(place: place, isHeaderVisible: $isHeaderVisible)) {
                                    Button(action : {}) { // to avoid navigationLink to be triggered when star is pressed
                                        FilteredRowView(text: $searchText, place: place)
                                    }
                                }
                            }
                        } else if selectedFilter == .all {
                            NavigationLink(destination: PlaceDetailsView(place: place, isHeaderVisible: $isHeaderVisible)) {
                                Button(action : {}) { // to avoid navigationLink to be triggered when star is pressed
                                    FilteredRowView(text: $searchText, place: place)
                                }
                            }
                        }
                    }
                }
                
            }
            .scrollContentBackground(.hidden)
        }
    }
}


struct FilteredRowView : View {
    @EnvironmentObject var places : Places
    @Binding var text : String
    var place : Place
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(place.name)
                        .foregroundColor(.black)
                    Spacer()
                }
                HStack {
                    Text("\(place.mushrooms?.first(where: { $0.lowercased().contains(self.text.lowercased())}) ?? "") have been found here")
                        .font(.custom("Arial", size: 12))
                        .foregroundColor(.black)
                    Spacer()
                }
            }
            Spacer()
            Button(action: {
                places.updateFavroriteFirestore(place: place)
            }) {
                Image(systemName: place.favorite ? "star.fill" : "star" )
            }
        }
    }
}

struct RowView : View {
    @EnvironmentObject var places : Places
    var place: Place

    var body: some View {
        HStack {
            SmallProfileImage(place: place)
            Text(place.name)
                .foregroundColor(.black)
            Spacer()
            Button(action: {
                places.updateFavroriteFirestore(place: place)
            }) {
                Image(systemName: place.favorite ? "star.fill" : "star" )
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
            Button(action: {
                self.text = ""
            }) {
                Image(systemName: "xmark.circle.fill").opacity(text == "" ? 0 : 1)
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct MushroomTitle : View {
    var body: some View {
        HStack {
            Text(" Mushroom place")
                .font(.largeTitle)
                .background(.clear)
                .fontWeight(.bold)
                .padding(.top)
            Spacer()
        }
    }
}

struct SmallProfileImage : View {
    let db = Firestore.firestore()
    let place : Place
    @State var imageURL = ""
    
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
        .frame(width: 40, height: 40)
        .clipShape(Circle())
        .onAppear() {
            fetchCreaterProfileImage(place: place)
        }
    }
    
    func fetchCreaterProfileImage (place: Place) {
        let id = place.createrUID
        
        let docRef = db.collection("users").document(id)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                imageURL = document.get("imageURL") as? String ?? ""
            } else {
                print("Document does not exist")
            }
        }
        
    }
}

//struct ListOfPlacesView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListOfPlacesView()
//    }
//}
