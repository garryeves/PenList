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
//    @Binding var showChild: Bool
    
    @ObservedObject var tempVars = manufacturerListVariables()
    
    
    var body: some View {
        if manufacturerList.manufacturers.count == 0 && !self.tempVars.showManufacturer {
            self.tempVars.showManufacturer = true
        }
        
        return VStack {
//            HStack {
//                Spacer()
//                Text("Manufacturers List")
//                    .font(.title)
//                Spacer()
//
//                Button("Close") {
//                    self.showChild = false
//                }
//            }
//            .padding()
            
            if manufacturerList.manufacturers.count == 0 {
                Text("Welcome.  The first step to take is to create a Manufacturer entry.")
            } else {
                List {
                    ForEach (manufacturerList.manufacturers) {item in
                        Section(header: HStack {Spacer()
                                                Text(item.name).font(.title)
                                                Spacer() }) {
                            manufacturerItemsView(item: item)
                        }
                        .onTapGesture {
                            self.workingVariables.selectedManufacturer = item
                            self.tempVars.showManufacturer = true
                        }
                    }
                }
                .padding(.bottom,10)
            }

            HStack {
                Spacer()
                                           
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
               
                Spacer()
            }
        }
    }
}

struct manufacturerItemsView: View {
    var item: manufacturer
    
    var body: some View {
        return HStack {
            if item.penItems.count > 0 {
                if item.penItems.count == 1 {
                    Text("1 pen       ")
                } else {
                    Text("\(item.penItems.count) pens      ")
                }
            }
            if item.inkItems.count > 0 {
                if item.inkItems.count == 1 {
                    Text("1 ink       ")
                }
                else {
                    Text("\(item.inkItems.count) inks       ")
                }
            }
            if item.notepadItems.count > 0 {
                if item.notepadItems.count == 1 {
                    Text("1 notepad")
                }
                else {
                    Text("\(item.notepadItems.count) notepads")
                }
            }
        }
    }
}
