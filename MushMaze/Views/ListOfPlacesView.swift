//
//  ListOfPlacesView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-31.
//

import SwiftUI

struct ListOfPlacesView: View {
    @EnvironmentObject var places : Places
    @Binding var signedOut : Bool
    @State var showProfile = false
    @State var showProfileButton = true
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    
    var body: some View {
        if showProfileButton {
            HStack {
                Spacer()
                Button(action: {
                    showProfile = true
                }) {
                    SmallUserImage()
                }.fullScreenCover(isPresented: $showProfile, content: {
                    ProfileView(signedOut: $signedOut)
                })
            }
        }
        NavigationView {
            List () {
                ForEach(places.places) { place in
                    NavigationLink(destination: PlaceDetailsView(place: place, showProfileButton: $showProfileButton)) {
                        //Text("place (place.name)")
                        RowView(place: place)
                    }
                }
            }
            .navigationTitle("Mushroom place")
        }
    }
}

struct RowView : View {
    var place: Place
    
        var body: some View {
            Text(place.name)
        }
    
}

//struct ListOfPlacesView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListOfPlacesView()
//    }
//}
