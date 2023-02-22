//
//  AcceptButtonContent.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-22.
//

import SwiftUI

struct AcceptButtonContent : View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Text("Accept")
            .frame(width: 90, height: 30)
            .foregroundColor(colorScheme == . light ? .black : .white)
            .background(colorScheme == .light ? Color.green : Color(UIColor.systemGreen))
            .cornerRadius(15)
            .font(.headline)
    }
}

struct AcceptButtonContent_Previews: PreviewProvider {
    static var previews: some View {
        AcceptButtonContent()
    }
}
