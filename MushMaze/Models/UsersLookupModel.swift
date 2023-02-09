//
//  UsersLookupModel.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-09.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class UsersLookupModel : ObservableObject {
    
    @Published var queriedUsers : [User] = []
    let db = Firestore.firestore()
    
    func fetchUsers(from keyword : String) {
        db.collection("users").whereField("keywordsForLookup", arrayContains: keyword).getDocuments { querySnapshot, err in
            guard let documents = querySnapshot?.documents, err == nil else {return}
            self.queriedUsers = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: User.self)
            }
        }
    }
    
    
}
