//
//  Notification.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-16.
//

import Foundation
import FirebaseFirestoreSwift

struct Notification : Codable, Identifiable {
    @DocumentID var id : String?
    var date : Date = Date()
    var senderNotificationUserId : String
    var friendRequestID : String?
    var placeID : String?
    var type : NotificationType
    
    enum NotificationType: String, Codable {
        case notification, friendRequest
    }
}
