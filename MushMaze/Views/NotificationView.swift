//
//  NotificationView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-09.
//

import SwiftUI
import FirebaseAuth

struct NotificationView: View {
    @EnvironmentObject var userModel : UserModel
    @EnvironmentObject var friends : Friends
    @EnvironmentObject var places : Places
    @State var senderImageURL = ""
    @State var senderFullName = ""
    @State var isHeaderVisbible = true
    @State var showAlert = false
    @State var showProfileView = false
    
    var body: some View {
        if isHeaderVisbible {
            HStack {
                Spacer()
                Button(action: {
                    showProfileView.toggle()
                }) {
                    ProfileImageNavigationIcon()
                }.fullScreenCover(isPresented: $showProfileView, content: {
                    ProfileView()
                })
            }
            NotificationTitle()
        }
        NavigationView {
            if userModel.notifications.isEmpty {
                HStack {
                    Text("It looks like you haven't received any notifications yet. Don't worry, we'll let you know when there's something new!")
                }
                .padding()
            } else {
                List {
                    ForEach(userModel.notifications) { notification in
                        switch notification.type {
                        case .friendRequest:
                            if let matchingFriendRequest = friends.friendRequests.first(where: { $0.id == notification.friendRequestID }) {
                                Button(action: {}) {
                                    FriendRequestRowView(notification: notification, friendRequest: matchingFriendRequest)
                                }
                            }
                        case .tag:
                            if let matchingPlace = places.allSavedPlaces.first(where: {$0.id == notification.placeID }) {
                                NavigationLink(destination: PlaceDetailsView(place: matchingPlace, isHeaderVisible: $isHeaderVisbible)) {
                                    TagNotificationRowView(notification: notification)
                                }
                            } else {
                                TagNotificationRowView(notification: notification)
                                    .alert(isPresented: $showAlert) {
                                        Alert(title: Text("Error"), message: Text("It seems like the user has deleted the mushroom place"), dismissButton: .default(Text("Ok")))
                                    }
                                    .onTapGesture {
                                        showAlert = true
                                    }
                            }
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

struct TagNotificationRowView : View {
    let notification : Notification
    @EnvironmentObject var places : Places
    @EnvironmentObject var userModel : UserModel
    @State var friendFullName = ""
    @State var imageURL = " "
    
    var body: some View {
        VStack {
            HStack {
                if imageURL != "" {
                    ProfileImageFromURL(imageURL: imageURL)
                } else {
                    DefaultProfileImage()
                }
                Text("**\(friendFullName)** notified you")
            }
            HStack {
                Text("tap to see the mushroom place")
                    .italic()
                    .foregroundColor(Color(.systemGray2))
            }
        }
        .onAppear() {
            userModel.fetchUserInfo(userID: notification.senderNotificationUserId) { (url, firstName, lastName, error) in
                if let error = error {
                    print("error fetching imageURL \(error)")
                }
                if let url = url, let firstName = firstName, let lastName = lastName {
                    imageURL = url
                    friendFullName = "\(firstName) \(lastName)"
                }
            }
        }
    }
    
}
struct NotificationTitle : View {
    var body: some View {
        HStack {
            Spacer().frame(maxWidth: 10)
            Text("Notifications")
                .font(.largeTitle)
                .background(.clear)
                .fontWeight(.bold)
                .padding(.bottom)
            Spacer()
        }
    }
}

struct FriendRequestRowView : View {
    @EnvironmentObject var friends : Friends
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var places : Places
    @Environment(\.colorScheme) var colorScheme
    let notification : Notification
    let friendRequest : FriendRequest
    @State var fullName = ""
    @State var friendUserID = ""
    @State var imageURL = " "
    
    var body: some View {
        if let currentUser = Auth.auth().currentUser {
            HStack {
                if imageURL != "" {
                    ProfileImageFromURL(imageURL: imageURL)
                } else {
                    DefaultProfileImage()
                }
                
                Spacer().frame(maxWidth: 10)
                HStack {
                    if friendRequest.status == .accepted {
                        Text("You and **\(fullName)** are now connected as friends!")
                            .foregroundColor(.black)
                        
                    } else if currentUser.uid != notification.senderNotificationUserId {
                        
                        Text("**\(fullName)** has requested to be friends with you")
                            .foregroundColor(colorScheme == .light ? .black : .white)
                    }
                }
                Spacer()
                
                if friendRequest.status == .pending {
                    VStack {
                        Button(action: {
                            friends.acceptFriendRequest(friendRequest: friendRequest)
                        }) {
                            AcceptButtonContent()
                        }
                        .padding(.trailing, 1)
                        
                        Button(action: {
                            friends.declineFriendRequest(friendRequest: friendRequest)
                        }) {
                            DeclineButtonContent()
                        }
                        .padding(.trailing, 1)
                    }
                    Spacer().frame(maxWidth: 1)
                }
                
            }
            .onAppear() {
                if currentUser.uid != notification.senderNotificationUserId {
                    friendUserID = notification.senderNotificationUserId
                } else {
                    friendUserID = notification.recipientId
                }
                userModel.fetchUserInfo(userID: friendUserID) { (url, firstName, lastName, error) in
                    if let error = error {
                        print("error fetching imageURL \(error)")
                    }
                    if let url = url, let firstName = firstName, let lastName = lastName {
                        imageURL = url
                        fullName = "\(firstName) \(lastName)"
                    }
                }
            }
        }
    }
}

//struct NotificationView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationView()
//    }
//}
