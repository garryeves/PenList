//
//  carryListiPadView.swift
//  PenList
//
//  Created by Garry Eves on 5/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct carryListiPadView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @ObservedObject var tempVars: contentViewWorkingVariables
    
    @State var showEDCReview = false
    @State var showMyNotepad = false
    
    var body: some View {
        return GeometryReader { geometry in
            ZStack(alignment: .leading) {
                HStack {
             //       if currentUseList.use.count > 0 {
                        VStack {
                            Text("Carry List")
                                .font(.headline)
                            .sheet(isPresented: self.$showEDCReview, onDismiss: { self.showEDCReview = false }) {
                                EDCReviewView(tempVars: self.tempVars, showChild: self.$showEDCReview)
                                }
                            
                            List {
                                ForEach (currentUseList.use) {item in
                                    Text("\(item.penName) - \(item.inkName)")
//                                        .contextMenu {
//                                            Button("Review") {
//                                                self.tempVars.EDCItem = item
//                                                self.tempVars.rating = item.rating
//                                                self.showEDCReview = true
//                                            }
//                                            Button("Finished") {
//                                                item.dateEnded = Date()
//                                                item.save()
//                                            sleep(2)
//                                                currentUseList.reload()
//                                                self.tempVars.reloadScreen.toggle()
//                                            }
//                                    }
                                    
                                    Menu("Action to take") {
                                        Button("Review") {
                                            self.tempVars.EDCItem = item
                                            self.tempVars.rating = item.rating
                                            self.showEDCReview = true
                                        }
                                        Button("Finished") {
                                            item.dateEnded = Date()
                                            item.save()
                                        sleep(2)
                                            currentUseList.reload()
                                            self.tempVars.reloadScreen.toggle()
                                        }
                                    }
                                }
                            }
                        }
                        .frame(minWidth: 0, idealWidth: geometry.size.width/2, maxWidth: geometry.size.width/2)
               //     }
        
                    if self.tempVars.selectedPen.name != "" || self.tempVars.selectedInk.name != "" {
                        VStack (alignment: .leading){
                            HStack {
                                Spacer()
                                
                                Text("Add New Carry")
                                    .font(.headline)
                                    .padding(.top, 0)
                            
                                Spacer()
                            }
                            
                            HStack {
                                Text("Pen:")
                                    .frame(width: 40)
                                
                                Text(self.tempVars.selectedPen.name)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding(.top, 10)
                            
                            HStack {
                                Text("Ink:")
                                .frame(width: 40)

                                Text(self.tempVars.selectedInk.name)
                                    .foregroundColor(.red)
                                 
                                Spacer()
                            }
                            .padding(.top, 10)
                            
                            if self.tempVars.selectedPen.name != "" && self.tempVars.selectedInk.name != "" {
                                HStack {
                                    Spacer()
                                    
                                    Button("Add to Carry List") {
                            
                                        let temp = currentUse(newPenID: self.tempVars.selectedPen.myPenID.uuidString, newInkID: self.tempVars.selectedInk.inkID)
                                        
                                        currentUseList.append(temp)
                                        self.tempVars.selectedPen = myPen()
                                        self.tempVars.selectedInk = myInk()
                                    }
                                
                                    Spacer()
                                }
                                .padding(.top, 10)
                            }
                            Spacer()
                        }
                        Spacer()
                    } else {
                        VStack {
                            Text("Notepads")
                            .font(.headline)
                            List {
                                ForEach (currentNotepadList.activeNotepads) {item in
                                    Text("\(item.name)")
//                                        .contextMenu {
//                                            Button("Finished") {
//                                                item.finishedUsing = Date()
//                                                item.save()
//                                                sleep(2)
//                                                currentNotepadList.reload()
//                                                self.tempVars.reloadScreen.toggle()
//                                            }
//                                        }
                                    .onTapGesture {
                                        self.workingVariables.selectedMyNotepad = item
                                        self.showMyNotepad = true
                                    }
                                    .sheet(isPresented: self.$showMyNotepad, onDismiss: { self.showMyNotepad = false
                                    }) {
                                        myNotepadView(workingVariables: self.workingVariables, showChild: self.$showMyNotepad)
                                        }
                                    
                                    Menu("Action to take") {
                                        Button("Finished") {
                                            item.finishedUsing = Date()
                                            item.save()
                                            sleep(2)
                                            currentNotepadList.reload()
                                            self.tempVars.reloadScreen.toggle()
                                        }
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
