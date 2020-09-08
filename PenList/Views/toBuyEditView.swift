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
    @ObservedObject var kbDetails = KeyboardResponder()
    @Binding var showChild: Bool
    
    @State var reload = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        var typeText = "Select type"
        var typeStatus = "Select Status"
        var manufacturerText = "Select Manufacturer"
        
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
            tempVars.workingItem.manufacturer = manufacturerList.manufacturers[tempVars.rememberedIntManufacturer].name
            tempVars.rememberedIntManufacturer = -1
        }

        if tempVars.workingItem.manufacturer != "" {
            manufacturerText = tempVars.workingItem.manufacturer
        }
        
        var borderColour = Color.black
        
        if colorScheme == .dark {
            borderColour = Color.white
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
                    
            Form {
                Text(typeText)
                    .foregroundColor(.blue)
                    .onTapGesture {
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
                
                if tempVars.workingItem.type != "" {
                    Text(manufacturerText)
                        .foregroundColor(.blue)
                        .onTapGesture {
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
                    
                    if tempVars.workingItem.manufacturer != "" && tempVars.workingItem.manufacturer != "No Manufacturer" {
                        
                        TextField("Name", text: $tempVars.workingItem.name, onEditingChanged: { _ in self.reload.toggle()})
                            
                        TextField("Where From", text: $tempVars.workingItem.whereFrom)
                          
                        TextField("Cost", text: $tempVars.workingItem.cost)
                        
                        Text(typeStatus)
                            .foregroundColor(.blue)
                            .onTapGesture {
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
                        
                    }
                }
            }
            .frame(height: 300)
            
            if tempVars.workingItem.manufacturer != "" && tempVars.workingItem.manufacturer != "No Manufacturer" {
                Text("Notes")
                    .font(.headline)
                    .padding(.bottom, 5)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)

                GeometryReader { geometry in
                    TextEditor(text: $tempVars.workingItem.notes)
                        .border(borderColour, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                        .frame(width: geometry.size.width - 40, alignment: .center)
                        .padding()
                }
                
                Button("Save") {
                    self.tempVars.save()
                    self.tempVars.tobuyList = toBuys()
                }
                .padding(.bottom, 10)
            }
                    
            Spacer()
        }
        .padding(.bottom, kbDetails.currentHeight)
    }
}

