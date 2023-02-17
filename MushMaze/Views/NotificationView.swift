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
    @State var senderImageURL = ""
    @State var senderFullName = ""
    
    
    var body: some View {
        NavigationView {
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
                        // lägg till vy för tag-notiser här
                        Text("Tag notification")
                    }
                }
            }
            .navigationTitle("Notifications")
        }
    }
}

struct FriendRequestRowView : View {
    @EnvironmentObject var friends : Friends
    @EnvironmentObject var userModel: UserModel
    let notification : Notification
    let friendRequest : FriendRequest
    @State var fullName = ""
    @State var friendUserID = ""
    
    var body: some View {
        if let currentUser = Auth.auth().currentUser {
            HStack {
                SenderProfileView(userId: notification.senderNotificationUserId)
                
                if friendRequest.status == .accepted {
                    Text("You and **\(fullName)** are now connected as friends!")
                        .foregroundColor(.black)
                    
                } else if currentUser.uid != notification.senderNotificationUserId {
                    
                    Text("**\(fullName)** has requested to be friends with you")
                        .foregroundColor(.black)
                    
                    if friendRequest.status == .pending {
                        VStack {
                            Button(action: {
                                friends.acceptFriendRequest(friendRequest: friendRequest)
                            }) {
                                AcceptButtonContent()
                            }
                            
                            Button(action: {
                                friends.declineFriendRequest(friendRequest: friendRequest)
                            }) {
                                DeclineButtonContent()
                            }
                        }
                    }
                }
            }
            .onAppear() {
                if currentUser.uid != notification.senderNotificationUserId {
                    friendUserID = notification.senderNotificationUserId
                } else {
                    friendUserID = notification.recipientId
                }
                userModel.fetchUserInfo(userID: friendUserID) { (url, name, error) in
                    if let error = error {
                        print("error fetching imageURL \(error)")
                    }
                    if let name = name {
                        fullName = name
                    }
                }
            }
        }
    }
}


struct SenderProfileView : View {
    @EnvironmentObject var userModel : UserModel
    var userId: String
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
            fetchCreaterProfileImage(userId: userId)
        }
    }
    
    func fetchCreaterProfileImage (userId: String) {
        
        userModel.fetchUserInfo(userID: userId) { (url, name, error) in
            if let error = error {
                print("error fetching imageURL \(error)")
            }
            if let url = url {
                imageURL = url
            }
        }
    }
}

struct SmallProfileImageTest : View {
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
        userModel.fetchUserInfo(userID: id) { (url, name, error) in
            if let error = error {
                print("error fetching imageURL \(error)")
            }
            if let url = url {
                imageURL = url
            }
        }
    }
}

//struct NotificationView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationView()
//    }
//}
