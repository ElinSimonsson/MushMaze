//
//  User.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-25.
//

import Foundation
import FirebaseFirestoreSwift

struct User : Codable, Identifiable {
    @DocumentID var id : String?
    //var fullName : String
    var firstName : String
    var lastName : String
    var userId : String
    var imageURL : String
    var keywordsForLookup : [String] {
        [self.firstName.generateStringSequence(), self.lastName.generateStringSequence(), "\(self.firstName) \(self.lastName)".generateStringSequence()].flatMap{$0}

    }
}

extension String {
    func generateStringSequence () -> [String] {
        guard self.count > 0 else {return []}
        var sequences : [String] = []
        for i in 1...self.count {
            sequences.append(String(self.prefix(i)))
        }
        return sequences
    }
}
