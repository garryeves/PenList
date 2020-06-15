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
            
            if workingVariables.selectedManufacturer.name == "" {
                HStack {
                    Text("Manufacturer")
                        .padding(.trailing, 10)
                    TextField("Manufacturer", text: $workingVariables.selectedManufacturer.name)
                    Button("Add") {
                        self.workingVariables.selectedManufacturer.isNew = false
                        self.workingVariables.selectedManufacturer.save()
                        self.workingVariables.reloadManufacturer.toggle()
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .padding(.bottom, 5)
            } else {
                Form {
                    TextField("Manufacturer", text: $workingVariables.selectedManufacturer.name)
                    
                    if workingVariables.selectedManufacturer.name != "" && !workingVariables.selectedManufacturer.isNew {
                        TextField("Country", text: $workingVariables.selectedManufacturer.country)
                    }
                }
                .frame(height: 120)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .padding(.bottom, 20)

                if workingVariables.selectedManufacturer.name != "" && !workingVariables.selectedManufacturer.isNew {
                    Button("Save") {
                        if self.workingVariables.selectedManufacturer.isNew {
                            manufacturerList.append(self.workingVariables.selectedManufacturer)
                            self.workingVariables.selectedManufacturer.isNew = false
                        }
                        self.workingVariables.selectedManufacturer.save()
                    }
                    .padding(.bottom, 20)
                
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
                    .padding(.bottom, 10)
                }
            }
          //  Spacer()
        }
    }
}

