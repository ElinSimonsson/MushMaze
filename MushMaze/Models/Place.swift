//
//  Place.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-24.
//

import Foundation
import CoreLocation
import FirebaseFirestoreSwift

struct Place : Identifiable, Codable, Equatable {
    @DocumentID var id : String?
    var date : Date = Date()
    var createrUID : String
    var name : String
    var description : String?
    var mushrooms : [String]?
    var imageURL : String
    var latitude : Double
    var longitude : Double
    var distance : Double?
    var favorite : Bool
    var coordinate : CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
