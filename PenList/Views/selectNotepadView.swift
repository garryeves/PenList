//
//  selectNotepadView.swift
//  PenList
//
//  Created by Garry Eves on 12/7/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class selectNotepadDetailsWorkingVariables: ObservableObject {

    @Published var reload = false

    @Published var selectedManufacturer = manufacturer()
    
    var setManufacturer : manufacturer {
        get {
            return selectedManufacturer
        }
        set {
            selectedManufacturer = newValue
            loadPotentialNotepads()
            selectedNotepad = notepad()
            reload.toggle()
        }
    }
    
    func manufacturerName() -> String {
        if selectedManufacturer.name != "" {
            let temp = manufacturerList.manufacturers.filter { $0.manID == selectedManufacturer.manID }
            
            if temp.count > 0 {
                return temp[0].name
            }
        }
        
        return "Select"
    }
    
    
    @Published var selectedNotepad = notepad()
    
    var setNotepad : notepad {
        get {
            return selectedNotepad
        }
        set {
            selectedNotepad = newValue
            reload.toggle()
        }
    }
    
    
    var potentialNotepads: [notepad] = Array()
    
    var noNotepadSelected = false
    
    func loadPotentialNotepads() {
        potentialNotepads = notepadList.notepads.filter { $0.manID == selectedNotepad.manID }
    }
    
}

struct selectNotepadView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    
    @Binding var showChild: Bool

    @ObservedObject var tempVars = selectNotepadDetailsWorkingVariables()
    
    var body: some View {
        
        UITableView.appearance().separatorStyle = .none
        
        var notePadText = "Select"
        
        if tempVars.selectedNotepad.name != "" {
            notePadText = tempVars.selectedNotepad.name
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
                
                if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                    Menu(tempVars.manufacturerName()) {
                        ForEach (manufacturerList.manufacturers, id: \.self) { item in
                            Button(item.name) {
                                tempVars.setManufacturer = item
                                tempVars.reload.toggle()
                            }
                        }
                    }
                } else {
                    Picker("", selection: $tempVars.setManufacturer) {
                        ForEach (manufacturerList.manufacturers, id: \.self) { item in
                            Text(item.name)
                        }
                    }
                }

            }
            .padding()
            
            if tempVars.potentialNotepads.count > 0 {
                HStack {
                    Text("Ink")
                    
                    if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                        Menu(notePadText) {
                            ForEach (self.tempVars.potentialNotepads, id: \.self) { item in
                                Button(item.name) {
                                    tempVars.setNotepad = item
                                }
                            }
                        }
                    } else {
                        Picker("", selection: $tempVars.setNotepad) {
                            ForEach (self.tempVars.potentialNotepads, id: \.self) { item in
                                Text(item.name)
                            }
                        }
                    }
                }
            }
            
            if tempVars.selectedNotepad.name != "" {
                Button("Add Ink To My Collection") {
                    self.workingVariables.selectedMyNotepad.notepadID = self.tempVars.selectedNotepad.notepadID.uuidString
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
