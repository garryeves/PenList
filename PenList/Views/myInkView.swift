//
//  myInkView.swift
//  PenList
//
//  Created by Garry Eves on 22/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class myInkDetailsWorkingVariables: ObservableObject {
//    var showModalNib = pickerComms()
//    var rememberedIntNib = -1
//    @Published var showNibPicker = false

//    var showModalNibMaterial = pickerComms()
//    var rememberedIntNibMaterial = -1
//    @Published var showNibMaterialPicker = false
    
    @Published var showManufacturer = false
    
    func triggerInkSelector() {
        DispatchQueue.global(qos: .background).async {
            sleep(1)
            DispatchQueue.main.async {
                self.showManufacturer = true
            }
        }
    }
}

struct myInkView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @Binding var showChild: Bool
    
    @ObservedObject var tempVars = myInkDetailsWorkingVariables()
    @ObservedObject var tempPhoto = selectedImageClass()
    @State var showPhotoPicker = false
    
    var body: some View {
        UITableView.appearance().separatorStyle = .none
        
        if workingVariables.selectedMyInk.inkID == "" && !tempVars.showManufacturer {
            tempVars.triggerInkSelector()
        }
                
        return VStack {
            HStack {
                Spacer()
                Text(workingVariables.selectedMyInk.name)
                    .font(.title)
                    .sheet(isPresented: self.$tempVars.showManufacturer, onDismiss: { self.tempVars.showManufacturer = false }) {
                        selectInkView(workingVariables: self.workingVariables, showChild: self.$tempVars.showManufacturer)
                        }
                Spacer()
                
                Button("Close") {
                    self.workingVariables.myInkList = myInks()
                    self.workingVariables.reload.toggle()
                    self.showChild = false
                }
            }
            .padding(.bottom, 30)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 15)

            Form {
                Section(header: Text("Purchased").font(.headline)) {
                    TextField("Purchased From", text: $workingVariables.selectedMyInk.boughtFrom)
                    
                    TextField("Price", text: $workingVariables.selectedMyInk.cost)
                    
                    DatePicker(selection: $workingVariables.selectedMyInk.dateBought, displayedComponents: .date) {
                        Text("Purchase Date")
                    }
                    .labelsHidden()
                }
            }
            .frame(height: 200)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)

            HStack {
                Spacer()
                
                Text("Notes")
                .font(.headline)
                
                Spacer()
                
                Button("Photos") {
                    self.showPhotoPicker = true
                }
                    .padding(.trailing, 20)
                    .sheet(isPresented: self.$showPhotoPicker, onDismiss: { self.showPhotoPicker = false }) {
                        myInkPhotosView(showChild: self.$showPhotoPicker, workingVariables: self.workingVariables)
                    }
            }
            .padding(.bottom, 5)
            
            TextView(text: $workingVariables.selectedMyInk.notes)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
            Button("Save") {
                self.workingVariables.selectedMyInk.save()
                sleep(2)
                currentInkList = myInks()
                self.workingVariables.reloadPen.toggle()
            }
            .padding(.bottom, 15)
        }
    }
}
