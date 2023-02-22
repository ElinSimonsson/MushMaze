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
import UIKit

class Places : ObservableObject {
    @Published var allSavedPlaces = [Place]()
    @Published var favoritePlaces = [Place]()
    @Published var savingPlace = false
    @Published var placeSuccessfullySaved = false
    @Published var newDataFetched = false
    @Published var place: Place?
    @Published var placeDeleted = false
    var placesListeners = [ListenerRegistration]()
    let friends : Friends
    
    init(friends: Friends) {
        self.friends = friends
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
                          sharedPlace: sharedPlace)
        
        do {
            _ = try
            db.collection("users").document(user.uid).collection("places").addDocument(from: place)
            self.placeSuccessfullySaved = true
            self.savingPlace = false
        } catch {
            print("error saving to firebase")
        }
    }
    
    func listenToFavoritePlacesFirestore () {
        guard let currentUser = Auth.auth().currentUser else {return}
        
        db.collection("users").document(currentUser.uid).collection("favoritePlaces").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else {return}
            if let err = err {
                print("error getting document from firestore \(err)")
            } else {
                self.favoritePlaces.removeAll()
                for document in snapshot.documents {
                    let result = Result {
                        try document.data(as: Place.self)
                    }
                    switch result {
                    case .success(let favoritePlace) :
                        self.favoritePlaces.append(favoritePlace)
                    case .failure(let error) :
                        print("failed decoding favoritePlace \(error)")
                    }
                }
            }
        }
    }
    
    func listenToFirestore () {
        
        guard let user = Auth.auth().currentUser else {return}
        
        var listener : ListenerRegistration?
        
          listener = db.collection("users")
            .document(user.uid)
            .collection("places")
            .order(by: "date")
            .addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {return}

            if let error = error {
                print("error getting document \(error.localizedDescription)")
            } else {
                var myPlaces = [Place]()
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
                if let listener = listener {
                    self.placesListeners.append(listener)
                }
                
                // find existing places in the list that match the user ID
                let existingPlaces = self.allSavedPlaces.filter { $0.createrUID == user.uid }
                
                // replace existing places with updated place if they match
                for place in myPlaces {
                    if let existingPlaceIndex = self.allSavedPlaces.firstIndex(where: { $0.id == place.id }) {
                        self.allSavedPlaces[existingPlaceIndex] = place
                    } else {
                        self.allSavedPlaces.append(place)
                    }
                }
                // delete existing place if this place isn´t in the user places list
                for existingPlace in existingPlaces {
                    if !myPlaces.contains(where: { $0.id == existingPlace.id }) {
                        if let index = self.allSavedPlaces.firstIndex(where: { $0.id == existingPlace.id }) {
                            self.allSavedPlaces.remove(at: index)
                        }
                    }
                }
                self.updateFavoritesDataFirestore()
                self.allSavedPlaces = self.allSavedPlaces.sorted (by:{ $0.date > $1.date })
            }
        }
    }
    
    func listenFriendsSharedPlaces() {
        for friend in friends.friends {
            if let friendID = friend.id {
                
                var listener : ListenerRegistration?
                
                listener = db.collection("users").document(friendID).collection("places").whereField("sharedPlace", isEqualTo: true).addSnapshotListener { snapshot, error in
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
                                    friendPlaces.append(friendPlace)
                                
                            case .failure(let error) :
                                print("failed decoding friend place : \(error)")
                            }
                        }
                        
                        if let listener = listener {
                            self.placesListeners.append(listener)
                        }
                        
                        // find existing places in the list that match the friend ID
                        let existingPlaces = self.allSavedPlaces.filter { $0.createrUID == friendID }
                        
                        // replace existing places with updated place if they match
                        for friendPlace in friendPlaces {
                            if let existingPlaceIndex = self.allSavedPlaces.firstIndex(where: { $0.id == friendPlace.id }) {
                                self.allSavedPlaces[existingPlaceIndex] = friendPlace
                            } else {
                                self.allSavedPlaces.append(friendPlace)
                            }
                        }
                        // delete existing place if this place isn´t in the friend places list
                        for existingPlace in existingPlaces {
                            if !friendPlaces.contains(where: { $0.id == existingPlace.id }) {
                                if let index = self.allSavedPlaces.firstIndex(where: { $0.id == existingPlace.id }) {
                                    self.allSavedPlaces.remove(at: index)
                                }
                            }
                        }
                    }
                    self.updateFavoritesDataFirestore()
                    self.allSavedPlaces = self.allSavedPlaces.sorted (by:{ $0.date > $1.date })
                }
            }
        }
    }
    
    func updateSharedPlace(place: Place) {
        guard let currentUser = Auth.auth().currentUser else {return}
        if let documentID = place.id {
            db.collection("users")
                .document(currentUser.uid)
                .collection("places")
                .document(documentID)
                .updateData(["sharedPlace" : !place.sharedPlace])
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
    
    func updateFavoritesDataFirestore () {
        guard let currentUser = Auth.auth().currentUser else {return}
        for place in allSavedPlaces {
            
            if favoritePlaces.contains(where: {$0.id == place.id}) {
                guard let placeID = place.id else {return}
                
                let favoritePlaceRef = db.collection("users")
                   .document(currentUser.uid)
                   .collection("favoritePlaces")
                   .document(placeID)
                
                do {
                 try favoritePlaceRef.setData(from: place)
                } catch {
                    print("failed to update favorite data")
                }
            }
        }
        
        for favoritePlace in favoritePlaces {
            if !allSavedPlaces.contains(where: {$0.id == favoritePlace.id}) {
                guard let placeID = favoritePlace.id else {return}
                db.collection("users")
                   .document(currentUser.uid)
                   .collection("favoritePlaces")
                   .document(placeID)
                   .delete()
            }
        }
    }
    
    func updateFavorites (place: Place) {
        guard let currentUser = Auth.auth().currentUser else {return}
        
        guard let placeID = place.id else {return}
        
        let favoritePlaceRef = db.collection("users")
            .document(currentUser.uid)
            .collection("favoritePlaces")
            .document(placeID)
        
        if favoritePlaces.contains(where: {$0.id == place.id}) {
            favoritePlaceRef.delete()
        } else {
            do {
             try favoritePlaceRef.setData(from: place)
            } catch {
                print("failed to make a clon of the place and save in firestore")
            }
        }
    }
    
    func updateDistance (place: Place, with distance: Double) {
        if let index = allSavedPlaces.firstIndex(of: place) {
            allSavedPlaces[index].distance = distance
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
    func uploadImageAndSaveToFirestore (selectedImage : UIImage?, latitude : Double, longitude: Double, name : String, description : String, mushrooms: [String], isShared : Bool) {
        
        savingPlace = true
        let fileName = "\(UUID().uuidString).jpg"
        let ref = Storage.storage().reference(withPath: fileName)
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.5) else {return}
        ref.putData(imageData ,metadata: nil) { metadata, err in
            if let err = err {
                print("failed to push image to Storage\(err)")
                return
            }
            ref.downloadURL { url, err in
                if let err = err {
                    print("failed to retrieve downloadURL \(err)")
                    return
                } else {
                    print("successfully stored image with url : \(url?.absoluteString ?? "")")
                    guard let imageURL = url?.absoluteString else {return}
                    self.addPlaceWithMushrooms(latitude: latitude, longitude: longitude, name: name, description: description, mushrooms: mushrooms, imageURL: imageURL, sharedPlace: isShared)
                    //self.savingPlace = false
                }
            }
        }
    }
    
    func clearAllPlaces () {
        allSavedPlaces.removeAll()
        favoritePlaces.removeAll()
    }
    
    func stopListening() {
        for listener in placesListeners {
                    listener.remove()
                }
        
                placesListeners = []
    }
}
