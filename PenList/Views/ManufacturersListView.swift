//
//  ManufacturersListView.swift
//  PenList
//
//  Created by Garry Eves on 26/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct ManufacturersListView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @Binding var showChild: Bool
    
    @State var showManufacturer = false
    
    var body: some View {
        return VStack {
            HStack {
                Spacer()
                Text("Manufacturers List")
                    .font(.title)
                Spacer()
                
                Button("Close") {
                    self.showChild = false
                }
            }
            .padding()
            
            List {
                ForEach (manufacturerList.manufacturers) {item in
                    Section(header: HStack {Spacer()
                                            Text(item.name).font(.title)
                                            Spacer() }) {
                        manufacturerItemsView(item: item)
                    }
                    .onTapGesture {
                        self.workingVariables.selectedManufacturer = item
                        self.showManufacturer = true
                    }
                }
            }
            .padding(.bottom,10)

            HStack {
                Spacer()
                                           
                Button("Add Manufacturer") {
                    self.workingVariables.selectedManufacturer = manufacturer()
                    self.showManufacturer = true
                }
                .padding()
                .sheet(isPresented: self.$showManufacturer, onDismiss: { self.showManufacturer = false }) {
                    manufacturerView(workingVariables: self.workingVariables, showChild: self.$showManufacturer)
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
