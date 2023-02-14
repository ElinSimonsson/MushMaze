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
                        SmallUserImage()
                    }.fullScreenCover(isPresented: $showProfile, content: {
                        ProfileView()
                    })
                }
                HStack {
                    YourFriendsTitle()
                }
                Spacer()
                if userModel.friends.isEmpty {
                    Text("No friends")
                    Spacer()
                } else {
                    List {
                        ForEach (userModel.friends) { friend in
                            HStack {
                                SmallProfileImageView(imageURL: friend.imageURL)
                                Spacer()
                                Text(friend.fullName)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color(.systemGray6))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AddFriendButton(showProfileSearchView: $showProfileSearchView)
                        .sheet(isPresented: $showProfileSearchView, content: ProfileSearchView.init)
                }
            }
            .navigationTitle("Your friends")
        }
    }
}

struct SmallProfileImageView : View {
    var imageURL : String
    
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
        .frame(width: 45, height: 45)
        .clipShape(Circle())
    }
}

struct YourFriendsTitle : View {
    var body: some View {
        HStack {
            Text(" Your friends")
                .font(.largeTitle)
                .background(.clear)
                .fontWeight(.bold)
                .padding(.bottom)
            Spacer()
        }
    }
}

struct AddFriendButton : View {
    let darkTurquoise = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    @Binding var showProfileSearchView : Bool
    
    var body : some View {
        HStack {
            Spacer()
            Button(action: {
               showProfileSearchView = true
            }) {
                Image(systemName: "person.badge.plus")
                    .foregroundColor(.white)
                    .font(.system(size: 30))
            }
            .frame(width: 50, height: 50)
            .background(Color(darkTurquoise))
            .clipShape(Circle())
        }
    }
}

//struct FriendListView_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendListView()
//    }
//}
