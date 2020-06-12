//
//  inkDetails.swift
//  PenList
//
//  Created by Garry Eves on 22/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class inkDetailsWorkingVariables: ObservableObject {
    var showModalInkType = pickerComms()
    var rememberedIntInkType = -1
    @Published var showInkTypePicker = false
}

struct inkDetails: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @Binding var showChild: Bool
    
    @ObservedObject var tempVariables = inkDetailsWorkingVariables()
    
    var body: some View {
        
        UITableView.appearance().separatorStyle = .none
        
        
        if tempVariables.rememberedIntInkType > -1 {
            workingVariables.selectedInk.inkType = inkTypes[tempVariables.rememberedIntInkType]
            tempVariables.rememberedIntInkType = -1
        }
        
        var inkTypeText = "Select"
        
        if workingVariables.selectedInk.inkType != "" {
            inkTypeText = workingVariables.selectedInk.inkType
        }
        
        return VStack {
            HStack {
                Spacer()
                Text("Ink Details")
                    .font(.title)
                Spacer()
                
                Button("Close") {
                    self.showChild = false
                }
            }
            .padding()
            
            HStack {
                Text("Name")
                    .padding(.trailing, 10)
                
                TextField("Name", text: $workingVariables.selectedInk.name)
                
                Spacer()
            }
            .padding()
            
            HStack {
                Text("Ink Family")
                    .padding(.trailing, 10)
                
                TextField("Ink Family", text: $workingVariables.selectedInk.inkFamily)
                
                Spacer()
            }
            .padding()
            
            HStack {
                Text("Type")
                    .padding(.trailing, 10)
                
                Button(inkTypeText) {
                    self.tempVariables.rememberedIntInkType = -1
                    self.tempVariables.showModalInkType.displayList.removeAll()
                    
                    for item in inkTypes {
                        self.tempVariables.showModalInkType.displayList.append(displayEntry(entryText: item))
                    }
                    
                    self.tempVariables.showInkTypePicker = true
                }
                .sheet(isPresented: self.$tempVariables.showInkTypePicker, onDismiss: { self.tempVariables.showInkTypePicker = false }) {
                    pickerView(displayTitle: "Select Filling System", rememberedInt: self.$tempVariables.rememberedIntInkType, showPicker: self.$tempVariables.showInkTypePicker, showModal: self.$tempVariables.showModalInkType)
                            }
                
                Spacer()
            }
            .padding()
            
            HStack {
                Text("Colour")
                    .padding(.trailing, 10)
                
                TextField("Colour", text: $workingVariables.selectedInk.colour)
                
                Spacer()
            }
            .padding()
            
            HStack {
                Text("Notes")
                    .padding(.trailing, 10)
                
                TextView(text: $workingVariables.selectedInk.notes)
                .padding()
                
                Spacer()
            }
            .padding()
            
            Button("Save") {
                if self.workingVariables.selectedInk.isNew {
                    inkList.append(self.workingVariables.selectedInk)
                    self.workingVariables.selectedInk.isNew = false
                }
                self.workingVariables.selectedInk.save()
            }
            
            
            Spacer()
        }
    }
}
