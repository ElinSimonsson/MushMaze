//
//  FriendRequest.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-09.
//

import Foundation
import FirebaseFirestoreSwift

struct FriendRequest : Codable, Identifiable {
    @DocumentID var id : String?
    //var date : Date = Date()
    var senderId: String
    var recipientId: String
    var status : RequestStatus
    
    
    enum RequestStatus: String, Codable {
        case pending, accepted, declined
    }
}
