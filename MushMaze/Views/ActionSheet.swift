//
//  ActionSheet.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-06.
//

import SwiftUI

struct ActionSheet : View {
    @EnvironmentObject var places : Places
    @Environment(\.presentationMode) var presentationMode
    @Binding var showChoicePopUp : Bool
    @Binding var isEditing : Bool
    @Binding var isHeaderVisible : Bool 
    var place : Place
    
    var body: some View {
            List {
                HStack {
                    Button {
                        isEditing = true
                        showChoicePopUp = false
                    } label: {
                        Label("Edit", systemImage: "pencil")
                            .foregroundColor(.black)
                    }
                }
                .listRowBackground(Color(.systemGray6))
                
                HStack {
                    Button {
                        places.updateFavorites(place: place)
                    } label: {
                        if places.favoritePlaces.contains(where: {$0.id == place.id}) {
                            Label("Remove from favorites", systemImage: "star.fill")
                                .foregroundColor(.black)
                        } else {
                            Label("Add to favorites", systemImage: "star")
                                .foregroundColor(.black)
                        }
                    }
                }
                .listRowBackground(Color(.systemGray6))
                
                HStack {
                    Button {
                        places.updateSharedPlace(place: place)
                    } label: {
                        Label(place.sharedPlace ? "Make this to privacy" : "Share with friends",
                              systemImage: place.sharedPlace ? "person.2.slash" : "person.2")
                        .foregroundColor(.black)
                        .padding(.bottom, 5)
                        
                    }
                }
                .listRowBackground(Color(.systemGray6))
                HStack {
                    Button {
                        places.deletePlace(place: place)
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    .onChange(of: places.placeDeleted) { newValue in
                        if places.placeDeleted {
                            // so header in ListOfPlacesView be displayed at the same time when the view becomes visible
                            
                            isHeaderVisible = true // Cannot assign to value: 'isHeaderVisible' is a 'let' constant
                            
                            places.placeDeleted = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .listRowBackground(Color(.systemGray6))
            }
            .scrollContentBackground(.hidden)
    }
}


//struct ChoicePopUp_Previews: PreviewProvider {
//    static var previews: some View {
//        ChoicePopUp()
//    }
//}
