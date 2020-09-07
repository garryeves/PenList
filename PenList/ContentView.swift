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
    
    let columnWidth = 400
}

struct ContentView: View {
    @ObservedObject var workingVariables = mainWorkingVariables()
    
    @ObservedObject var tempVars = contentViewWorkingVariables()

    
//    init() {
//        // To remove all separators including the actual ones:
//        UITableView.appearance().separatorStyle = .none
//    }
    
    var body: some View {
        self.workingVariables.reloadData()
    
        if manufacturerList.manufacturers.count == 0 && !self.tempVars.showManufacturers {
            self.tempVars.showManufacturers = true
        }
        
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
