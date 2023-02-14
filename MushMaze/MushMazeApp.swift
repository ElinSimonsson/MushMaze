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
    
    init() {
        FirebaseApp.configure()
            let userModel = UserModel()
            let places = Places(userModel: userModel)
            _userModel = StateObject(wrappedValue: userModel)
            _places = StateObject(wrappedValue: places)
            
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(places)
                .environmentObject(userModel)
        }
    }
}
