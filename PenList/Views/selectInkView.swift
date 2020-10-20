//
//  selectInkView.swift
//  PenList
//
//  Created by Garry Eves on 28/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class selectInkDetailsWorkingVariables: ObservableObject {

    @Published var reload = false
        
    @Published var selectedManufacturer = manufacturer()
    @Published var selectedInk = ink()
    
    var setManufacturer : manufacturer {
        get {
            return selectedManufacturer
        }
        set {
            selectedManufacturer = newValue
            loadPotentialInks()
            reload.toggle()
        }
    }
    
    var setInk : ink {
        get {
            return selectedInk
        }
        set {
            selectedInk = newValue
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
        
    var potentialInks: [ink] = Array()
    
    var noInkSelected = false
    
    func loadPotentialInks() {
        potentialInks = inkList.inks.filter { $0.manID == selectedManufacturer.manID.uuidString }
    }
}

struct selectInkView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    
    @Binding var showChild: Bool

    @ObservedObject var tempVars = selectInkDetailsWorkingVariables()
    
    var body: some View {
        
        UITableView.appearance().separatorStyle = .none
            
        var penText = "Select"
        
        if tempVars.selectedInk.name != "" {
            penText = tempVars.selectedInk.name
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
            
            if tempVars.potentialInks.count > 0 {
                HStack {
                    Text("Ink")
                    
                    if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                        Menu(penText) {
                            ForEach (self.tempVars.potentialInks, id: \.self) { item in
                                Button(item.name) {
                                    tempVars.setInk = item
                                    tempVars.reload.toggle()
                                }
                            }
                        }
                    } else {
                        Picker("", selection: $tempVars.setInk) {
                            ForEach (self.tempVars.potentialInks, id: \.self) { item in
                                Text(item.name)
                            }
                        }
                    }
                }
                .padding()
            }
            
            if tempVars.selectedInk.name != "" {
                Button("Add Ink To My Collection") {
                    self.workingVariables.selectedMyInk.inkID = self.tempVars.selectedInk.inkID.uuidString
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

