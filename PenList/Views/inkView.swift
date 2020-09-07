//
//  inkView.swift
//  PenList
//
//  Created by Garry Eves on 7/9/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct inkView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @ObservedObject var tempVars: contentViewWorkingVariables
    
    @State var showToBuy = false
    @State var showAbout = false
    @State var showMyInk = false
    
    var body: some View {
        return  VStack {
            HStack {
                Spacer()
                Text("Ink List")
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
                                ForEach (self.workingVariables.myInkList.inks) {item in
                                    VStack {
                                        if item.inkFamily == "" {
                                            Text("\(item.manufacturer) - \(item.name)")
                                                .padding()
                                        } else {
                                            Text("\(item.manufacturer) - \(item.inkFamily) \(item.name)")
                                                .padding()
                                        }
                                        
                                        HStack {
                                            Button("Details") {
                                                self.workingVariables.selectedMyInk = item
                                                self.showMyInk = true
                                            }
                                            
                                            Spacer()
                                            
                                            Button("Finished") {
                                                item.finished = true
                                                item.save()
                                            sleep(2)
                                                currentUseList.reload()
                                                self.tempVars.reloadScreen.toggle()
                                            }
                                        }
                                        .padding()
    //                                    .onTapGesture {
    //                                        self.tempVars.selectedInk = item
    //                                    }
                                    }
                                }
                                .frame(width: CGFloat(tempVars.columnWidth), alignment: .center)
                                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                                .padding()
                            }
                        }
                        .background(Color.gray.opacity(0.05))

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

