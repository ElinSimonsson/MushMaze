//
//  ImageMod.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-27.
//

import Foundation
import SwiftUI

extension Image {
    
    func imageMod() -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: 300, height: 230)
            .cornerRadius(10)
            .padding(.top, 40)
            .padding(.bottom, 40)
    }
}
