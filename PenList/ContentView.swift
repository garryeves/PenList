//
//  ContentView.swift
//  PenList
//
//  Created by Garry Eves on 20/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

class contentViewWorkingVariables: ObservableObject {

    @Published var selectedPen = myPen()
    @Published var selectedInk = myInk()

    @Published var reloadScreen = false
    
    var EDCItem = currentUse()
    
    @Published var rating: Int64 = 0
    
    @Published var showManufacturers = false
    
    let columnWidth = 300
}

struct ContentView: View {
    @ObservedObject var workingVariables = mainWorkingVariables()
    
    @ObservedObject var tempVars = contentViewWorkingVariables()

    var body: some View {
        self.workingVariables.reloadData()
    
        if manufacturerList.manufacturers.count == 0 && !self.tempVars.showManufacturers {
            self.tempVars.showManufacturers = true
        }
        
        // The following is used to populate the decodes table.  only uncomment for the first time to be run
        
     //   workingVariables.loadDecodes()
        

        
        return TabView {
            
            EDCView(workingVariables: workingVariables, tempVars: tempVars)
                .tabItem {
                    Image(systemName: "pencil.tip")
                    Text("Pens")
                }
        
            inkView(workingVariables: workingVariables, tempVars: tempVars)
                .tabItem {
                    Image(systemName: "eyedropper")
                    Text("Ink")
                }
            
            notepadView(workingVariables: workingVariables, tempVars: tempVars)
                .tabItem {
                    Image(systemName: "book")
                    Text("Notepads")
                }
            
            ManufacturersListView(workingVariables: self.workingVariables)
                .tabItem {
                    Image(systemName: "bag")
                    Text("Manufacturers")
                }
            
            toBuyView()
                .tabItem {
                    Image(systemName: "cart")
                    Text("To Buy")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
