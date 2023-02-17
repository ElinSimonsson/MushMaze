//
//  ProfileSearchView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-09.
//

import SwiftUI
import FirebaseAuth

struct ProfileSearchView: View {
    //@EnvironmentObject var userModel : UserModel
    @EnvironmentObject var friends : Friends
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
            Spacer()
                if keyword != "" && usersLookup.queriedUsers.isEmpty {
                    Text("There were no results for \"\(keyword)\". Try a new search")
                    Spacer()
                } else {
                    ScrollView {
                    ForEach(usersLookup.queriedUsers, id: \.id) { user in
                        ProfileBarView(user: user)
                    }
                }
                    .padding(.top, 30)
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
    @EnvironmentObject var friends : Friends
    var user : User
    
    var body: some View {
        if let currentUser = userModel.user {
            if currentUser.userId != user.userId {
                HStack {
                    ProfileImageView(imageURL: user.imageURL)
                    Text(user.fullName)
                    Spacer()

                    let pendingRequest = friends.friendRequests.first(where: {
                        ($0.senderId == currentUser.userId && $0.recipientId == user.userId) ||
                        ($0.recipientId == currentUser.userId && $0.senderId == user.userId)
                    })

                    if let pendingRequest = pendingRequest {
                        if pendingRequest.senderId != currentUser.userId && pendingRequest.status == .pending {

                            Button(action: {
                                friends.declineFriendRequest(friendRequest: pendingRequest)
                            }) {
                                DeclineButtonContent()
                            }
                            Button(action: {
                                friends.acceptFriendRequest(friendRequest: pendingRequest)
                            }) {
                                AcceptButtonContent()
                            }
                        } else if pendingRequest.status == .pending {
                            DefaultButtonContent(buttonText: "Pending")
                        } else if pendingRequest.status == .accepted {
                            DefaultButtonContent(buttonText: "Friend")
                        }
                    } else {
                        Button(action: {
                            friends.sendRequestToFriend(recipientId: user.userId) //
                        }) {
                            RequestButtonContent()
                        }
                    }
                }
            }
        }
    }
}

struct DefaultButtonContent : View {
    var buttonText : String
    var body: some View {
        Text(buttonText)
            .frame(width: 100, height: 30)
            .background(Color(.systemGray6))
            .cornerRadius(15)
    }
}

struct DeclineButtonContent : View {
    var body: some View {
        Text("Decline")
            .frame(width: 90, height: 30)
            .foregroundColor(.black)
            .background(Color(.systemGray6))
            .cornerRadius(15)
    }
}

struct RequestButtonContent : View {
    let darkTurquoise = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    var body: some View {
        Text("Request")
            .frame(width: 100, height: 30)
            .foregroundColor(.black)
            .background(Color.init(uiColor: darkTurquoise))
            .cornerRadius(15)
    }
}

struct AcceptButtonContent : View {
    let darkTurquoise = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    var body: some View {
        Text("Accept")
            .frame(width: 90, height: 30)
            .foregroundColor(.black)
            .background(Color.init(uiColor: darkTurquoise))
            .cornerRadius(15)
            .font(.headline)
    }
}

struct FriendTextContent : View {
    var body: some View {
        Text("Friend")
            .frame(width: 100, height: 30)
            .background(Color(.systemGray6))
            .cornerRadius(15)
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
