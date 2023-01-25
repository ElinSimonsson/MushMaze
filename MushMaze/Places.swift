//
//  Places.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-24.
//

import Foundation
import FirebaseFirestore

class Places : ObservableObject {
   @Published var places = [Place]()
    
   private var db = Firestore.firestore()
    

    func addPlace (latitude : Double, longitude : Double) {
        //let place = Place(name: placeName, latitude: latitude, longitude: longitude)
        let place = Place(latitude: latitude, longitude: longitude)
        
        do {
            _ = try
                db.collection("places").addDocument(from: place)
            print("successed to save")
        } catch {
            print("Error saving to Firebase")
        }
    }
    
    func listenToFirestore () {
        db.collection("places").addSnapshotListener { snapshot, error in
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
                    case .failure(let error) :
                        print("Error decoding place : \(error.localizedDescription)")
                    }
                }
            }
        }
            
    }
}
