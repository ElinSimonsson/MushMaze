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
        case map, list, friendList
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
                } else if destinations == .friendList {
                    ProfileSearchView()
                }
                Spacer()
                ToggleButtonsView(destinations: $destinations)
            }
        }
    }
}

struct ToggleButtonsView : View {
    @Binding var destinations : DestinationView.Destination
    @Environment(\.colorScheme) var colorScheme
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
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            .font(.system(size: 30))
                    }
                    Spacer()
                    Button(action: {
                        destinations = .list
                    }) {
                        Image(systemName: destinations == .list ? "list.clipboard.fill" : "list.bullet.clipboard")
                            .foregroundColor(colorScheme == .light ? .black : .white)
                            .font(.system(size: 30))
                    }
                    Spacer()
                    Button(action: {
                        destinations = .friendList
                    }) {
                        Image(systemName: destinations == .friendList ? "person.2.fill" : "person.2")
                            .foregroundColor(colorScheme == .light ? . black : .white)
                            .font(.system(size: 30))
                    }
                    Spacer()
                }
                .edgesIgnoringSafeArea(.top)
                .background(Color(.systemGray6))
            }
        } else  {
            
            HStack (spacing: 0) {
                Spacer()
                Button(action: {
                    destinations = .map
                }){
                    Image(systemName: destinations == .map ? "map.fill" : "map")
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .font(.system(size: 30))
                }
                Spacer()
                Button(action: {
                    destinations = .list
                }) {
                    Image(systemName: destinations == .list ? "list.clipboard.fill" : "list.bullet.clipboard")
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .font(.system(size: 30))
                }
                Spacer()
                Button(action: {
                    destinations = .friendList
                }) {
                    Image(systemName: destinations == .friendList ? "person.2.fill" : "person.2")
                        .foregroundColor(colorScheme == .light ? . black : .white)
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
