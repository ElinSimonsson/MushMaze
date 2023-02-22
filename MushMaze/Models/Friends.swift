//
//  Friends.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-16.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth

class Friends : ObservableObject {
    let db = Firestore.firestore()
    @Published var friendRequests = [FriendRequest]()
    @Published var friends = [Friend]()
    @Published var taggedFriends = [Friend]()
    @Published var allFriendsAreFetched = false
    @Published var successSendTagging = false
    @Published var newFriendCreated = false
    var friendRequestAddedToFriendCollection = true
    var listenerFriends: ListenerRegistration?
    var listenerFriendRequests: ListenerRegistration?
    var listenerMyFriendRequests: ListenerRegistration?
    var friendListeners = [ListenerRegistration]()
    
    
    func sendTagNotification (placeId : String) {
        guard let currentUser = Auth.auth().currentUser else {return}
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        for friend in taggedFriends {
            guard let friendId = friend.id else {return}
            let newNotification = Notification(senderNotificationUserId: currentUser.uid, recipientId: friendId, placeID: placeId, read: false , type: .tag)
            
            do {
                _ = try
                db.collection("users").document(friendId).collection("notifications").addDocument(from: newNotification)
            } catch {
                print("error send notification to friend")
            }
        }
        dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main) {
            self.successSendTagging = true
            self.taggedFriends.removeAll()
        }
        
    }
    
    func updateTaggedFriendsList (friend: Friend) {
        if taggedFriends.contains(where: { $0.id == friend.id }) {
            if let index = taggedFriends.firstIndex(where: { $0.id == friend.id }) {
                taggedFriends.remove(at: index)
            }
        } else {
            taggedFriends.append(friend)
        }
    }
    
    func sendNotificationForFriendRequest (to friendId: String, friendRequestId : String) {
        guard let currentUser = Auth.auth().currentUser else {return}
        
        let newNotification = Notification(senderNotificationUserId: currentUser.uid, recipientId: friendId, friendRequestID: friendRequestId,
                                           read: false, type: .friendRequest)
        
        do {
            _ = try
            db.collection("users").document(friendId).collection("notifications").addDocument(from: newNotification)
        } catch {
            print("error send notification to friend")
        }
    }
    
    func declineFriendRequest(friendRequest : FriendRequest) {
        guard let friendRequestID = friendRequest.id else {return}
        guard let currentUser = Auth.auth().currentUser else {return}
        
        db.collection("users")
            .document(currentUser.uid)
            .collection("friendRequest")
            .document(friendRequestID)
            .delete()
    }
    
    func acceptFriendRequest (friendRequest : FriendRequest) {
        guard let friendRequestID = friendRequest.id else {return}
        guard let currentUser = Auth.auth().currentUser else {return}
        
        db.collection("users")
            .document(currentUser.uid)
            .collection("friendRequest")
            .document(friendRequestID)
            .updateData(["status" : "accepted"])
        
        sendNotificationForFriendRequest(to: friendRequest.senderId, friendRequestId: friendRequestID)
    }
    
    func startListenFriends () {
        guard let currentUser = Auth.auth().currentUser else {return}
        
        listenerFriends = db.collection("users").document(currentUser.uid).collection("friends").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else {return}
            if let err = err {
                print("failed getting friends document \(err)")
            } else {
                self.friends.removeAll()
                for document in snapshot.documents {
                    let result = Result {
                        try document.data(as: Friend.self)
                    }
                    switch result {
                    case .success(let friend) :
                        self.friends.append(friend)
                    case .failure(let error) :
                        print("Error decoding friend \(error)")
                    }
                }
            }
            self.allFriendsAreFetched = true
        }
    }
    
    func createFriend (friendRequest : FriendRequest) {
        if friendRequest.status == .accepted {
            guard let currentUser = Auth.auth().currentUser else {return}
            let friendRef = db.collection("users").document(currentUser.uid).collection("friends")
            
            let friendId = friendRequest.senderId == currentUser.uid ? friendRequest.recipientId : friendRequest.senderId
            
            if !self.friends.contains(where: {$0.id == friendId}) {
                self.db.collection("users").document(friendId).getDocument { (document, error) in
                    if let document = document, let data = document.data() {
                        let firstName = data["firstName"] as? String ?? ""
                        let lastName = data["lastName"] as? String ?? ""
                        let imageURL = data["imageURL"] as? String ?? ""
                        
                        let newFriend = Friend(id: friendId, firstName: firstName, lastName: lastName, imageURL: imageURL)
                        
                        do {
                            let newFriendRef = friendRef.document(friendId)
                            try newFriendRef.setData(from: newFriend)
                            self.newFriendCreated = true
                        } catch {
                            print("Error setting data: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    func sendRequestToFriend (recipientId : String) {
        friendRequestAddedToFriendCollection = false
        guard let currentUser = Auth.auth().currentUser else {return}
        
        let data : [String : Any] = [
            "date" : Timestamp(date: Date()),
            "senderId" : currentUser.uid,
            "recipientId" : recipientId,
            "status" : "pending"]
        
        var ref: DocumentReference? = nil
        ref = db.collection("users").document(currentUser.uid).collection("friendRequest").addDocument(data: data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                // send the friendRequest to friend with the same friendRequest documentId
                self.db.collection("users").document(recipientId).collection("friendRequest").document(ref!.documentID).setData(data) { err in
                    if let err = err {
                        print("Error adding document :\(err)")
                    } else {
                        self.friendRequestAddedToFriendCollection = true
                        self.sendNotificationForFriendRequest(to: recipientId, friendRequestId: ref!.documentID)
                    }
                }
            }
        }
    }
    
    func listenFriendRequestFirestore () {
        guard let user = Auth.auth().currentUser else {return}
        
        listenerFriendRequests = db.collection("users").document(user.uid).collection("friendRequest").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else {return}
            if let err = err {
                print("failed getting documents \(err)")
            } else {
                self.friendRequests.removeAll()
                for document in snapshot.documents {
                    let result = Result {
                        try document.data(as: FriendRequest.self)
                    }
                    switch result {
                    case .success(let friendRequest) :
                        self.friendRequests.append(friendRequest)
                        
                        if friendRequest.status == .accepted {
                            //self.createFriend(friendRequest: friendRequest)
                            self.createFriend(friendRequest: friendRequest)
                        }
                    case .failure(let error) :
                        print("Error decoding friendRequest \(error)")
                    }
                }
                self.listenMyFriendsFriendRequest()
                self.startListenFriends()
            }
        }
    }
    
    func listenMyFriendsFriendRequest() {
        guard let currentUser = Auth.auth().currentUser else { return }
        for friendRequest in friendRequests {
            guard let friendRequestID = friendRequest.id else {return}
            if friendRequest.senderId == currentUser.uid && friendRequest.recipientId != currentUser.uid {
                let friendID = friendRequest.recipientId
                var listener: ListenerRegistration?
                listener = db.collection("users").document(friendID)
                    .collection("friendRequest")
                    .whereField("senderId", isEqualTo: currentUser.uid)
                    .whereField("recipientId", isEqualTo: friendID)
                    .addSnapshotListener { snapshot, error in
                        guard let snapshot = snapshot else {return}
                        var friendRequestExists = false
                        for document in snapshot.documents {
                            let result = Result {
                                try document.data(as: FriendRequest.self)
                            }
                            
                            switch result {
                            case .success(let friendRequest):
                                friendRequestExists = true
                                self.updateMyFriendRequest(friendRequest: friendRequest)
                            case .failure(let error):
                                print("Error decoding friendRequest: \(error)")
                            }
                        }
                        
                        self.friendListeners.append(listener!)
                        
                        if !friendRequestExists && self.friendRequestAddedToFriendCollection {
                            print("friend request i min vän lista finns inte")
                            self.db.collection("users").document(currentUser.uid)
                                .collection("friendRequest").document(friendRequestID).delete() { error in
                                    if let error = error {
                                        print("Error removing friend request: \(error)")
                                    } else {
                                        print("Friend request successfully removed!")
                                    }
                                }
                        }
                    }
            }
        }
    }
    
    func updateMyFriendRequest (friendRequest : FriendRequest) {
        guard let friendRequestID = friendRequest.id else {return}
        guard let currentUser = Auth.auth().currentUser else {return}
        
        if friendRequest.status == .accepted {
            print("update My friend request körs, status är accepted")
            print("accepted")
            db.collection("users")
                .document(currentUser.uid)
                .collection("friendRequest")
                .document(friendRequestID)
                .updateData(["status" : "accepted"])
        }
    }
    
    func stopListening () {
        for listener in friendListeners {
            listener.remove()
        }
        friendListeners = []
        
        
        listenerFriends?.remove()
        listenerFriendRequests?.remove()
        listenerMyFriendRequests?.remove()
        
        listenerFriends = nil
        listenerFriendRequests = nil
        listenerMyFriendRequests = nil
    }
    
    func clearAllFriendList () {
        friendRequests.removeAll()
         friends.removeAll()
    }
}
