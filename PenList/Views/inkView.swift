//
//  inkView.swift
//  PenList
//
//  Created by Garry Eves on 7/9/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class inkViewWorkingVariables: ObservableObject {
    @Published var showAbout = false
    @Published var showMyInk = false
    @Published var showHistory = false
}

struct inkView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @ObservedObject var tempVars: contentViewWorkingVariables
    
//    @State var showAbout = false
//    @State var showMyInk = false
//    @State var showHistory = false
    @State var usagePassedEntry = usageWorkingVariables()
    @ObservedObject var inkTemp = inkViewWorkingVariables()
    
    var body: some View {
        print("Ignore this ink debug line - for some reason fails without it - \(usagePassedEntry.inkID)")

        return  VStack {
            HStack {
                Spacer()
                Text("Ink List")
                    .font(.title)
                    .onTapGesture {
                        self.inkTemp.showAbout.toggle()
                }
                    .sheet(isPresented: self.$inkTemp.showAbout, onDismiss: { self.inkTemp.showAbout = false }) {
                    aboutScreenView(showChild: self.$inkTemp.showAbout)
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
                                            .sheet(isPresented: self.$inkTemp.showMyInk, onDismiss: { self.inkTemp.showMyInk = false }) {
                                                myInkView(workingVariables: self.workingVariables, showChild: self.$inkTemp.showMyInk)
                                                }
                                        
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
                                                    self.inkTemp.showMyInk = true
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
                                                    self.inkTemp.showHistory = true
                                                })
                                            }
                                            .padding(.top,5)
                                            .padding(.leading, 15)
                                            .padding(.trailing, 15)
                                        }
                                        .padding()
                                        .sheet(isPresented: self.$inkTemp.showHistory, onDismiss: { self.inkTemp.showHistory = false }) {
                                            usageHistoryView(workingVariables: usagePassedEntry, showChild: self.$inkTemp.showHistory)
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

