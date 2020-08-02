//
//  ContentView.swift
//  PenList
//
//  Created by Garry Eves on 20/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class contentViewWorkingVariables: ObservableObject {

    @Published var selectedPen = myPen()
    @Published var selectedInk = myInk()

    @Published var reloadScreen = false
    
    var EDCItem = currentUse()
    
    @Published var rating: Int64 = 0
    
    @Published var showManufacturers = false
}

struct ContentView: View {
    @ObservedObject var workingVariables = mainWorkingVariables()
    
    @ObservedObject var tempVars = contentViewWorkingVariables()
    
    @State var showMyPen = false
    @State var showMyPenPhone = false
    @State var showMyInk = false
    @State var showToBuy = false
    @State var showAbout = false
    
    @State var showAllPens = false
    
    init() {
        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        self.workingVariables.reloadData()
    
        if manufacturerList.manufacturers.count == 0 && !self.tempVars.showManufacturers {
            self.tempVars.showManufacturers = true
        }

        return VStack {
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
                ZStack(alignment: .leading) {
                    
                    VStack {
                        if manufacturerList.manufacturers.count > 0 {
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                carryListiPhoneView(workingVariables: self.workingVariables, tempVars: self.tempVars)
                            } else {
                                carryListiPadView(workingVariables: self.workingVariables, tempVars: self.tempVars)
                            }
                            
                            HStack {
                                VStack {
                                    HStack {
                                        if self.showAllPens {
                                            Text("My Pen Collection")
                                                .font(.headline)
                                                .onTapGesture {
                                                    self.showAllPens.toggle()
                                                }
                                            .sheet(isPresented: self.$showMyPenPhone, onDismiss: { self.showMyPenPhone = false }) {
                                                myPenViewPhone(workingVariables: self.workingVariables, showChild: self.$showMyPenPhone)
                                                }
                                        
                                        } else {
                                            Text("My Unused Pens")
                                                .font(.headline)
                                                .onTapGesture {
                                                    self.showAllPens.toggle()
                                                }
                                            .sheet(isPresented: self.$showMyPenPhone, onDismiss: { self.showMyPenPhone = false }) {
                                                myPenViewPhone(workingVariables: self.workingVariables, showChild: self.$showMyPenPhone)
                                                }
                                        }
                                        
                                        Text(" ")
                                            .sheet(isPresented: self.$showMyPen, onDismiss: { self.showMyPen = false
                                            }) {
                                                myPenView(workingVariables: self.workingVariables, showChild: self.$showMyPen)
                                                }
                                    }
                                    
                                    if self.showAllPens {
                                        List {
                                            ForEach (self.workingVariables.myPenList.pens) {item in
                                                Text(item.name)
                                                    .contextMenu {
                                                        Button("Details") {
                                                            self.workingVariables.selectedMyPen = item
                                                            if UIDevice.current.userInterfaceIdiom == .phone {
                                                                 self.showMyPenPhone = true
                                                             } else {
                                                                 self.showMyPen = true
                                                             }
                                                        }
                                                    }
                                                    .onTapGesture {
                                                        self.tempVars.selectedPen = item
                                                    }
                                            }
                                        }
                                    } else { // show unused pens only
                                        List {
                                            ForEach (self.workingVariables.myPenList.unusedPens) {item in
                                                Text(item.name)
                                                    .contextMenu {
                                                        Button("Details") {
                                                            self.workingVariables.selectedMyPen = item
                                                            if UIDevice.current.userInterfaceIdiom == .phone {
                                                                 self.showMyPenPhone = true
                                                             } else {
                                                                 self.showMyPen = true
                                                             }
                                                        }
                                                    }
                                                    .onTapGesture {
                                                        self.tempVars.selectedPen = item
                                                    }
                                            }
                                        }
                                    }
                                }
                        
                                VStack {
                                    HStack {
                                        Text("My Ink Collection")
                                            .font(.headline)
                                            .sheet(isPresented: self.$showMyInk, onDismiss: { self.showMyInk = false }) {
                                                myInkView(workingVariables: self.workingVariables, showChild: self.$showMyInk)
                                                }
                                    }
                                    
                                    List {
                                        ForEach (self.workingVariables.myInkList.inks) {item in
                                            Text(item.name)
                                            .contextMenu {
                                                Button("Details") {
                                                    self.workingVariables.selectedMyInk = item
                                                    self.showMyInk = true
                                                }
                                            }
                                            .onTapGesture {
                                                self.tempVars.selectedInk = item
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, 15)
                
                        } else {
                            // No manufacturers yet so show onboarding
                            Text("Welcome.  The first step to take is to create a Manufacturer entry.")
                        }
                        
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
