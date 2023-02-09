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
                    ProfileBarView(user: user)
                }
            }
        }
        .padding()
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            userModel.loadUserInformation()
        }
        
        
    }
}

struct SearchBarView : View {
    @Binding var keyword : String
    
    var body: some View {
        HStack {
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
    
    var body: some View {
        if let currentUser = userModel.user {
            if currentUser.userId != user.userId {
                HStack {
                    ProfileImageView(imageURL: user.imageURL)
                    Text(user.fullName)
                    Spacer()
                    Button(action: {
                        print("user: \(user.userId) tapped")
                    }) {
                        Text("Request")
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
