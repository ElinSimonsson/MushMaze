//
//  Places.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class Places : ObservableObject {
    @Published var places = [Place]()
    @Published var placeSaved = false
    @Published var newDataFetched = false
    @Published var place: Place?
    @Published var placeDeleted = false
    let userModel : UserModel
    
    init(userModel : UserModel) {
        self.userModel = userModel
    }
   private var db = Firestore.firestore()
    
    func addPlaceWithMushrooms (latitude: Double,
                                longitude: Double,
                                name: String,
                                description: String,
                                mushrooms: [String],
                                imageURL: String,
                                sharedPlace : Bool) {
        
        guard let user = Auth.auth().currentUser else {return}
        
        let place = Place(createrUID: user.uid,
                          name: name,
                          description: description,
                          mushrooms: mushrooms,
                          imageURL: imageURL,
                          latitude: latitude,
                          longitude: longitude,
                          favorite: false,
                          sharedPlace: sharedPlace) // default
        
        do {
            _ = try
            db.collection("users").document(user.uid).collection("places").addDocument(from: place)
            print("saved successfully")
        } catch {
            print("error saving to firebase")
        }
    }
    
    func listenToFirestore () {
        var myPlaces = [Place]()
        guard let user = Auth.auth().currentUser else {return}

        db.collection("users")
            .document(user.uid)
            .collection("places")
            .order(by: "date")
            .addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {return}

            if let error = error {
                print("error getting document \(error.localizedDescription)")
            } else {
                for document in snapshot.documents {
                    let result = Result {
                        try document.data(as: Place.self)
                    }
                    switch result {
                    case .success(let place) :
                        myPlaces.append(place)
                        self.newDataFetched = true
                    case .failure(let error) :
                        print("Error decoding place : \(error.localizedDescription)")
                    }
                }
                
                // find existing places in the list that match the user ID
                let existingPlaces = self.places.filter { $0.createrUID == user.uid }
                
                // replace existing places with updated place if they match
                for place in myPlaces {
                    if let existingPlaceIndex = self.places.firstIndex(where: { $0.id == place.id }) {
                        self.places[existingPlaceIndex] = place
                    } else {
                        self.places.append(place)
                    }
                }
                // delete existing place if this place isn´t in the user places list
                for existingPlace in existingPlaces {
                    if !myPlaces.contains(where: { $0.id == existingPlace.id }) {
                        if let index = self.places.firstIndex(where: { $0.id == existingPlace.id }) {
                            self.places.remove(at: index)
                        }
                    }
                }
                self.places = self.places.sorted (by:{ $0.date > $1.date })
            }
        }
    }
    
    func testListenToFirestoreWithFriendsSharedPlace() {
        
        for friend in userModel.friends {
            if let friendID = friend.id {
                db.collection("users").document(friendID).collection("places").addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot else { return }
                    
                    if let error = error {
                        print("Error getting friend's document: \(error.localizedDescription)")
                    } else {
                        var friendPlaces = [Place]()
                        
                        for document in snapshot.documents {
                            let result = Result {
                                try document.data(as: Place.self)
                            }
                            switch result {
                            case.success(let friendPlace) :
                                if friendPlace.sharedPlace {
                                    friendPlaces.append(friendPlace)
                                }
                            case .failure(let error) :
                                print("failed decoding friend place : \(error)")
                            }
                        }
                        // find existing places in the list that match the friend ID
                        let existingPlaces = self.places.filter { $0.createrUID == friendID }
                        
                        // replace existing places with updated place if they match
                        for friendPlace in friendPlaces {
                            if let existingPlaceIndex = self.places.firstIndex(where: { $0.id == friendPlace.id }) {
                                self.places[existingPlaceIndex] = friendPlace
                            } else {
                                self.places.append(friendPlace)
                            }
                        }
                        // delete existing place if this place isn´t in the friend places list
                        for existingPlace in existingPlaces {
                            if !friendPlaces.contains(where: { $0.id == existingPlace.id }) {
                                if let index = self.places.firstIndex(where: { $0.id == existingPlace.id }) {
                                    self.places.remove(at: index)
                                }
                            }
                        }
                    }
                    self.places = self.places.sorted (by:{ $0.date > $1.date })
                }
            }
        }
    }
    
    func updatePlaceToFirestore (place: Place, placeName : String, description : String, mushrooms : [String]) {
        guard let currentUser = Auth.auth().currentUser else {return}
        
        if let documentID = place.id {
            db.collection("users")
                .document(currentUser.uid)
                .collection("places")
                .document(documentID).updateData(["name" : placeName,
                                                  "description" : description,
                                                  "mushrooms" : mushrooms])
        }
    }
    
    func updateFavroriteFirestore (place: Place) {
        guard let user = Auth.auth().currentUser else {return}
        if let documentId = place.id {
            db.collection("users").document(user.uid).collection("places").document(documentId).updateData(["favorite" : !place.favorite])
        }
    }
    
    func updateDistance (place: Place, with distance: Double) {
        if let index = places.firstIndex(of: place) {
            places[index].distance = distance
        }
    }
    
    func deletePlace (place: Place) {
        let storage = Storage.storage()
        guard let currentUser = Auth.auth().currentUser else {return}
        let storageRef = storage.reference(forURL: place.imageURL)

        // first, the image is removed from storage and then the document is removed from firestore
        storageRef.delete { error in
            if let error = error {
                print(error)
            } else {
                if let documentID = place.id {
                    self.db.collection("users").document(currentUser.uid).collection("places").document(documentID).delete() { err in
                        if let err = err {
                           print("failed removing document : \(err)")
                        } else {
                            print("Document successfully removed")
                            self.placeDeleted = true
                        }
                    }
                }
            }
        }
    }
}
