//
//  ChoicePopUp.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-06.
//

import SwiftUI

struct ChoicePopUp : View {
    @EnvironmentObject var places : Places
    @Binding var showChoicePopUp : Bool
    @Binding var isEditing : Bool
    @Binding var isHeaderVisible : Bool
    var place : Place
    
    var body: some View {
            VStack {
                HStack {
                    Spacer().frame(maxWidth: 10)
                    Button {
                        print("Edit")
                        isEditing = true
                        showChoicePopUp = false
                    } label: {
                        Label("Edit", systemImage: "pencil")
                            .foregroundColor(.black)
                            .padding(.bottom, 5)
                    }
                    Spacer()
                }
                
                HStack {
                    Spacer().frame(maxWidth: 10)
                    Button {
                        places.updateFavroriteFirestore(place: place)
                    } label: {
                        Label(place.favorite ? "Remove from favorites" : "Add to favorites",
                              systemImage: place.favorite ? "star.fill" : "star")
                        .foregroundColor(.black)
                        .padding(.bottom, 5)
                    }
                    Spacer()
                }
                HStack {
                    Spacer().frame(maxWidth: 10)
                    Button {
                        places.deletePlace(place: place)
                    } label: {
                        Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                    }
                    .onChange(of: places.placeDeleted) { newValue in
                        if places.placeDeleted {
                        // so header in ListOfPlacesView be displayed at the same time when the view becomes visible
                            isHeaderVisible = true
                            places.placeDeleted = false
                        }
                    }
                    Spacer()
                }
        }
        .frame(width: 220, height: 150)
        .background(.white)
        .cornerRadius(10)
        .shadow(radius: 10)
        .simultaneousGesture(TapGesture().onEnded { _ in
            // tapGesture wont triggers in this view
        })
    }
}

//struct ChoicePopUp_Previews: PreviewProvider {
//    static var previews: some View {
//        ChoicePopUp()
//    }
//}
