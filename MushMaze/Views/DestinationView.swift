//
//  DestinationView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-31.
//

import SwiftUI

struct DestinationView: View {
    let locationManager = LocationManager()
    @State var destinations = Destination.map
    
    enum Destination {
        case map, list
    }
    
    init() {
        locationManager.startLocationUpdate()
    }
    
    var body: some View {
        if destinations == .map {
            ZStack { // mapView needs to cover the entire screen for convertPointToCoordinate to be able to convert to the correct coordinate
                if destinations == .map {
                    MapView(locationManager: locationManager)
                }
                ToggleButtonsView(destinations: $destinations)
            }
        } else {
            VStack {
                if destinations == .list {
                    ListOfPlacesView()
                }
                Spacer()
                ToggleButtonsView(destinations: $destinations)
            }
        }
    }
}

struct ToggleButtonsView : View {
    @Binding var destinations : DestinationView.Destination
    
    var body: some View {
        if destinations == .map {
            VStack {
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
                .edgesIgnoringSafeArea(.top)
                .background(Color(.systemGray6))
            }
        } else if destinations == .list {
            
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
            .edgesIgnoringSafeArea(.top)
            .background(Color(.systemGray6))
            
        }
    }
}


//struct TabbedView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabbedView()
//    }
//}
