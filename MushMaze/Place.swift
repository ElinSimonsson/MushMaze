//
//  Place.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-24.
//

import Foundation
import CoreLocation
import FirebaseFirestoreSwift

struct Place : Identifiable, Codable {
    @DocumentID var id : String?
    var name : String? // optional - temporarily. will change later
    var description : String?
    var mushrooms : [String]?
    var latitude : Double
    var longitude : Double
    var coordinate : CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
