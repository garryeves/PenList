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
  //  @Binding var showChild: Bool
    
    @ObservedObject var tempVars = myToBuyWorkingVariables()
    @ObservedObject var kbDetails = KeyboardResponder()
    
    @State var showEdit = false
    
    var body: some View {
        UITableView.appearance().separatorStyle = .singleLine
        
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
//            HStack {
//                Spacer()
//                Text("Items To Buy")
//                    .font(.title)
//                Spacer()
//                
//                Button("Close") {
//                    self.showChild = false
//                }
//            }
//            .padding(.bottom, 10)
//            .padding(.leading, 20)
//            .padding(.trailing, 20)
//            .padding(.top, 15)
//            
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
                .padding(.trailing, 30)
                .sheet(isPresented: self.$tempVars.showDisplayTypePicker, onDismiss: { self.tempVars.showDisplayTypePicker = false }) {
                    pickerView(displayTitle: "Select Purchase Type", rememberedInt: self.$tempVars.rememberedIntDisplayType, showPicker: self.$tempVars.showDisplayTypePicker, showModal: self.$tempVars.showModalDisplayType)
                            }
            }
 // What I want to do is group by type then manufacturer and display nicer
            List {
                ForEach (displayList) {topLevel in
                    Section(header: HStack {Spacer()
                                            Text(topLevel.type).font(.title)
                                            Spacer() }) {
                        ForEach (topLevel.toBuys) { manuf in
                            Section(header: HStack {Spacer()
                                Text(manuf.manufacturer).font(.headline)
                                                    Spacer() }) {
                                ForEach (manuf.toBuys) { item in
                                    VStack (alignment: .leading){
                                        HStack {
                                            Text(item.name)
                                            Spacer()
                                            Text(item.cost)
                                        }
                                        .padding(.bottom, 5)
                                    }
                                    .contextMenu {
                                        Button("Details") {
                                            self.tempVars.workingItem = item
                                            self.showEdit = true
                                        }
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
                                        Button("Remove") {
                                            self.tempVars.delete(item)
                                            self.tempVars.tobuyList = toBuys()
                                            self.tempVars.reload.toggle()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
            Button("Add") {
                self.tempVars.add()
                self.showEdit = true
            }
            .sheet(isPresented: self.$showEdit, onDismiss: { self.showEdit = false }) {
                toBuyEditView(tempVars: self.tempVars, showChild: self.$showEdit)
                }

            Spacer()
        }
        .padding(.bottom, kbDetails.currentHeight)
    }
}
