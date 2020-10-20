//
//  toBuyView.swift
//  PenList
//
//  Created by Garry Eves on 19/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

let tobuyPen = "Pen"
let toBuyInk = "Ink"
let toBuyNotebook = "Notebook"
let toBuyOther = "Other"

let toBuyType = [tobuyPen, toBuyInk, toBuyNotebook, toBuyOther]

let toBuyStatusPlanned = "Planned"
let toBuyStatusOrdered = "Ordered"
let toBuyStatusBought = "Bought"

let toBuyStatus = [toBuyStatusPlanned, toBuyStatusOrdered, toBuyStatusBought]

class myToBuyWorkingVariables: ObservableObject {

    var tobuyList = toBuys()
    var workingItem: toBuy!
    
    @Published var reload = false
    
    @Published var selectedManufacturer = manufacturer()
    
    @Published var status = toBuyStatusPlanned
    @Published var type = ""
    
    var setType: String {
        get {
            return type
        }
        set {
            type = newValue
            workingItem.type = type
            reload.toggle()
        }
    }
    
    var setStatus: String {
        get {
            return status
        }
        set {
            status = newValue
            workingItem.status = status
            reload.toggle()
        }
    }
    
    
    var setManufacturer : manufacturer {
        get {
            return selectedManufacturer
        }
        set {
            selectedManufacturer = newValue
            workingItem.manufacturer = selectedManufacturer.name
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
    
    @Published var displayType = ""
    
    func add() {
        let temp = toBuy()
        workingItem = temp
    }
    
    func save() {
        if selectedManufacturer.name != "" {
            workingItem.manID = selectedManufacturer.manID.uuidString
        }
        workingItem.save()
        
        sleep(2)
        
        tobuyList = toBuys()
    }
    
    func delete(_ item: toBuy) {
        item.delete()
        sleep(2)
        
        tobuyList = toBuys()
    }

}

struct toBuyView: View {
    @ObservedObject var tempVars = myToBuyWorkingVariables()
    @ObservedObject var kbDetails = KeyboardResponder()
    
    @State var showEdit = false
    
    var body: some View {
        UITableView.appearance().separatorStyle = .singleLine
        
        let columnWidth = 300
        
        var typeText = "Select type"
        
        var displayList = self.tempVars.tobuyList.toBuyGroup
        
        if tempVars.displayType != "" {
            typeText = tempVars.displayType
            displayList = self.tempVars.tobuyList.toBuyGroup.filter {$0.type == typeText}
        }
        
        return VStack {
            HStack {
                Text("Filter by")
                
                if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                    Menu(typeText) {
                        ForEach (toBuyType, id: \.self) { item in
                            Button(item) {
                                tempVars.displayType = item
                                tempVars.reload.toggle()
                            }
                        }
                    }
                } else {
                    Picker("", selection: $tempVars.displayType) {
                        ForEach (toBuyType, id: \.self) { item in
                            Text(item)
                        }
                    }
                }
            }
            .padding(.top, 15)
            
            GeometryReader { geometry in
                if manufacturerList.manufacturers.count > 0 {
                    VStack {
                        ScrollView {
                            ForEach (displayList) {topLevel in
                                Text(topLevel.type).font(.largeTitle)
                                    .padding(.top, 5)
                                    .padding(.bottom, 5)
                            
                                ForEach (topLevel.toBuys) { manuf in
                                    Text(manuf.manufacturer).font(.title)
                                
                                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: (Int(geometry.size.width) - 40) / columnWidth)) {
                                        ForEach (manuf.toBuys) {item in
                                            ZStack {
                                                Rectangle()
                                                    .fill(fillColour)
                                                    .cornerRadius(10.0)

                                                VStack {
                                                    Text(item.name)
                                                        .padding(.top,15)
                                                        .padding(.bottom,5)

                                                    if item.cost != "" {
                                                        Text(item.cost)
                                                            .padding(.bottom,5)
                                                    }
                                                    
                                                    Menu("Action to take") {
                                                        Button("Details", action: {
                                                            self.tempVars.workingItem = item
                                                            self.tempVars.type = item.type
                                                            self.tempVars.status = item.status
                                                            self.tempVars.selectedManufacturer = item.manufacturerRecord!
                                                            self.showEdit = true
                                                        })
                                                        
                                                        Button("Mark as Bought", action: {
                                                            item.status = toBuyStatusBought
                                                            item.save()
                                                        
                                                            // now we need to create the item in the correct table
                                                            
                                                            switch item.type {
                                                                case tobuyPen:
                                                                    let tempPen = pen()
                                                                    
                                                                    tempPen.newPen(passedname: item.name, passedmanID: item.manID, passednotes: item.notes)
                                                                
                                                                    sleep(2)
                                                                    
                                                                    penList = pens()
                                                                    currentPenList = myPens()
                                                                
                                                                case toBuyInk:
                                                                    let tempInk = ink()
                                                                        
                                                                    tempInk.newInk(passedmanID: item.manID, passedname: item.name, passednotes: item.notes)
                                                                    
                                                                    sleep(2)
                                                                  
                                                                    inkList = inks()
                                                                    currentInkList = myInks()
                                                                
                                                                case toBuyNotebook:
                                                                    print("At the momnt we don't do anything with Notebooks")
                                                                
                                                                default:
                                                                    print("At the momnt we don't do anything with Other")
                                                            }
                                                            
                                                            self.tempVars.tobuyList = toBuys()
                                                            self.tempVars.reload.toggle()
                                                        })
                                                        
                                                        Button("Remove", action: {
                                                            self.tempVars.delete(item)
                                                            self.tempVars.tobuyList = toBuys()
                                                            self.tempVars.reload.toggle()
                                                        })
                                                        
                                                    }
                                                    .padding(.leading, 15)
                                                    .padding(.trailing, 15)
                                                    .padding(.bottom, 15)
                                                }
                                            }
                                            .frame(width: CGFloat(columnWidth), alignment: .center)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Button("Add") {
                            self.tempVars.add()
                            self.showEdit = true
                        }
                        .padding()
                        .sheet(isPresented: self.$showEdit, onDismiss: { self.showEdit = false }) {
                            toBuyEditView(tempVars: self.tempVars, showChild: self.$showEdit)
                            }
                    }
                } else {
                    Spacer()
                    Text("You must create a Manufaturer first")
                        .font(.largeTitle)
                    Spacer()
                }
            }
        }
    }
}
