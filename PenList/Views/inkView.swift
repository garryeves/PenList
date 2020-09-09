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
                                            
                                            HStack {
                                                Button("Details") {
                                                    self.workingVariables.selectedMyInk = item
                                                    self.showMyInk = true
                                                }
                                                .sheet(isPresented: self.$showMyInk, onDismiss: { self.showMyInk = false }) {
                                                    myInkView(workingVariables: self.workingVariables, showChild: self.$showMyInk)
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
                } else {
                    Spacer()
                    Text("You must create a Manufaturer first")
                        .font(.largeTitle)
                    Spacer()
                }
            }
        }
    }
}

