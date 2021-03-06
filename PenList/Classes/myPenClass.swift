//
//  myPenClass.swift
//  PenList
//
//  Created by Garry Eves on 21/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation
import SwiftUI
import CloudKit

let defaultAddInkMessage = "Select Ink"

class myPens: NSObject {
    fileprivate var myPenList: [myPen] = Array()
    
    override init() {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        
        for item in myCloudDB.getMyPen() {
            let object = myPen(passedpenID: item.penID,
                               passedcolour: item.colour,
                               passeddatePurchased: item.datePurchased,
                               passeddateSold: item.dateSold,
                               passeddesc: item.description,
                               passedlimitedEditionNumber: item.limitedEditionNumber,
                               passedname: item.name,
                               passednib: item.nib,
                               passednibMaterial: item.nibMaterial,
                               passednotes: item.notes,
                               passedprice: item.price,
                               passedpurchasedFrom: item.purchasedFrom,
                               passedrating: item.rating,
                               passedrepairInfo: item.repairInfo,
                               passedreview: item.review,
                               passedsellingPrice: item.sellingPrice,
                               passedsoldTo: item.soldTo,
                               passedstatus: item.status,
                               passedyearOfManufacture: item.yearOfManufacture,
                               passedmyPenID: item.myPenID,
                               passedSerialNo: item.serialNo)
            
            myPenList.append(object)
        }
        
        sortArrayByName()
    }
    
    func append(_ newItem: myPen){
        myPenList.append(newItem)
    }

    func sortArrayByName() {
        if myPenList.count > 1 {
            myPenList.sort {
                if $0.manufacturer == $1.manufacturer {
                    return $0.name < $1.name
                } else {
                    return $0.manufacturer < $1.manufacturer
                }
            }
        }
    }
    
    var active: [myPen] {
        get {
            var temp: [myPen] = Array()
            
            for item in myPenList {
                switch item.status {
                    case .Active :
                        temp.append(item)
                        
                    case .Finished :
                        let _ = 1
                }
            }
            
            return temp
        }
    }
    
    var pens: [myPen] {
        get {
            return myPenList
        }
    }
    
    var unusedPens: [myPen] {
        get {
            var tempList: [myPen] = Array()
            
            for item in myPenList {
                var itemFound = false
                
                for edc in currentUseList.use {
                    if item.myPenID.uuidString == edc.penID {
                        itemFound = true
                        break
                    }
                }
                
                if !itemFound {
                    tempList.append(item)
                }
            }
            
            return tempList
        }
    }
}

class myPen: NSObject, Identifiable, ObservableObject {
    var myPenID = UUID()
    var penID = ""
    var colour = ""
    var datePurchased = Date()
    var dateSold = getDefaultDate()
    var desc = ""
    var limitedEditionNumber = ""
    var name = ""
    var nib = ""
    var nibMaterial = ""
    var notes = ""
    var price = 0.0
    var purchasedFrom = ""
    var rating: Int64 = 0
    var repairInfo = ""
    var review = ""
    var sellingPrice = 0.0
    var soldTo = ""
    var status = penStatus.Active
    var yearOfManufacture = ""
    var photoList: myPenPhotos?
    var loadedImages: [tempImages] = Array()
    var serialNo = ""
    
    var addInkMessage = defaultAddInkMessage
    
    private var storedInk = myInk()
    
    var selectedInk: myInk {
        get {
            return storedInk
        }
        set {
            if newValue.name != "" {
                var tempName = "\(newValue.manufacturer) - \(newValue.name)"
                if newValue.inkFamily != "" {
                    tempName = "\(newValue.manufacturer) - \(newValue.inkFamily) \(newValue.name)"
                }
                addInkMessage = "Add \(tempName)"
                storedInk = newValue
            } else {
                addInkMessage = defaultAddInkMessage
            }
        }
    }
    
    var isNew = true

    var cost: String {
        get {
            return price.formatCurrency
        }
        set {
            if newValue.isDouble() {
                price = Double(newValue)!
            } else {
                let working = newValue.formatCurrencyNoSign
                if working != -1.0 {
                    price = working
                }
            }
        }
    }
    
    var soldFor: String {
        get {
            return sellingPrice.formatCurrency
        }
        set {
            if newValue.isDouble() {
                sellingPrice = Double(newValue)!
            } else {
                let working = newValue.formatCurrencyNoSign
                if working != -1.0 {
                    sellingPrice = working
                }
            }
        }
    }
    
    var manufacturer: String {
        get {
            for item in penList.pens {
                if item.penID.uuidString == penID {
                    return item.manufacturer
                }
            }
            
            return ""
        }
        set {
            for item in manufacturerList.manufacturers {
                if item.name == newValue {
                    for workingPen in penList.pens {
                        if workingPen.penID.uuidString == penID {
                            workingPen.manID = item.manID.uuidString
                        }
                    }
                }
            }
        }
    }
    
    var penName: String {
        get {
            for item in currentPenList.pens {
                if item.myPenID.uuidString == myPenID.uuidString {
                    return item.name
                }
            }
            
            return ""
        }
    }
    
    var model: String {
        get {
            for item in penList.pens {
                if item.penID.uuidString == penID {
                    return item.name
                }
            }
            
            return ""
        }
    }
    var images: myPenPhotos {
        get {
            if photoList == nil {
                photoList = myPenPhotos(penID: myPenID.uuidString)
            }
            return photoList!
        }
    }
    
    override init() {
        super.init()
    }
    
    init(passedpenID: String,
         passedcolour: String,
         passeddatePurchased: Date,
         passeddateSold: Date,
         passeddesc: String,
         passedlimitedEditionNumber: String,
         passedname: String,
         passednib: String,
         passednibMaterial: String,
         passednotes: String,
         passedprice: Double,
         passedpurchasedFrom: String,
         passedrating: Int64,
         passedrepairInfo: String,
         passedreview: String,
         passedsellingPrice: Double,
         passedsoldTo: String,
         passedstatus: String,
         passedyearOfManufacture: String,
         passedmyPenID: String,
         passedSerialNo: String) {
        super.init()
        
        penID = passedpenID
        colour = passedcolour
        datePurchased = passeddatePurchased
        dateSold = passeddateSold
        desc = passeddesc
        limitedEditionNumber = passedlimitedEditionNumber
        name = passedname
        nib = passednib
        nibMaterial = passednibMaterial
        notes = passednotes
        price = passedprice
        purchasedFrom = passedpurchasedFrom
        rating = passedrating
        repairInfo = passedrepairInfo
        review = passedreview
        sellingPrice = passedsellingPrice
        soldTo = passedsoldTo
        switch passedstatus {
            case "Active" :
                status = .Active
            default :
                status = .Finished
        }
        yearOfManufacture = passedyearOfManufacture
        myPenID = UUID(uuidString: passedmyPenID)!
        serialNo = passedSerialNo
        
        isNew = false
    }
    
    init(passedpenID: String,
         passedname: String,
         passednotes: String) {
        super.init()
        
        penID = passedpenID
        datePurchased = Date()
        name = passedname
        notes = passednotes

        isNew = false
        
        save()
    }

    func save()
    {
        var tempStatus = ""
        
        switch status {
            case .Active:
                tempStatus = "Active"
                
            case .Finished:
                tempStatus = "Finished"
        }
        
        let temp = MyPen(colour: colour,
                         datePurchased: datePurchased,
                         dateSold: dateSold,
                         description: desc,
                         limitedEditionNumber: limitedEditionNumber,
                         name: name,
                         nib: nib,
                         nibMaterial: nibMaterial,
                         notes: notes,
                         penID: penID,
                         price: price,
                         purchasedFrom: purchasedFrom,
                         rating: rating,
                         repairInfo: repairInfo,
                         review:review,
                         sellingPrice: sellingPrice,
                         soldTo: soldTo,
                         status: tempStatus,
                         yearOfManufacture: yearOfManufacture,
                         myPenID: myPenID.uuidString,
                         serialNo: serialNo)
            
        myCloudDB.saveMyPen(temp)
    }
    
    func loadImages(tempVars: myPenDetailsWorkingVariables) {
        if images.photos.count > 0 {
            if loadedImages.count == 0 {
                for item in images.photos {
                    
                    let temp = tempImages(passedId: item.myPhotoID, image: item.decodedImage)
                    
                    loadedImages.append(temp)
                }
                tempVars.showPhotoButton()
            } else {
                tempVars.showPhotoButton()
            }
        } else {
            tempVars.showPhotoButton()
        }
    }

//    func addPhoto(_ photoID: Image) {
    func addPhoto(_ photoID: UIImage) {
        let tempPhoto = myPenPhoto(passedpenID: myPenID.uuidString, passedinkID: "", passedtype: "Pen", passedimage: photoID, passeduseID: "")
        images.append(tempPhoto)
        
   //     let temp = tempImages(passedId: tempPhoto.myPhotoID, image: photoID)
        let temp = tempImages(passedId: tempPhoto.myPhotoID, image: tempPhoto.decodedImage)
        loadedImages.append(temp)
    }
}

struct MyPen {
    public var colour: String
    public var datePurchased: Date
    public var dateSold: Date
    public var description: String
    public var limitedEditionNumber: String
    public var name: String
    public var nib: String
    public var nibMaterial: String
    public var notes: String
    public var penID: String
    public var price: Double
    public var purchasedFrom: String
    public var rating: Int64
    public var repairInfo: String
    public var review: String
    public var sellingPrice: Double
    public var soldTo: String
    public var status: String
    public var yearOfManufacture: String
    public var myPenID: String
    public var serialNo: String
}

extension CloudKitInteraction {
    private func populateMyPen(_ records: [CKRecord]) -> [MyPen] {
        var tempArray: [MyPen] = Array()
        
        for record in records {
            let tempItem = MyPen(colour: decodeString(record.object(forKey: "colour")),
                                 datePurchased: decodeDate(record.object(forKey: "datePurchased")),
                                 dateSold: decodeDate(record.object(forKey: "dateSold")),
                                 description: decodeString(record.object(forKey: "description")),
                                 limitedEditionNumber: decodeString(record.object(forKey: "limitedEditionNumber")),
                                 name: decodeString(record.object(forKey: "name")),
                                 nib: decodeString(record.object(forKey: "nib")),
                                 nibMaterial: decodeString(record.object(forKey: "nibMaterial")),
                                 notes: decodeString(record.object(forKey: "notes")),
                                 penID: decodeString(record.object(forKey: "penID")),
                                 price: decodeDouble(record.object(forKey: "price")),
                                 purchasedFrom: decodeString(record.object(forKey: "purchasedFrom")),
                                 rating: decodeInt64(record.object(forKey: "rating")),
                                 repairInfo: decodeString(record.object(forKey: "repairInfo")),
                                 review: decodeString(record.object(forKey: "review")),
                                 sellingPrice: decodeDouble(record.object(forKey: "sellingPrice")),
                                 soldTo: decodeString(record.object(forKey: "soldTo")),
                                 status: decodeString(record.object(forKey: "status")),
                                 yearOfManufacture: decodeString(record.object(forKey: "yearOfManufacture")),
                                 myPenID: decodeString(record.object(forKey: "myPenID")),
                                 serialNo: decodeString(record.object(forKey: "serialNo"))
                                 )
            
            tempArray.append(tempItem)
        }
        
        return tempArray
    }
    
    func getMyPen()->[MyPen] {
     //   let predicate = NSPredicate(format: "TRUEPREDICATE")
        let predicate = NSPredicate(format: "dateSold == %@", getDefaultDate() as CVarArg)

        let query = CKQuery(recordType: "myPen", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()
        
        return populateMyPen(returnArray)
    }

    func saveMyPen(_ sourceRecord: MyPen) {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "myPenID == \"\(sourceRecord.myPenID)\"") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "myPen", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else {
                if records!.count > 0 {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record!.setValue(sourceRecord.colour, forKey: "colour")
                    record!.setValue(sourceRecord.datePurchased, forKey: "datePurchased")
                    record!.setValue(sourceRecord.dateSold, forKey: "dateSold")
                    record!.setValue(sourceRecord.description, forKey: "description")
                    record!.setValue(sourceRecord.limitedEditionNumber, forKey: "limitedEditionNumber")
                    record!.setValue(sourceRecord.name, forKey: "name")
                    record!.setValue(sourceRecord.nib, forKey: "nib")
                    record!.setValue(sourceRecord.nibMaterial, forKey: "nibMaterial")
                    record!.setValue(sourceRecord.notes, forKey: "notes")
                    record!.setValue(sourceRecord.price, forKey: "price")
                    record!.setValue(sourceRecord.purchasedFrom, forKey: "purchasedFrom")
                    record!.setValue(sourceRecord.rating, forKey: "rating")
                    record!.setValue(sourceRecord.repairInfo, forKey: "repairInfo")
                    record!.setValue(sourceRecord.review, forKey: "review")
                    record!.setValue(sourceRecord.sellingPrice, forKey: "sellingPrice")
                    record!.setValue(sourceRecord.soldTo, forKey: "soldTo")
                    record!.setValue(sourceRecord.status, forKey: "status")
                    record!.setValue(sourceRecord.yearOfManufacture, forKey: "yearOfManufacture")
                    record!.setValue(sourceRecord.serialNo, forKey: "serialNo")
                    
                    // Save this record again
                    self.privateDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
                            sem.signal()
                        } else {
                            if debugMessages {
                                NSLog("Successfully updated record!")
                            }
                            sem.signal()
                        }
                    })
                } else {  // Insert
                    let record = CKRecord(recordType: "myPen")
                    record.setValue(sourceRecord.penID, forKey: "penID")
                    record.setValue(sourceRecord.datePurchased, forKey: "datePurchased")
                    record.setValue(sourceRecord.colour, forKey: "colour")
                    record.setValue(sourceRecord.dateSold, forKey: "dateSold")
                    record.setValue(sourceRecord.description, forKey: "description")
                    record.setValue(sourceRecord.limitedEditionNumber, forKey: "limitedEditionNumber")
                    record.setValue(sourceRecord.name, forKey: "name")
                    record.setValue(sourceRecord.nib, forKey: "nib")
                    record.setValue(sourceRecord.nibMaterial, forKey: "nibMaterial")
                    record.setValue(sourceRecord.notes, forKey: "notes")
                    record.setValue(sourceRecord.price, forKey: "price")
                    record.setValue(sourceRecord.purchasedFrom, forKey: "purchasedFrom")
                    record.setValue(sourceRecord.rating, forKey: "rating")
                    record.setValue(sourceRecord.repairInfo, forKey: "repairInfo")
                    record.setValue(sourceRecord.review, forKey: "review")
                    record.setValue(sourceRecord.sellingPrice, forKey: "sellingPrice")
                    record.setValue(sourceRecord.soldTo, forKey: "soldTo")
                    record.setValue(sourceRecord.status, forKey: "status")
                    record.setValue(sourceRecord.yearOfManufacture, forKey: "yearOfManufacture")
                    record.setValue(sourceRecord.myPenID, forKey: "myPenID")
                    record.setValue(sourceRecord.serialNo, forKey: "serialNo")
                    
                    self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
                            sem.signal()
                        } else {
                            if debugMessages {
                                NSLog("Successfully saved record!")
                            }
                            sem.signal()
                        }
                    })
                }
            }
        })
        sem.wait()
    }
}

