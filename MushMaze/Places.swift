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
    
   private var db = Firestore.firestore()
    
    
    func addPlaceWithMushrooms (latitude: Double,
                                longitude: Double,
                                name: String,
                                description: String,
                                mushrooms: [String],
                                imageURL: String) {
        
        guard let user = Auth.auth().currentUser else {return}
        
        let place = Place(name: name,
                          description: description,
                          mushrooms: mushrooms,
                          imageURL: imageURL,
                          latitude: latitude,
                          longitude: longitude,
                          isSelected: false)
        
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
                        self.places.append(place)
                        print(place.name)
                    case .failure(let error) :
                        print("Error decoding place : \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func setAllIsSelectedFalse() {
        for i in 0..<places.count {
            places[i].isSelected = false
        }
    }
    
    func updateIsSelected (place: Place, with isSelected : Bool) {
//        for i in 0..<places.count {
//                places[i].isSelected = false
//            }
        
        if let index = places.firstIndex(of: place) {
            places[index].isSelected = true
            print("sätt till true \(place.name), isSelected: \(place.isSelected)")
        }
    }
    
    func testUpdateAllToFalse(place: Place, with isSelected: Bool) {
        if let index = places.firstIndex(of: place) {
            places[index].isSelected = false
            print("sätt alla false \(place.name), isSelected: \(place.isSelected)")
        }
    }
    
    func updateDistance (place: Place, with distance: Double) {
        
        if let index = places.firstIndex(of: place) {
            print("funktion inne places körs")
            places[index].distance = distance
            print("\(place.name), distans: \(place.distance)")
        }
    }
}
