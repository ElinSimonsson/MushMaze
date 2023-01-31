//
//  PlaceDetailsView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-31.
//

import SwiftUI

struct PlaceDetailsView: View {
    var place : Place
    @Binding var showProfileButton : Bool
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear() {
                showProfileButton = false
            }
            .onDisappear() {
                showProfileButton = true
            }
    }
}

//struct PlaceDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlaceDetailsView()
//    }
//}
