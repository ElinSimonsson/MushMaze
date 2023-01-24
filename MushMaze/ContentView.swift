//
//  ContentView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-24.
//

import SwiftUI

struct ContentView: View {
    let locationManager = LocationManager()
   // @StateObject var places = Places()
    
    
    init() {
        locationManager.startLocationUpdate()
    }
    
    var body: some View {
        MapView(locationManager: locationManager)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
