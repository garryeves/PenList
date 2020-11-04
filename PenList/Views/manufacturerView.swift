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
    @State var newItem = ""
    @State var dupItemFound = false
    
    var body: some View {
        
        UITableView.appearance().separatorStyle = .none
        
        let manufacturersPens = penList.pens.filter { $0.manID == workingVariables.selectedManufacturer.manID.uuidString }

        let manufacturersInks = inkList.inks.filter { $0.manID == workingVariables.selectedManufacturer.manID.uuidString }
        
        let manufacturersNotepads = notepadList.notepads.filter { $0.manID == workingVariables.selectedManufacturer.manID.uuidString }
 
print("Garry - reloading showInk \(showInk) - newItem \(newItem)")
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
                        Text("Add New Item")
                            .padding(.top, 5)
                        
                        TextField("New item name", text: $newItem)
                            .padding(.top, 5)
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                            .padding(.bottom, 5)
                        
                        if newItem != "" {
                            HStack {
                                Button("Add Pen") {
                                    var dupFound = false

                                    for item in penList.pens {
                                        if item.name.lowercased() == self.newItem.lowercased() {
                                            dupFound = true
                                            break
                                        }
                                    }

                                    if !dupFound {
                                        self.workingVariables.selectedPen = pen(passedmanID: self.workingVariables.selectedManufacturer.manID.uuidString, passedname: newItem)
                                        self.showPen = true
                                    } else {
                                        dupItemFound = true
                                    }
                                }
                                .alert(isPresented: $dupItemFound) {
                                            Alert(title: Text("Duplicate Pen Found"), message: Text("Please Check the pen name"), dismissButton: .default(Text("OK")))
                                        }
                                .sheet(isPresented: self.$showPen, onDismiss: {
                                        penList = pens()
                                        self.showPen = false
                                        self.newItem = ""
                                }) {
                                    penDetails(workingVariables: self.workingVariables, showChild: self.$showPen)
                                    }
                                
                                Button("Add Ink") {
                                    var dupFound = false

                                    for item in inkList.inks {
                                        if item.name.lowercased() == self.newItem.lowercased() {
                                            dupFound = true
                                            break
                                        }
                                    }

                                    if !dupFound {
                                        self.workingVariables.selectedInk = ink(passedmanID: self.workingVariables.selectedManufacturer.manID.uuidString, passedname: newItem)
                                        self.showInk = true
                                    } else {
                                        dupItemFound = true
                                    }
                                }
                                .alert(isPresented: $dupItemFound) {
                                            Alert(title: Text("Duplicate Ink Found"), message: Text("Please Check the ink name"), dismissButton: .default(Text("OK")))
                                        }
                                .sheet(isPresented: self.$showInk, onDismiss: {
                                        inkList = inks()
                                        self.showInk = false
                                        self.newItem = ""
                                }) {
                                    inkDetails(workingVariables: self.workingVariables, showChild: self.$showInk)
                                    }
                                
                                Button("Add Notepad") {
                                    var dupFound = false

                                    for item in notepadList.notepads {
                                        if item.name.lowercased() == self.newItem.lowercased() {
                                            dupFound = true
                                            break
                                        }
                                    }

                                    if !dupFound {
                                        self.workingVariables.selectedNotepad = notepad(passedmanID: self.workingVariables.selectedManufacturer.manID.uuidString, passedname: newItem)
                                        self.showNotepad = true
                                    } else {
                                        dupItemFound = true
                                    }
                                }
                                .alert(isPresented: $dupItemFound) {
                                            Alert(title: Text("Duplicate Notepad Found"), message: Text("Please Check the notepad name"), dismissButton: .default(Text("OK")))
                                        }
                                .sheet(isPresented: self.$showNotepad, onDismiss: {
                                        notepadList = notepads()
                                        self.showNotepad = false
                                        self.newItem = ""
                                }) {
                                    notepadDetails(workingVariables: self.workingVariables, showChild: self.$showNotepad)
                                    }
                            }
                            .padding(.bottom, 10)
                        }
                    } else {
                        HStack {
                            Spacer()

                            Text("Add New Item")
                            
                            TextField("New item name", text: $newItem)

                            if newItem != "" {
                                Button("Add Pen") {
                                    var dupFound = false

                                    for item in penList.pens {
                                        if item.name.lowercased() == self.newItem.lowercased() {
                                            dupFound = true
                                            break
                                        }
                                    }

                                    if !dupFound {
                                        self.workingVariables.selectedPen = pen(passedmanID: self.workingVariables.selectedManufacturer.manID.uuidString, passedname: newItem)
                                        self.showPen = true
                                    } else {
                                        dupItemFound = true
                                    }
                                }
                                .alert(isPresented: $dupItemFound) {
                                            Alert(title: Text("Duplicate Pen Found"), message: Text("Please Check the pen name"), dismissButton: .default(Text("OK")))
                                        }
                                .sheet(isPresented: self.$showPen, onDismiss: {
                                        penList = pens()
                                        self.showPen = false
                                        self.newItem = ""
                                }) {
                                    penDetails(workingVariables: self.workingVariables, showChild: self.$showPen)
                                    }
                                
                                Button("Add Ink") {
                                    var dupFound = false

                                    for item in inkList.inks {
                                        if item.name.lowercased() == self.newItem.lowercased() {
                                            dupFound = true
                                            break
                                        }
                                    }

                                    if !dupFound {
                                        self.workingVariables.selectedInk = ink(passedmanID: self.workingVariables.selectedManufacturer.manID.uuidString, passedname: newItem)
                                        self.showInk = true
                                    } else {
                                        dupItemFound = true
                                    }
                                }
                                .alert(isPresented: $dupItemFound) {
                                            Alert(title: Text("Duplicate Ink Found"), message: Text("Please Check the ink name"), dismissButton: .default(Text("OK")))
                                        }
                                .sheet(isPresented: self.$showInk, onDismiss: {
                                        inkList = inks()
                                        self.showInk = false
                                        self.newItem = ""
                                }) {
                                    inkDetails(workingVariables: self.workingVariables, showChild: self.$showInk)
                                    }
                                
                                Button("Add Notepad") {
                                    var dupFound = false

                                    for item in notepadList.notepads {
                                        if item.name.lowercased() == self.newItem.lowercased() {
                                            dupFound = true
                                            break
                                        }
                                    }

                                    if !dupFound {
                                        self.workingVariables.selectedNotepad = notepad(passedmanID: self.workingVariables.selectedManufacturer.manID.uuidString, passedname: newItem)
                                        self.showNotepad = true
                                    } else {
                                        dupItemFound = true
                                    }
                                }
                                .alert(isPresented: $dupItemFound) {
                                            Alert(title: Text("Duplicate Notepad Found"), message: Text("Please Check the notepad name"), dismissButton: .default(Text("OK")))
                                        }
                                .sheet(isPresented: self.$showNotepad, onDismiss: {
                                        notepadList = notepads()
                                        self.showNotepad = false
                                        self.newItem = ""
                                }) {
                                    notepadDetails(workingVariables: self.workingVariables, showChild: self.$showNotepad)
                                    }
                            }
                        }
                        .padding()
                    

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
                                }
                                .padding(.bottom, 10)
                            }
                        }
                    }
                }
                
                }
            }
        }
    }
}

