//
//  PenListShared.swift
//  PenList
//
//  Created by Garry Eves on 21/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation

var manufacturerList = manufacturers()
var inkList = inks()
var penList = pens()
var notepadList = notepads()
var currentPenList = myPens()
var currentInkList = myInks()
var currentNotepadList = myNotepads()
var currentUseList = currentUses()

let currentPenStatusActive = "Active"
let currentPenStatusFinished = "Finished"

let currentPenStatusTypes = [currentPenStatusActive, currentPenStatusFinished]
