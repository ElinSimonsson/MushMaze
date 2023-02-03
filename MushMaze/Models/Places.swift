//
//  Places.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class Places : ObservableObject {
    @Published var places = [Place]()
    @Published var placeSaved = false
    @Published var newDataFetched = false
    @Published var place: Place?
    
   private var db = Firestore.firestore()
    
    
    func addPlaceWithMushrooms (latitude: Double,
                                longitude: Double,
                                name: String,
                                description: String,
                                mushrooms: [String],
                                imageURL: String) {
        
        guard let user = Auth.auth().currentUser else {return}
        
        let place = Place(createrUID: user.uid,
                          name: name,
                          description: description,
                          mushrooms: mushrooms,
                          imageURL: imageURL,
                          latitude: latitude,
                          longitude: longitude,
                          favorite: false) // default
        
        do {
            _ = try
            db.collection("users").document(user.uid).collection("places").addDocument(from: place)
            print("saved successfully")
        } catch {
            print("error saving to firebase")
        }
    }
    
    func listenToFirestore () {
        print("listenToFirestore körs")
        
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
                self.places.removeAll()
                for document in snapshot.documents {
                    let result = Result {
                        try document.data(as: Place.self)
                    }
                    switch result {
                    case .success(let place) :
                        self.places.append(place)
                        print("place fetched hej")
                        self.newDataFetched = true
                    case .failure(let error) :
                        print("Error decoding place : \(error.localizedDescription)")
                    }
                }
                self.places = self.places.reversed() // order the array so that the newest location is first and the oldest is last
            }
        }
    }
    
    func updateFavroriteFirestore (place: Place) {
        guard let user = Auth.auth().currentUser else {return}
        if let id = place.id {
            db.collection("users").document(user.uid).collection("places").document(id).updateData(["favorite" : !place.favorite])
        }
    }
    
    func updateDistance (place: Place, with distance: Double) {
        
        if let index = places.firstIndex(of: place) {
            
            places[index].distance = distance
            
        }
    }
}
