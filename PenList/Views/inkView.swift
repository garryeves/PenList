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
    @State var showHistory = false
    @State var usagePassedEntry = usageWorkingVariables()
    
    var body: some View {
        print("Ignore this debug line - for some reason fails without it - \(usagePassedEntry.inkID)")

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
                                    ZStack {
                                        Rectangle()
                                            .fill(fillColour)
                                            .cornerRadius(10.0)
                                            .frame(width: CGFloat(tempVars.columnWidth), alignment: .center)
                                        
                                        VStack {
                                            Text("")
                                            if item.inkFamily == "" {
                                                Text(item.manufacturer)
                                            } else {
                                                Text("\(item.manufacturer) - \(item.inkFamily)")
                                            }
                                            Text(item.name)
                                            
                                            Menu("Action to take") {
                                                Button("Details", action: {
                                                    self.workingVariables.selectedMyInk = item
                                                    self.showMyInk = true
                                                })
                                                
                                                Button("Finished", action: {
                                                    item.finished = true
                                                    item.save()
                                                    sleep(2)
                                                    currentUseList.reload()
                                                    self.tempVars.reloadScreen.toggle()
                                                })
                                                
                                                Button("History", action: {
                                                    usagePassedEntry = usageWorkingVariables(inkItem: item)
                                                    self.showHistory = true
                                                })
                                            }
                                            .padding(.top,5)
                                            .padding(.leading, 15)
                                            .padding(.trailing, 15)
                                            .sheet(isPresented: self.$showMyInk, onDismiss: { self.showMyInk = false }) {
                                                myInkView(workingVariables: self.workingVariables, showChild: self.$showMyInk)
                                                }
                                        }
                                        .padding()
                                        .sheet(isPresented: self.$showHistory, onDismiss: { self.showHistory = false }) {
                                            usageHistoryView(workingVariables: usagePassedEntry, showChild: self.$showHistory)
                                            }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Spacer()
                    Text("You must create a Manufacturer first")
                        .font(.largeTitle)
                    Spacer()
                }
            }
        }
    }
}

