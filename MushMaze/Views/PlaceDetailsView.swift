//
//  PlaceDetailsView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-31.
//

import SwiftUI

struct PlaceDetailsView: View {
    var place : Place
    @Binding var isHeaderVisible : Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isHeaderVisible = true
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                    }
                }
            }
            .onAppear() {
                isHeaderVisible = false
            }
    }
}

