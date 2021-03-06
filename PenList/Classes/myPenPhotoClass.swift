//
//  myPenPhotoClass.swift
//  PenList
//
//  Created by Garry Eves on 21/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit

//class manufacturers: NSObject {
//    fileprivate var myManufacturers: [manufacturer] = Array()
//
//    override init() {
//        super.init()
//
//        for item in myCloudDB.getManufacturers() {
//            let object = manufacturer(passedmanID: item.manID,
//                                      passedname: item.name,
//                                      passednotes: item.notes,
//                                      passedcountry: item.country)
//            myManufacturers.append(object)
//        }
//
//        sortArrayByName()
//    }
//
//    func append(_ newItem: manufacturer){
//        myManufacturers.append(newItem)
//    }
//
//    func sortArrayByName() {
//        if myManufacturers.count > 1 {
//            myManufacturers.sort {
//                if $0.name == $1.name {
//                    return $0.country < $1.country
//                } else {
//                    return $0.name < $1.name
//                }
//            }
//        }
//    }
//
//    var manufacturers: [manufacturer] {
//        get {
//            return myManufacturers
//        }
//    }
//}
//
//class manufacturer: NSObject, Identifiable, ObservableObject {
//    var manID = UUID()
//    var name = ""
//    var notes = ""
//    var country = ""
//    var isNew = true
//
//    override init() {
//        super.init()
//    }
//
//    init(passedmanID: String,
//         passedname: String,
//         passednotes: String,
//         passedcountry: String) {
//        super.init()
//        manID = UUID(uuidString: passedmanID)!
//        name = passedname
//        notes = passednotes
//        country = passedcountry
//        isNew = false
//    }
//
//    func save()
//    {
//        let temp = Manufacturer(country: country,
//                                manID: manID.uuidString,
//                                name: name,
//                                notes: notes)
//
//        myCloudDB.saveManufacturer(temp)
//    }
//}
//
//struct MyPenPhoto {
//    public var inkID: String
//    public var photo: CKAsset
//}
//
//extension CloudKitInteraction {
//    private func populateMyInkPhoto(_ records: [CKRecord]) -> [MyInkPhoto] {
//        var tempArray: [Manufacturer] = Array()
//
//        for record in records {
//            let tempItem = MyInkPhoto(country: decodeString(record.object(forKey: "country")),
//                                    manID: decodeString(record.object(forKey: "manID")),
//                                    name: decodeString(record.object(forKey: "name")),
//                                    notes: decodeString(record.object(forKey: "notes")))
//
//            tempArray.append(tempItem)
//        }
//
//        return tempArray
//    }
//
//    func getMyInkPhoto()->[MyInkPhoto] {
//        let predicate = NSPredicate(format: "TRUEPREDICATE")
//
//        let query = CKQuery(recordType: "manufacturer", predicate: predicate)
//        let sem = DispatchSemaphore(value: 0)
//        fetchPrivateServices(query: query, sem: sem, completion: nil)
//
//        sem.wait()
//
//        return populateManufacturer(returnArray)
//    }
//
//    func saveMyInkPhoto(_ sourceRecord: MyInkPhoto) {
//        let sem = DispatchSemaphore(value: 0)
//        let predicate = NSPredicate(format: "manID == \"\(sourceRecord.manID)\"") // better be accurate to get only the record you need
//        let query = CKQuery(recordType: "manufacturer", predicate: predicate)
//        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
//            if error != nil {
//                NSLog("Error querying records: \(error!.localizedDescription)")
//            }
//            else {
//                if records!.count > 0 {
//                    let record = records!.first// as! CKRecord
//                    // Now you have grabbed your existing record from iCloud
//                    // Apply whatever changes you want
//                    record!.setValue(sourceRecord.manID, forKey: "manID")
//                    record!.setValue(sourceRecord.country, forKey: "country")
//                    record!.setValue(sourceRecord.name, forKey: "name")
//                    record!.setValue(sourceRecord.notes, forKey: "notes")
//
//                    // Save this record again
//                    self.privateDB.save(record!, completionHandler: { (savedRecord, saveError) in
//                        if saveError != nil {
//                            NSLog("Error saving record: \(saveError!.localizedDescription)")
//                            self.saveOK = false
//                            sem.signal()
//                        } else {
//                            if debugMessages {
//                                NSLog("Successfully updated record!")
//                            }
//                            sem.signal()
//                        }
//                    })
//                } else {  // Insert
//                    let record = CKRecord(recordType: "manufacturer")
//                    record.setValue(sourceRecord.manID, forKey: "manID")
//                    record.setValue(sourceRecord.country, forKey: "country")
//                    record.setValue(sourceRecord.name, forKey: "name")
//                    record.setValue(sourceRecord.notes, forKey: "notes")
//
//                    self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
//                        if saveError != nil {
//                            NSLog("Error saving record: \(saveError!.localizedDescription)")
//                            self.saveOK = false
//                            sem.signal()
//                        } else {
//                            if debugMessages {
//                                NSLog("Successfully saved record!")
//                            }
//                            sem.signal()
//                        }
//                    })
//                }
//            }
//        })
//        sem.wait()
//    }
//}

