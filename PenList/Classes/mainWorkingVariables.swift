//
//  mainWorkingVariables.swift
//  PenList
//
//  Created by Garry Eves on 22/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation

enum edcViewType {
    case Inked
    case UnInked
}

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
    
    @Published var inkSort = inkSortManufacturer {
        didSet {
            if inkSort == inkSortColour {
                myInkList.sortArrayByColour()
            } else {
                myInkList.sortArrayByName()
            }
        }
    }
    
    func addPen() {
        selectedPen = pen()
        selectedPen.manID = selectedManufacturer.manID.uuidString
    }
    
    func addInk() {
        selectedInk = ink()
        selectedInk.manID = selectedManufacturer.manID.uuidString
    }
    
    func addNotepad() {
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
        myInkList = myInks(sortOrder: inkSort)
    }
    
    var decodeList = decodes()
    
    func loadDecodes() {
        let temp = populateDatabase()
        temp.loadDecodes()
        
        sleep(2)
        decodeList = decodes()
    }
    
    @Published var edcView: edcViewType = .Inked
}
