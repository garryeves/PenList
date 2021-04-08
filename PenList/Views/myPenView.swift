//
//  myPenView.swift
//  PenList
//
//  Created by Garry Eves on 22/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class myPenDetailsWorkingVariables: ObservableObject {

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
    
    @Published var imagesLoaded = false
    
    func showPhotoButton() {
        DispatchQueue.main.async {
            self.imagesLoaded = true
        }
    }
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
        
        if !tempVars.imagesLoaded {
            DispatchQueue.global(qos: .background).async {
                workingVariables.selectedMyPen.loadImages(tempVars: tempVars)
            }
        }
        var nibText = "Select Nib"
        
        if workingVariables.selectedMyPen.nib != "" {
            nibText = workingVariables.selectedMyPen.nib
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
                    
                    if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                        Menu(nibText) {
                            ForEach (workingVariables.decodeList.decodesText("NibSize"), id: \.self) { item in
                                Button(item) {
                                    workingVariables.selectedMyPen.nib = item
                                    tempVars.reload.toggle()
                                }
                            }
                        }
                        .padding(.bottom, 10)
                    } else {
                        Picker("Nib Size", selection: $workingVariables.selectedMyPen.nib) {
                            ForEach (workingVariables.decodeList.decodesText("NibSize"), id: \.self) { item in
                                Text(item)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    
                    if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                        Menu(nibMaterialText) {
                            ForEach (workingVariables.decodeList.decodesText("NibMaterial"), id: \.self) { item in
                                Button(item) {
                                    workingVariables.selectedMyPen.nibMaterial = item
                                }
                            }
                        }
                        .padding(.bottom, 10)
                    } else {
                        Picker("Nib Material", selection: $workingVariables.selectedMyPen.nibMaterial) {
                            ForEach (workingVariables.decodeList.decodesText("NibMaterial"), id: \.self) { item in
                                Text(item)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
                
                Section(header: Text("Purchased").font(.headline)) {
                    TextField("Purchased From", text: $workingVariables.selectedMyPen.purchasedFrom)
                    
                    TextField("Price", text: $workingVariables.selectedMyPen.cost)
                    
                    DatePicker(selection: $workingVariables.selectedMyPen.datePurchased, displayedComponents: .date) {
                        Text("Purchase Date")
                    }
                    
                    TextField("Serial No", text: $workingVariables.selectedMyPen.serialNo)
                }
                Section(header: Text("Sold").font(.headline)) {
                    if workingVariables.selectedMyPen.dateSold == getDefaultDate() {
                        TextField("Sold For", text: $workingVariables.selectedMyPen.soldFor)
                        Button("Mark as sold/disposed of") {
                            workingVariables.selectedMyPen.dateSold = Date()
                            workingVariables.selectedMyPen.save()
                            sleep(2)
                            self.workingVariables.myPenList = myPens()
                            self.showChild = false
                        }
                    } else {
                        Text("Sold For \(workingVariables.selectedMyPen.soldFor))")
                        Text("Sold/disposed of on \(workingVariables.selectedMyPen.dateSold.formatDateToString)")
                    }
                }
            }
         //   .frame(height: 430)
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
 
            HStack {
                Spacer()
                
                Text("Notes")
                    .font(.headline)
                
                Spacer()
                
                if tempVars.imagesLoaded {
                    Button("Photos") {
                        self.showPhotoPicker = true
                    }
                        .padding(.trailing, 20)
                        .sheet(isPresented: self.$showPhotoPicker, onDismiss: { self.showPhotoPicker = false
                            self.tempVars.imagesLoaded = false
                        }) {
                            myPenImagesView(showChild: self.$showPhotoPicker, workingVariables: self.workingVariables)
                        }
                }
            }
                .padding(.bottom, 5)

            GeometryReader { geometry in
                TextEditor(text: $workingVariables.selectedMyPen.notes)
                    .border(borderColour, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
               //     .frame(width: geometry.size.width - 40, alignment: .center)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
            }
            .frame(height: 100)
            
            Button("Save") {
                self.workingVariables.selectedMyPen.save()
                sleep(2)
                currentPenList = myPens()
                self.tempVars.reload.toggle()
                //self.workingVariables.reloadPen.toggle()
            }
            .padding(.bottom, 15)
        }
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
        
        var nibText = "Select"
        
        if workingVariables.selectedMyPen.nib != "" {
            nibText = workingVariables.selectedMyPen.nib
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
            
            if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                Menu(nibText) {
                    ForEach (workingVariables.decodeList.decodesText("NibSize"), id: \.self) { item in
                        Button(item) {
                            workingVariables.selectedMyPen.nib = item
                        }
                    }
                }
                .padding(.bottom, 10)
            } else {
                Picker("Nib Size", selection: $workingVariables.selectedMyPen.nib) {
                    ForEach (workingVariables.decodeList.decodesText("NibSize"), id: \.self) { item in
                        Text(item)
                    }
                }
                .padding(.bottom, 10)
            }
            
            if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                Menu(nibMaterialText) {
                    ForEach (workingVariables.decodeList.decodesText("NibMaterial"), id: \.self) { item in
                        Button(item) {
                            workingVariables.selectedMyPen.nibMaterial = item
                        }
                    }
                }
                .padding(.bottom, 10)
            } else {
                Picker("Nib Material", selection: $workingVariables.selectedMyPen.nibMaterial) {
                    ForEach (workingVariables.decodeList.decodesText("NibMaterial"), id: \.self) { item in
                        Text(item)
                    }
                }
                .padding(.bottom, 10)
            }
        
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

                DatePicker(selection: $workingVariables.selectedMyPen.datePurchased, displayedComponents: .date) {
                    Text("Purchase Date")
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
                
                if tempVars.imagesLoaded {
                    Button("Photos") {
                        self.showPhotoPicker = true
                    }
                        .padding(.trailing, 20)
                        .sheet(isPresented: self.$showPhotoPicker, onDismiss: { self.showPhotoPicker = false
                                self.tempVars.imagesLoaded = false }) {
                            myPenImagesView(showChild: self.$showPhotoPicker, workingVariables: self.workingVariables)
                        }
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
