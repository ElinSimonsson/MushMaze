//
//  FriendListView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-13.
//

import SwiftUI

struct FriendListView: View {
    @EnvironmentObject var userModel : UserModel
    @EnvironmentObject var places : Places
    @EnvironmentObject var friends : Friends
    @State var showProfileSearchView = false
    @State var showProfile = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showProfile.toggle()
                    }) {
                        ProfileImageNavigationIcon()
                    }.fullScreenCover(isPresented: $showProfile, content: {
                        ProfileView()
                    })
                }
                HStack {
                    YourFriendsTitle()
                }
                if friends.friends.isEmpty {
                    Spacer()
                    Text("No friends found")
                    Spacer()
                } else {
                    List {
                        ForEach (friends.friends) { friend in
                            FriendRowView(friend: friend)
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
                    AddFriendButton(showProfileSearchView: $showProfileSearchView)
                        .sheet(isPresented: $showProfileSearchView, content: ProfileSearchView.init)
        }
    }
}

struct FriendRowView : View {
    let friend : Friend
    
    var body: some View {
        HStack {
            if friend.imageURL != "" {
                ProfileImageFromURL(imageURL: friend.imageURL)
            } else {
                DefaultProfileImage()
            }
            Spacer().frame(maxWidth: 15)
            Text("\(friend.firstName) \(friend.lastName)")
            Spacer()
        }
    }
}

struct YourFriendsTitle : View {
    var body: some View {
        HStack {
            Spacer().frame(maxWidth: 10)
            Text("Your friends")
                .font(.largeTitle)
                .background(.clear)
                .fontWeight(.bold)
                .padding(.bottom)
            Spacer()
        }
    }
}

struct AddFriendButton : View {
    let forestGreen = Color(red: 86/255, green: 158/255, blue: 105/255)
    @Binding var showProfileSearchView : Bool
    
    var body : some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showProfileSearchView = true
                    }) {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                    }
                    .frame(width: 60, height: 60)
                    .background(forestGreen)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                Spacer().frame(maxWidth: 15)
            }
            Spacer().frame(maxHeight: 18)
        }
    }
}


//struct FriendListView_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendListView()
//    }
//}
