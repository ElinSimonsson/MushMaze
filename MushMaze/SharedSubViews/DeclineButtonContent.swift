//
//  DeclineButtonContent.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-22.
//

import SwiftUI

struct DeclineButtonContent : View {
    @Environment(\.colorScheme) var colorScheme
    let gray = Color.gray.opacity(0.5)
    var body: some View {
        Text("Decline")
            .frame(width: 90, height: 30)
            .foregroundColor(colorScheme == .light ? .black : .white)
            .background(colorScheme == .light ? Color(.systemGray6) : gray)
            .cornerRadius(15)
    }
}

struct DeclineButtonContent_Previews: PreviewProvider {
    static var previews: some View {
        DeclineButtonContent()
    }
}
