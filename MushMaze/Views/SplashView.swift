//
//  SplashView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-20.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var isActive = false
    @State var size = 0.8
    @State var opacity = 0.4
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                VStack {
                    Image(colorScheme == .light ? "logo-black" : "logo-white")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear() {
                    withAnimation(.easeIn(duration: 1.8)) {
                        self.size = 0.99
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isActive = true
                }
            }
        }
       
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
