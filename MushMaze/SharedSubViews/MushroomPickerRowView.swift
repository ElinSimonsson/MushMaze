//
//  MushroomPickerRowView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-02-21.
//

import SwiftUI

struct MushroomPickerRowView: View {
    let mushrooms = ["Chanterelle", "Funnel chanterelle" , "Champignons", "black trumpet", "Porcini", "Hedgehog Mushroom", "Bay Bolete"]
    let forestGreen = Color(red: 86/255, green: 158/255, blue: 105/255)
    @Binding var selectedMushrooms : [String]
    @State var selection = "Mushroom"
    
    @State private var selectedMushroomIndex = 0
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                Picker(selection: $selectedMushroomIndex, label: Text("")) {
                    ForEach(0 ..< mushrooms.count, id: \.self) { index in
                        Text(self.mushrooms[index]).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            Spacer()
            HStack {

                Button(action: {
                    let selectedMushroom = self.mushrooms[self.selectedMushroomIndex]
                    self.selectedMushrooms.append(selectedMushroom)
                    self.selectedMushroomIndex = 0 // reset the selection to the first item
                }) {
                    Text("Add")
                        .foregroundColor(.white)
                        .frame(width: 100, height: 40)
                        .background(forestGreen)
                        .cornerRadius(15)
                }
            }
            Spacer()
        }
        .padding(.bottom, 20)
    }
}

//struct MushroomPickerRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        MushroomPickerRowView(selectedMushrooms: <#T##Binding<[String]>#>)
//    }
//}
