//
//  ProfileImageFromURL.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-22.
//

import SwiftUI

struct ProfileImageFromURL : View {
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
        .frame(width: 50, height: 50)
        .clipShape(Circle())
    }
}

//struct ProfileImageFromURL_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileImageFromURL()
//    }
//}
