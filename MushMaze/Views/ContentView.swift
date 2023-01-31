//
//  ContentView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-24.
//

import SwiftUI

struct ContentView: View {
    //let locationManager = LocationManager()
    @State var signedIn = false
    @State var signedOut = false
    
//    init() {
//        locationManager.startLocationUpdate()
//    }
    
    var body: some View {

        if !signedOut && signedIn { // måste skicka med signedOut till signingInView för att ändra signedout till false när anvädmaren har loggat in
            TabbedView(signedOut: $signedOut)
        } else {
            SigningInView(signedIn: $signedIn)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
