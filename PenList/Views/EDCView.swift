//
//  EDCView.swift
//  PenList
//
//  Created by Garry Eves on 7/9/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

let fillColour = Color(red: 190/255, green: 254/255, blue: 235/255).opacity(0.3)
// let fillColour = Color.gray.opacity(0.2)

class newPenWorkingVariables: ObservableObject {
    var penListItem = myPen()
    
    @Published var reload = false
    
    @Published var showInk = false
    
    func processRecord(selectedPen: myPen, selectedInk: myInk) {
            let temp = currentUse(newPenID: selectedPen.myPenID.uuidString, newInkID: selectedInk.inkID)

            currentUseList.append(temp)

            reload.toggle()
    }
}

struct EDCView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @ObservedObject var tempVars: contentViewWorkingVariables
    var openState : edcViewType
    
    @State var showAbout = false
   
    var body: some View {
//        print("Ignore this debug line - for some reason fails without it - \(usagePassedEntry.penID)")
        
  //      print("Device = \(UIDevice.current.identifierForVendor)")
        workingVariables.edcView = openState
        return  VStack {
//            Text("\(UIDevice.current.identifierForVendor!)")
            switch workingVariables.edcView {
                case .Inked :
                    HStack {
                        Spacer()
                        Text("My Inked Pens")
                            .font(.title)
                            .onTapGesture {
                                self.showAbout.toggle()
                            }
                            .sheet(isPresented: self.$showAbout, onDismiss: { self.showAbout = false }) {
                                aboutScreenView(showChild: self.$showAbout)
                            }
                        Spacer()
//                        Button("View My UnInked Pens") {
//                            workingVariables.edcView = .UnInked
//                        }
                    }
                    .padding()
                    if manufacturerList.manufacturers.count > 0 {
                        InkedView(workingVariables: workingVariables, tempVars: tempVars)
                    } else {
                        HStack {
                            Spacer()
                            Text("You must create a Manufacturer first")
                                .font(.largeTitle)
                            Spacer()
                        }
                    }
                
                case .UnInked:
                    HStack {
                        Spacer()
                        Text("My UnInked Pens")
                            .font(.title)
                            .onTapGesture {
                                self.showAbout.toggle()
                            }
                            .sheet(isPresented: self.$showAbout, onDismiss: { self.showAbout = false }) {
                                aboutScreenView(showChild: self.$showAbout)
                            }
                        Spacer()
//                        Button("View My Inked Pens") {
//                            workingVariables.edcView = .Inked
//                        }
                    }
                    .padding()
                    
                    if manufacturerList.manufacturers.count > 0 {
                        UnInkedView(workingVariables: workingVariables, tempVars: tempVars)
                    } else {
                        HStack {
                            Spacer()
                            Text("You must create a Manufacturer first")
                                .font(.largeTitle)
                            Spacer()
                        }
                    }
            }
        
         
            if UIDevice.current.identifierForVendor?.uuidString == "2E0C8BB8-4795-4FE9-9AD3-A8EEA4B93333" || UIDevice.current.identifierForVendor?.uuidString == "600AE059-7C8C-5CB6-BF25-8914225E43E9" || UIDevice.current.identifierForVendor?.uuidString == "C2174B0A-1FAE-4932-BC92-3E37683DDD3C" {
                Button("Refresh Airtable") {
                    processAirtable()
                }
                .padding()
            }
        }
    }
    
    func processAirtable() {
        let temp = myPens()
        
        // delete existing entries
        
        // Process Pens
        
        var manufacturerList: [String] = Array()
        
        // Delete existing Manufacturers
        
        let _ = airtablePenManufacturer(action: "DELETE")
        let _ = airtablePen(action: "DELETE")
        let _ = airtableInkManufacturer(action: "DELETE")
        let _ = airtableInk(action: "DELETE")

        
        for item in temp.pens {
            
            // Build Manufacturer list
            
            if manufacturerList.count == 0 {
                manufacturerList.append(item.manufacturer)
                let _ = airtablePenManufacturer(newmanufacturer: item.manufacturer)
            } else {
                var itemFound = false
                for check in manufacturerList {
                    if check == item.manufacturer {
                        itemFound = true
                    }
                }
                
                if !itemFound {
                    manufacturerList.append(item.manufacturer)
                    let _ = airtablePenManufacturer(newmanufacturer: item.manufacturer)
                }
            }
            
            // Process pen
            
            let _ = airtablePen(newname: item.penName, newmanufacturer: item.manufacturer, newmodel: item.model)
        }
        
        // Process inks
        
        manufacturerList.removeAll()
        
        // Build Manufacturer list
        let temp2 = myInks()
        
        for item in temp2.inks {
            
            // Build Manufacturer list
            
            if manufacturerList.count == 0 {
                manufacturerList.append(item.manufacturer)
                let _ = airtableInkManufacturer(newmanufacturer: item.manufacturer)
            } else {
                var itemFound = false
                for check in manufacturerList {
                    if check == item.manufacturer {
                        itemFound = true
                    }
                }
                
                if !itemFound {
                    manufacturerList.append(item.manufacturer)
                    let _ = airtableInkManufacturer(newmanufacturer: item.manufacturer)
                }
            }
            
            // Process Ink
            
            let _ = airtableInk(newname: item.name, newmanufacturer: item.manufacturer)
        }
        
        // process ink
    }
}

struct InkedView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @ObservedObject var tempVars: contentViewWorkingVariables
    @ObservedObject var newInk = newPenWorkingVariables()
    
    @State var showMyPen = false
    @State var showMyPenPhone = false
    @State var showHistory = false
    @State var showEDCReview = false
    
    @State var usagePassedEntry = usageWorkingVariables()
   
    var body: some View {
        //        print("Ignore this debug line - for some reason fails without it - \(usagePassedEntry.penID)")
        
        HStack {
            Text(" ")
                .sheet(isPresented: self.$showMyPenPhone, onDismiss: { self.showMyPenPhone = false
                                                            self.workingVariables.reload.toggle()
                }) {
                    myPenViewPhone(workingVariables: self.workingVariables, showChild: self.$showMyPenPhone)
                    }
            
            Text(" ")
                .sheet(isPresented: self.$showMyPen, onDismiss: { self.showMyPen = false
                                                        self.workingVariables.reload.toggle()
                }) {
                        myPenView(workingVariables: self.workingVariables, showChild: self.$showMyPen)
                }
            
            Text(" ")
                .sheet(isPresented: self.$showHistory, onDismiss: { self.showHistory = false }) {
                    usageHistoryView(workingVariables: usagePassedEntry, showChild: self.$showHistory)
                    }
            
            Text(" ")
                .sheet(isPresented: self.$showEDCReview, onDismiss: { self.showEDCReview = false }) {
                    EDCReviewView(workingVariables: self.workingVariables, tempVars: self.tempVars, showChild: self.$showEDCReview)
                    }
        }
        
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: (Int(geometry.size.width) - 40) / tempVars.columnWidth)) {
                    ForEach (currentUseList.use) {item in
                        ZStack {
                            Rectangle()
                                .fill(fillColour)
                                .cornerRadius(10.0)
                        
                            VStack {
                                Text(item.penManufacturer)
                                    .padding(.top, 10)
                                    .padding(.leading,10)
                                    .padding(.trailing,10)

                                Text(item.penName)
                                    .padding(.bottom, 5)
                                    .padding(.leading,10)
                                    .padding(.trailing,10)
                             
                                if item.inkFamily == "" {
                                    Text(item.inkManufacturer)
                                        .padding(.leading,10)
                                        .padding(.trailing,10)
                                } else {
                                    Text("\(item.inkManufacturer) - \(item.inkFamily)")
                                        .padding(.leading,10)
                                        .padding(.trailing,10)
                                }
                                
                                Text(item.inkName)
                                    .padding(.leading,10)
                                    .padding(.trailing,10)
                                    .padding(.bottom, 10)

                                Menu("Action to take") {
                                    Button("Pen Details", action: {
                                            self.workingVariables.selectedMyPen = item.currentPen
                                            if UIDevice.current.userInterfaceIdiom == .phone {
                                                 self.showMyPenPhone = true
                                             } else {
                                                 self.showMyPen = true
                                             }
                                    })
                                    
                                    Button("Review", action: {
                                            self.tempVars.EDCItem = item
                                            self.tempVars.rating = item.rating
                                            self.showEDCReview = true})
                                    
                                    Button("Finished", action: {
                                        item.dateEnded = Date()
                                        item.save()
                                        sleep(2)
                                        currentUseList.reload()
                                        self.tempVars.reloadScreen.toggle()
                                    })
                                    
                                    Button("History", action: {
                                        usagePassedEntry = usageWorkingVariables(penItem: item.currentPen)
                                        self.showHistory = true
                                    })
                                }
                                .padding(.top,5)
                                .padding(.leading, 15)
                                .padding(.trailing, 15)
                                .padding(.bottom, 15)
                            }
                        }
                        .frame(width: CGFloat(tempVars.columnWidth), alignment: .center)
                    }
                }
            }
            .padding()
        }
    }
}

struct UnInkedView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @ObservedObject var tempVars: contentViewWorkingVariables
    @ObservedObject var newInk = newPenWorkingVariables()
    
    @State var showMyPen = false
    @State var showMyPenPhone = false
    @State var showHistory = false
    @State var showEDCReview = false
    
    @State var usagePassedEntry = usageWorkingVariables()
   
    var body: some View {
        //        print("Ignore this debug line - for some reason fails without it - \(usagePassedEntry.penID)")
        
      // print("reload UnInkedView")
        
        HStack {
            Text(" ")
                .sheet(isPresented: self.$showMyPenPhone, onDismiss: { self.showMyPenPhone = false
                                                                self.workingVariables.reload.toggle()
                }) {
                    myPenViewPhone(workingVariables: self.workingVariables, showChild: self.$showMyPenPhone)
                    }
            
            Text(" ")
                .sheet(isPresented: self.$showMyPen, onDismiss: { self.showMyPen = false
                                                                self.workingVariables.reload.toggle()
                }) {
                        myPenView(workingVariables: self.workingVariables, showChild: self.$showMyPen)
                }
            
            Text(" ")
                .sheet(isPresented: self.$showHistory, onDismiss: { self.showHistory = false }) {
                    usageHistoryView(workingVariables: usagePassedEntry, showChild: self.$showHistory)
                    }
            
            Text(" ")
                .sheet(isPresented: self.$showEDCReview, onDismiss: { self.showEDCReview = false }) {
                    EDCReviewView(workingVariables: self.workingVariables, tempVars: self.tempVars, showChild: self.$showEDCReview)
                    }
        }
        
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: (Int(geometry.size.width) - 40) / tempVars.columnWidth)) {
                    ForEach (self.workingVariables.myPenList.unusedPens) {item in
                        ZStack {
                            Rectangle()
                                .fill(fillColour)
                                .cornerRadius(10.0)
                                .frame(width: CGFloat(tempVars.columnWidth), alignment: .center)

                            VStack {
                                Text("")
                                Text(item.manufacturer)
                                Text("")
                                Text(item.name)
                                Text("")
                                
                                Menu("Action to take") {
                                    // Build up list of colours
                                    ForEach (workingVariables.decodeList.decodesText("InkColour"), id: \.self) { colourItem in
                                        Menu(colourItem) {
                                            ForEach (self.workingVariables.myInkList.inksForColour(colourItem), id: \.self) { inkItem in
                                                Button("Add \(inkItem.name)") {
                                                    newInk.processRecord(selectedPen: item, selectedInk: inkItem)
                                                    workingVariables.myPenList = myPens()
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Build up list of Manufacturers
                                    
                                    Text(" ")
                                    
                                    ForEach (manufacturerList.manufacturerWithInk, id: \.self) { manItem in
                                        Menu(manItem.name) {
                                            ForEach (manItem.activeInks, id: \.self) { inkItem in
                                                Button("Add \(inkItem.name)") {
                                                    newInk.processRecord(selectedPen: item, selectedInk: inkItem)
                                                    workingVariables.myPenList = myPens()
                                                }
                                            }
                                        }
                                    }
                                    
                                    Text(" ")
                                    
                                    Button("Pen Details", action: {
                                        self.workingVariables.selectedMyPen = item
                                        if UIDevice.current.userInterfaceIdiom == .phone {
                                             self.showMyPenPhone = true
                                         } else {
                                             self.showMyPen = true
                                         }
                                    })
                                    
                                    Button("History", action: {
                                        usagePassedEntry = usageWorkingVariables(penItem: item)
                                        self.showHistory = true
                                    })
                                }
                                .padding(.top,5)
                                .padding(.leading, 15)
                                .padding(.trailing, 15)
                            }
                            .padding()
                        }
                    }
                }
            }
        }
    }
}
