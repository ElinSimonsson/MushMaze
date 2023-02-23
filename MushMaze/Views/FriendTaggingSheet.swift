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
    
    var isButtonDisabled: Bool {
        friends.taggedFriends.isEmpty
    }
    
    var body: some View {
        HStack {
            Text("Notify your friends")
                .font(.largeTitle)
                .bold()
        }
        .onDisappear() {
            friends.taggedFriends.removeAll()
        }
        .padding(.top, 30)
        List {
            ForEach (friends.friends) { friend in
                FriendTaggingRowView(friend: friend)
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
                guard let placeId = place.id else {return}
                friends.sendTagNotification(placeId: placeId)
            }) {
                SendButtonContent(isButtonDisabled: isButtonDisabled)
            }
            .disabled(isButtonDisabled)
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

struct FriendTaggingRowView : View {
    @EnvironmentObject var friends : Friends
    let friend : Friend
    
    var body: some View {
        HStack {
            Spacer().frame(maxWidth: 10)
            if friend.imageURL != "" {
                ProfileImageFromURL(imageURL: friend.imageURL)
            } else {
                DefaultProfileImage()
            }
            
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
}

struct SendButtonContent : View {
    let fernGreen = Color(red: 113/255, green: 188/255, blue: 120/255)
    let disabledGray = Color.gray.opacity(0.5)
    let isButtonDisabled : Bool
    var body: some View {
        Text("Send")
            .font(.title3)
            .foregroundColor(.black)
            .padding()
            .frame(width: 220, height: 60)
            .background(isButtonDisabled ? disabledGray : fernGreen)
            .cornerRadius(15.0)
    }
}

//struct FriendTaggingSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendTaggingSheet()
//    }
//}
