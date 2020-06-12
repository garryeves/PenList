//
//  penDetails.swift
//  PenList
//
//  Created by Garry Eves on 22/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class penDetailsWorkingVariables: ObservableObject {
    var showModalFilling = pickerComms()
    var rememberedIntFilingSystem = -1
    @Published var showFilingPicker = false
}

struct penDetails: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @Binding var showChild: Bool
    
    @ObservedObject var tempVariables = penDetailsWorkingVariables()
    
    @State var showDimensions = false
    
    var body: some View {
        UITableView.appearance().separatorStyle = .none
        
        if tempVariables.rememberedIntFilingSystem > -1 {
            workingVariables.selectedPen.fillingSystem = fillerSystems[tempVariables.rememberedIntFilingSystem]
            tempVariables.rememberedIntFilingSystem = -1
        }
        
        var fillingSystemText = "Select"
        
        if workingVariables.selectedPen.fillingSystem != "" {
            fillingSystemText = workingVariables.selectedPen.fillingSystem
        }
        
        return VStack {
            HStack {
                Spacer()
                Text("Pen Details")
                    .font(.title)
                Spacer()
                
                Button("Close") {
                    self.showChild = false
                }
            }
            .padding()
            
            HStack {
                Text("Name")
                    .padding(.trailing, 10)
                
                TextField("Name", text: $workingVariables.selectedPen.name)
                
                Spacer()
            }
            .padding()
            
            HStack {
                Text("Filling System")
                    .padding(.trailing, 10)

                Button(fillingSystemText) {
                    self.tempVariables.rememberedIntFilingSystem = -1
                    self.tempVariables.showModalFilling.displayList.removeAll()
                    
                    for item in fillerSystems {
                        self.tempVariables.showModalFilling.displayList.append(displayEntry(entryText: item))
                    }
                    
                    self.tempVariables.showFilingPicker = true
                }
                .sheet(isPresented: self.$tempVariables.showFilingPicker, onDismiss: { self.tempVariables.showFilingPicker = false }) {
                    pickerView(displayTitle: "Select Filling System", rememberedInt: self.$tempVariables.rememberedIntFilingSystem, showPicker: self.$tempVariables.showFilingPicker, showModal: self.$tempVariables.showModalFilling)
                            }
                
                Spacer()
            }
            .padding()
            
            Button("Dimensions") {
                self.showDimensions = true
            }
            .padding()
            .sheet(isPresented: self.$showDimensions, onDismiss: { self.showDimensions = false }) {
                penDimensionView(workingVariables: self.workingVariables,
                                     showChild: self.$showDimensions)
                }

            HStack {
                Text("Notes")
                    .padding(.trailing, 10)
                
                TextView(text: $workingVariables.selectedPen.notes)
                .padding()
                
                Spacer()
            }
            .padding()
            
            Button("Save") {
                if self.workingVariables.selectedPen.isNew {
                    penList.append(self.workingVariables.selectedPen)
                    self.workingVariables.selectedPen.isNew = false
                    self.workingVariables.reload.toggle()
                }
                self.workingVariables.selectedPen.save()
            }
            
            Spacer()
        }
    }
}
