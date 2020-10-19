//
//  myNotepadView.swift
//  PenList
//
//  Created by Garry Eves on 12/7/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class myNotepadDetailsWorkingVariables: ObservableObject {
    @Published var showManufacturer = false
    
    func triggerNotepadSelector() {
        DispatchQueue.global(qos: .background).async {
            sleep(1)
            DispatchQueue.main.async {
                self.showManufacturer = true
            }
        }
    }
    
    @Published var reload = false
}

struct myNotepadView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @Binding var showChild: Bool
    
    @ObservedObject var tempVars = myNotepadDetailsWorkingVariables()
//    @ObservedObject var tempPhoto = selectedImageClass()
    @ObservedObject var kbDetails = KeyboardResponder()
 //   @State var showPhotoPicker = false
    @State var showDatePicker = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        UITableView.appearance().separatorStyle = .none

        if workingVariables.selectedMyNotepad.notepadID == "" && !tempVars.showManufacturer {
            tempVars.triggerNotepadSelector()
        }
        
        var borderColour = Color.black
        
        if colorScheme == .dark {
            borderColour = Color.white
        }

        return VStack {
            HStack {
                Spacer()
                if workingVariables.selectedNotepad.manufacturer != "" {
                    Text("\(workingVariables.selectedNotepad.manufacturer) - \(workingVariables.selectedNotepad.name)")
                    .font(.title)
                    .sheet(isPresented: self.$tempVars.showManufacturer, onDismiss: { self.tempVars.showManufacturer = false }) {
                        selectNotepadView(workingVariables: self.workingVariables, showChild: self.$tempVars.showManufacturer)
                        }
                } else {
                    Text("\(workingVariables.selectedMyNotepad.manufacturer) - \(workingVariables.selectedMyNotepad.name)")
                        .font(.title)
                        .sheet(isPresented: self.$tempVars.showManufacturer, onDismiss: { self.tempVars.showManufacturer = false }) {
                            selectNotepadView(workingVariables: self.workingVariables, showChild: self.$tempVars.showManufacturer)
                        }
                }
                Spacer()
                
                Button("Close") {
                    self.workingVariables.myNotepadList = myNotepads()
              //     self.workingVariables.reload.toggle()
                    self.showChild = false
                }
            }
            .padding(.bottom, 30)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 15)

            Form {
                Section(header: Text("Purchased").font(.headline)) {
                    TextField("Purchased From", text: $workingVariables.selectedMyNotepad.boughtFrom)
                    
                    TextField("Price", text: $workingVariables.selectedMyNotepad.cost)
                    
                    DatePicker(selection: $workingVariables.selectedMyNotepad.dateBought, displayedComponents: .date) {
                        Text("Purchase Date")
                    }
                    
                    if workingVariables.selectedMyNotepad.startedUsing == nil {
                        Button("Start Using") {
                            self.workingVariables.selectedMyNotepad.startedUsing = Date()
                            self.workingVariables.selectedMyNotepad.save()
                            self.workingVariables.reloadMyNotepad.toggle()
                        }
                    } else {
                        Text("Started using : \(workingVariables.selectedMyNotepad.startedUsing!.formatDateToString)")
                    }
                    
                    if workingVariables.selectedMyNotepad.finishedUsing != nil {
                        Text("Finished using : \(workingVariables.selectedMyNotepad.finishedUsing!.formatDateToString)")
                    }
                    
                }
            }
            .frame(height: 300)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)

            HStack {
                Spacer()
                
                Text("Notes")
                .font(.headline)
                
                Spacer()
                
//                Button("Photos") {
//                    self.showPhotoPicker = true
//                }
//                    .padding(.trailing, 20)
//                    .sheet(isPresented: self.$showPhotoPicker, onDismiss: { self.showPhotoPicker = false }) {
//                        myInkPhotosView(showChild: self.$showPhotoPicker, workingVariables: self.workingVariables)
//                    }
            }
            .padding(.bottom, 5)
            
            GeometryReader { geometry in
                TextEditor(text: $workingVariables.selectedMyNotepad.notes)
                    .border(borderColour, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    .frame(width: geometry.size.width - 40, alignment: .center)
                    .padding()
            }
            
            Button("Save") {
                self.workingVariables.selectedMyNotepad.save()
                sleep(2)
                currentNotepadList = myNotepads()
                self.tempVars.reload.toggle()
             //   self.workingVariables.reloadPen.toggle()
            }
            .padding(.bottom, 15)
        }
        .padding(.bottom, kbDetails.currentHeight)
    }
}


