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
            
            HStack {
                List {
                    ForEach (manufacturerList.manufacturers) {item in
                        HStack {
                            Text(item.displayMessage)
                        }
                        .onTapGesture {
                            self.workingVariables.selectedManufacturer = item
                            self.showManufacturer = true
                        }
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

