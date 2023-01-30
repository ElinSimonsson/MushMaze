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
    @EnvironmentObject var places : Places
    let db = Firestore.firestore()
    @State var longPressLocation = CGPoint.zero
    //    @State var customPlace = Place(latitude: 0, longitude: 0)
    @State var coordinate = CLLocationCoordinate2D(latitude: 200, longitude: 200)
    @Environment(\.colorScheme) var colorScheme
    let darkTurquoise = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    @State var showProfile = false
    @State var showAddPlaceView = false
    @State var selectedPlace : Place?
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 59.243013423142024, longitude: 17.9932212288352), span:
                                            MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    HStack{
                        Spacer()
                        Button(action: {
                            showProfile = true
                        }) {
                            SmallUserImage()
                        }.fullScreenCover(isPresented: $showProfile, content: {
                            ProfileView(signedOut: $signedOut)
                        })
                    }
                    Map(coordinateRegion: $region,
                        interactionModes: [.all],
                        showsUserLocation: true,
                        userTrackingMode: .constant(.follow),
                        annotationItems: places.places) { place in
                        MapAnnotation(coordinate: place.coordinate, anchorPoint: CGPoint(x: 0.5, y: 0.5)) { // create own content on every map marker
                            ZStack {
                                MapPinMarker(place: place)
                                    .onTapGesture {
                                        self.selectedPlace = place
                                        places.setAllIsSelectedFalse()
                                        places.updateIsSelected(place: place, with: true)
                                    }
                                
                                if let isSelected = place.isSelected {
                                    if isSelected {
                                        MapAnnotationDetailView(place: place, closure: calculateDistance)
                                            .onAppear() {
                                                calculateDistance()
                                            }
                                    }
                                }
                                
                            }
                            .padding(.vertical, 60)
                        }
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
                                        //addPlaceByTap(at: longPressLocation, for: proxy.size)
                                        
                                    default:
                                        break
                                    }
                                })
                        .highPriorityGesture(DragGesture(minimumDistance: 10))
                        .colorScheme(colorScheme == .dark ? .dark : .light)
                }
            }
            .onAppear() {
                places.listenToFirestore()
            }
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
                        AddPlaceView(coordinate: coordinate)
                    })
                    .frame(width: 50, height: 50)
                    .background(Color(darkTurquoise))
                    .clipShape(Circle())
                }
                .padding()
            }
            
        }
    }
    
    func addPin () -> CLLocationCoordinate2D? {
        if let location = locationManager.location {
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
        
        showAddPlaceView = true
        return CLLocationCoordinate2D(latitude: lat-ySpan, longitude: lon + xSpan)
    }
    
    func calculateDistance () {
        print("funktionen utanför calcutate körs, inne")
        if let location = locationManager.location {
            print("location inne i funktion")
            let currentLatitude = location.latitude
            let currentLongitude = location.longitude
            
            for place in places.places {
                let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
                let userLocation = CLLocation(latitude: currentLatitude, longitude: currentLongitude)
                let distance = userLocation.distance(from: placeLocation)
                places.updateDistance(place: place, with: distance)
            }
        }
    }
}

struct MapAnnotationDetailView : View {
    var place : Place
    var closure : () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    closure()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            Spacer()
            Text("\(place.name)")
                .fontWeight(.bold)
            Text("distance: \(place.distance ?? 0.0)")
            Spacer()
        }
        .frame(width: 200, height: 200)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
        .offset(x: 0, y: -70)
    }
}

struct MapPinMarker : View {
    var place : Place
    
    var body: some View {
        Image("circleMapMarkerMushroom")
            .resizable()
            .frame(width: 30, height: 30)
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
