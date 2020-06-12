//
//  pickerView.swift
//  evesShared
//
//  Created by Garry Eves on 13/7/19.
//  Copyright © 2019 Garry Eves. All rights reserved.
//

import SwiftUI

struct displayEntry: Identifiable, Hashable {
    let id = UUID()
    
    var entryText: String
//    var entryLine: Int = 0
}

class pickerComms: ObservableObject, Identifiable {
  //  public init() {}
    
    let id = UUID()
    @Published var reloadFlag = false
    
    var displayList: [displayEntry] = Array()
    var type: String = ""
    var selectedItem = 0
    
}

struct pickerView : View {
    var displayTitle: String
    @Binding var rememberedInt: Int
    @Binding var showPicker: Bool
    @Binding var showModal: pickerComms

    @State var selectedItem = 0
    
    var body: some View {
        if selectedItem > showModal.displayList.count {
            selectedItem = 0
        }
        
        return VStack (alignment: .center) {
            Text(displayTitle)
                .font(.title)

            Picker(selection: $selectedItem, label: Text("")) {
                
                ForEach(0 ..< showModal.displayList.count) { item in
                    Text(self.showModal.displayList[item].entryText).tag(item)
                }
            }
            .padding()
            .frame(width: 200, height: 300, alignment: .center)
            
            Button("Select") {
                self.rememberedInt = self.selectedItem
                self.showPicker = false
                self.showModal.reloadFlag = true
            }
        }
    }
}
