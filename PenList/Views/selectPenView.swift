//
//  selectPenView.swift
//  PenList
//
//  Created by Garry Eves on 22/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class selectPenDetailsWorkingVariables: ObservableObject {
    var showModalManufacturer = pickerComms()
    var rememberedIntManufacturer = -1
    @Published var showManufacturerPicker = false
    
    var showModalPen = pickerComms()
    var rememberedIntPen = -1
    @Published var showPenPicker = false
        
    @Published var manID = ""
    var manufacturerName = ""
    @Published var penID = ""
    var penName = ""
    
    var potentialPens: [pen] = Array()
    
    var noPenSelected = false
    
    func loadPotentialPens() {
        potentialPens = penList.pens.filter { $0.manID == manID }
    }
    
}


struct selectPenView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    
    @Binding var showChild: Bool

    @ObservedObject var tempVars = selectPenDetailsWorkingVariables()
    
    var body: some View {

        UITableView.appearance().separatorStyle = .none
        
        if tempVars.rememberedIntManufacturer > -1 {
            tempVars.manID = manufacturerList.manufacturers[tempVars.rememberedIntManufacturer].manID.uuidString
            tempVars.manufacturerName = manufacturerList.manufacturers[tempVars.rememberedIntManufacturer].name
            tempVars.rememberedIntManufacturer = -1
            tempVars.penID = ""
            tempVars.penName = ""
            tempVars.loadPotentialPens()
        }
        
        var manufacturerText = "Select"
        
        if tempVars.manufacturerName != "" {
            manufacturerText = tempVars.manufacturerName
        }
        
        if tempVars.rememberedIntPen > -1 {
            tempVars.penID = tempVars.potentialPens[tempVars.rememberedIntPen].penID.uuidString
            tempVars.penName = tempVars.potentialPens[tempVars.rememberedIntPen].name
            tempVars.rememberedIntPen = -1
        }
        
        var penText = "Select"
        
        if tempVars.penID != "" {
            penText = tempVars.penName
        }
        
        return VStack {
            HStack {
                Spacer()
                Text("Select Pen")
                    .font(.title)
                Spacer()
                
                Button("Close") {
                    self.showChild = false
                    self.tempVars.noPenSelected = true
                }
            }
            .padding()
        
            HStack {
                Text("Manufacturer")
                    .padding(.trailing, 10)
                Button(manufacturerText) {
                    self.tempVars.rememberedIntManufacturer = -1
                    self.tempVars.showModalManufacturer.displayList.removeAll()
                    
                    for item in manufacturerList.manufacturers {
                        self.tempVars.showModalManufacturer.displayList.append(displayEntry(entryText: item.name))
                    }
                    
                    self.tempVars.showManufacturerPicker = true
                }
                .sheet(isPresented: self.$tempVars.showManufacturerPicker, onDismiss: { self.tempVars.showManufacturerPicker = false }) {
                    pickerView(displayTitle: "Select Manufacturer", rememberedInt: self.$tempVars.rememberedIntManufacturer, showPicker: self.$tempVars.showManufacturerPicker, showModal: self.$tempVars.showModalManufacturer)
                            }
            }
            .padding()
            
            if tempVars.potentialPens.count > 0 {
                HStack {
                    Text("Pen")
                    
                    Button(penText) {
                        self.tempVars.rememberedIntPen = -1
                        self.tempVars.showModalPen.displayList.removeAll()
                        
                        for item in self.tempVars.potentialPens {
                            self.tempVars.showModalPen.displayList.append(displayEntry(entryText: item.name))
                        }
                        
                        self.tempVars.showPenPicker = true
                    }
                    .padding()
                    .sheet(isPresented: self.$tempVars.showPenPicker, onDismiss: { self.tempVars.showPenPicker = false }) {
                        pickerView(displayTitle: "Select Pen", rememberedInt: self.$tempVars.rememberedIntPen, showPicker: self.$tempVars.showPenPicker, showModal: self.$tempVars.showModalPen)
                                }
                }
                
            }
            
            if tempVars.penID != "" {
                Button("Add Pen To My Collection") {
                    self.workingVariables.selectedMyPen.penID = self.tempVars.penID
                    self.workingVariables.selectedMyPen.name = self.tempVars.penName
                    self.workingVariables.selectedMyPen.save()
                    currentPenList.append(self.workingVariables.selectedMyPen)
                    self.showChild = false
                }
            }
            
            Spacer()
        }
    }
}
