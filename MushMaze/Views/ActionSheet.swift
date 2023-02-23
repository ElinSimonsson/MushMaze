//
//  ActionSheet.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-06.
//

import SwiftUI

struct ActionSheet : View {
    @EnvironmentObject var places : Places
    @Environment (\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @Binding var showChoicePopUp : Bool
    @Binding var isEditing : Bool
    @Binding var isHeaderVisible : Bool 
    var place : Place
    
    var body: some View {
            List {
                EditButton(editAction: {
                    isEditing = true
                    showChoicePopUp = false
                })
                
                EditFavoriteButton(place: place) {
                    places.updateFavorites(place: place)
                }
                
                EditSharedPlace(place: place) {
                    places.updateSharedPlace(place: place)
                }
                
                DeletePlaceButton() {
                    places.deletePlace(place: place)
                }
                .onChange(of: places.placeDeleted) { newValue in
                    if places.placeDeleted {
                        // so header in ListOfPlacesView be displayed at the same time when the view becomes visible
                        
                        isHeaderVisible = true
                        places.placeDeleted = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .scrollContentBackground(.hidden)
    }
}

struct EditButton : View {
    @Environment (\.colorScheme) var colorScheme
    var editAction : () -> Void
    
    var body: some View {
        HStack {
            Button {
               editAction()
            } label: {
                Label("Edit", systemImage: "pencil")
                    .foregroundColor(colorScheme == .light ? .black : .white)
            }
        }
        .listRowBackground(Color(.systemGray6))
    }
}

struct EditFavoriteButton : View {
    @EnvironmentObject var places : Places
    @Environment (\.colorScheme) var colorScheme
    let place : Place
    let editFavoriteAction : () -> Void
    
    var body: some View {
        HStack {
            Button {
               editFavoriteAction()
            } label: {
                if places.favoritePlaces.contains(where: {$0.id == place.id}) {
                    Label("Remove from favorites", systemImage: "star.fill")
                        .foregroundColor(colorScheme == .light ? .black : .white)
                } else {
                    Label("Add to favorites", systemImage: "star")
                        .foregroundColor(colorScheme == .light ? .black : .white)
                }
            }
        }
        .listRowBackground(Color(.systemGray6))
    }
}

struct EditSharedPlace : View {
    @Environment (\.colorScheme) var colorScheme
    let place: Place
    let editSharedAction : () -> Void
    
    var body: some View {
        HStack {
            Button {
               editSharedAction()
            } label: {
                Label(place.sharedPlace ? "Make this to privacy" : "Share with friends",
                      systemImage: place.sharedPlace ? "person.2.slash" : "person.2")
                .foregroundColor(colorScheme == .light ? .black : .white)
                .padding(.bottom, 5)
                
            }
        }
        .listRowBackground(Color(.systemGray6))
    }
}

struct DeletePlaceButton : View {
    let deleteAction : () -> Void
    
    var body: some View {
        HStack {
            Button {
                deleteAction()
            } label: {
                Label("Delete", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
        .listRowBackground(Color(.systemGray6))
    }
}


//struct ChoicePopUp_Previews: PreviewProvider {
//    static var previews: some View {
//        ChoicePopUp()
//    }
//}
