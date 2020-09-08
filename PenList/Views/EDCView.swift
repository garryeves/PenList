//
//  EDCView.swift
//  PenList
//
//  Created by Garry Eves on 7/9/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

let fillColour = Color(red: 190/255, green: 254/255, blue: 235/255).opacity(0.2)
// let fillColour = Color.gray.opacity(0.2)

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

            Text("My EDC Pens")
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
                                                Text(item.inkManufacturer)                             .padding(.leading,10)
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
                                    .frame(width: CGFloat(tempVars.columnWidth), alignment: .center)
                                }
                            }
                        }
                        .frame(height: geometry.size.height * 0.6 )
                        .padding()
                        
                        VStack {
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
                        .padding()
                    }
                }
            }
            

//                        } else {
//                            // No manufacturers yet so show onboarding
//                            Text("Welcome.  The first step to take is to create a Manufacturer entry.")
//                        }


                    }
                }

}
