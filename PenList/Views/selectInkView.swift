//
//  selectInkView.swift
//  PenList
//
//  Created by Garry Eves on 28/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class selectInkDetailsWorkingVariables: ObservableObject {
    var showModalManufacturer = pickerComms()
    var rememberedIntManufacturer = -1
    @Published var showManufacturerPicker = false
    
    var showModalInk = pickerComms()
    var rememberedIntInk = -1
    @Published var showInkPicker = false
        
    @Published var manID = ""
    var manufacturerName = ""
    @Published var inkID = ""
    var inkName = ""
    
    var potentialInks: [ink] = Array()
    
    var noInkSelected = false
    
    func loadPotentialInks() {
        potentialInks = inkList.inks.filter { $0.manID == manID }
    }
    
}

struct selectInkView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    
    @Binding var showChild: Bool

    @ObservedObject var tempVars = selectInkDetailsWorkingVariables()
    
    var body: some View {
        
        UITableView.appearance().separatorStyle = .none
        
        if tempVars.rememberedIntManufacturer > -1 {
            tempVars.manID = manufacturerList.manufacturers[tempVars.rememberedIntManufacturer].manID.uuidString
            tempVars.manufacturerName = manufacturerList.manufacturers[tempVars.rememberedIntManufacturer].name
            tempVars.rememberedIntManufacturer = -1
            tempVars.inkID = ""
            tempVars.inkName = ""
            tempVars.loadPotentialInks()
        }
        
        var manufacturerText = "Select"
        
        if tempVars.manufacturerName != "" {
            manufacturerText = tempVars.manufacturerName
        }
        
        if tempVars.rememberedIntInk > -1 {
            tempVars.inkID = tempVars.potentialInks[tempVars.rememberedIntInk].inkID.uuidString
            tempVars.inkName = tempVars.potentialInks[tempVars.rememberedIntInk].name
            tempVars.rememberedIntInk = -1
        }
        
        var penText = "Select"
        
        if tempVars.inkID != "" {
            penText = tempVars.inkName
        }
        
        return VStack {
            HStack {
                Spacer()
                Text("Select Ink")
                    .font(.title)
                Spacer()
                
                Button("Close") {
                    self.showChild = false
                    self.tempVars.noInkSelected = true
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
            
            if tempVars.potentialInks.count > 0 {
                HStack {
                    Text("Ink")
                    
                    Button(penText) {
                        self.tempVars.rememberedIntInk = -1
                        self.tempVars.showModalInk.displayList.removeAll()
                        
                        for item in self.tempVars.potentialInks {
                            self.tempVars.showModalInk.displayList.append(displayEntry(entryText: item.name))
                        }
                        
                        self.tempVars.showInkPicker = true
                    }
                    .padding()
                    .sheet(isPresented: self.$tempVars.showInkPicker, onDismiss: { self.tempVars.showInkPicker = false }) {
                        pickerView(displayTitle: "Select Ink", rememberedInt: self.$tempVars.rememberedIntInk, showPicker: self.$tempVars.showInkPicker, showModal: self.$tempVars.showModalInk)
                                }
                }
                
            }
            
            if tempVars.inkID != "" {
                Button("Add Ink To My Collection") {
                    self.workingVariables.selectedMyInk.inkID = self.tempVars.inkID
//                    self.workingVariables.selectedMyInk.name = self.tempVars.inkName
                    self.workingVariables.selectedMyInk.save()
                    currentInkList.append(self.workingVariables.selectedMyInk)
                    self.showChild = false
                }
                .padding()
            }
            
            Spacer()
        }
    }
}

