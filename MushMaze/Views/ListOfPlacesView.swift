//
//  ListOfPlacesView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-31.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ListOfPlacesView: View {
    @EnvironmentObject var places : Places
    @EnvironmentObject var userModel : UserModel
    
    @State var showProfile = false
    @State var isHeaderVisible = true
    @State private var searchText = ""
    @State var showFavorite = true
    
    enum FilterPlace: String, CaseIterable {
        case all = "Show all places"
        case favorite = "Show my favorites"
        case myPlaces = "Show my places"
        case friendsPlace = "Show friends' places"
    }
    
    @State var selectedPlaceFilter = FilterPlace.all
    
    
    var filteredPlaces: [Place] {
        if selectedPlaceFilter == .favorite {
            return places.favoritePlaces.filter { place in
                guard let mushrooms = place.mushrooms else { return false }
                return mushrooms.contains(where: {$0.lowercased().contains(searchText.lowercased())})
            }
        } else {
            return places.allSavedPlaces.filter { place in
                guard let mushrooms = place.mushrooms else { return false }
                return mushrooms.contains(where: {$0.lowercased().contains(searchText.lowercased())})
            }
        }
    }
    
    
    
    var body: some View {
                if isHeaderVisible {
                    HeaderView(searchText: $searchText, showProfile: $showProfile, selectedPlaceFilter: $selectedPlaceFilter)
                }
        NavigationView  {
            if searchText != "" && filteredPlaces.isEmpty {
                Text("There were no results for \"\(searchText)\". Try a new search")
            } else {
                List () {
                    if searchText == "" {
                        if selectedPlaceFilter == .favorite {
                            ForEach(places.favoritePlaces) { place in
                                NavigationLink(destination: PlaceDetailsView(place: place, isHeaderVisible: $isHeaderVisible)) {
                                    RowView(place: place)
                                }
                            }
                            .listRowBackground(Color(.systemGray6))
                        } else if selectedPlaceFilter == .myPlaces {
                            ForEach(places.allSavedPlaces) { place in
                                if let user = userModel.user {
                                    if user.userId == place.createrUID {
                                        NavigationLink(destination: PlaceDetailsView(place: place, isHeaderVisible: $isHeaderVisible)) {
                                            RowView(place: place)
                                        }
                                    }
                                }
                            }
                            .listRowBackground(Color(.systemGray6))
                        } else if selectedPlaceFilter == .friendsPlace {
                            ForEach(places.allSavedPlaces) { place in
                                if let user = userModel.user {
                                    if user.userId != place.createrUID {
                                        NavigationLink(destination: PlaceDetailsView(place: place, isHeaderVisible: $isHeaderVisible)) {
                                            RowView(place: place)
                                        }
                                        
                                    }
                                }
                            }
                            .listRowBackground(Color(.systemGray6))
                        } else if selectedPlaceFilter == .all {
                            ForEach(places.allSavedPlaces) { place in
                                NavigationLink(destination: PlaceDetailsView(place: place, isHeaderVisible: $isHeaderVisible)) {
                                    RowView(place: place)
                                }
                            }
                            .listRowBackground(Color(.systemGray6))
                        }
                    } else {
                        if selectedPlaceFilter == .myPlaces {
                            ForEach(filteredPlaces) { place in
                                if let user = userModel.user {
                                    if user.userId == place.createrUID {
                                        NavigationLink(destination: PlaceDetailsView(place: place, isHeaderVisible: $isHeaderVisible)) {
                                            FilteredRowView(text: $searchText, place: place)
                                        }
                                    }
                                }
                            }
                            .listRowBackground(Color(.systemGray6))
                        } else if selectedPlaceFilter == .friendsPlace {
                            ForEach(filteredPlaces) { place in
                                if let user = userModel.user {
                                    if user.userId != place.createrUID {
                                        NavigationLink(destination: PlaceDetailsView(place: place, isHeaderVisible: $isHeaderVisible)) {
                                            FilteredRowView(text: $searchText, place: place)
                                        }
                                    }
                                }
                            }
                            .listRowBackground(Color(.systemGray6))
                        } else {
                            ForEach(filteredPlaces) { place in
                                NavigationLink(destination: PlaceDetailsView(place: place, isHeaderVisible: $isHeaderVisible)) {
                                    FilteredRowView(text: $searchText, place: place)
                                }
                            }
                            .listRowBackground(Color(.systemGray6))
                        }
                    }
                }
                .shadow(
                    color: Color.gray.opacity(0.7),
                    radius: 8,
                    x: 0,
                    y: 0
                )
                .scrollContentBackground(.hidden)
            }
        }
    }
}

struct FilteredRowView : View {
    @EnvironmentObject var places : Places
    @Environment(\.colorScheme) var colorScheme
    @Binding var text : String
    var place : Place
    
    var body: some View {
        Button(action : {}) { // to avoid navigationLink to be triggered when star is pressed
            HStack {
                SmallProfileImage(place: place)
                VStack {
                    HStack {
                        Text(place.name)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        Spacer()
                    }
                    HStack {
                        Text("\(place.mushrooms?.first(where: { $0.lowercased().contains(self.text.lowercased())}) ?? "") have been found here")
                            .font(.custom("Arial", size: 12))
                            .foregroundColor(colorScheme == .light ? .black : .white)
                        Spacer()
                    }
                }
                Spacer()
                Button(action: {
                    places.updateFavorites(place: place)
                }) {
                    if places.favoritePlaces.contains(where: {$0.id == place.id}) {
                        Image(systemName: "star.fill")
                    } else {
                        Image(systemName: "star")
                    }
                }
            }
        }
    }
}

struct RowView : View {
    @EnvironmentObject var places : Places
    @Environment(\.colorScheme) var colorScheme
    var place: Place
    
    
    var body: some View {
        Button(action : {}) { // to avoid navigationLink to be triggered when star is pressed
            HStack {
                SmallProfileImage(place: place)
                Text(place.name)
                    .foregroundColor(colorScheme == .light ? .black : .white)
                    .font(.headline)
                Spacer()
                
                Button(action: {
                    places.updateFavorites(place: place)
                }) {
                    if places.favoritePlaces.contains(where: {$0.id == place.id}) {
                        Image(systemName: "star.fill")
                    } else {
                        Image(systemName: "star")
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
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
            Spacer().frame(maxWidth: 10)
            Text("Mushroom place")
                .font(.largeTitle)
                .background(.clear)
                .fontWeight(.bold)
            Spacer()
        }
    }
}

struct SmallProfileImage : View {
    @EnvironmentObject var userModel : UserModel
    let place : Place
    @State private var imageURL = ""
    
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
        .onAppear() {
            fetchCreaterProfileImage(place: place)
        }
    }
    
    func fetchCreaterProfileImage (place: Place) {
        let id = place.createrUID
//        userModel.fetchUserInfo(userID: id) { (url, name, error) in
//            if let error = error {
//                print("error fetching imageURL \(error)")
//            }
//            if let url = url {
//                imageURL = url
//            }
//        }
        userModel.fetchUserInfo(userID: id) { (url, firstName, lastName, error ) in
            if let error = error {
                print("error fetching imageURL \(error)")
            }
            if let url = url {
                imageURL = url
            }
        }
    }
}

struct HeaderView: View {
    @Binding var searchText: String
    @Binding var showProfile: Bool
    @Binding var selectedPlaceFilter: ListOfPlacesView.FilterPlace
    
    var body: some View {
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
                            ProfileView()
                        })
                    }
                    HStack {
                        Picker(selection: $selectedPlaceFilter, label: Text("")) {
                            ForEach(ListOfPlacesView.FilterPlace.allCases, id: \.self) { selected in
                                Text(selected.rawValue).tag(selected)
                            }
                        }
                        .onChange(of: selectedPlaceFilter, perform:  { tag in
                            print("test \(tag)")
                        })
                    }
                }
            }
            MushroomTitle()
        }
        .edgesIgnoringSafeArea(.bottom)
        .padding(.leading, 10)
    }
}





//struct ListOfPlacesView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListOfPlacesView()
//    }
//}
