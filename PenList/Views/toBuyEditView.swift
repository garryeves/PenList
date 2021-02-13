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
        
        if tempVars.type != "" {
            typeText = tempVars.type
        }
        
        if tempVars.status != "" {
            typeStatus = tempVars.status
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
                if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                    Menu(typeText) {
                        ForEach (toBuyType, id: \.self) { item in
                            Button(item) {
                                tempVars.setType = item
                            }
                        }
                    }
                } else {
                    Picker("", selection: $tempVars.setType) {
                        ForEach (toBuyType, id: \.self) { item in
                            Text(item)
                        }
                    }
                }
                
                if tempVars.workingItem.type != "" {
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
                    
                    if tempVars.workingItem.manufacturer != "" && tempVars.workingItem.manufacturer != "No Manufacturer" {
                        
                        TextField("Name", text: $tempVars.workingItem.name, onEditingChanged: { _ in self.reload.toggle()})
                            
                        TextField("Where From", text: $tempVars.workingItem.whereFrom)
                          
                        TextField("Cost", text: $tempVars.workingItem.cost)
                        
                        
                        if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                            Menu(typeStatus) {
                                ForEach (toBuyStatus, id: \.self) { item in
                                    Button(item) {
                                        tempVars.setStatus = item
                                        tempVars.reload.toggle()
                                    }
                                }
                            }
                        } else {
                            Picker("", selection: $tempVars.setStatus) {
                                ForEach (toBuyStatus, id: \.self) { item in
                                    Text(item)
                                }
                            }
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
                    self.tempVars.type = ""
                    self.tempVars.resetManufacturer()
                }
                .padding(.bottom, 10)
            }
                    
            Spacer()
        }
        .padding(.bottom, kbDetails.currentHeight)
    }
}

