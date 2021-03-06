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
                            ZStack {
                                Rectangle()
                                    .fill(fillColour)
                                    .cornerRadius(10.0)
                                    .frame(width: CGFloat(tempVars.columnWidth), alignment: .center)
                                
                                VStack {
                                    Text(item.manufacturer)
                                        .padding(.top, 10)
                                    Text(item.name)

                                    Menu("Action to take") {
                                        Button("Details", action: {
                                            self.workingVariables.selectedMyNotepad = item
                                            self.showMyNotepad = true
                                        })
                                        
                                        Button("Finished", action: {
                                            item.finishedUsing = Date()
                                            item.save()
                                            sleep(2)
                                            currentNotepadList.reload()
                                            self.tempVars.reloadScreen.toggle()
                                        })
                                    }
                                    .padding(.top,5)
                                    .padding(.leading, 15)
                                    .padding(.trailing, 15)
                                    .sheet(isPresented: self.$showMyNotepad, onDismiss: { self.showMyNotepad = false
                                    }) {
                                        myNotepadView(workingVariables: self.workingVariables, showChild: self.$showMyNotepad)
                                        }
                                }
                                .padding()
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
