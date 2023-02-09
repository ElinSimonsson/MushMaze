//
//  NotificationView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-09.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var userModel : UserModel
    @State var senderImageURL = ""
    @State var senderFullName = ""
    
    var body: some View {
        ScrollView {
            ForEach (userModel.friendRequests) { friendRequest in
                if let user = userModel.user {
                    if friendRequest.senderId != user.userId {
                        HStack {
                            SenderProfileView(imageURL: $senderImageURL)
                            Text("\(senderFullName) has requested to be friends with you")
                            if friendRequest.status == .pending {
                                Button(action: {
                                    userModel.acceptFriendRequest(friendRequest: friendRequest)
                                }) {
                                   Text("Accept")
                                }
                                Button(action: {
                                    
                                }) {
                                   Text("Decline")
                                }
                            } else if friendRequest.status == .accepted {
                                Text("Accepted")
                            }
                        }
                        .onAppear() {
                            fetchSenderInformation(friendRequest: friendRequest)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    func fetchSenderInformation (friendRequest : FriendRequest) {
        userModel.fetchUserInfo(userID: friendRequest.senderId) { imageurl, name, error in
            if let imageurl = imageurl {
                senderImageURL = imageurl
            }
            if let name = name {
                senderFullName = name
            }
            if let error = error {
                print("error fetching sender information \(error)")
            }
        }
    }
}

struct SenderProfileView : View {
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
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .onAppear() {
                
            }
            
        
    }
    
    func fetchSenderProfile (friendRequest : FriendRequest) {
       // userModel.fetchUserInfo(userID: friendRequest.senderId) {
            
        //}
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
