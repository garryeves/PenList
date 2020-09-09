//
//  ManufacturersListView.swift
//  PenList
//
//  Created by Garry Eves on 26/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class manufacturerListVariables: ObservableObject {
    @Published var showManufacturer = false
}

struct ManufacturersListView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    
    @ObservedObject var tempVars = manufacturerListVariables()
        
    var body: some View {
        if manufacturerList.manufacturers.count == 0 && !self.tempVars.showManufacturer {
            self.tempVars.showManufacturer = true
        }
        
        let columnWidth = 250
        
        return VStack {
            if manufacturerList.manufacturers.count == 0 {
                Text("Welcome.  The first step to take is to create a Manufacturer entry.")
            } else {
                
                GeometryReader { geometry in
                    VStack {
                        ScrollView {
                            ForEach (manufacturerList.manufacturers) {item in
                                HStack {
                                    Spacer()
                                    Text(item.name).font(.largeTitle)
                                        
                                    Spacer()
                                    
                                    Button("\(item.name) Details") {
                                        self.workingVariables.selectedManufacturer = item
                                        self.tempVars.showManufacturer = true
                                    }
                                }
                                .padding(.top, 5)
                                .padding(.bottom, 5)
                                .padding(.leading, 15)
                                .padding(.trailing, 15)
                    
                                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: (Int(geometry.size.width) - 40) / columnWidth)) {
                                    
                                    if item.penItems.count > 0 {
                                        ForEach (item.penItems) {subItem in
                                            ZStack {
                                                Rectangle()
                                                    .fill(fillColour)
                                                    .cornerRadius(10.0)

                                                Text("Pen : \(subItem.name)")
                                                    .padding(.top,15)
                                                    .padding(.bottom,15)
                                            }
                                            .frame(width: CGFloat(columnWidth), alignment: .center)
                                        }
                                    }
                                    
                                    if item.inkItems.count > 0 {
                                        ForEach (item.inkItems) {subItem in
                                            ZStack {
                                                Rectangle()
                                                    .fill(fillColour)
                                                    .cornerRadius(10.0)

                                                if subItem.inkFamily == "" {
                                                    Text("Ink : \(subItem.name)")
                                                        .padding(.top,15)
                                                        .padding(.bottom,15)
                                                } else {
                                                    Text("Ink : \(subItem.inkFamily) \(subItem.name)")
                                                        .padding(.top,15)
                                                        .padding(.bottom,15)
                                                }
                                            }
                                            .frame(width: CGFloat(columnWidth), alignment: .center)
                                        }
                                    }
                                    
                                    if item.notepadItems.count > 0 {
                                        ForEach (item.notepadItems) {subItem in
                                            ZStack {
                                                Rectangle()
                                                    .fill(fillColour)
                                                    .cornerRadius(10.0)

                                                Text("Notepad : \(subItem.name)")
                                                    .padding(.top,15)
                                                    .padding(.bottom,15)
                                            }
                                            .frame(width: CGFloat(columnWidth), alignment: .center)
                                        }
                                    }
                                }

                            }
                        }
                    }
                }
                
                Button("Add Manufacturer") {
                    self.workingVariables.selectedManufacturer = manufacturer()
                    self.tempVars.showManufacturer = true
                }
                .padding()
                .sheet(isPresented: self.$tempVars.showManufacturer, onDismiss: { self.tempVars.showManufacturer = false
                    self.workingVariables.reloadManufacturer.toggle()
                }) {
                    manufacturerView(workingVariables: self.workingVariables, showChild: self.$tempVars.showManufacturer)
                   }
            }
        }
    }
}
