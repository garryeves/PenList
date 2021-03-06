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
        for item in myCloudDB.getPenPhoto(penID: penID) {
            let object = myPenPhoto(passedmyPhotoID: item.myPhotoID,
                                    passedpenID: item.penID,
                                    passedinkID: item.inkID,
                                    passedtype: item.type,
                                    passedimage: item.photo,
                                    passeduseID: item.useID)

            myPenList.append(object)
        }
        
        for item in myCloudDB.getPenPhoto(inkID: penID) {
            let object = myPenPhoto(passedmyPhotoID: item.myPhotoID,
                                    passedpenID: item.penID,
                                    passedinkID: item.inkID,
                                    passedtype: item.type,
                                    passedimage: item.photo,
                                    passeduseID: item.useID)

            myPenList.append(object)
        }
        
        for item in myCloudDB.getPenPhoto(useID: penID) {
            let object = myPenPhoto(passedmyPhotoID: item.myPhotoID,
                                    passedpenID: item.penID,
                                    passedinkID: item.inkID,
                                    passedtype: item.type,
                                    passedimage: item.photo,
                                    passeduseID: item.useID)

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
    var inkID = ""
    var useID = ""
    var type = ""
//    var image: Image?
//    var image: UIImage?
    var image: Data?
    var saveCalled = false

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
    
//    var compressedImage : Image? {
//        if image != nil {
//            return image!
//        } else {
//            return nil
//        }
//    }
    
//    var decodedImage: Image {
 //   var decodedImage: UIImage {
    var decodedImage: Data {
       // return UIImage(data: image!)!
        return image!
        //return Image(uiImage: image!)
    }
    
    override init() {
        super.init()
    }
    
//    init(passedpenID: String,
//         passedinkID: String,
//         passedtype: String,
//  //       passedimage: Image?,
//  //       passedimage: UIImage?,
//         passedimage: Data?,
//         passeduseID: String) {
//        super.init()
//
//        penID = passedpenID
//        inkID = passedinkID
//        useID = passeduseID
//        type = passedtype
//        image = passedimage
//
//        save()
//    }
    
    init(passedpenID: String,
         passedinkID: String,
         passedtype: String,
  //       passedimage: Image?,
         passedimage: UIImage?,
  //       passedimage: Data?,
         passeduseID: String) {
        super.init()
        
        penID = passedpenID
        inkID = passedinkID
        useID = passeduseID
        type = passedtype
        image = compressImage(passedimage!)

        save()
    }
    
    init(passedmyPhotoID: String,
         passedpenID: String,
         passedinkID: String,
         passedtype: String,
//         passedimage: Image?,
 //        passedimage: UIImage?,
         passedimage: Data?,
         passeduseID: String) {
        super.init()
        
        penID = passedpenID
        inkID = passedinkID
        useID = passeduseID
        type = passedtype
        image = passedimage
        myPhotoID = UUID(uuidString: passedmyPhotoID)!
        saveCalled = true
        isNew = false
    }

    func save()
    {
        let temp = MyPenPhoto(myPhotoID: myPhotoID.uuidString,
                              penID: penID,
                              inkID: inkID,
                              useID: useID,
                              photo: image,
                              type: type)
            
        myCloudDB.saveMyPen(temp)
        
        saveCalled = true
    }
}

struct MyPenPhoto {
    public var myPhotoID: String
    public var penID: String
    public var inkID: String
    public var useID: String
//    public var photo: Image?
//    public var photo: UIImage?
    public var photo: Data?
    public var type: String
}

extension CloudKitInteraction {
    private func populateMyPenPhoto(_ records: [CKRecord]) -> [MyPenPhoto] {
        var tempArray: [MyPenPhoto] = Array()
        
        for record in records {
            if record.object(forKey: "photo") != nil {
    //            var tempimage: UIImage!
                var imageData: Data = Data()
    //            var photo: Image!
                
                if let asset = record["photo"] as? CKAsset {
                    imageData = try! Data(contentsOf: (asset.fileURL!))
                    
                    let imgData = NSData(data: imageData)
                    let imageSize: Int = imgData.count
                    print("retrieved actual size of image in KB: %f ", Double(imageSize) / 1000.0)
                    
                    
                    
              //      tempimage = UIImage(data: data!)
 //                   photo = Image(uiImage: tempimage!)
                    }
                let tempItem = MyPenPhoto(myPhotoID: decodeString(record.object(forKey: "myPhotoID")),
                                          penID: decodeString(record.object(forKey: "penID")),
                                          inkID: decodeString(record.object(forKey: "inkID")),
                                          useID: decodeString(record.object(forKey: "useID")),
                                          photo: imageData,
                                    //      photo: tempimage,
//                                          photo: photo,
                                          type: decodeString(record.object(forKey: "type")))
                
                tempArray.append(tempItem)
            }
        }
        
        return tempArray
    }
    
    func getPenPhoto(penID: String)->[MyPenPhoto] {
        let predicate = NSPredicate(format: "penID == \"\(penID)\"")

        let query = CKQuery(recordType: "myPenPhoto", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()

        return populateMyPenPhoto(returnArray)
    }
    
    func getPenPhoto(inkID: String)->[MyPenPhoto] {
        let predicate = NSPredicate(format: "(inkID == \"\(inkID)\")")

        let query = CKQuery(recordType: "myPenPhoto", predicate: predicate)
        let sem = DispatchSemaphore(value: 0)
        fetchPrivateServices(query: query, sem: sem, completion: nil)
        
        sem.wait()

        return populateMyPenPhoto(returnArray)
    }
    
    func getPenPhoto(useID: String)->[MyPenPhoto] {
        let predicate = NSPredicate(format: "(useID == \"\(useID)\")")

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
        
        if sourceRecord.photo != nil {
//            let workingImage = sourceRecord.photo!.asUIImage()
            
            privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if error != nil {
                    NSLog("Error querying records: \(error!.localizedDescription)")
                }
                else {
                    if records!.count > 0 {
//                        let record = records!.first// as! CKRecord
//                        // Now you have grabbed your existing record from iCloud
//                        // Apply whatever changes you want
//                        record!.setValue(sourceRecord.type, forKey: "type")
//
//                        var imageURL: URL!
//                        let tempImageName = "photo.jpg"
//                        let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
//
////                        let imageData: Data = workingImage.jpegData(compressionQuality: 1.0)!
//                        let imageData: Data = sourceRecord.photo!.jpegData(compressionQuality: 1.0)!
//                        let path = "\(documentsPathString!)/\(tempImageName)"
//                        try? sourceRecord.photo!.jpegData(compressionQuality: 1.0)!.write(to: URL(fileURLWithPath: path), options: [.atomic])
//                        imageURL = URL(fileURLWithPath: path)
//                        try? imageData.write(to: imageURL, options: [.atomic])
//
//                        let File:CKAsset? = CKAsset(fileURL: URL(fileURLWithPath: path))
//                        record!.setObject(File, forKey: "photo")
//
//                        // Save this record again
//                        self.privateDB.save(record!, completionHandler: { (savedRecord, saveError) in
//                            if saveError != nil {
//                                NSLog("Error saving record: \(saveError!.localizedDescription)")
//                                self.saveOK = false
//                                sem.signal()
//                            } else {
//                                if debugMessages {
//                                    NSLog("Successfully updated record!")
//                                }
//                                sem.signal()
//                            }
//                        })
                    } else {  // Insert
                        let record = CKRecord(recordType: "myPenPhoto")
                        
                        record.setValue(sourceRecord.myPhotoID, forKey: "myPhotoID")
                        record.setValue(sourceRecord.penID, forKey: "penID")
                        record.setValue(sourceRecord.inkID, forKey: "inkID")
                        record.setValue(sourceRecord.useID, forKey: "useID")
                        record.setValue(sourceRecord.type, forKey: "type")

                        var imageURL: URL!
                        let tempImageName = "photo.jpg"
                        let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
       
                        let imageData = sourceRecord.photo
                        
//                        var sizematched = false
//
//                        var compressionamount: CGFloat = 1.0
//
//                        var imageData: Data?
//
//                        while !sizematched {
//
//                            let squashedImageData: Data = sourceRecord.photo!.jpegData(compressionQuality: compressionamount)!
//
//                            let squashedImageSize: Int = squashedImageData.count
//
////                            print("Compressions ratio = \(compressionamount)")
////                            print("compressed size of image in KB: %f ", Double(squashedImageSize) / 1000.0)
//
//                            if squashedImageSize < 501 {
//                                imageData = squashedImageData
//                                sizematched = true
//                            }
//
//                            if compressionamount <= 0.11 {
//                                imageData = squashedImageData
//                                sizematched = true
//                            }
//
//                            compressionamount -= 0.1
//                        }
                        
                        let imageSize: Int = imageData!.count
                        print("save size of image in KB: %f ", Double(imageSize) / 1000.0)
                        
                        let path = "\(documentsPathString!)/\(tempImageName)"
//                        try? sourceRecord.photo!.jpegData(compressionQuality: 1.0)!.write(to: URL(fileURLWithPath: path), options: [.atomic])
                        imageURL = URL(fileURLWithPath: path)
                        try? imageData?.write(to: imageURL, options: [.atomic])

                        let File:CKAsset? = CKAsset(fileURL: URL(fileURLWithPath: path))
                        record.setObject(File, forKey: "photo")
                        
                        self.privateDB.save(record, completionHandler: { (savedRecord, saveError) in
                            if saveError != nil {
                                NSLog("Error saving record: \(saveError!.localizedDescription)")
        print("Garry - save error")
                                self.saveOK = false
                                sem.signal()
                            } else {
        print("Garry - save was good")
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
}



extension View {
// This function changes our View to UIView, then calls another function
// to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
// here is the call to the function that converts UIView to UIImage: `.asImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
