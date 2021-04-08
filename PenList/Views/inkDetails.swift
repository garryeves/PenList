//
//  inkDetails.swift
//  PenList
//
//  Created by Garry Eves on 22/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class inkDetailsWorkingVariables: ObservableObject {
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
        
//        var inkTypeText = "Select"
//        
//        if workingVariables.selectedInk.inkType != "" {
//            inkTypeText = workingVariables.selectedInk.inkType
//        }
        
        var borderColour = Color.black
        
        if colorScheme == .dark {
            borderColour = Color.white
        }
        
        var colourText = "Select Colour"
        
        if workingVariables.selectedInk.colour != "" {
            colourText = workingVariables.selectedInk.colour
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
                    
//                    if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
//                        Menu(inkTypeText) {
//                            ForEach (workingVariables.decodeList.decodesText("inkType"), id: \.self) { item in
//                                Button(item) {
//                                    workingVariables.selectedInk.inkType = item
//                                    tempVariables.reload.toggle()
//                                }
//                            }
//                        }
//                        .padding(.bottom, 10)
//                    } else {
//                        Picker("Ink Type", selection: $workingVariables.selectedInk.inkType) {
//                            ForEach (workingVariables.decodeList.decodesText("inkType"), id: \.self) { item in
//                                Text(item)
//                            }
//                        }
//                        .padding(.bottom, 10)
//                    }
                    
                    if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                        Menu(colourText) {
                            ForEach (workingVariables.decodeList.decodesText("InkColour"), id: \.self) { item in
                                Button(item) {
                                    workingVariables.selectedInk.colour = item
                                    tempVariables.reload.toggle()
                                }
                            }
                        }
                        .padding(.bottom, 10)
                    } else {
                        Picker("Colour", selection: $workingVariables.selectedInk.colour) {
                            ForEach (workingVariables.decodeList.decodesText("InkColour"), id: \.self) { item in
                                Text(item)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    
                    
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
