//
//  penImageClass.swift
//  PenList
//
//  Created by Garry Eves on 12/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import Foundation
import CloudKit
import SwiftUI

class myPenPhotos: NSObject {
    fileprivate var myPenList: [myPenPhoto] = Array()
    
    override init() {
        super.init()
    }
    
    init(penID: String) {
        super.init()
        
        if myCloudDB == nil {
            myCloudDB = CloudKitInteraction()
        }
        for item in myCloudDB.getPenPhoto(penID) {
            let object = myPenPhoto(passedmyPhotoID: item.myPhotoID,
                                    passedpenID: item.penID,
                                    passedtype: item.type,
                                    passedimage: item.photo)

            myPenList.append(object)
        }
    }
    
    func append(_ newItem: myPenPhoto){
        myPenList.append(newItem)
    }
    
    var photos: [myPenPhoto] {
        get {
            return myPenList
        }
    }
}

class myPenPhoto: NSObject, Identifiable, ObservableObject {
    var myPhotoID = UUID()
    var penID = ""
    var type = ""
    var image: UIImage?

    var isNew = true

    var penName: String {
        get {
            for item in currentPenList.pens {
                if item.myPenID.uuidString == penID {
                    return item.name
                }
            }
            
            return ""
        }
    }
    
    var decodedImage: Image {
        return Image(uiImage: image!)
    }
    
    override init() {
        super.init()
    }
    
    init(passedpenID: String,
         passedtype: String,
         passedimage: UIImage?) {
        super.init()
        
        penID = passedpenID
        type = passedtype
        image = passedimage

        save()
    }
    
    init(passedmyPhotoID: String,
         passedpenID: String,
         passedtype: String,
         passedimage: UIImage?) {
        super.init()
        
        penID = passedpenID
        type = passedtype
        image = passedimage
        myPhotoID = UUID(uuidString: passedmyPhotoID)!
        
        isNew = false
    }

    func save()
    {
        let temp = MyPenPhoto(myPhotoID: myPhotoID.uuidString,
                              penID: penID,
                              photo: image,
                              type: type)
            
        myCloudDB.saveMyPen(temp)
    }
}

struct MyPenPhoto {
    public var myPhotoID: String
    public var penID: String
    public var photo: UIImage?
    public var type: String
}

extension CloudKitInteraction {
    private func populateMyPenPhoto(_ records: [CKRecord]) -> [MyPenPhoto] {
        var tempArray: [MyPenPhoto] = Array()
        
        for record in records {
            if record.object(forKey: "photo") != nil {
                var photo: UIImage!
                
                if let asset = record["photo"] as? CKAsset,
                    let data = try? Data(contentsOf: (asset.fileURL!)),
                    let image = UIImage(data: data) {
                        photo = image
                    }
                let tempItem = MyPenPhoto(myPhotoID: decodeString(record.object(forKey: "myPhotoID")),
                                          penID: decodeString(record.object(forKey: "penID")),
                                          photo: photo,
                                          type: decodeString(record.object(forKey: "type")))
                
                tempArray.append(tempItem)
            }
        }
        
        return tempArray
    }
    
    func getPenPhoto(_ penID: String)->[MyPenPhoto] {
        let predicate = NSPredicate(format: "penID == \"\(penID)\"")

        let query = CKQuery(recordType: "myPenPhoto", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()

        return populateMyPenPhoto(returnArray)
    }

    func saveMyPen(_ sourceRecord: MyPenPhoto) {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "myPhotoID == \"\(sourceRecord.myPhotoID)\"") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "myPenPhoto", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else {
                if records!.count > 0 {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    record!.setValue(sourceRecord.type, forKey: "type")

                    if sourceRecord.photo != nil {
                        var imageURL: URL!
                        let tempImageName = "photo.jpg"
                        let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                        
                        let imageData: Data = sourceRecord.photo!.jpegData(compressionQuality: 1.0)!
                        let path = "\(documentsPathString!)/\(tempImageName)"
                        try? sourceRecord.photo!.jpegData(compressionQuality: 1.0)!.write(to: URL(fileURLWithPath: path), options: [.atomic])
                        imageURL = URL(fileURLWithPath: path)
                        try? imageData.write(to: imageURL, options: [.atomic])

                        let File:CKAsset? = CKAsset(fileURL: URL(fileURLWithPath: path))
                        record!.setObject(File, forKey: "photo")
                    }
          
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
                    let record = CKRecord(recordType: "myPenPhoto")
                    
                    record.setValue(sourceRecord.myPhotoID, forKey: "myPhotoID")
                    record.setValue(sourceRecord.penID, forKey: "penID")
                    record.setValue(sourceRecord.type, forKey: "type")

                    if sourceRecord.photo != nil {
                        var imageURL: URL!
                        let tempImageName = "photo.jpg"
                        let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                        
                        let imageData: Data = sourceRecord.photo!.jpegData(compressionQuality: 1.0)!
                        let path = "\(documentsPathString!)/\(tempImageName)"
                        try? sourceRecord.photo!.jpegData(compressionQuality: 1.0)!.write(to: URL(fileURLWithPath: path), options: [.atomic])
                        imageURL = URL(fileURLWithPath: path)
                        try? imageData.write(to: imageURL, options: [.atomic])

                        let File:CKAsset? = CKAsset(fileURL: URL(fileURLWithPath: path))
                        record.setObject(File, forKey: "photo")
                    }
                    
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

