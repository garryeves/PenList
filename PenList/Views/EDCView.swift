//
//  EDCView.swift
//  PenList
//
//  Created by Garry Eves on 7/9/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct EDCView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @ObservedObject var tempVars: contentViewWorkingVariables
    
    @State var showMyPen = false
    @State var showMyPenPhone = false
    @State var showMyInk = false
    @State var showToBuy = false
    @State var showAbout = false
    
    @State var showAllPens = false
    
    @State var showEDCReview = false

    var body: some View {
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

            GeometryReader { geometry in
                if manufacturerList.manufacturers.count > 0 {
                    VStack {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: (Int(geometry.size.width) - 40) / tempVars.columnWidth)) {
                                ForEach (currentUseList.use) {item in
                                    VStack {
                                        Text("")
                                        Text("\(item.penManufacturer) - \(item.penName)")
                                        Text("")
                                        Text("\(item.inkManufacturer) - \(item.inkName)")
                                        Text("")
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
                                        .padding()


                                    }
                                    .frame(width: CGFloat(tempVars.columnWidth), alignment: .center)
                                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                                    .padding()
                                }
                            }
                        }

                        Text("My Unused Pens")
                            .font(.headline)
                            .padding()
                            .sheet(isPresented: self.$showMyPenPhone, onDismiss: { self.showMyPenPhone = false }) {
                                    myPenViewPhone(workingVariables: self.workingVariables, showChild: self.$showMyPenPhone)
                            }

                        ScrollView {
                            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: (Int(geometry.size.width) - 40) / tempVars.columnWidth)) {
                                ForEach (self.workingVariables.myPenList.unusedPens) {item in
                                    VStack {
                                        Text("")
                                        Text("\(item.manufacturer) - \(item.name)")
                                        Text("")
                                        HStack{
                                            Spacer()
                                            Button("Details") {
                                                self.workingVariables.selectedMyPen = item
                                                if UIDevice.current.userInterfaceIdiom == .phone {
                                                     self.showMyPenPhone = true
                                                 } else {
                                                     self.showMyPen = true
                                                 }
                                            }
                                            .sheet(isPresented: self.$showMyPenPhone, onDismiss: { self.showMyPenPhone = false }) {
                                                myPenViewPhone(workingVariables: self.workingVariables, showChild: self.$showMyPenPhone)
                                                }

                                            Spacer()
                                        }
                                        .padding()
                                    }
                                    .frame(width: CGFloat(tempVars.columnWidth), alignment: .center)
                                    .border(Color.black, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                                    .padding()
                                }
                            }
                        }

                        Text("Notepads")
                            .font(.headline)
                            .padding()

                    }
                    .background(Color.gray.opacity(0.05))
                }
            }


//                    ScrollView {
//                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: (Int(geometry.size.width) - 40) / columnWidth)) {
//                        ForEach (currentNotepadList.activeNotepads) {item in
//                            VStack {
//                                Text("\(item.name)")
//                                    .padding()
//
//                                HStack {
//                                    Button("Details") {
//                                        self.workingVariables.selectedMyNotepad = item
//                                        self.showMyNotepad = true
//                                    }
//                                    .sheet(isPresented: self.$showMyNotepad, onDismiss: { self.showMyNotepad = false
//                                    }) {
//                                        myNotepadView(workingVariables: self.workingVariables, showChild: self.$showMyNotepad)
//                                        }
//                                    Spacer()
//
//                                    Button("Finished") {
//                                        item.finishedUsing = Date()
//                                        item.save()
//                                        sleep(2)
//                                        currentNotepadList.reload()
//                                        self.tempVars.reloadScreen.toggle()
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }


                ZStack(alignment: .leading) {

                    VStack {
                        if manufacturerList.manufacturers.count > 0 {
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

                        Button("Manufacturers") {
                            self.tempVars.showManufacturers = true
                        }
                        .padding()
                        .sheet(isPresented: self.$tempVars.showManufacturers, onDismiss: { self.tempVars.showManufacturers = false }) {
                            ManufacturersListView(workingVariables: self.workingVariables, showChild: self.$tempVars.showManufacturers)
                           }

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
                    }
                }
            }
        }
    }
}
