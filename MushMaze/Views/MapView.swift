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
    @Binding var signedOut : Bool
    @StateObject var places = Places()
    let db = Firestore.firestore()
    @State var longPressLocation = CGPoint.zero
//    @State var customPlace = Place(latitude: 0, longitude: 0)
    @State var coordinate = CLLocationCoordinate2D(latitude: 200, longitude: 200)
    @Environment(\.colorScheme) var colorScheme
    let darkTurquoise = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    @State var showProfile = false
    @State var showAddPlaceView = false
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 59.243013423142024, longitude: 17.9932212288352), span:
                                            MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showProfile = true
                }) {
                    SmallUserImage()
                }.fullScreenCover(isPresented: $showProfile, content: {
                    ProfileView(signedOut: self.$signedOut)
                })
            }
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
                                      coordinate = addPlaceByTap(at: longPressLocation, for: proxy.size)
                                        
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
                                coordinate = addPin() ?? CLLocationCoordinate2D(latitude: 100, longitude: 200)
                                if (coordinate.latitude >= -90 && coordinate.latitude <= 90) && (coordinate.longitude >= -180 && coordinate.longitude <= 180) {
                                    showAddPlaceView = true
                                }
                                
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                            }
                            .fullScreenCover(isPresented: $showAddPlaceView, content: {
                                AddPlaceView() // skicka med coordinate
                            })
                            .frame(width: 50, height: 50)
                            .background(Color(darkTurquoise))
                            .clipShape(Circle())
                        }
                        .padding()
                    }
                    .onAppear() {
                        places.listenToFirestore()
                    }
                }
            }
//            if showAddPlaceView {
//                AddPlaceView() //skicka med coordinate sen när allt funkar
//            }
        }
    }
    
    func addPin () -> CLLocationCoordinate2D? {
        if let location = locationManager.location {
            //places.addPlace(latitude: location.latitude, longitude: location.longitude)
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
        return nil
    }
    
    func addPlaceByTap (at point: CGPoint, for mapSize: CGSize) -> CLLocationCoordinate2D {
        let lat = region.center.latitude
        let lon = region.center.longitude
        
        let mapCenter = CGPoint(x: mapSize.width/2, y: mapSize.height/2)
        
        // X
        let xValue = (point.x - mapCenter.x) / mapCenter.x
        let xSpan = xValue * region.span.longitudeDelta/2
        
        // Y
        let yValue = (point.y - mapCenter.y) / mapCenter.y
        let ySpan = yValue * region.span.latitudeDelta/2
        
        //places.addPlace(latitude: lat-ySpan, longitude: lon + xSpan)
        showAddPlaceView = true
        return CLLocationCoordinate2D(latitude: lat-ySpan, longitude: lon + xSpan)
        
        
    }
}

struct SmallUserImage : View {
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    var body: some View {
        Image(systemName: "person")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .background(lightGreyColor)
            .frame(width: 40, height: 40)
            .clipped()
            .cornerRadius(150)
            .padding(.trailing, 5)
        
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
