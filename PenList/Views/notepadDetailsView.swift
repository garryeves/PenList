//
//  notepadDetailsView.swift
//  PenList
//
//  Created by Garry Eves on 12/7/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class notepadDetailsWorkingVariables: ObservableObject {

    @Published var reload = false
}

struct notepadDetails: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @Binding var showChild: Bool
    
    @ObservedObject var kbDetails = KeyboardResponder()
    @ObservedObject var tempVariables = notepadDetailsWorkingVariables()
    
    @State var showMyNotepad = false
    @State var noName = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        UITableView.appearance().separatorStyle = .none

        var borderColour = Color.black
        
        if colorScheme == .dark {
            borderColour = Color.white
        }
        
        return VStack {
            HStack {
                Spacer()
                Text("Notepad Details")
                    .font(.title)
                Spacer()
                
                Button("Close") {
                    self.showChild = false
                }
            }
            .padding()
            
            if workingVariables.selectedNotepad.name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                Text("Please enter the name of the Notepad and then press 'Add'")
            }
            
            Form {
                TextField("Name", text: $workingVariables.selectedNotepad.name)
            }
            
            if workingVariables.selectedNotepad.name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                Button("Add") {
                    if self.workingVariables.selectedNotepad.name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                        self.noName = true
                    } else {
                        self.workingVariables.selectedNotepad.isNew = false
                        self.workingVariables.selectedNotepad.save()
                        sleep(2)
                        notepadList = notepads()
                        
                        self.tempVariables.reload.toggle()
                    }
                }
                .alert(isPresented: self.$noName) {
                    Alert(title: Text("Error"),
                          message: Text("You need to provide a Notepad name before you can add it"),
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
                            TextEditor(text: $workingVariables.selectedNotepad.notes)
                                .border(borderColour, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                                .frame(width: geometry.size.width - 40, alignment: .center)
                                .padding()
                        }
                    }
                    .padding(.trailing, 10)
                    
                    VStack {
                        Text("Current Notepads")
                            .font(.subheadline)
                        
                        List {
                            ForEach (workingVariables.selectedNotepad.notepadItems) { item in
                                Text(item.name)
                                .onTapGesture {
                                    self.workingVariables.selectedMyNotepad = item
                                    
                                    self.showMyNotepad = true
                                }
                            }
                        }
                        
                        Button("Add Notepad Stock") {
                            self.workingVariables.selectedMyNotepad = myNotepad()
                            self.workingVariables.selectedMyNotepad.manufacturer = self.workingVariables.selectedNotepad.manufacturer
                            self.workingVariables.selectedMyNotepad.notepadID = self.workingVariables.selectedNotepad.notepadID.uuidString
                            
                            self.showMyNotepad = true
                        }
                        .sheet(isPresented: self.$showMyNotepad, onDismiss: { self.showMyNotepad = false
                        }) {
                            myNotepadView(workingVariables: self.workingVariables, showChild: self.$showMyNotepad)
                            }
                    }
                }
                .padding()
                
                Button("Save") {
                    if self.workingVariables.selectedNotepad.isNew {
                        notepadList.append(self.workingVariables.selectedNotepad)
                        self.workingVariables.selectedNotepad.isNew = false
                    }
                    self.workingVariables.selectedNotepad.save()
                }
            }
            Spacer()
        }
        .padding(.bottom, kbDetails.currentHeight)
    }
}
