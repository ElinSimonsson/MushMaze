//
//  PlaceDetailsView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-31.
//

import SwiftUI

struct PlaceDetailsView: View {
    var place : Place
    @EnvironmentObject var userModel : UserModel
    @State var createrFullName = ""
    @State var createrImageURL = ""
   
    
    @Binding var isHeaderVisible : Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack{
                CreaterRowView(place: place, fullName: $createrFullName, imageURL: $createrImageURL)
                PlaceName(placeName: place.name)
                PlaceImage(imageURL: place.imageURL)
                if let description = place.description {
                    DescriptionContent(description: description)
                }
                MushroomSubTitle()
                if let mushrooms = place.mushrooms {
                    ForEach(mushrooms, id: \.self) { mushroom in
                        MushroomSpeciesRowView(mushroom: mushroom)
                    }
                }
            }
            .onAppear() {
                isHeaderVisible = false
                fetchCreaterInfo(place: place)
            }
        }
        
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
    }
    
    
    func fetchCreaterInfo (place : Place) {
        let id = place.createrUID
        
        userModel.fetchUserInfo(userID: id) {(url, name, error) in
            if let error = error {
                print("error fetching creater info \(error)")
            }
            if let url = url {
               createrImageURL = url
            }
            if let name = name {
                createrFullName = name
            }
        }
    }
}

struct MushroomSpeciesRowView : View {
    let mushroom : String
    
    var body: some View {
        HStack {
            Spacer().frame(maxWidth: 15)
            Text("* \(mushroom)")
                .padding(.bottom, 5)
            Spacer()
        }
        
    }
}

struct MushroomSubTitle : View {
    var body: some View {
        HStack {
            Spacer().frame(maxWidth: 15)
            Text("Mushroom founded here:")
                .fontWeight(.bold)
    
            Spacer()
        }
        .padding(.top, 15)
        .padding(.bottom, 10)
    }
}

struct DescriptionContent : View {
    let description : String
    
    var body: some View {
        HStack {
            Spacer().frame(maxWidth: 15)
            Text(description)
            Spacer().frame(maxWidth: 15)
        }
        .padding(.top, 10)
    }
}

struct PlaceImage : View {
    let imageURL : String
    
    var body: some View {
        
        HStack {
            AsyncImage(url: URL(string: imageURL),
                       content:  { image in
                image
                    .resizable()
                    .scaledToFill()
                
            },
                       placeholder: {ProgressView()}
            )
            .aspectRatio(contentMode: .fit)
            .frame(width: UIScreen.main.bounds.size.width - 10, height: 250)
        }

    }
    
}

struct PlaceName : View {
    let placeName : String
    
    var body: some View {
        HStack {
            Text(placeName)
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 20)
        }
    }
}

struct SmallCreaterImage : View {
    @EnvironmentObject var userModel : UserModel
    @Binding var imageURL : String
    
    var body: some View {
        
        AsyncImage(url: URL(string: imageURL),
                   content:  { image in
            image
                .resizable()
                .scaledToFit()
            
        },
                   placeholder: {ProgressView()}
        )
        .aspectRatio(contentMode: .fill)
        .frame(width: 50, height: 50)
        .clipShape(Circle())
    }
}

struct CreaterRowView : View {
    var place : Place
    @Binding var fullName : String
    @Binding var imageURL : String
    
    var date : String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: place.date)
    }
    
    var body : some View {
            HStack {
                Spacer().frame(maxWidth: 10)
               SmallCreaterImage(imageURL: $imageURL)
                Spacer().frame(maxWidth: 10)
                Text(fullName)
                Spacer()
                Text(date)
                Spacer().frame(maxWidth: 10)
            }
            .padding(.top, 20)
    }
}


