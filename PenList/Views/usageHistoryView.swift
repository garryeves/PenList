//
//  usageHistoryView.swift
//  PenList
//
//  Created by Garry Eves on 13/10/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class usageWorkingVariables: ObservableObject {
    var penRecord: myPen!
    var inkRecord: myInk!
    
    var penID = ""
    var inkID = ""
    
    init() {
        
    }
    
    init(penItem: myPen) {
        penRecord = penItem
        penID = penRecord.myPenID.uuidString
    }
    
    init(inkItem: myInk) {
        inkRecord = inkItem
        inkID = inkRecord.inkID
    }
}

struct usageHistoryView: View {
    @ObservedObject var workingVariables: usageWorkingVariables
    @Binding var showChild: Bool
    
    var body: some View {
        var workingList: currentUses!
        if workingVariables.penID != "" {
            workingList = currentUses(penID: workingVariables.penID)
        } else if workingVariables.inkID != "" {
            workingList = currentUses(inkID: workingVariables.inkID)
        }
        
        return VStack {
            HStack {
                Spacer()
                
                VStack (alignment: .center) {
                    if workingVariables.penID != "" {
                        Text(workingVariables.penRecord.name)
                            .font(.title)
                    } else if workingVariables.inkID != "" {
                        Text(workingVariables.inkRecord.name)
                            .font(.title)
                    }
                    Text("Usage History")
                        .font(.title)
                }
                Spacer()
                
                Button("Close") {
                    self.showChild = false
                }
            }
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 15)
            
            if workingList == nil {
                Spacer()
                Text("Sorry, there is no history record found")
                    .font(.title)
                Spacer()
            } else if workingList.use.count == 0 {
                Spacer()
                Text("Sorry, there is no history record found")
                    .font(.title)
                Spacer()
            } else {
                List {
                    ForEach (workingList.use) { item in
                        HStack {
                            if workingVariables.penID != "" {
                                Text(item.inkName)
                            } else if workingVariables.inkID != "" {
                                Text(item.penName)
                            }

                            Spacer()

                            if item.dateEnded <= Date() {
                                Text("\(item.dateStarted.formatDateToString) - \(item.dateEnded.formatDateToString)")
                                    .frame(width: 200)
                            } else {
                                Text(item.dateStarted.formatDateToString)
                                    .frame(width: 200)
                            }
                        }.padding()
                    }
                }
               
                Spacer()
            }
        }
    }
}

