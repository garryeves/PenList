//
//  selectPenView.swift
//  PenList
//
//  Created by Garry Eves on 22/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class selectPenDetailsWorkingVariables: ObservableObject {

    @Published var reload = false

    @Published var selectedManufacturer = manufacturer()
    @Published var selectedPen = pen()
    
    var setManufacturer : manufacturer {
        get {
            return selectedManufacturer
        }
        set {
            selectedManufacturer = newValue
            loadPotentialPens()
            reload.toggle()
        }
    }
    
    var setPen : pen {
        get {
            return selectedPen
        }
        set {
            selectedPen = newValue
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
    
    var potentialPens: [pen] = Array()
    
    var noPenSelected = false
    
    func loadPotentialPens() {
        potentialPens = penList.pens.filter { $0.manID == selectedManufacturer.manID.uuidString }
    }
}


struct selectPenView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    
    @Binding var showChild: Bool

    @ObservedObject var tempVars = selectPenDetailsWorkingVariables()
    
    var body: some View {

        UITableView.appearance().separatorStyle = .none
        
        var penText = "Select"
        
        if tempVars.selectedPen.name != "" {
            penText = tempVars.selectedPen.name
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
            
            if tempVars.potentialPens.count > 0 {
                HStack {
                    Text("Pen")
                    
                    if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                        Menu(penText) {
                            ForEach (self.tempVars.potentialPens, id: \.self) { item in
                                Button(item.name) {
                                    tempVars.setPen = item
                                    tempVars.reload.toggle()
                                }
                            }
                        }
                    } else {
                        Picker("", selection: $tempVars.setPen) {
                            ForEach (self.tempVars.potentialPens, id: \.self) { item in
                                Text(item.name)
                            }
                        }
                    }
                }
            }
            
            if tempVars.selectedPen.name != "" {
                Button("Add Pen To My Collection") {
                    self.workingVariables.selectedMyPen.penID = self.tempVars.selectedPen.penID.uuidString
                    self.workingVariables.selectedMyPen.name = self.tempVars.selectedPen.name
                    self.workingVariables.selectedMyPen.save()
                    currentPenList.append(self.workingVariables.selectedMyPen)
                    self.showChild = false
                }
            }
            
            Spacer()
        }
    }
}
