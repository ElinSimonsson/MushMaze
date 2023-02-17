//
//  MushMazeApp.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-24.
//

import SwiftUI
import Firebase


@main
struct MushMazeApp: App {
    @StateObject var userModel : UserModel
    @StateObject var places : Places
    @StateObject var friends : Friends
    
    init() {
        FirebaseApp.configure()
        let userModel = UserModel()
        let friends = Friends()
        let places = Places(friends: friends)
        _userModel = StateObject(wrappedValue: userModel)
        _friends = StateObject(wrappedValue: friends)
        _places = StateObject(wrappedValue: places)
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(places)
                .environmentObject(userModel)
                .environmentObject(friends)
        }
    }
}
