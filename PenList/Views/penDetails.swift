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
    @ObservedObject var kbDetails = KeyboardResponder()
    
    @State var showDimensions = false
    @State var showMyPen = false
    @State var showMyPenPhone = false
    
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
        
        var dimensionsCap = "Cap"
        var dimensionsBody = "Body"
        var dimensionsGrip = "Grip"
        
        if workingVariables.selectedPen.diameterCap != "" ||
            workingVariables.selectedPen.lengthCap != "" ||
            workingVariables.selectedPen.weightCap != "" {
            dimensionsCap = "Cap: Diameter \(workingVariables.selectedPen.diameterCap), length: \(workingVariables.selectedPen.lengthCap), weight \(workingVariables.selectedPen.weightCap)"
        }

        if workingVariables.selectedPen.diameterBody != "" ||
            workingVariables.selectedPen.lengthBody != "" ||
            workingVariables.selectedPen.weightBody != "" {
            dimensionsBody = "Body: Diameter \(workingVariables.selectedPen.diameterBody), length: \(workingVariables.selectedPen.lengthBody), weight \(workingVariables.selectedPen.weightBody)"
        }
        
        if workingVariables.selectedPen.diameterGrip != "" ||
        workingVariables.selectedPen.lengthClosed != "" ||
            workingVariables.selectedPen.weightTotal != "" {
            dimensionsGrip = "Grip Diameter \(workingVariables.selectedPen.diameterGrip), closed length: \(workingVariables.selectedPen.lengthClosed), weight \(workingVariables.selectedPen.weightTotal)"
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
            
            Form {
                TextField("Name", text: $workingVariables.selectedPen.name)
                if workingVariables.selectedPen.name != "" {
                    Text(fillingSystemText)
                        .foregroundColor(.blue)
                        .onTapGesture {
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
                    Text(dimensionsCap)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            self.showDimensions = true
                        }
                    
                    Text(dimensionsBody)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            self.showDimensions = true
                        }
                    
                    Text(dimensionsGrip)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            self.showDimensions = true
                        }
                    .sheet(isPresented: self.$showDimensions, onDismiss: { self.showDimensions = false }) {
                        penDimensionView(workingVariables: self.workingVariables,
                                             showChild: self.$showDimensions)
                        }
                }
            }
            .frame(height: 250)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 10)
            
            if workingVariables.selectedPen.name == "" {
                Button("Add") {
                    self.workingVariables.selectedPen.isNew = false
                    self.workingVariables.selectedPen.save()
                    sleep(2)
                    penList = pens()
                    
                    self.workingVariables.reloadPen.toggle()
                }
            } else {
                HStack {
                    VStack {
                        Text("Notes")
                            .font(.subheadline)
                    
                        TextView(text: $workingVariables.selectedPen.notes)
                            .padding()
                    }
                    .padding(.trailing, 10)
                    
                    VStack {
                        Text("Current Pens")
                            .font(.subheadline)
                        .sheet(isPresented: self.$showMyPenPhone, onDismiss: { self.showMyPenPhone = false }) {
                            myPenViewPhone(workingVariables: self.workingVariables, showChild: self.$showMyPenPhone)
                            }
                        
                        List {
                            ForEach (workingVariables.selectedPen.penItems) { item in
                                Text(item.name)
                                .onTapGesture {
                                    self.workingVariables.selectedMyPen = item
                                    
                                    if UIDevice.current.userInterfaceIdiom == .phone {
                                        self.showMyPenPhone = true
                                    } else {
                                        self.showMyPen = true
                                    }
                                }
                            }
                        }
                        
                        Button("Add Pen") {
                            self.workingVariables.selectedMyPen = myPen()
                            self.workingVariables.selectedMyPen.manufacturer = self.workingVariables.selectedPen.manufacturer
                            self.workingVariables.selectedMyPen.penID = self.workingVariables.selectedPen.penID.uuidString
                            
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                self.showMyPenPhone = true
                            } else {
                                self.showMyPen = true
                            }
                        }
                        .sheet(isPresented: self.$showMyPen, onDismiss: { self.showMyPen = false
                        }) {
                            myPenView(workingVariables: self.workingVariables, showChild: self.$showMyPen)
                            }
                    }
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
            }
            Spacer()
        }
        .padding(.bottom, kbDetails.currentHeight)
    }
}
