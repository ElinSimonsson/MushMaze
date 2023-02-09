//
//  ProfileSearchView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-09.
//

import SwiftUI
import FirebaseAuth

struct ProfileSearchView: View {
    @EnvironmentObject var userModel : UserModel
    @StateObject var usersLookup = UsersLookupModel()
    @State var keyword : String = ""
    
    
    var body: some View {
        let keywordBinding = Binding<String> (
            get: {
                keyword
            },
            set: {
                keyword = $0
                usersLookup.fetchUsers(from: keyword)
            }
        )
        VStack {
            SearchBarView(keyword: keywordBinding)
            ScrollView {
                ForEach(usersLookup.queriedUsers, id: \.id) { user in
                    ProfileBarView(user: user) {
                        userModel.sendRequestToFriend(recipientId: user.userId)
                    }
                }
            }
        }
        .padding()
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SearchBarView : View {
    @Binding var keyword : String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search friends", text: $keyword)
            Button(action: {
                self.keyword = ""
            }) {
                Image(systemName: "xmark.circle.fill").opacity(keyword == "" ? 0 : 1)
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ProfileBarView : View {
    @EnvironmentObject var userModel : UserModel
    var user : User
    let action : () -> Void
    
    var body: some View {
        if let currentUser = userModel.user {
            if currentUser.userId != user.userId {
                HStack {
                    ProfileImageView(imageURL: user.imageURL)
                    Text(user.fullName)
                    Spacer()
                    
                    let pendingRequest = userModel.friendRequests.first(where: {
                        ($0.senderId == currentUser.userId && $0.recipientId == user.userId) ||
                        ($0.recipientId == currentUser.userId && $0.senderId == user.userId)
                    })
                    
                    if let pendingRequest = pendingRequest {
                        if pendingRequest.senderId != currentUser.userId && pendingRequest.status == .pending {
                            Button(action: {
                                print("accept")
                            }) {
                                Text("Accept")
                            }
                            Button(action: {
                                print("decline")
                            }) {
                                Text("Decline")
                            }
                        } else if pendingRequest.status == .pending {
                            Text("Pending")
                        } else if pendingRequest.status == .accepted {
                            Text("Friend")
                        }
                    } else {
                        Button(action: {
                            userModel.sendRequestToFriend(recipientId: user.userId)
                        }) {
                            Text("Request")
                        }
                    }
                }
            }
        }
    }
}

struct ProfileImageView : View {
    var imageURL : String
    
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
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        } else {
            SmallUserImage()
        }
    }
}

//struct ProfileSearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileSearchView()
//    }
//}
