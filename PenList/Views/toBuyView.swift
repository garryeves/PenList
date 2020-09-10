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
    
    @Published var showModalDisplayType = pickerComms()
    @Published var rememberedIntDisplayType = -1
    @Published var showDisplayTypePicker = false
    
    @Published var showModalType = pickerComms()
    @Published var rememberedIntType = -1
    @Published var showTypePicker = false
    
    @Published var showModalStatus = pickerComms()
    @Published var rememberedIntStatus = -1
    @Published var showStatusPicker = false
    
    @Published var showModalManufacturer = pickerComms()
    @Published var rememberedIntManufacturer = -1
    @Published var showManufacturerPicker = false
    
    @Published var reload = false
    
    var manID = ""
    
    var displayType = ""
    
    func add() {
        let temp = toBuy()
        workingItem = temp
    }
    
    func save() {
        if manID != "" {
            workingItem.manID = manID
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
        
        if tempVars.rememberedIntDisplayType > -1 {
            if tempVars.rememberedIntDisplayType == 0 {
                tempVars.displayType = ""
            } else {
                tempVars.displayType = toBuyType[tempVars.rememberedIntDisplayType - 1]
                tempVars.rememberedIntDisplayType = -1
            }
        }
        
        var displayList = self.tempVars.tobuyList.toBuyGroup
        
        if tempVars.displayType != "" {
            typeText = tempVars.displayType
            displayList = self.tempVars.tobuyList.toBuyGroup.filter {$0.type == typeText}
        }
        
        return VStack {
            HStack {
                Text("Filter by")
                
                Button(typeText) {
                    self.tempVars.rememberedIntDisplayType = -1
                    self.tempVars.showModalDisplayType.displayList.removeAll()
                    self.tempVars.showModalDisplayType.displayList.append(displayEntry(entryText: ""))
                    
                    for item in toBuyType {
                        self.tempVars.showModalDisplayType.displayList.append(displayEntry(entryText: item))
                    }
                    
                    self.tempVars.showDisplayTypePicker = true
                }
                .sheet(isPresented: self.$tempVars.showDisplayTypePicker, onDismiss: { self.tempVars.showDisplayTypePicker = false }) {
                    pickerView(displayTitle: "Select Purchase Type", rememberedInt: self.$tempVars.rememberedIntDisplayType, showPicker: self.$tempVars.showDisplayTypePicker, showModal: self.$tempVars.showModalDisplayType)
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
                                                    
                                                    Button("Details") {
                                                        self.tempVars.workingItem = item
                                                        self.showEdit = true
                                                    }
                                                    .padding(.bottom,5)

                                                    HStack {
                                                        Spacer()
                                                        
                                                        Button("Mark as Bought") {
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
                                                        }
                                                        
                                                        Spacer()

                                                        Button("Remove") {
                                                            self.tempVars.delete(item)
                                                            self.tempVars.tobuyList = toBuys()
                                                            self.tempVars.reload.toggle()
                                                        }
                                                        
                                                        Spacer()
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
