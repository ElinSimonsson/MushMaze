//
//  FriendTaggingSheet.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-17.
//

import SwiftUI

struct FriendTaggingSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var friends: Friends
    @Binding var showIsSentPopUp : Bool
    var place : Place
    
    var body: some View {
        HStack {
            Text("Notify your friends")
                .font(.largeTitle)
                .bold()
        }
        .onDisappear() {
            print("disappear körs")
            friends.taggedFriends.removeAll()
        }
        .padding(.top, 30)
        List {
            ForEach (friends.friends) { friend in
                HStack {
                    Spacer().frame(maxWidth: 10)
                    SmallProfileImageView(imageURL: friend.imageURL)
                    Spacer().frame(maxWidth: 20)
                    Text("\(friend.firstName) \(friend.lastName)")
                        .bold()
                    Spacer()
                    
                    if friends.taggedFriends.contains(where: { $0.id == friend.id }) {
                        Image(systemName: "checkmark.circle")
                            .onTapGesture() {
                                friends.updateTaggedFriendsList(friend: friend)
                            }
                    } else {
                        Image(systemName: "circle")
                            .onTapGesture() {
                                friends.updateTaggedFriendsList(friend: friend)
                            }
                    }
                }
            }
            .listRowBackground(Color(.systemGray6))
        }
        .shadow(
            color: Color.gray.opacity(0.7),
            radius: 8,
            x: 0,
            y: 0
        )
        .scrollContentBackground(.hidden)
        HStack {
            Button(action: {
                print("knapp trycktes")
                guard let placeId = place.id else {return}
                friends.sendTagNotification(placeId: placeId)
            }) {
                SendButtonContent()
            }
            .onChange(of: friends.successSendTagging) { newVule in
                if friends.successSendTagging == true {
                    showIsSentPopUp = true
                    presentationMode.wrappedValue.dismiss()
                    friends.successSendTagging = false
                }
            }
        }
        .padding(.bottom, 30)
    }
}

struct SendButtonContent : View {
    let darkTurquoise = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    var body: some View {
        Text("Send")
            .font(.title3)
            .foregroundColor(.black)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color(darkTurquoise))
            .cornerRadius(15.0)
    }
}

//struct FriendTaggingSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendTaggingSheet()
//    }
//}
