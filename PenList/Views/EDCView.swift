//
//  EDCView.swift
//  PenList
//
//  Created by Garry Eves on 7/9/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

let fillColour = Color.gray.opacity(0.2)

class newPenWorkingVariables: ObservableObject {
    var showModalInk = pickerComms()
    var rememberedInkInt = -1
    var penListItem = myPen()
    
    @Published var showInk = false
    @Published var reload = false
    
    func processRecord(workingPenList: myPens, workingInkList: myInks) {
        if rememberedInkInt > -1 {
            var penIndex = 0
            
            var countIndex = 0
            
            for item in workingPenList.unusedPens {
                if item.myPenID == penListItem.myPenID {
                    penIndex = countIndex
                    break
                }
                countIndex += 1
            }
            workingPenList.unusedPens[penIndex].selectedInk = workingInkList.inks[rememberedInkInt]
            rememberedInkInt = -1
        }
    }
}

struct EDCView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @ObservedObject var tempVars: contentViewWorkingVariables
    @ObservedObject var newInk = newPenWorkingVariables()
    
    @State var showMyPen = false
    @State var showMyPenPhone = false
    @State var showToBuy = false
    @State var showAbout = false
    
    @State var showAllPens = false
    
    @State var showEDCReview = false
   
    var body: some View {
        if newInk.rememberedInkInt > -1 {
            newInk.processRecord(workingPenList: self.workingVariables.myPenList, workingInkList: self.workingVariables.myInkList)
        }
        
        return  VStack {
            HStack {
                Spacer()
                Text("Pen List")
                    .font(.title)
                    .onTapGesture {
                        self.showAbout.toggle()
                }
                .sheet(isPresented: self.$showAbout, onDismiss: { self.showAbout = false }) {
                    aboutScreenView(showChild: self.$showAbout)
                }
                Spacer()
            }
            .padding()

            Text("My Unused Pens")
                .font(.headline)
                .padding()
                .sheet(isPresented: self.$showMyPenPhone, onDismiss: { self.showMyPenPhone = false }) {
                    myPenViewPhone(workingVariables: self.workingVariables, showChild: self.$showMyPenPhone)
                    }
            
            GeometryReader { geometry in
                if manufacturerList.manufacturers.count > 0 {
                    VStack {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: (Int(geometry.size.width) - 40) / tempVars.columnWidth)) {
                                ForEach (currentUseList.use) {item in
                                    ZStack {
                                        Rectangle()
                                            .fill(fillColour)
                                            .cornerRadius(10.0)
                                            .frame(width: CGFloat(tempVars.columnWidth), alignment: .center)
                                    
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
                                                Text(item.inkManufacturer)                                            .padding(.leading,10)
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

                                            Button("Pen Details") {
                                                self.workingVariables.selectedMyPen = item.currentPen
                                                if UIDevice.current.userInterfaceIdiom == .phone {
                                                     self.showMyPenPhone = true
                                                 } else {
                                                     self.showMyPen = true
                                                 }
                                            }
                                            
                                            HStack{
                                                Button("Review") {
                                                    self.tempVars.EDCItem = item
                                                    self.tempVars.rating = item.rating
                                                    self.showEDCReview = true
                                                }
                                                .sheet(isPresented: self.$showEDCReview, onDismiss: { self.showEDCReview = false }) {
                                                    EDCReviewView(tempVars: self.tempVars, showChild: self.$showEDCReview)
                                                    }

                                                Spacer()
                                            
                                                Button("Finished") {
                                                    item.dateEnded = Date()
                                                    item.save()
                                                sleep(2)
                                                    currentUseList.reload()
                                                    self.tempVars.reloadScreen.toggle()
                                                }
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

                        Text("My Unused Pens")
                            .font(.headline)
                            .padding()
                            .sheet(isPresented: self.$showMyPen, onDismiss: { self.showMyPen = false }) {
                                    myPenView(workingVariables: self.workingVariables, showChild: self.$showMyPen)
                            }

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
                                            Button(item.addInkMessage) {
                                                if item.addInkMessage == defaultAddInkMessage {
                                                    self.newInk.penListItem = item
                                                    self.newInk.rememberedInkInt = -1
                                                    self.newInk.showModalInk.displayList.removeAll()
                                                    
                                                    for item in self.workingVariables.myInkList.inks {
                                                        
                                                        var tempName = "\(item.manufacturer) - \(item.name)"
                                                        if item.inkFamily != "" {
                                                            tempName = "\(item.manufacturer) - \(item.inkFamily) \(item.name)"
                                                        }
                                                        
                                                        self.newInk.showModalInk.displayList.append(displayEntry(entryText: tempName))
                                                    }
                                                    
                                                    self.newInk.showInk = true
                                                } else {
                                                    let temp = currentUse(newPenID: item.myPenID.uuidString, newInkID: item.selectedInk.inkID)
                                                    
                                                    currentUseList.append(temp)
                                                    self.workingVariables.myPenList = myPens()
                                                    newInk.reload.toggle()
                                                }
                                            }
                                            .sheet(isPresented: self.$newInk.showInk, onDismiss: { self.newInk.showInk = false }) {
                                                pickerView(displayTitle: "Select Ink", rememberedInt: self.$newInk.rememberedInkInt, showPicker: self.$newInk.showInk, showModal: self.$newInk.showModalInk)
                                                        }
                                
                                            HStack{
                                                Spacer()
                                                Button("Pen Details") {
                                                    self.workingVariables.selectedMyPen = item
                                                    if UIDevice.current.userInterfaceIdiom == .phone {
                                                         self.showMyPenPhone = true
                                                     } else {
                                                         self.showMyPen = true
                                                     }
                                                }

                                                Spacer()
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
            
//                            HStack {
//                                VStack {
//                                    HStack {
//                                        if self.showAllPens {
//                                            Text("My Pen Collection")
//                                                .font(.headline)
//                                                .onTapGesture {
//                                                    self.showAllPens.toggle()
//                                                }
//                                            .sheet(isPresented: self.$showMyPenPhone, onDismiss: { self.showMyPenPhone = false }) {
//                                                myPenViewPhone(workingVariables: self.workingVariables, showChild: self.$showMyPenPhone)
//                                                }
//
//                                        } else {
//                                            Text("My Unused Pens")
//                                                .font(.headline)
//                                                .onTapGesture {
//                                                    self.showAllPens.toggle()
//                                                }
//                                            .sheet(isPresented: self.$showMyPenPhone, onDismiss: { self.showMyPenPhone = false }) {
//                                                myPenViewPhone(workingVariables: self.workingVariables, showChild: self.$showMyPenPhone)
//                                                }
//                                        }
//
//                                        Text(" ")
//                                            .sheet(isPresented: self.$showMyPen, onDismiss: { self.showMyPen = false
//                                            }) {
//                                                myPenView(workingVariables: self.workingVariables, showChild: self.$showMyPen)
//                                                }
//                                    }
//
//                                    if self.showAllPens {
//                                        List {
//                                            ForEach (self.workingVariables.myPenList.pens) {item in
//                                                Text(item.name)
//                                                    .contextMenu {
//                                                        Button("Details") {
//                                                            self.workingVariables.selectedMyPen = item
//                                                            if UIDevice.current.userInterfaceIdiom == .phone {
//                                                                 self.showMyPenPhone = true
//                                                             } else {
//                                                                 self.showMyPen = true
//                                                             }
//                                                        }
//                                                    }
//                                                    .onTapGesture {
//                                                        self.tempVars.selectedPen = item
//                                                    }
//                                            }
//                                        }
//                                    } else { // show unused pens only
//                                        List {
//                                            ForEach (self.workingVariables.myPenList.unusedPens) {item in
//                                                Text(item.name)
//                                                    .contextMenu {
//                                                        Button("Details") {
//                                                            self.workingVariables.selectedMyPen = item
//                                                            if UIDevice.current.userInterfaceIdiom == .phone {
//                                                                 self.showMyPenPhone = true
//                                                             } else {
//                                                                 self.showMyPen = true
//                                                             }
//                                                        }
//                                                    }
//                                                    .onTapGesture {
//                                                        self.tempVars.selectedPen = item
//                                                    }
//                                            }
//                                        }
//                                    }
//                                }
//
//                                VStack {
//                                    HStack {
//                                        Text("My Ink Collection")
//                                            .font(.headline)
//                                            .sheet(isPresented: self.$showMyInk, onDismiss: { self.showMyInk = false }) {
//                                                myInkView(workingVariables: self.workingVariables, showChild: self.$showMyInk)
//                                                }
//                                    }
//
//                                    List {
//                                        ForEach (self.workingVariables.myInkList.inks) {item in
//                                            Text(item.name)
//                                            .contextMenu {
//                                                Button("Details") {
//                                                    self.workingVariables.selectedMyInk = item
//                                                    self.showMyInk = true
//                                                }
//                                            }
//                                            .onTapGesture {
//                                                self.tempVars.selectedInk = item
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(.top, 15)
//
//                        } else {
//                            // No manufacturers yet so show onboarding
//                            Text("Welcome.  The first step to take is to create a Manufacturer entry.")
//                        }

                            HStack {
                                Spacer()
                                    
                                Button("Manufacturers") {
                                    self.tempVars.showManufacturers = true
                                }
                                .padding()
                                .sheet(isPresented: self.$tempVars.showManufacturers, onDismiss: { self.tempVars.showManufacturers = false }) {
                                    ManufacturersListView(workingVariables: self.workingVariables, showChild: self.$tempVars.showManufacturers)
                                   }

                                Spacer()
                                
                                if manufacturerList.manufacturers.count > 0 {
                                    Button("To Buy") {
                                        self.showToBuy = true
                                    }
                                    .padding()
                                    .sheet(isPresented: self.$showToBuy, onDismiss: {
                                        self.showToBuy = false
                                                      }) {
                                            toBuyView(showChild: self.$showToBuy)
                                        }
                                }
                                Spacer()
                            }
                    }
                }

}
