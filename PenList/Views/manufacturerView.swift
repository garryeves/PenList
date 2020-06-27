//
//  manufacturerView.swift
//  PenList
//
//  Created by Garry Eves on 20/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct manufacturerView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @ObservedObject var kbDetails = KeyboardResponder()
    @Binding var showChild: Bool
    @State var showPen = false
    @State var showInk = false
    
    var body: some View {
        
        UITableView.appearance().separatorStyle = .none
        
        
        let manufacturersPens = penList.pens.filter { $0.manID == workingVariables.selectedManufacturer.manID.uuidString }
        
        let manufacturersInks = inkList.inks.filter { $0.manID == workingVariables.selectedManufacturer.manID.uuidString }

        return VStack {
                HStack {
                    Spacer()
                    Text("Manufacturer Details")
                        .font(.title)
                    Spacer()
                    
                    Button("Close") {
                        self.showChild = false
                    }
                }
                .padding()
                
                if self.workingVariables.selectedManufacturer.name == "" {
                    HStack {
                        Text("Manufacturer")
                            .padding(.trailing, 10)
                        TextField("Manufacturer", text: self.$workingVariables.selectedManufacturer.name)
                        Button("Add") {
                            var dupFound = false
                                            
                            for item in manufacturerList.manufacturers {
                                if item.name.lowercased() == self.workingVariables.selectedManufacturer.name.lowercased() {
                                    dupFound = true
                                    self.workingVariables.selectedManufacturer = item
                                    break
                                }
                            }
                                            
                            if !dupFound {
                                self.workingVariables.selectedManufacturer.isNew = false
                                self.workingVariables.selectedManufacturer.save()
                                sleep(2)
                            }
                            
                            manufacturerList = manufacturers()
                            self.workingVariables.reloadManufacturer.toggle()
                        }
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .padding(.bottom, 5)
                } else {
                    Form {
                        TextField("Manufacturer", text: self.$workingVariables.selectedManufacturer.name)
                        
                        if self.workingVariables.selectedManufacturer.name != "" && !self.workingVariables.selectedManufacturer.isNew {
                            TextField("Country", text: self.$workingVariables.selectedManufacturer.country)
                        }
                    }
                    .frame(height: 120)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .padding(.bottom, 20)

                    if self.workingVariables.selectedManufacturer.name != "" && !self.workingVariables.selectedManufacturer.isNew {
                        Button("Save") {
                            if self.workingVariables.selectedManufacturer.isNew {
                                manufacturerList.append(self.workingVariables.selectedManufacturer)
                                self.workingVariables.selectedManufacturer.isNew = false
                            }
                            self.workingVariables.selectedManufacturer.save()
                        }
                        .padding(.bottom, 20)
                    
                        VStack {
                            HStack {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("Pens")
                                            .font(.headline)
                                        Spacer()
                                    }
                                    if manufacturersPens.count > 0 {
                                        List {
                                            ForEach (manufacturersPens) {item in
                                                Text(item.name)
                                                .onTapGesture {
                                                    self.workingVariables.selectedPen = item
                                                    self.showPen = true
                                                }
                                            }
                                        }
                                        .border(Color.gray)
                                        .padding(.leading, 20)
                                        .padding(.trailing, 20)
                                    }
                                    Spacer()
                                    
                                    Button("Add Pen") {
                                        self.workingVariables.addPen()

                                        self.showPen = true
                                    }
                                    .padding(.bottom, 10)
                                    .sheet(isPresented: self.$showPen, onDismiss: { self.showPen = false }) {
                                        penDetails(workingVariables: self.workingVariables, showChild: self.$showPen)
                                        }
                                }
                                .padding(.bottom, 10)
                            
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("Inks")
                                            .font(.headline)
                                        Spacer()
                                    }
                                    if manufacturersInks.count > 0 {
                                        List {
                                            ForEach (manufacturersInks) {item in
                                                Text(item.name)
                                                .onTapGesture {
                                                    self.workingVariables.selectedInk = item
                                                    self.showInk = true
                                                }
                                            }
                                        }
                                        .border(Color.gray)
                                        .padding(.leading, 20)
                                        .padding(.trailing, 20)
                                    }
                                
                                    Spacer()
                                    
                                    Button("Add Ink") {
                                        self.workingVariables.addInk()
                                        
                                        self.showInk = true
                                    }
                                        .padding(.bottom, 10)
                                    .sheet(isPresented: self.$showInk, onDismiss: { self.showInk = false }) {
                                        inkDetails(workingVariables: self.workingVariables, showChild: self.$showInk)
                                        }
                                }
                                .padding(.bottom, 10)
                            }
                        }
                    }
                }
        }
        .padding(.bottom, kbDetails.currentHeight)
    }
}

