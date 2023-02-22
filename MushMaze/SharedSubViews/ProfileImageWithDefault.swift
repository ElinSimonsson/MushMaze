//
//  ProfileImageWithDefault.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-22.
//

import SwiftUI

struct ProfileImageWithDefault: View {
    @EnvironmentObject var userModel : UserModel
    @State var imageURL = " "
    let userID : String
   
    
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
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .onAppear() {
                fetchProfileImageURL(userID: userID)
            }
        } else {
            DefaultProfileImage()
        }
    }
    
    func fetchProfileImageURL (userID : String) {
        userModel.fetchUserInfo(userID: userID) { (url, firstName, lastName, error ) in
                    if let error = error {
                        print("error fetching imageURL \(error)")
                    }
                    if let url = url {
                        imageURL = url
                    }
                }    }
}

//struct ProfileImageWithDefault_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileImageWithDefault()
//    }
//}
