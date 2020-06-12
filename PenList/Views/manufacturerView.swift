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
            
            HStack {
                Text("Manufacturer")
                    .padding(.trailing, 10)
                TextField("Manufacturer", text: $workingVariables.selectedManufacturer.name)
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 5)
            
            HStack {
                Text("Country of Origin")
                    .padding(.trailing, 10)
                TextField("Country", text: $workingVariables.selectedManufacturer.country)
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 5)
            
            Button("Save") {
                if self.workingVariables.selectedManufacturer.isNew {
                    manufacturerList.append(self.workingVariables.selectedManufacturer)
                    self.workingVariables.selectedManufacturer.isNew = false
                }
                self.workingVariables.selectedManufacturer.save()
            }
            
            if workingVariables.selectedManufacturer.name != "" && !workingVariables.selectedManufacturer.isNew {
                HStack {
                    VStack {
                        Text("Pens")
                            .font(.headline)
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
                        }
                    
                        Button("Add Pen") {
                            self.workingVariables.addPen()

                            self.showPen = true
                        }
                        .padding()
                        .sheet(isPresented: self.$showPen, onDismiss: { self.showPen = false }) {
                            penDetails(workingVariables: self.workingVariables, showChild: self.$showPen)
                            }
                    }
                    
                    VStack {
                        Text("Inks")
                            .font(.headline)
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
                        }
                    
                        Button("Add Ink") {
                            self.workingVariables.addInk()
                            
                            self.showInk = true
                        }
                        .sheet(isPresented: self.$showInk, onDismiss: { self.showInk = false }) {
                            inkDetails(workingVariables: self.workingVariables, showChild: self.$showInk)
                            }
                    }
                    .padding()
                }
            }
            
            Spacer()
        }
    }
}

