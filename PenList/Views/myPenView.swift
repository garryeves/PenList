//
//  myPenView.swift
//  PenList
//
//  Created by Garry Eves on 22/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class myPenDetailsWorkingVariables: ObservableObject {
    var showModalNib = pickerComms()
    var rememberedIntNib = -1
    @Published var showNibPicker = false

    @Published var showModalNibMaterial = pickerComms()
    var rememberedIntNibMaterial = -1
    @Published var showNibMaterialPicker = false
    
    @Published var showManufacturer = false
    
    func triggerPenSelector() {
        DispatchQueue.global(qos: .background).async {
            sleep(1)
            DispatchQueue.main.async {
                self.showManufacturer = true
            }
        }
    }
    
    @Published var image: Image? = nil
    
    @Published var reload = false
}

struct myPenView: View {
    
    @ObservedObject var workingVariables: mainWorkingVariables
    @Binding var showChild: Bool
    
    @ObservedObject var kbDetails = KeyboardResponder()
    @ObservedObject var tempVars = myPenDetailsWorkingVariables()
    @ObservedObject var tempPhoto = selectedImageClass()
    @State var showPhotoPicker = false
    @State var showDatePicker = false

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {

        if workingVariables.selectedMyPen.penID == "" && !tempVars.showManufacturer {
            tempVars.triggerPenSelector()
        }
        
        if tempVars.rememberedIntNib > -1 {
            workingVariables.selectedMyPen.nib = workingVariables.decodeList.decodes("NibSize")[tempVars.rememberedIntNib].decodeDescription
            tempVars.rememberedIntNib = -1
        }
        
        var nibText = "Select Nib"
        
        if workingVariables.selectedMyPen.nib != "" {
            nibText = workingVariables.selectedMyPen.nib
        }
        
        if tempVars.rememberedIntNibMaterial > -1 {
            workingVariables.selectedMyPen.nibMaterial = workingVariables.decodeList.decodes("NibMaterial")[tempVars.rememberedIntNibMaterial].decodeDescription
            tempVars.rememberedIntNibMaterial = -1
        }
        
        var nibMaterialText = "Select Nib Material"
        
        if workingVariables.selectedMyPen.nibMaterial != "" {
            nibMaterialText = workingVariables.selectedMyPen.nibMaterial
        }

        var borderColour = Color.black
        
        if colorScheme == .dark {
            borderColour = Color.white
        }

        return VStack {
            HStack {
                Spacer()
                if workingVariables.selectedPen.manufacturer != "" {
                    Text("\(workingVariables.selectedPen.manufacturer) - \(workingVariables.selectedPen.name)")
                        .font(.title)
                    .sheet(isPresented: self.$tempVars.showManufacturer, onDismiss: { self.tempVars.showManufacturer = false }) {
                        selectPenView(workingVariables: self.workingVariables, showChild: self.$tempVars.showManufacturer)
                        }
                } else {
                    Text("\(workingVariables.selectedMyPen.manufacturer) - \(workingVariables.selectedMyPen.name)")
                        .font(.title)
                    .sheet(isPresented: self.$tempVars.showManufacturer, onDismiss: { self.tempVars.showManufacturer = false }) {
                        selectPenView(workingVariables: self.workingVariables, showChild: self.$tempVars.showManufacturer)
                        }
                }
                Spacer()
                
                Button("Close") {
                    self.workingVariables.myPenList = myPens()
                    self.showChild = false
                }
            }
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 15)
            
            Form {
                Section(header: Text("Details").font(.headline)) {
                    TextField("Name", text: $workingVariables.selectedMyPen.name)
                    
                    TextField("colour", text: $workingVariables.selectedMyPen.colour)
                    
                    
                    Button(nibText) {
                        self.tempVars.rememberedIntNib = -1
                        self.tempVars.showModalNib.displayList.removeAll()
                        
                        for item in workingVariables.decodeList.decodes("NibSize") {
                            self.tempVars.showModalNib.displayList.append(displayEntry(entryText: item.decodeDescription))
                        }
                    
                        self.tempVars.showNibPicker = true
                    }
                    .sheet(isPresented: self.$tempVars.showNibPicker, onDismiss: { self.tempVars.showNibPicker = false }) {
                    pickerView(displayTitle: "Select Nib Size", rememberedInt: self.$tempVars.rememberedIntNib, showPicker: self.$tempVars.showNibPicker, showModal: self.$tempVars.showModalNib)
                            }
                    
                    Button(nibMaterialText) {
                        self.tempVars.rememberedIntNibMaterial = -1
                        self.tempVars.showModalNibMaterial.displayList.removeAll()
                        
                        for item in workingVariables.decodeList.decodes("NibMaterial") {
                            self.tempVars.showModalNibMaterial.displayList.append(displayEntry(entryText: item.decodeDescription))
                        }
                        
                        self.tempVars.showNibMaterialPicker = true
                    }
                        .sheet(isPresented: self.$tempVars.showNibMaterialPicker, onDismiss: { self.tempVars.showNibMaterialPicker = false }) {
                            pickerView(displayTitle: "Select Nib Material", rememberedInt: self.$tempVars.rememberedIntNibMaterial, showPicker: self.$tempVars.showNibMaterialPicker, showModal: self.$tempVars.showModalNibMaterial)
                                }
                        }
                
                Section(header: Text("Purchased").font(.headline)) {
                    TextField("Purchased From", text: $workingVariables.selectedMyPen.purchasedFrom)
                    
                    TextField("Price", text: $workingVariables.selectedMyPen.cost)
                    
//                    #if targetEnvironment(macCatalyst)
//                        DatePicker(selection: $workingVariables.selectedMyPen.datePurchased, displayedComponents: .date) {
//                            Text("Purchase Date")
//                        }
//                        .labelsHidden()
//                    #else
                         Text(workingVariables.selectedMyPen.datePurchased.formatDateToString)
                            .onTapGesture {
                                self.showDatePicker = true
                            }
                            .sheet(isPresented: self.$showDatePicker, onDismiss: { self.showDatePicker = false }) {
                                pickerDateView(displayTitle: "Purchase Date", showPicker: self.$showDatePicker, selectedDate: self.$workingVariables.selectedMyPen.datePurchased)
                                }
//                    #endif
                }
            }
            .frame(height: 400)
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
                        myPenImagesView(showChild: self.$showPhotoPicker, workingVariables: self.workingVariables)
                    }
            }
                .padding(.bottom, 5)

            GeometryReader { geometry in
                TextEditor(text: $workingVariables.selectedMyPen.notes)
                    .border(borderColour, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    .frame(width: geometry.size.width - 40, alignment: .center)
                    .padding()
            }
            
            Button("Save") {
                self.workingVariables.selectedMyPen.save()
                sleep(2)
                currentPenList = myPens()
                self.tempVars.reload.toggle()
                //self.workingVariables.reloadPen.toggle()
            }
            .padding(.bottom, 15)
        }
//        .onTapGesture {
//            let keyWindow = UIApplication.shared.connectedScenes
//                               .filter({$0.activationState == .foregroundActive})
//                               .map({$0 as? UIWindowScene})
//                               .compactMap({$0})
//                               .first?.windows
//                               .filter({$0.isKeyWindow}).first
//            keyWindow!.endEditing(true)
//        }
        .padding(.bottom, kbDetails.currentHeight)
    }
}

struct myPenViewPhone: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @Binding var showChild: Bool
    
    @ObservedObject var kbDetails = KeyboardResponder()
    @ObservedObject var tempVars = myPenDetailsWorkingVariables()
    @ObservedObject var tempPhoto = selectedImageClass()
    @State var showPhotoPicker = false
    
    @State var showDatePicker = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if workingVariables.selectedMyPen.penID == "" && !tempVars.showManufacturer {
            tempVars.triggerPenSelector()
        }
        
        if tempVars.rememberedIntNib > -1 {
            workingVariables.selectedMyPen.nib = workingVariables.decodeList.decodes("NibSize")[tempVars.rememberedIntNib].decodeDescription
            tempVars.rememberedIntNib = -1
        }
        
        var nibText = "Select"
        
        if workingVariables.selectedMyPen.nib != "" {
            nibText = workingVariables.selectedMyPen.nib
        }
        
        if tempVars.rememberedIntNibMaterial > -1 {
            workingVariables.selectedMyPen.nibMaterial = workingVariables.decodeList.decodes("NibMaterial")[tempVars.rememberedIntNibMaterial].decodeDescription
            tempVars.rememberedIntNibMaterial = -1
        }
        
        var nibMaterialText = "Select"
        
        if workingVariables.selectedMyPen.nibMaterial != "" {
            nibMaterialText = workingVariables.selectedMyPen.nibMaterial
        }

        var borderColour = Color.black
        
        if colorScheme == .dark {
            borderColour = Color.white
        }
        
        return VStack {
            HStack {
                Spacer()
                Text("\(workingVariables.selectedMyPen.manufacturer) - \(workingVariables.selectedMyPen.penName)")
                    .font(.title)
                .sheet(isPresented: self.$tempVars.showManufacturer, onDismiss: { self.tempVars.showManufacturer = false }) {
                    selectPenView(workingVariables: self.workingVariables, showChild: self.$tempVars.showManufacturer)
                    }
                Spacer()
                
                Button("Close") {
                    self.workingVariables.myPenList = myPens()
                    self.workingVariables.reload.toggle()
                    self.showChild = false
                }
            }
            .padding(.bottom, 5)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 5)

            TextField("Name", text: $workingVariables.selectedMyPen.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            TextField("colour", text: $workingVariables.selectedMyPen.colour)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            HStack {
                Text("Nib")
                    .padding(.trailing, 5)

                Button(nibText) {
                        self.tempVars.rememberedIntNib = -1
                        self.tempVars.showModalNib.displayList.removeAll()
                        
                        for item in workingVariables.decodeList.decodes("NibSize") {
                            self.tempVars.showModalNib.displayList.append(displayEntry(entryText: item.decodeDescription))
                        }
                        
                        self.tempVars.showNibPicker = true
                    }
                    .sheet(isPresented: self.$tempVars.showNibPicker, onDismiss: { self.tempVars.showNibPicker = false }) {
                        pickerView(displayTitle: "Select Nib Size", rememberedInt: self.$tempVars.rememberedIntNib, showPicker: self.$tempVars.showNibPicker, showModal: self.$tempVars.showModalNib)
                            }
                
                 Button(nibMaterialText) {
                         self.tempVars.rememberedIntNibMaterial = -1
                         self.tempVars.showModalNibMaterial.displayList.removeAll()
                         
                         for item in workingVariables.decodeList.decodes("NibMaterial"){
                            self.tempVars.showModalNibMaterial.displayList.append(displayEntry(entryText: item.decodeDescription))
                         }
                         
                        self.tempVars.showNibMaterialPicker = true
                     }
                    .sheet(isPresented: self.$tempVars.showNibMaterialPicker, onDismiss: { self.tempVars.showNibMaterialPicker = false }) {
                        pickerView(displayTitle: "Select Nib Material", rememberedInt: self.$tempVars.rememberedIntNibMaterial, showPicker: self.$tempVars.showNibMaterialPicker, showModal: self.$tempVars.showModalNibMaterial)
                }
            }
            .padding(.bottom, 5)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            
            VStack{
                Text("Purchased")
                    .font(.headline)
                .padding(.bottom, 5)
                
                TextField("Purchased From", text: $workingVariables.selectedMyPen.purchasedFrom)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)

                TextField("Price", text: $workingVariables.selectedMyPen.cost)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.trailing, 10)
                .padding(.leading, 20)
                .padding(.bottom, 5)

                 Text(workingVariables.selectedMyPen.datePurchased.formatDateToString)
                    .onTapGesture {
                        self.showDatePicker = true
                    }
                    .sheet(isPresented: self.$showDatePicker, onDismiss: { self.showDatePicker = false }) {
                        pickerDateView(displayTitle: "Purchase Date", showPicker: self.$showDatePicker, selectedDate: self.$workingVariables.selectedMyPen.datePurchased)
                        }
            }
            .padding(.bottom, 5)
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
                        myPenImagesView(showChild: self.$showPhotoPicker, workingVariables: self.workingVariables)
                    }
            }
                .padding(.bottom, 5)

            GeometryReader { geometry in
                TextEditor(text: $workingVariables.selectedMyPen.notes)
                    .border(borderColour, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    .frame(width: geometry.size.width - 40, alignment: .center)
                    .padding()
            }

            Button("Save") {
                self.workingVariables.selectedMyPen.save()
                sleep(2)
                currentPenList = myPens()
                self.workingVariables.reloadPen.toggle()
            }
            .padding(.bottom, 5)
        }
//        .onTapGesture {
//            let keyWindow = UIApplication.shared.connectedScenes
//                               .filter({$0.activationState == .foregroundActive})
//                               .map({$0 as? UIWindowScene})
//                               .compactMap({$0})
//                               .first?.windows
//                               .filter({$0.isKeyWindow}).first
//            keyWindow!.endEditing(true)
//        }
        .padding(.bottom, kbDetails.currentHeight)
    }
}
