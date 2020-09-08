//
//  inkDetails.swift
//  PenList
//
//  Created by Garry Eves on 22/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class inkDetailsWorkingVariables: ObservableObject {
    var showModalInkType = pickerComms()
    var rememberedIntInkType = -1
    @Published var showInkTypePicker = false
    @Published var reload = false
}

struct inkDetails: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @Binding var showChild: Bool
    
    @ObservedObject var tempVariables = inkDetailsWorkingVariables()
    @ObservedObject var kbDetails = KeyboardResponder()
    
    @State var showMyInk = false

    @State var noName = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        UITableView.appearance().separatorStyle = .none
        
        if tempVariables.rememberedIntInkType > -1 {
            workingVariables.selectedInk.inkType = inkTypes[tempVariables.rememberedIntInkType]
            tempVariables.rememberedIntInkType = -1
        }
        
        var inkTypeText = "Select"
        
        if workingVariables.selectedInk.inkType != "" {
            inkTypeText = workingVariables.selectedInk.inkType
        }
        
        var borderColour = Color.black
        
        if colorScheme == .dark {
            borderColour = Color.white
        }
        
        return VStack {
            HStack {
                Spacer()
                Text("Ink Details")
                    .font(.title)
                Spacer()
                
                Button("Close") {
                    self.showChild = false
                }
            }
            .padding()
            
            if workingVariables.selectedInk.name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                Text("Please enter the name of the Ink and then press 'Add'")
            }
            
            Form {
                TextField("Name", text: $workingVariables.selectedInk.name)
                
                if workingVariables.selectedInk.name.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    TextField("Ink Family", text: $workingVariables.selectedInk.inkFamily)
                    
                    Text(inkTypeText)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            self.tempVariables.rememberedIntInkType = -1
                            self.tempVariables.showModalInkType.displayList.removeAll()
                            
                            for item in inkTypes {
                                self.tempVariables.showModalInkType.displayList.append(displayEntry(entryText: item))
                            }
                            
                            self.tempVariables.showInkTypePicker = true
                        }
                    .sheet(isPresented: self.$tempVariables.showInkTypePicker, onDismiss: { self.tempVariables.showInkTypePicker = false }) {
                        pickerView(displayTitle: "Select Filling System", rememberedInt: self.$tempVariables.rememberedIntInkType, showPicker: self.$tempVariables.showInkTypePicker, showModal: self.$tempVariables.showModalInkType)
                                }
                    
                    TextField("Colour", text: $workingVariables.selectedInk.colour)
                }
            }
            .frame(height: 220)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 10)
                
            if workingVariables.selectedInk.name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                Button("Add") {
                    if self.workingVariables.selectedInk.name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                        self.noName = true
                    } else {
                        self.workingVariables.selectedInk.isNew = false
                        self.workingVariables.selectedInk.save()
                        sleep(2)
                        inkList = inks()
                        
                        self.tempVariables.reload.toggle()
                    }
                }
                .alert(isPresented: self.$noName) {
                    Alert(title: Text("Error"),
                          message: Text("You need to provide an Ink name before you can add it"),
                          dismissButton: .default(Text("OK"), action: {
                            self.noName = false
                             }))
                }
            } else {
            
                HStack {
                    VStack {
                        Text("Notes")
                            .font(.subheadline)
                        
                        GeometryReader { geometry in
                            TextEditor(text: $workingVariables.selectedInk.notes)
                                .border(borderColour, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                                .frame(width: geometry.size.width - 40, alignment: .center)
                                .padding()
                        }
                    }
                    .padding(.trailing, 10)
                    
                    VStack {
                        Text("Current Inks")
                            .font(.subheadline)
                        
                        List {
                            ForEach (workingVariables.selectedInk.inkItems) { item in
                                Text(item.name)
                                .onTapGesture {
                                    self.workingVariables.selectedMyInk = item
                                    
                                    self.showMyInk = true
                                }
                            }
                        }
                        
                        Button("Add Ink Stock") {
                            self.workingVariables.selectedMyInk = myInk()
                            self.workingVariables.selectedMyInk.manufacturer = self.workingVariables.selectedInk.manufacturer
                            self.workingVariables.selectedMyInk.inkID = self.workingVariables.selectedInk.inkID.uuidString
                            
                            self.showMyInk = true
                        }
                        .sheet(isPresented: self.$showMyInk, onDismiss: { self.showMyInk = false
                        }) {
                            myInkView(workingVariables: self.workingVariables, showChild: self.$showMyInk)
                            }
                    }
                }
                .padding()
                
                Button("Save") {
                    if self.workingVariables.selectedInk.isNew {
                        inkList.append(self.workingVariables.selectedInk)
                        self.workingVariables.selectedInk.isNew = false
                    }
                    self.workingVariables.selectedInk.save()
                }
            }
            Spacer()
        }
        .padding(.bottom, kbDetails.currentHeight)
    }
}
