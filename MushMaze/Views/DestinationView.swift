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
    @EnvironmentObject var friends : Friends
    
    
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
                    TabButtonsView(destinations: $destinations)
                }
            }
            .onChange(of: friends.allFriendsAreFetched, perform: { tag in
                if friends.allFriendsAreFetched {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        places.listenFriendsSharedPlaces()
                        friends.allFriendsAreFetched = false
                    }
                }
            })
            .onAppear() {
                userModel.loadUserInformation()
                userModel.listenNotificationsFromFirestore()
                friends.listenFriendRequestFirestore()
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
                        .onAppear() {
                            userModel.updateReadNotification()
                        }
                }
                Spacer()
                TabButtonsView(destinations: $destinations)
                    .onChange(of: friends.allFriendsAreFetched, perform: { tag in
                        if friends.allFriendsAreFetched {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                places.listenFriendsSharedPlaces()
                                friends.allFriendsAreFetched = false
                            }
                        }
                    })
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

struct TabButtonsView : View {
    @Binding var destinations : DestinationView.Destination
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userModel : UserModel
    @EnvironmentObject var places : Places
    
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
                    .foregroundColor(colorScheme == .light ? .black : .white)
                    .font(.system(size: 30))
            }
            Spacer()
            Button(action: {
                destinations = .notification
            }) {
                ZStack {
                    Image(systemName: destinations == .notification ? "bell.fill" : "bell")
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .font(.system(size: 30))
                    
                    if userModel.notificationNewCount > 0 {
                        Text("\(userModel.notificationNewCount)")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 10, y: -10)
                    }
                }
            }
            Spacer()
        }
        .onChange(of: userModel.hasNewNotifications, perform:  { tag in
            if userModel.hasNewNotifications, destinations == .notification, userModel.notificationNewCount > 0 {
                userModel.updateReadNotification()
            }
            userModel.hasNewNotifications = false
        })
        .edgesIgnoringSafeArea(.top)
        .background(Color(.systemGray6))
    }
}
