//
//  myInkView.swift
//  PenList
//
//  Created by Garry Eves on 22/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class myInkDetailsWorkingVariables: ObservableObject {
    @Published var showManufacturer = false
    
    func triggerInkSelector() {
        DispatchQueue.global(qos: .background).async {
            sleep(1)
            DispatchQueue.main.async {
                self.showManufacturer = true
            }
        }
    }
    
    @Published var reload = false
    
    @Published var imagesLoaded = false
    
    func showPhotoButton() {
        DispatchQueue.main.async {
            self.imagesLoaded = true
        }
    }
}

struct myInkView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @Binding var showChild: Bool
    
    @ObservedObject var tempVars = myInkDetailsWorkingVariables()
    @ObservedObject var tempPhoto = selectedImageClass()
    @ObservedObject var kbDetails = KeyboardResponder()
    @State var showPhotoPicker = false
    @State var showDatePicker = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        UITableView.appearance().separatorStyle = .none
        
        if workingVariables.selectedMyInk.inkID == "" && !tempVars.showManufacturer {
            tempVars.triggerInkSelector()
        }
              
        if !workingVariables.selectedMyInk.photosLoaded {
            workingVariables.selectedMyInk.photosLoaded = true

            if !tempVars.imagesLoaded {
                DispatchQueue.global(qos: .background).async {
                        workingVariables.selectedMyInk.loadImages(tempVars: tempVars)
                }
            }
        }
        
        var borderColour = Color.black
        
        if colorScheme == .dark {
            borderColour = Color.white
        }
        
        var inkTypeText = "Select"
        
        if workingVariables.selectedMyInk.inkType != "" {
            inkTypeText = workingVariables.selectedMyInk.inkType
        }

        return VStack {
            HStack {
                Spacer()
                if workingVariables.selectedInk.manufacturer != "" {
                    Text("\(workingVariables.selectedInk.manufacturer) - \(workingVariables.selectedInk.name)")
                    .font(.title)
                    .sheet(isPresented: self.$tempVars.showManufacturer, onDismiss: { self.tempVars.showManufacturer = false }) {
                        selectInkView(workingVariables: self.workingVariables, showChild: self.$tempVars.showManufacturer)
                        }
                } else {
                    Text("\(workingVariables.selectedMyInk.manufacturer) - \(workingVariables.selectedMyInk.name)")
                    .font(.title)
                    .sheet(isPresented: self.$tempVars.showManufacturer, onDismiss: { self.tempVars.showManufacturer = false }) {
                        selectInkView(workingVariables: self.workingVariables, showChild: self.$tempVars.showManufacturer)
                        }
                }
                Spacer()
                
                Button("Close") {
                    self.workingVariables.myInkList = myInks()
                 //   self.workingVariables.reload.toggle()
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
                    
                    if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                        Menu(inkTypeText) {
                            ForEach (workingVariables.decodeList.decodesText("inkType"), id: \.self) { item in
                                Button(item) {
                                    workingVariables.selectedMyInk.inkType = item
                                    tempVars.reload.toggle()
                                }
                            }
                        }
                        .padding(.bottom, 10)
                    } else {
                        Picker("Ink Type", selection: $workingVariables.selectedMyInk.inkType) {
                            ForEach (workingVariables.decodeList.decodesText("inkType"), id: \.self) { item in
                                Text(item)
                            }
                        }
                        .padding(.bottom, 10)
                    }

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
                
                if tempVars.imagesLoaded {
                    Button("Photos") {
                        self.showPhotoPicker = true
                    }
                        .padding(.trailing, 20)
                        .sheet(isPresented: self.$showPhotoPicker, onDismiss: { self.showPhotoPicker = false
                                self.tempVars.imagesLoaded = false
                                workingVariables.selectedMyInk.photosLoaded = false
                        }) {
                            myInkPhotosView(showChild: self.$showPhotoPicker, workingVariables: self.workingVariables)
                        }
                }
            }
            .padding(.bottom, 5)
            
            GeometryReader { geometry in
                TextEditor(text: $workingVariables.selectedMyInk.notes)
                    .border(borderColour, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    .frame(width: geometry.size.width - 40, alignment: .center)
                    .padding()
            }
            
            Button("Save") {
                self.workingVariables.selectedMyInk.save()
                sleep(2)
                currentInkList = myInks()
                self.tempVars.reload.toggle()
              //  self.workingVariables.reloadPen.toggle()
            }
            .padding(.bottom, 15)
        }
        .padding(.bottom, kbDetails.currentHeight)
    }
}
