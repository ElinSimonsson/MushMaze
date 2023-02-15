//
//  DestinationView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-31.
//

import SwiftUI

struct DestinationView: View {
    let locationManager = LocationManager()
    @State var destinations = Destination.map
    @EnvironmentObject var userModel : UserModel
    @EnvironmentObject var places : Places
    
    
    enum Destination {
        case map, list, friendList, notification
    }
    
    init() {
        locationManager.startLocationUpdate()
        
    }
    
    var body: some View {
        if destinations == .map {
            ZStack { // mapView needs to cover the entire screen for convertPointToCoordinate to be able to convert to the correct coordinate
                    MapView(locationManager: locationManager)
                VStack {
                    Spacer()
                    ToggleButtonsView(destinations: $destinations)
                }
            }
            .onChange(of: userModel.allFriendsAreFetched, perform: { tag in
                if userModel.allFriendsAreFetched {
                    places.listenFriendsSharedPlaces()
                    userModel.allFriendsAreFetched = false
                }
            })
            .onAppear() {
                userModel.startListenFriends()
                userModel.loadUserInformation()
                userModel.listenFriendRequestFirestore()
                places.listenToFirestore()
                places.listenToFavoritePlacesFirestore()
            }
        } else {
            VStack {
                if destinations == .list {
                    ListOfPlacesView()
                } else if destinations == .friendList {
                    FriendListView()
                } else if destinations == .notification {
                    NotificationView()
                }
                Spacer()
                ToggleButtonsView(destinations: $destinations)
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

struct ToggleButtonsView : View {
    @Binding var destinations : DestinationView.Destination
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
            HStack (spacing: 0) {
                Spacer()
                Button(action: {
                    destinations = .map
                }){
                    Image(systemName: destinations == .map ? "map.fill" : "map")
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .font(.system(size: 30))
                }
                Spacer()
                Button(action: {
                    destinations = .list
                }) {
                    Image(systemName: destinations == .list ? "list.clipboard.fill" : "list.bullet.clipboard")
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .font(.system(size: 30))
                }
                Spacer()
                Button(action: {
                    destinations = .friendList
                }) {
                    Image(systemName: destinations == .friendList ? "person.2.fill" : "person.2")
                        .foregroundColor(colorScheme == .light ? . black : .white)
                        .font(.system(size: 30))
                }
                Spacer()
                Button(action: {
                    destinations = .notification
                }) {
                    Image(systemName: destinations == .notification ? "bell.fill" : "bell")
                        .foregroundColor(colorScheme == .light ? . black : .white)
                        .font(.system(size: 30))
                }
                Spacer()
            }

            .edgesIgnoringSafeArea(.top)
            .background(Color(.systemGray6))
    }
}


//struct TabbedView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabbedView()
//    }
//}
