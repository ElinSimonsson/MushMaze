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
    @StateObject var places = Places()
    
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(places)
        }
    }
}
