//
//  ContentView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-24.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var userModel : UserModel
    
    
    var body: some View {

        //ProfileSearchView()
        if !userModel.signedOut && userModel.signedIn {
            DestinationView()
        } else {
            SigningInView()
        }
   }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
