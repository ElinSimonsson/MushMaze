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
                    SmallUserImage()
                }.fullScreenCover(isPresented: $showProfileView, content: {
                    ProfileView()
                })
            }
            NotificationTitle()
        }
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

struct TagNotificationRowView : View {
    let notification : Notification
    @EnvironmentObject var places : Places
    @EnvironmentObject var userModel : UserModel
    @State var friendFullName = ""
    @State var imageURL = ""
    
    
    var body: some View {
        VStack {
            HStack {
                SenderProfileView(imageURL: $imageURL)
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
    let notification : Notification
    let friendRequest : FriendRequest
    @State var fullName = ""
    @State var friendUserID = ""
    @State var imageURL = ""
    
    var body: some View {
        if let currentUser = Auth.auth().currentUser {
            HStack {
                SenderProfileView(imageURL: $imageURL)
                
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


struct SenderProfileView : View {
    @EnvironmentObject var userModel : UserModel
    //var userId: String
    @Binding var imageURL: String
    
    
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
           // fetchCreaterProfileImage(userId: userId)
        }
    }
    
//    func fetchCreaterProfileImage (userId: String) {
//
//        userModel.fetchUserInfo(userID: userId) { (url, name, error) in
//            if let error = error {
//                print("error fetching imageURL \(error)")
//            }
//            if let url = url {
//                imageURL = url
//            }
//        }
//    }
}

//struct NotificationView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationView()
//    }
//}
