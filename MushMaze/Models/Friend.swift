//
//  Friend.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-09.
//

import Foundation
import FirebaseFirestoreSwift

struct Friend : Codable, Identifiable {
    @DocumentID var id : String?
    var firstName: String
    var lastName: String
    var imageURL : String
    
}
