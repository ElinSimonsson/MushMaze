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
    @State var longPressLocation = CGPoint.zero
    @State var customPlace = Place(latitude: 0, longitude: 0)
    @Environment(\.colorScheme) var colorScheme
    let darkTurquoise = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 59.243013423142024, longitude: 17.9932212288352), span:
                                            MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                
                Map(coordinateRegion: $region,
                    interactionModes: [.all],
                    showsUserLocation: true,
                    userTrackingMode: .constant(.follow),
                    annotationItems: places.places) { place in
                    MapMarker(coordinate: place.coordinate)
                }
                    .gesture(LongPressGesture(
                        minimumDuration: 0.25)
                        .sequenced(before: DragGesture(
                            minimumDistance: 0,
                            coordinateSpace: .local))
                            .onEnded { value in
                                switch value {
                                case .second(true, let drag):
                                    longPressLocation = drag?.location ?? .zero
                                    addPlaceByTap(at: longPressLocation, for: proxy.size)
                                    
                                default:
                                    break
                                }
                            })
                    .highPriorityGesture(DragGesture(minimumDistance: 10))
                    .colorScheme(colorScheme == .dark ? .dark : .light)
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
    }
    
    func addPin () {
        if let location = locationManager.location {
            places.addPlace(latitude: location.latitude, longitude: location.longitude)
        }
    }
    
    func addPlaceByTap (at point: CGPoint, for mapSize: CGSize) {
        let lat = region.center.latitude
        let lon = region.center.longitude
        
        let mapCenter = CGPoint(x: mapSize.width/2, y: mapSize.height/2)
        
        // X
        let xValue = (point.x - mapCenter.x) / mapCenter.x
        let xSpan = xValue * region.span.longitudeDelta/2
        
        // Y
        let yValue = (point.y - mapCenter.y) / mapCenter.y
        let ySpan = yValue * region.span.latitudeDelta/2
        
        places.addPlace(latitude: lat-ySpan, longitude: lon + xSpan)
        
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
