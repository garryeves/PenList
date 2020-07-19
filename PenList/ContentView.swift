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
    
    init() {
        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        
        self.workingVariables.reloadData()
    
        if manufacturerList.manufacturers.count == 0 && !self.tempVars.showManufacturers {
            self.tempVars.showManufacturers = true
        }

        return VStack {
            HStack {
                Spacer()
                Text("Pen List")
                    .font(.title)
                Spacer()
                Text("Version \(version) - \(build)")
            }
            .padding()
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    
                    VStack {
                        if manufacturerList.manufacturers.count > 0 {
                         //   if currentUseList.use.count > 0 || self.tempVars.selectedPen.penID != "" || self.tempVars.selectedInk.inkID != ""  {
                                if UIDevice.current.userInterfaceIdiom == .phone {
                                    carryListiPhoneView(workingVariables: self.workingVariables, tempVars: self.tempVars)
                                } else {
                                    carryListiPadView(workingVariables: self.workingVariables, tempVars: self.tempVars)
                                }
                //            }
                            
                            HStack {
                                VStack {
                                    HStack {
                                        HStack {
                                            Text("My Pen Collection")
                                                .font(.headline)
                                            .sheet(isPresented: self.$showMyPenPhone, onDismiss: { self.showMyPenPhone = false }) {
                                                myPenViewPhone(workingVariables: self.workingVariables, showChild: self.$showMyPenPhone)
                                                }
                                            
                                            Text(" ")
                                                .sheet(isPresented: self.$showMyPen, onDismiss: { self.showMyPen = false
                                                }) {
                                                    myPenView(workingVariables: self.workingVariables, showChild: self.$showMyPen)
                                                    }
                                        }
//                                        if self.workingVariables.myPenList.pens.count > 0 {
//                                            Button("Add to collection") {
//                                                self.workingVariables.selectedMyPen = myPen()
//                                                if UIDevice.current.userInterfaceIdiom == .phone {
//                                                    self.showMyPenPhone = true
//                                                } else {
//                                                    self.showMyPen = true
//                                                }
//                                            }
//                                            .padding(.leading, 10)
//                                            .sheet(isPresented: self.$showMyPen, onDismiss: { self.showMyPen = false
//                                            }) {
//                                                myPenView(workingVariables: self.workingVariables, showChild: self.$showMyPen)
//                                                }
//                                        }
                                    }
                                    
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
                                }
                        
                                VStack {
                                    HStack {
                                        Text("My Ink Collection")
                                            .font(.headline)
                                            .sheet(isPresented: self.$showMyInk, onDismiss: { self.showMyInk = false }) {
                                                myInkView(workingVariables: self.workingVariables, showChild: self.$showMyInk)
                                                }
                                        
//                                        if inkList.inks.count > 0 {
//                                            Button("Add to collection") {
//                                                self.workingVariables.selectedMyInk = myInk()
//                                                self.showMyInk = true
//                                            }
//                                            .padding(.leading, 10)
//                                            .sheet(isPresented: self.$showMyInk, onDismiss: { self.showMyInk = false }) {
//                                                myInkView(workingVariables: self.workingVariables, showChild: self.$showMyInk)
//                                                }
//                                        }
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
