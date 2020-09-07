//
//  notepadView.swift
//  PenList
//
//  Created by Garry Eves on 7/9/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct notepadView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @ObservedObject var tempVars: contentViewWorkingVariables
    
    @State var showMyNotepad = false
    @State var showAbout = false
    @State var showToBuy = false
    
    var body: some View {
        return  VStack {
            HStack {
                Spacer()
                Text("Notepad List")
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
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: (Int(geometry.size.width) - 40) / tempVars.columnWidth)) {
                        ForEach (currentNotepadList.activeNotepads) {item in
                            VStack {
                                Text(item.manufacturer)
                                    .padding(.top, 10)
                                Text(item.name)

                                HStack {
                                    Button("Details") {
                                        self.workingVariables.selectedMyNotepad = item
                                        self.showMyNotepad = true
                                    }
                                    .sheet(isPresented: self.$showMyNotepad, onDismiss: { self.showMyNotepad = false
                                    }) {
                                        myNotepadView(workingVariables: self.workingVariables, showChild: self.$showMyNotepad)
                                        }
                                    Spacer()

                                    Button("Finished") {
                                        item.finishedUsing = Date()
                                        item.save()
                                        sleep(2)
                                        currentNotepadList.reload()
                                        self.tempVars.reloadScreen.toggle()
                                    }
                                }
                                .padding()
                            }
                            .frame(width: CGFloat(tempVars.columnWidth), alignment: .center)
                            .border(Color.black, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                            .padding()
                        }
                    }
                }
                    .background(Color.gray.opacity(0.05))
            }
        }
        
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
