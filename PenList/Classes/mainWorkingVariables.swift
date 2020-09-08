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
    
    var selectedNotepad = notepad()
    
    var myPenList = myPens()
    
    var myInkList = myInks()
    
    var myNotepadList = myNotepads()
    
    var selectedMyPen = myPen()
    
    var selectedMyInk = myInk()
    
    var selectedMyNotepad = myNotepad()
    
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
    
    func addNotepad() {
        if selectedManufacturer.isNew {
            if selectedManufacturer.name != "" {
                selectedManufacturer.save()
            } else { // No manufacturer details have been provided
                return
            }
        }
        selectedNotepad = notepad()
        selectedNotepad.manID = selectedManufacturer.manID.uuidString
    }
    
    @Published var reload = false
    
    @Published var reloadManufacturer = false
    @Published var reloadPen = false
    @Published var reloadInk = false
    @Published var reloadNotepad = false
    @Published var reloadMyNotepad = false
    
    func reloadData() {
        myPenList = myPens()
        myInkList = myInks()
    }
    
    var decodeList = decodes()
    
    func loadDecodes() {
        let temp = populateDatabase()
        temp.loadDecodes()
        
        sleep(2)
        decodeList = decodes()
    }
}
