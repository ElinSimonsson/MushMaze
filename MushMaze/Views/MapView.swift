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
    let db = Firestore.firestore()
    let locationManager : LocationManager
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var places : Places
    @State var coordinate = CLLocationCoordinate2D(latitude: 200, longitude: 200)
    @State var longPressLocation = CGPoint.zero
    @State var showProfile = false
    @State var showAddPlaceView = false
    @State var placesList = [Place]()
    @State var showMapAnnonation = false
    @State var selectedPlace : Place?
    @State var userTrackingModeValue: MapUserTrackingMode = .follow
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 59.243013423142024, longitude: 17.9932212288352), span:
                                            MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Map(coordinateRegion: $region,
                    interactionModes: [.all],
                    showsUserLocation: true,
                    userTrackingMode: .constant(userTrackingModeValue),
                    annotationItems: places.places) { place in
                    MapAnnotation(coordinate: place.coordinate, anchorPoint: CGPoint(x: 0.5, y: 0.5)) {
                        ZStack {
                            MapPinMarker(place: place)
                                .onTapGesture {
                                    if selectedPlace?.id != place.id {
                                        self.selectedPlace = place
                                        self.showMapAnnonation = true
                                    } else {
                                        showMapAnnonation = false
                                        self.selectedPlace = nil
                                    }
                                }
                            if let selectedPlace = selectedPlace {
                                if selectedPlace.id == place.id {
                                    if showMapAnnonation {
                                        MapAnnotationDetailView(place: place, closure: calculateDistance)
                                            .onAppear() {
                                                print("onAppear")
                                                calculateDistance()
                                                
                                            }
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
                                    coordinate = convertPointToCoordinate(at: longPressLocation, for: proxy.size)
                                default:
                                    break
                                }
                            })
                    .highPriorityGesture(DragGesture(minimumDistance: 10))
                    .colorScheme(colorScheme == .dark ? .dark : .light)
                VStack {
                    Spacer()
                    MapUserTrackingModeButton(userTrackingModeValue: $userTrackingModeValue)
                    Spacer().frame(maxHeight: 20)
                    AddPlaceButton(showAddPlaceView: $showAddPlaceView, coordinate: $coordinate) {
                        
                        coordinate = addPin() ?? CLLocationCoordinate2D(latitude: 100, longitude: 200)
                        if (coordinate.latitude >= -90 && coordinate.latitude <= 90) && (coordinate.longitude >= -180 && coordinate.longitude <= 180) {
                            showAddPlaceView = true
                        }
                    }
                    Spacer().frame(maxHeight: 50)
                }
                .padding()
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showProfile = true
                        }) {
                            SmallUserImage()
                        }.fullScreenCover(isPresented: $showProfile, content: {
                            ProfileView()
                        })
                        .padding(.bottom,10)
                    }
                    .frame(height: 50)
                    .background(colorScheme == .light ? .white : .black)
                    Spacer()
                }
            }
        }
    }
    
    
    func addPin () -> CLLocationCoordinate2D? {
        if let location = locationManager.location {
            print("addPin, location inte nil")
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
        return nil
    }
    
    func convertPointToCoordinate (at point: CGPoint, for mapSize: CGSize) -> CLLocationCoordinate2D {
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
 
        if let location = locationManager.location {
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
    @EnvironmentObject var places : Places
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(place.name)")
                .fontWeight(.bold)
            if let distance = place.distance {
                if distance > 1000 {
                    Text("distance: \(Int(distance / 1000 + 0.5)) km")
                } else {
                    Text("distance: \(Int(distance + 0.5)) m")
                }
                Spacer()
            }
            Text("Mushrooms founded here:")
                .fontWeight(.bold)
                .font(.subheadline)
            if let mushrooms = place.mushrooms {
                if mushrooms.count > 1 {
                    ForEach (mushrooms[0...1], id: \.self) { mushroom in
                        Text("* \(mushroom)")
                    }
                } else {
                    ForEach (mushrooms, id: \.self) { mushroom in
                        Text("* \(mushroom)")
                    }
                }
                Spacer()
            }
        }
        .frame(width: 200, height: 200)
        .background(colorScheme == .light ? .white : .black)
        .cornerRadius(10)
        .shadow(radius: 10)
        .offset(x: 0, y: -120)
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
            .aspectRatio(contentMode: .fill)
            .background(lightGreyColor)
            .frame(width: 40, height: 40)
            .clipped()
            .cornerRadius(150)
            .padding(.trailing, 5)
    }
}

struct MapUserTrackingModeButton : View {
    let darkTurquoise = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    @Binding var userTrackingModeValue: MapUserTrackingMode
    
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                if userTrackingModeValue == .follow {
                    userTrackingModeValue = .none
                } else {
                    userTrackingModeValue = .follow
                }
            }) {
                Image(systemName: userTrackingModeValue == . none ? "paperplane" : "paperplane.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
            .frame(width: 50, height: 50)
            .background(Color(darkTurquoise))
            .clipShape(Circle())
        }
    }
}

struct AddPlaceButton : View {
    let darkTurquoise = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    @Binding var showAddPlaceView : Bool
    @Binding var coordinate : CLLocationCoordinate2D
    var closure : () -> Void
    
    var body : some View {
        HStack {
            Spacer()
            
            Button(action: {
                self.closure()
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
    }
}



//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
