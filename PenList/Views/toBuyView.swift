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
    var manufacturerName = ""
    
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

}

struct toBuyView: View {
    @Binding var showChild: Bool
    
    @ObservedObject var tempVars = myToBuyWorkingVariables()
    
    @State var showEdit = false
    
    var body: some View {
        UITableView.appearance().separatorStyle = .singleLine
        return VStack {
            HStack {
                Spacer()
                Text("Items To Buy")
                    .font(.title)
                Spacer()
                
                Button("Close") {
                    self.showChild = false
                }
            }
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 15)
            
            List {
                ForEach (self.tempVars.tobuyList.toBuyList) {item in
                    VStack (alignment: .leading){
                        HStack {
                            Text(item.manufacturer)
                                .frame(width: 150, alignment: .leading)
                            
                            Text(item.name)
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        
                        HStack {
                            Text(item.type)
                                .frame(width: 150, alignment: .leading)

                            Text(item.cost)
                            
                            Spacer()
                        }
                    }
                    .onTapGesture {
                        self.tempVars.workingItem = item
                        self.showEdit = true
                    }
                }
            }
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
    }
}
