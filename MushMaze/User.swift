//
//  User.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-25.
//

import Foundation
import FirebaseFirestoreSwift

struct User : Codable {
    @DocumentID var id : String?
    var fullName : String
    var userId : String
}
