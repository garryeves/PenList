//
//  notepadDetailsView.swift
//  PenList
//
//  Created by Garry Eves on 12/7/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct notepadDetails: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @Binding var showChild: Bool
    
    @ObservedObject var kbDetails = KeyboardResponder()
    
    @State var showMyNotepad = false
    
    var body: some View {
        UITableView.appearance().separatorStyle = .none
        
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
            
            Form {
                TextField("Name", text: $workingVariables.selectedNotepad.name)
            }
            
            if workingVariables.selectedNotepad.name == "" {
                Button("Add") {
                    self.workingVariables.selectedNotepad.isNew = false
                    self.workingVariables.selectedNotepad.save()
                    sleep(2)
                    notepadList = notepads()
                    
                    self.workingVariables.reloadNotepad.toggle()
                }
            } else {
            
                HStack {
                    VStack {
                        Text("Notes")
                            .font(.subheadline)
                        
                        TextView(text: $workingVariables.selectedNotepad.notes)
                        .padding()
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
