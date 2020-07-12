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

let fillerCartridge = "Cartridge"
let fillerPiston = "Built-In Piston"
let fillerVacuum = "Built-In Vacuum"
let fillerEyedropper = "Eyedropper"

let fillerSystems = [fillerCartridge, fillerPiston, fillerVacuum, fillerEyedropper]

let inkTypeCartridge = "Cartridge"
let inkTypeBottle = "Bottle"

let inkTypes = [inkTypeCartridge, inkTypeBottle]

let nibExtraFine = "Extra fine"
let nibFine = "Fine"
let nibMedium = "Medium"
let nibBroad = "Broad"
let nibAnfanger = "Anfanger"
let nibItalic = "Italic"
let nibStub = "Stub"
let nibNeedlepoint = "Needlepoint"
let nibExtraBroad = "Extra-broad"
let nibExtraExtraBroad = "Extra-extra-broad"
let nibObliqueMediumBroad = "Oblique medium/broad"
let nibLeftHand = "Left hand"
let niboundedMedium = "Rounded medium"
let nibMusic = "Music"
let nibZoon = "Zoon"
let nibReverseObliqueMedium = "Reverse oblique medium"

let nibTypes = [nibExtraFine, nibFine, nibMedium, nibBroad, nibAnfanger, nibItalic, nibStub, nibNeedlepoint, nibExtraBroad, nibExtraExtraBroad, nibObliqueMediumBroad, nibLeftHand, niboundedMedium, nibMusic, nibZoon, nibReverseObliqueMedium]

let nibMaterialSteel = "Steel"
let nibMaterialGold = "Gold"

let nibMaterialTypes = [nibMaterialSteel, nibMaterialGold]
