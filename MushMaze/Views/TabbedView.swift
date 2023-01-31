//
//  TabbedView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-31.
//

import SwiftUI

struct TabbedView: View {
    let locationManager = LocationManager()
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    @Binding var signedOut : Bool
    @State var destinations = Destination.map
    
    enum Destination {
        case map, list
    }
    
    var body: some View {
    
        VStack () {
            if destinations == .map {
                MapView(locationManager: locationManager, signedOut: $signedOut)
            } else if destinations == .list {
                ListOfPlacesView(signedOut: $signedOut)
            }
            Spacer()
            HStack (spacing: 0) {
                Spacer()
                Button(action: {
                    destinations = .map
                }){
                    Image(systemName: destinations == .map ? "map.fill" : "map")
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                }
                
                Spacer()
                Button(action: {
                    destinations = .list
                }) {
                    Image(systemName: destinations == .list ? "list.clipboard.fill" : "list.bullet.clipboard")
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                }
                Spacer()
            }
        }
        .onAppear() {
            locationManager.startLocationUpdate()
        }
    }
}

//struct TabbedView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabbedView()
//    }
//}
