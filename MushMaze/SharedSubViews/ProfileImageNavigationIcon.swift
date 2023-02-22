//
//  DefaultSmallProfileImage.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-22.
//

import SwiftUI

struct ProfileImageNavigationIcon: View {
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    var body: some View {
        Image(systemName: "person")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .background(lightGreyColor)
            .frame(width: 40, height: 40)
            .clipped()
            .cornerRadius(150)
            .padding(.trailing, 5)
    }
}

//struct DefaultSmallProfileImage_Previews: PreviewProvider {
//    static var previews: some View {
//        DefaultSmallProfileImage()
//    }
//}
