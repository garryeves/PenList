//
//  toBuyEditView.swift
//  PenList
//
//  Created by Garry Eves on 19/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct toBuyEditView: View {
    @ObservedObject var tempVars: myToBuyWorkingVariables
    @Binding var showChild: Bool
    
    @State var reload = false
    
    var body: some View {
        var typeText = "Select type"
        var typeStatus = "Select Status"
        var manufacturerText = "Select"
        
        if tempVars.rememberedIntType > -1 {
            tempVars.workingItem.type = toBuyType[tempVars.rememberedIntType]
            tempVars.rememberedIntType = -1
        }
        
        if tempVars.workingItem.type != "" {
            typeText = tempVars.workingItem.type
        }
        
        if tempVars.rememberedIntStatus > -1 {
            tempVars.workingItem.status = toBuyStatus[tempVars.rememberedIntStatus]
            tempVars.rememberedIntStatus = -1
        }
        
        if tempVars.workingItem.status != "" {
            typeStatus = tempVars.workingItem.status
        }
        
        if tempVars.rememberedIntManufacturer > -1 {
            tempVars.manID = manufacturerList.manufacturers[tempVars.rememberedIntManufacturer].manID.uuidString
            tempVars.manufacturerName = manufacturerList.manufacturers[tempVars.rememberedIntManufacturer].name
            tempVars.rememberedIntManufacturer = -1
        }
        
        if tempVars.manufacturerName != "" {
            manufacturerText = tempVars.manufacturerName
        }

        return VStack {
            HStack {
                Spacer()
                Text("Edit Item")
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
                    
            HStack {
                Button(typeText) {
                    self.tempVars.rememberedIntType = -1
                    self.tempVars.showModalType.displayList.removeAll()
                    
                    for item in toBuyType {
                        self.tempVars.showModalType.displayList.append(displayEntry(entryText: item))
                    }
                    
                    self.tempVars.showTypePicker = true
                }
                .padding(.trailing, 30)
                .sheet(isPresented: self.$tempVars.showTypePicker, onDismiss: { self.tempVars.showTypePicker = false }) {
                    pickerView(displayTitle: "Select Purchase Type", rememberedInt: self.$tempVars.rememberedIntType, showPicker: self.$tempVars.showTypePicker, showModal: self.$tempVars.showModalType)
                            }
                
                Text("Status")
                .padding(.trailing, 10)
                
                Button(typeStatus) {
                    self.tempVars.rememberedIntStatus = -1
                    self.tempVars.showModalStatus.displayList.removeAll()
                    
                    for item in toBuyStatus {
                        self.tempVars.showModalStatus.displayList.append(displayEntry(entryText: item))
                    }
                    
                    self.tempVars.showStatusPicker = true
                }
                .sheet(isPresented: self.$tempVars.showStatusPicker, onDismiss: { self.tempVars.showStatusPicker = false }) {
                    pickerView(displayTitle: "Select Status", rememberedInt: self.$tempVars.rememberedIntStatus, showPicker: self.$tempVars.showStatusPicker, showModal: self.$tempVars.showModalStatus)
                            }
                
                Spacer()
            }
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
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
                Spacer()
            }
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
            HStack {
                Text("Name")
                TextField("Name", text: $tempVars.workingItem.name)
            }
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
            HStack {
                Text("Where From")
                TextField("Where From", text: $tempVars.workingItem.whereFrom)
                  
                Text("Cost")
                TextField("Cost", text: $tempVars.workingItem.cost)
            }
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
                    
            Text("Notes")
                .font(.headline)
                .padding(.bottom, 5)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                    
            TextView(text: $tempVars.workingItem.notes)
                .padding(.bottom, 10)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            HStack {
                Button("Save") {
                    self.tempVars.save()
                }
                
                Spacer()
                
                Button("Mark as Bought") {
                    self.tempVars.workingItem.status = toBuyStatusBought
                    self.tempVars.save()
                    self.tempVars.reload.toggle()
                }
            }
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
                    
            Spacer()
        }
    }
}

