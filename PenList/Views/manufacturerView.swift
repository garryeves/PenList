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
    @State var showNotepad = false
    @State var newName = ""
    @State var reload = false
    @State var noName = false
    
    var body: some View {
        
        UITableView.appearance().separatorStyle = .none
        
        let manufacturersPens = penList.pens.filter { $0.manID == workingVariables.selectedManufacturer.manID.uuidString }

        let manufacturersInks = inkList.inks.filter { $0.manID == workingVariables.selectedManufacturer.manID.uuidString }
        
        let manufacturersNotepads = notepadList.notepads.filter { $0.manID == workingVariables.selectedManufacturer.manID.uuidString }
 
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
                
            if self.workingVariables.selectedManufacturer.name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                Text("Please enter the name of the Manufacturer and then press 'Add'")
            }
            
            Form {
                TextField("Manufacturer Name", text: self.$workingVariables.selectedManufacturer.name)
                
                if self.workingVariables.selectedManufacturer.name != "" {
                    TextField("Country", text: self.$workingVariables.selectedManufacturer.country)
                }
            }
            .frame(height: 120)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 20)

            if self.workingVariables.selectedManufacturer.name.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                if self.workingVariables.selectedManufacturer.name != "" {
                    Button("Save") {
                        if self.workingVariables.selectedManufacturer.name.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                            self.workingVariables.selectedManufacturer.save()
                        }
                    }
                    .padding(.bottom, 20)
                
                    if UIDevice.current.userInterfaceIdiom == .phone {
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
    
                        Button("Add Pen") {
                            self.workingVariables.addPen()

                            self.showPen = true
                        }
                        .padding(.bottom, 10)
                        .sheet(isPresented: self.$showPen, onDismiss: { self.showPen = false
                            self.workingVariables.reloadPen.toggle()
                        }) {
                            penDetails(workingVariables: self.workingVariables, showChild: self.$showPen)
                            }
                            
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
                        
                        Button("Add Ink") {
                            self.workingVariables.addInk()
                            
                            self.showInk = true
                        }
                            .padding(.bottom, 10)
                        .sheet(isPresented: self.$showInk, onDismiss: { self.showInk = false
                            self.workingVariables.reloadInk.toggle()
                        }) {
                            inkDetails(workingVariables: self.workingVariables, showChild: self.$showInk)
                            }
                         
                        HStack {
                            Spacer()
                            Text("Notepads")
                                .font(.headline)
                            Spacer()
                        }
                        if manufacturersNotepads.count > 0 {
                            List {
                                ForEach (manufacturersNotepads) {item in
                                    Text(item.name)
                                    .onTapGesture {
                                        self.workingVariables.selectedNotepad = item
                                        self.showNotepad = true
                                    }
                                }
                            }
                            .border(Color.gray)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                        }
                                                
                        Button("Add Notepad") {
                            self.workingVariables.addNotepad()
                            
                            self.showNotepad = true
                        }
                            .padding(.bottom, 10)
                        .sheet(isPresented: self.$showNotepad, onDismiss: { self.showNotepad = false
                            self.workingVariables.reloadNotepad.toggle()
                        }) {
                            notepadDetails(workingVariables: self.workingVariables, showChild: self.$showNotepad)
                            }
            
                    } else { //not iphone
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
                                
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("Notepads")
                                            .font(.headline)
                                        Spacer()
                                    }
                                    if manufacturersNotepads.count > 0 {
                                        List {
                                            ForEach (manufacturersNotepads) {item in
                                                Text(item.name)
                                                .onTapGesture {
                                                    self.workingVariables.selectedNotepad = item
                                                    self.showNotepad = true
                                                }
                                            }
                                        }
                                        .border(Color.gray)
                                        .padding(.leading, 20)
                                        .padding(.trailing, 20)
                                    }
                                
                                    Spacer()
                                    
                                    Button("Add Notepad") {
                                        self.workingVariables.addNotepad()
                                        
                                        self.showNotepad = true
                                    }
                                        .padding(.bottom, 10)
                                    .sheet(isPresented: self.$showNotepad, onDismiss: { self.showNotepad = false }) {
                                        notepadDetails(workingVariables: self.workingVariables, showChild: self.$showNotepad)
                                        }
                                }
                                .padding(.bottom, 10)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
    }
}

