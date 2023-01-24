//
//  MapView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-24.
//

import SwiftUI
import MapKit
import Firebase

struct MapView: View {
    
    var locationManager : LocationManager
    @StateObject var places = Places()
    let db = Firestore.firestore()
    @Environment(\.colorScheme) var colorScheme
    let darkTurquoise = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 59.243013423142024, longitude: 17.9932212288352), span:
                                            MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                interactionModes: [.all],
                showsUserLocation: true,
                userTrackingMode: .constant(.follow),
                annotationItems: places.places) { place in
                MapMarker(coordinate: place.coordinate)
            }.colorScheme(colorScheme == .dark ? .dark : .light)
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Button(action: {
                        addPin()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                            
                    }
                    .frame(width: 50, height: 50)
                    .background(Color(darkTurquoise))
                    .clipShape(Circle())
                 }
                .padding()
             }
                .onAppear() {
                    places.listenToFirestore()
                    //places.addPlace(placeName: "Test", latitude: 59.243013423142024, longitude: 17.9932212288352)
                    //places.addPlace(placeName: "Test 2", latitude: 59.2430134231420, longitude: 17.9932212288352)
            }
        }
    }
    
    func addPin () {
        if let location = locationManager.location {
            places.addPlace(placeName: "", latitude: location.latitude, longitude: location.longitude)
        }
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
