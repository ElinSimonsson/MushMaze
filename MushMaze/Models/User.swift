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
    var fullName : String
    var userId : String
    var imageURL : String
    var keywordsForLookup : [String] {
        [self.fullName.generateStringSequence()].flatMap {$0}
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
