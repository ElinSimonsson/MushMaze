//
//  TabbedView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-31.
//

import SwiftUI

struct DestinationView: View {
    let locationManager = LocationManager()
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    @State var destinations = Destination.map
    
    enum Destination {
        case map, list
    }
    
    var body: some View {
        if destinations == .map {
            ZStack { // map need to 
                if destinations == .map {
                    MapView(locationManager: locationManager)
                }
                ToggleButtonsView(destinations: $destinations)
            }
            .onAppear() {
                locationManager.startLocationUpdate()
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
