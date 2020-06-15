//
//  mainWorkingVariables.swift
//  PenList
//
//  Created by Garry Eves on 22/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation

class mainWorkingVariables: ObservableObject {
    var selectedManufacturer = manufacturer()
    
    var selectedPen = pen()
    
    var selectedInk = ink()
    
    var myPenList = myPens()
    
    var myInkList = myInks()
    
    var selectedMyPen = myPen()
    
    var selectedMyInk = myInk()
    
    func addPen() {
        if selectedManufacturer.isNew {
            if selectedManufacturer.name != "" {
                selectedManufacturer.save()
            } else { // No manufacturer details have been provided
                return
            }
        }
        selectedPen = pen()
        selectedPen.manID = selectedManufacturer.manID.uuidString
    }
    
    func addInk() {
        if selectedManufacturer.isNew {
            if selectedManufacturer.name != "" {
                selectedManufacturer.save()
            } else { // No manufacturer details have been provided
                return
            }
        }
        selectedInk = ink()
        selectedInk.manID = selectedManufacturer.manID.uuidString
    }
    
    @Published var reload = false
    
    @Published var reloadManufacturer = false
    @Published var reloadPen = false
    @Published var reloadInk = false
    
    func reloadData() {
        myPenList = myPens()
        myInkList = myInks()
    }
}
