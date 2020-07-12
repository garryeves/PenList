//
//  selectNotepadView.swift
//  PenList
//
//  Created by Garry Eves on 12/7/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class selectNotepadDetailsWorkingVariables: ObservableObject {
    var showModalManufacturer = pickerComms()
    var rememberedIntManufacturer = -1
    @Published var showManufacturerPicker = false
    
    var showModalNotepad = pickerComms()
    var rememberedIntNotepad = -1
    @Published var showNotepadPicker = false
        
    @Published var manID = ""
    var manufacturerName = ""
    @Published var notepadID = ""
    var notepadName = ""
    
    var potentialNotepads: [notepad] = Array()
    
    var noNotepadSelected = false
    
    func loadPotentialNotepads() {
        potentialNotepads = notepadList.notepads.filter { $0.manID == manID }
    }
    
}

struct selectNotepadView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    
    @Binding var showChild: Bool

    @ObservedObject var tempVars = selectNotepadDetailsWorkingVariables()
    
    var body: some View {
        
        UITableView.appearance().separatorStyle = .none
        
        if tempVars.rememberedIntManufacturer > -1 {
            tempVars.manID = manufacturerList.manufacturers[tempVars.rememberedIntManufacturer].manID.uuidString
            tempVars.manufacturerName = manufacturerList.manufacturers[tempVars.rememberedIntManufacturer].name
            tempVars.rememberedIntManufacturer = -1
            tempVars.notepadID = ""
            tempVars.notepadName = ""
            tempVars.loadPotentialNotepads()
        }
        
        var manufacturerText = "Select"
        
        if tempVars.manufacturerName != "" {
            manufacturerText = tempVars.manufacturerName
        }
        
        if tempVars.rememberedIntNotepad > -1 {
            tempVars.notepadID = tempVars.potentialNotepads[tempVars.rememberedIntNotepad].notepadID.uuidString
            tempVars.notepadName = tempVars.potentialNotepads[tempVars.rememberedIntNotepad].name
            tempVars.rememberedIntNotepad = -1
        }
        
        var notePadText = "Select"
        
        if tempVars.notepadID != "" {
            notePadText = tempVars.notepadName
        }
        
        return VStack {
            HStack {
                Spacer()
                Text("Select Notepad")
                    .font(.title)
                Spacer()
                
                Button("Close") {
                    self.showChild = false
                    self.tempVars.noNotepadSelected = true
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
            
            if tempVars.potentialNotepads.count > 0 {
                HStack {
                    Text("Ink")
                    
                    Button(notePadText) {
                        self.tempVars.rememberedIntNotepad = -1
                        self.tempVars.showModalNotepad.displayList.removeAll()
                        
                        for item in self.tempVars.potentialNotepads {
                            self.tempVars.showModalNotepad.displayList.append(displayEntry(entryText: item.name))
                        }
                        
                        self.tempVars.showNotepadPicker = true
                    }
                    .padding()
                    .sheet(isPresented: self.$tempVars.showNotepadPicker, onDismiss: { self.tempVars.showNotepadPicker = false }) {
                        pickerView(displayTitle: "Select Notepad", rememberedInt: self.$tempVars.rememberedIntNotepad, showPicker: self.$tempVars.showNotepadPicker, showModal: self.$tempVars.showModalNotepad)
                                }
                }
                
            }
            
            if tempVars.notepadID != "" {
                Button("Add Ink To My Collection") {
                    self.workingVariables.selectedMyNotepad.notepadID = self.tempVars.notepadID//                    self.workingVariables.selectedMyInk.name = self.tempVars.inkName
                    self.workingVariables.selectedMyNotepad.save()
                    currentNotepadList.append(self.workingVariables.selectedMyNotepad)
                    self.showChild = false
                }
                .padding()
            }
            
            Spacer()
        }
    }
}
