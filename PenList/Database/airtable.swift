//
//  airtable.swift
//  PenList
//
//  Created by Garry Eves on 25/3/21.
//  Copyright © 2021 Garry Eves. All rights reserved.
//

import Foundation

let airtableDatabase = "https://api.airtable.com/v0/applz8AAdyo6Lql2k"
let secretKey = "keyTuRCceCsEU0EmX"

class airTableCommon: ObservableObject {
    func delete (_ table: String) {
        let urlString = "\(airtableDatabase)/\(table)"
        
        let requestURL = URL(string: urlString)
        var urlRequest = URLRequest(url: requestURL!)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        
        let sem = DispatchSemaphore(value: 0)
        
        var deleteArray: [String] = Array()
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
    
            if (statusCode == 200) {
                let json = try? JSON(data: data!)
                
                for record in json!["records"] {
                    deleteArray.append(record.1["id"].string!)
                }
                
                sem.signal()
            } else  {
                print("Failed to connect")
                sem.signal()
            }
        }
        task.resume()
        
        sem.wait()
        
        performDelete(deleteArray, table: table)
    }
    
    private func performDelete(_ deleteArray: [String], table: String) {
        if deleteArray.count > 0 {
            // Only need to do something if the array has something

            var recordCount = 0
            
            var processArray: [String] = Array()
            
            for item in deleteArray {
                if recordCount == 9 {
                    runDelete(processArray, table: table)
                    processArray.removeAll()
                    recordCount = 0
                }
                
                processArray.append(item)
                recordCount += 1
            }
            
            if processArray.count > 0 {
                runDelete(processArray, table: table)
            }
        }
    }
    
    private func runDelete(_ processArray: [String], table: String) {
        let urlString = "\(airtableDatabase)/\(table)"

        var queryItems: [URLQueryItem] = Array()
        
        for item in processArray {
            queryItems.append(URLQueryItem(name: "records", value: item))
        }

        let tempurl = URL(string: "\(urlString)")
            
        var components = URLComponents(url: tempurl!, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems

        let temp: URL?
        temp = components?.url
             
        var urlRequest = URLRequest(url: temp!)

        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
            
        let sem = DispatchSemaphore(value: 0)

        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) -> Void in

            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode

            if (statusCode == 200) {
//                        let json = try? JSON(data: data!)

                sem.signal()
            } else  {
                print("Failed to connect")
                print("statusCode = \(statusCode)")
                print("Error : \(error!.localizedDescription)")
                sem.signal()
            }
        }
        task.resume()

        sem.wait()
    }
}

class airtablePens: ObservableObject  {
    private var fullStoryList: [airtablePen] = Array()
    
    init() {
        load()
    }
    
    func load()
    {
        fullStoryList.removeAll()
        
        let urlString = "\(airtableDatabase)/Pens"
        
        let requestURL = URL(string: urlString)
        var urlRequest = URLRequest(url: requestURL!)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        
        let sem = DispatchSemaphore(value: 0)
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
    
            if (statusCode == 200) {
                let json = try? JSON(data: data!)
                
                for record in json!["records"] {
                    let recordID = record.1["id"].string!
                    
                    var name = ""
                    var manufacturer = ""
                    var model = ""
                    
                    for fieldList in record.1["fields"] {
                        if fieldList.1.string != "" {
                            switch fieldList.0 {
                                case "Name":
                                    name = fieldList.1.string!

                                case "Manufacturer":
                                    manufacturer = fieldList.1.string!
                                
                                case "Model":
                                    model = fieldList.1.string!
                                
                                default:
                                    print("scheduleclass - unknown item - record = \(recordID) - \(fieldList.0) - \(fieldList.1)")
                                
                            }
                        }
                    }
                    
                    let newEntry = airtablePen(newRecordID: recordID,
                                               newname: name,
                                               newmanufacturer: manufacturer,
                                               newmodel: model)
                    
                    self.fullStoryList.append(newEntry)
                }
                
                sem.signal()
            } else  {
                print("Failed to connect")
                sem.signal()
            }
        }
        task.resume()
        
        sem.wait()
        
//        fullStoryList.sort {
//            if $0.Status == $1.Status {
//                return $0.DateScheduled < $1.DateScheduled
//            } else {
//                return $0.Status < $1.Status
//            }
//        }
//
//        setFilter(viewTypeAll)
    }
    
    var storyList : [airtablePen] {
        get {
            return fullStoryList
        }
    }
    
    func setFilter(_ filter: String) {
//        switch filter {
//            case viewTypeDrafting :
//                processedStoryList = fullStoryList.filter { $0.Status == "Drafted" || $0.Status == "Drafting" }
//
//            case viewTypeNoPodcast:
//                processedStoryList = fullStoryList.filter { $0.PodcastURL == "" && $0.Status == "Posted" }
//
//            case viewTypeNoYoutube:
//                processedStoryList = fullStoryList.filter { $0.YoutubeLink == "" && $0.Status == "Posted"}
//
//            case viewTypeReadyToStart:
//                processedStoryList = fullStoryList.filter { $0.Status == "Ready To Start" }
//
//            case viewTypePosted:
//                processedStoryList = fullStoryList.filter { $0.Status == "Posted"}
//
//            case viewTypeReadyToPost:
//                processedStoryList = fullStoryList.filter { $0.Status == "Ready To Record"}
//
//            default:
//                processedStoryList = fullStoryList
//        }
    }
}

class airtablePen: NSObject, ObservableObject, Identifiable {
    let ID = UUID()
    
    var recordID: String = ""
    var name: String = ""
    var manufacturer: String = ""
    var model: String = ""
    
    override init() {
        
    }
    
    init(newRecordID: String,
        newname: String,
        newmanufacturer: String,
        newmodel: String) {
        
       // super.init()
        
        recordID = newRecordID
        name = newname
        manufacturer = newmanufacturer
        model = newmodel

    }
    
    init(newname: String,
         newmanufacturer: String,
         newmodel: String) {
        super.init()
        
        name = newname
        manufacturer = newmanufacturer
        model = newmodel
        save()
    }
    
    init(action: String) {
        super.init()
        
        if action == "DELETE" {
            let deleteAction = airTableCommon()
            deleteAction.delete("Pens")
        }
    }
    
    func save() {
        if recordID == "" {
             // this is a new record so we POST
            
            let jsonObject: NSMutableDictionary = NSMutableDictionary()

            if name != "" {
                jsonObject.setValue(name, forKey: "Name")
              
            }
            
            if manufacturer != "" {
                jsonObject.setValue(manufacturer, forKey: "Manufacturer")
            }
            
            if model != "" {
                jsonObject.setValue(model, forKey: "Model")
            }

            let jsonObject2: NSMutableDictionary = NSMutableDictionary()
            
            jsonObject2.setValue(jsonObject, forKey: "fields")
            
            let jsonObject4: NSMutableArray = NSMutableArray()
            
            jsonObject4.add(jsonObject2)
            
            let jsonObject3: NSMutableDictionary = NSMutableDictionary()
            
            jsonObject3.setValue(jsonObject4, forKey: "records")
            
            let jsonData: Data

            do {
                jsonData = try JSONSerialization.data(withJSONObject: jsonObject3, options: JSONSerialization.WritingOptions()) as Data
//                let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//                print("Garry String = \(jsonString)")
                
                 let urlString = "\(airtableDatabase)/Pens"
                 
                 let requestURL = URL(string: urlString)
                 
                 var urlRequest = URLRequest(url: requestURL!)
                 
                 urlRequest.httpMethod = "POST"
                 urlRequest.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
                 urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                 urlRequest.httpBody = jsonData
                 
                 let sem = DispatchSemaphore(value: 0)
                 
                 let session = URLSession.shared
                 let task = session.dataTask(with: urlRequest) {
                     (data, response, error) -> Void in
                     
                     let httpResponse = response as! HTTPURLResponse
                     let statusCode = httpResponse.statusCode
             
                     if (statusCode == 200) {
                         let json = try? JSON(data: data!)
                    
                         for record in json!["records"] {
                            self.recordID = record.1["id"].string!
                        }
                       
                        sem.signal()
                     } else  {
                         print("Failed to connect")
                         print("statusCode = \(statusCode)")
                         print("Error : \(error!.localizedDescription)")
                         sem.signal()
                     }
                 }
                 task.resume()
                 
                 sem.wait()
                } catch _ {
                    print ("JSON Failure")
                }
            } else {
                    // this is a new record so we PATCH
                
                let jsonObject: NSMutableDictionary = NSMutableDictionary()

                if name != "" {
                    jsonObject.setValue(name, forKey: "Name")
                  
                }
                
                if manufacturer != "" {
                    jsonObject.setValue(manufacturer, forKey: "Manufacturer")
                }
                
                if model != "" {
                    jsonObject.setValue(model, forKey: "Model")
                }
                

                let jsonObject2: NSMutableDictionary = NSMutableDictionary()
                
                jsonObject2.setValue(recordID, forKey: "id")
                jsonObject2.setValue(jsonObject, forKey: "fields")
                
                let jsonObject4: NSMutableArray = NSMutableArray()
                
                jsonObject4.add(jsonObject2)
                
                let jsonObject3: NSMutableDictionary = NSMutableDictionary()
                
                jsonObject3.setValue(jsonObject4, forKey: "records")
                
                let jsonData: Data

                do {
                    jsonData = try JSONSerialization.data(withJSONObject: jsonObject3, options: JSONSerialization.WritingOptions()) as Data
//                    let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//                    print("Garry2 String = \(jsonString)")
                    
                    let urlString = "\(airtableDatabase)/Pens"
                    
                    let requestURL = URL(string: urlString)
                    
                    var urlRequest = URLRequest(url: requestURL!)
                    
                    urlRequest.httpMethod = "PATCH"
                    urlRequest.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
                    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.httpBody = jsonData
                    
                    let sem = DispatchSemaphore(value: 0)
                    
                    let session = URLSession.shared
                    let task = session.dataTask(with: urlRequest) {
                        (data, response, error) -> Void in
                        
                        let httpResponse = response as! HTTPURLResponse
                        let statusCode = httpResponse.statusCode
                
                        if (statusCode == 200) {
                           sem.signal()
                        } else  {
                            print("Failed to connect")
                            print("statusCode = \(statusCode)")
                            if error !=  nil {
                                print("Error : \(error!.localizedDescription)")
                            }
                            
                            sem.signal()
                        }
                    }
                    task.resume()
                    
                    sem.wait()
                } catch _ {
                    print ("JSON Failure")
                }
             }
    }
}


class airtablePenManufacturer: NSObject, ObservableObject, Identifiable {
    let ID = UUID()
    
    var recordID: String = ""
    var manufacturer: String = ""
    
//    override init() {
//
//    }
//
    init(newRecordID: String,
        newmanufacturer: String) {
        
       // super.init()
        
        recordID = newRecordID
        manufacturer = newmanufacturer

    }
    
    init(newmanufacturer: String) {
        super.init()
        
        manufacturer = newmanufacturer
        save()
    
    }
    
    init(action: String) {
        super.init()
        
        if action == "DELETE" {
            let deleteAction = airTableCommon()
            deleteAction.delete("PenManufacturers")
        }
    }
    
    func save() {
        if recordID == "" {
             // this is a new record so we POST
            
            let jsonObject: NSMutableDictionary = NSMutableDictionary()
            
            if manufacturer != "" {
                jsonObject.setValue(manufacturer, forKey: "Manufacturer")
            }

            let jsonObject2: NSMutableDictionary = NSMutableDictionary()
            
            jsonObject2.setValue(jsonObject, forKey: "fields")
            
            let jsonObject4: NSMutableArray = NSMutableArray()
            
            jsonObject4.add(jsonObject2)
            
            let jsonObject3: NSMutableDictionary = NSMutableDictionary()
            
            jsonObject3.setValue(jsonObject4, forKey: "records")
            
            let jsonData: Data

            do {
                jsonData = try JSONSerialization.data(withJSONObject: jsonObject3, options: JSONSerialization.WritingOptions()) as Data
//                let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//                print("Garry String = \(jsonString)")
                
                 let urlString = "\(airtableDatabase)/PenManufacturers"
                 
                 let requestURL = URL(string: urlString)
                 
                 var urlRequest = URLRequest(url: requestURL!)
                 
                 urlRequest.httpMethod = "POST"
                 urlRequest.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
                 urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                 urlRequest.httpBody = jsonData
                 
                 let sem = DispatchSemaphore(value: 0)
                 
                 let session = URLSession.shared
                 let task = session.dataTask(with: urlRequest) {
                     (data, response, error) -> Void in
                     
                     let httpResponse = response as! HTTPURLResponse
                     let statusCode = httpResponse.statusCode
             
                     if (statusCode == 200) {
                         let json = try? JSON(data: data!)
                    
                         for record in json!["records"] {
                            self.recordID = record.1["id"].string!
                        }
                       
                        sem.signal()
                     } else  {
                         print("Failed to connect")
                         print("statusCode = \(statusCode)")
                         print("Error : \(error!.localizedDescription)")
                         sem.signal()
                     }
                 }
                 task.resume()
                 
                 sem.wait()
                } catch _ {
                    print ("JSON Failure")
                }
            } else {
                    // this is a new record so we PATCH
                
                let jsonObject: NSMutableDictionary = NSMutableDictionary()

                if manufacturer != "" {
                    jsonObject.setValue(manufacturer, forKey: "Manufacturer")
                }

                let jsonObject2: NSMutableDictionary = NSMutableDictionary()
                
                jsonObject2.setValue(recordID, forKey: "id")
                jsonObject2.setValue(jsonObject, forKey: "fields")
                
                let jsonObject4: NSMutableArray = NSMutableArray()
                
                jsonObject4.add(jsonObject2)
                
                let jsonObject3: NSMutableDictionary = NSMutableDictionary()
                
                jsonObject3.setValue(jsonObject4, forKey: "records")
                
                let jsonData: Data

                do {
                    jsonData = try JSONSerialization.data(withJSONObject: jsonObject3, options: JSONSerialization.WritingOptions()) as Data
//                    let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//                    print("Garry2 String = \(jsonString)")
                    
                    let urlString = "\(airtableDatabase)/PenManufacturers"
                    
                    let requestURL = URL(string: urlString)
                    
                    var urlRequest = URLRequest(url: requestURL!)
                    
                    urlRequest.httpMethod = "PATCH"
                    urlRequest.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
                    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.httpBody = jsonData
                    
                    let sem = DispatchSemaphore(value: 0)
                    
                    let session = URLSession.shared
                    let task = session.dataTask(with: urlRequest) {
                        (data, response, error) -> Void in
                        
                        let httpResponse = response as! HTTPURLResponse
                        let statusCode = httpResponse.statusCode
                
                        if (statusCode == 200) {
                           sem.signal()
                        } else  {
                            print("Failed to connect")
                            print("statusCode = \(statusCode)")
                            if error !=  nil {
                                print("Error : \(error!.localizedDescription)")
                            }
                            
                            sem.signal()
                        }
                    }
                    task.resume()
                    
                    sem.wait()
                } catch _ {
                    print ("JSON Failure")
                }
             }
    }
}





class airtableInkManufacturer: NSObject, ObservableObject, Identifiable {
    let ID = UUID()
    
    var recordID: String = ""
    var manufacturer: String = ""
    
//    override init() {
//
//    }
//
    init(newRecordID: String,
        newmanufacturer: String) {
        
       // super.init()
        
        recordID = newRecordID
        manufacturer = newmanufacturer

    }
    
    init(newmanufacturer: String) {
        super.init()
        
        manufacturer = newmanufacturer
        save()
    }
    
    init(action: String) {
        super.init()
        
        if action == "DELETE" {
            let deleteAction = airTableCommon()
            deleteAction.delete("InkManufacturers")
        }
    }
    
    func save() {
        if recordID == "" {
             // this is a new record so we POST
            
            let jsonObject: NSMutableDictionary = NSMutableDictionary()
            
            if manufacturer != "" {
                jsonObject.setValue(manufacturer, forKey: "Manufacturer")
            }

            let jsonObject2: NSMutableDictionary = NSMutableDictionary()
            
            jsonObject2.setValue(jsonObject, forKey: "fields")
            
            let jsonObject4: NSMutableArray = NSMutableArray()
            
            jsonObject4.add(jsonObject2)
            
            let jsonObject3: NSMutableDictionary = NSMutableDictionary()
            
            jsonObject3.setValue(jsonObject4, forKey: "records")
            
            let jsonData: Data

            do {
                jsonData = try JSONSerialization.data(withJSONObject: jsonObject3, options: JSONSerialization.WritingOptions()) as Data
//                let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//                print("Garry String = \(jsonString)")
                
                 let urlString = "\(airtableDatabase)/InkManufacturers"
                 
                 let requestURL = URL(string: urlString)
                 
                 var urlRequest = URLRequest(url: requestURL!)
                 
                 urlRequest.httpMethod = "POST"
                 urlRequest.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
                 urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                 urlRequest.httpBody = jsonData
                 
                 let sem = DispatchSemaphore(value: 0)
                 
                 let session = URLSession.shared
                 let task = session.dataTask(with: urlRequest) {
                     (data, response, error) -> Void in
                     
                     let httpResponse = response as! HTTPURLResponse
                     let statusCode = httpResponse.statusCode
             
                     if (statusCode == 200) {
                         let json = try? JSON(data: data!)
                    
                         for record in json!["records"] {
                            self.recordID = record.1["id"].string!
                        }
                       
                        sem.signal()
                     } else  {
                         print("Failed to connect")
                         print("statusCode = \(statusCode)")
                         print("Error : \(error!.localizedDescription)")
                         sem.signal()
                     }
                 }
                 task.resume()
                 
                 sem.wait()
                } catch _ {
                    print ("JSON Failure")
                }
            } else {
                    // this is a new record so we PATCH
                
                let jsonObject: NSMutableDictionary = NSMutableDictionary()

                if manufacturer != "" {
                    jsonObject.setValue(manufacturer, forKey: "Manufacturer")
                }

                let jsonObject2: NSMutableDictionary = NSMutableDictionary()
                
                jsonObject2.setValue(recordID, forKey: "id")
                jsonObject2.setValue(jsonObject, forKey: "fields")
                
                let jsonObject4: NSMutableArray = NSMutableArray()
                
                jsonObject4.add(jsonObject2)
                
                let jsonObject3: NSMutableDictionary = NSMutableDictionary()
                
                jsonObject3.setValue(jsonObject4, forKey: "records")
                
                let jsonData: Data

                do {
                    jsonData = try JSONSerialization.data(withJSONObject: jsonObject3, options: JSONSerialization.WritingOptions()) as Data
//                    let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//                    print("Garry2 String = \(jsonString)")
                    
                    let urlString = "\(airtableDatabase)/InkManufacturers"
                    
                    let requestURL = URL(string: urlString)
                    
                    var urlRequest = URLRequest(url: requestURL!)
                    
                    urlRequest.httpMethod = "PATCH"
                    urlRequest.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
                    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.httpBody = jsonData
                    
                    let sem = DispatchSemaphore(value: 0)
                    
                    let session = URLSession.shared
                    let task = session.dataTask(with: urlRequest) {
                        (data, response, error) -> Void in
                        
                        let httpResponse = response as! HTTPURLResponse
                        let statusCode = httpResponse.statusCode
                
                        if (statusCode == 200) {
                           sem.signal()
                        } else  {
                            print("Failed to connect")
                            print("statusCode = \(statusCode)")
                            if error !=  nil {
                                print("Error : \(error!.localizedDescription)")
                            }
                            
                            sem.signal()
                        }
                    }
                    task.resume()
                    
                    sem.wait()
                } catch _ {
                    print ("JSON Failure")
                }
             }
    }
}



class airtableInks: ObservableObject  {
    private var fullStoryList: [airtableInk] = Array()
    
    init() {
        load()
    }
    
    func load()
    {
        fullStoryList.removeAll()
        
        let urlString = "\(airtableDatabase)/Inks"
        
        let requestURL = URL(string: urlString)
        var urlRequest = URLRequest(url: requestURL!)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        
        let sem = DispatchSemaphore(value: 0)
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
    
            if (statusCode == 200) {
                let json = try? JSON(data: data!)
                
                for record in json!["records"] {
                    let recordID = record.1["id"].string!
                    
                    var name = ""
                    var manufacturer = ""
                    
                    for fieldList in record.1["fields"] {
                        if fieldList.1.string != "" {
                            switch fieldList.0 {
                                case "Name":
                                    name = fieldList.1.string!

                                case "Manufacturer":
                                    manufacturer = fieldList.1.string!
                                
                                default:
                                    print("scheduleclass - unknown item - record = \(recordID) - \(fieldList.0) - \(fieldList.1)")
                                
                            }
                        }
                    }
                    
                    let newEntry = airtableInk(newRecordID: recordID,
                                               newname: name,
                                               newmanufacturer: manufacturer)
                    
                    self.fullStoryList.append(newEntry)
                }
                
                sem.signal()
            } else  {
                print("Failed to connect")
                sem.signal()
            }
        }
        task.resume()
        
        sem.wait()
        
//        fullStoryList.sort {
//            if $0.Status == $1.Status {
//                return $0.DateScheduled < $1.DateScheduled
//            } else {
//                return $0.Status < $1.Status
//            }
//        }
//
//        setFilter(viewTypeAll)
    }
    
    var storyList : [airtableInk] {
        get {
            return fullStoryList
        }
    }
    
    func setFilter(_ filter: String) {
//        switch filter {
//            case viewTypeDrafting :
//                processedStoryList = fullStoryList.filter { $0.Status == "Drafted" || $0.Status == "Drafting" }
//
//            case viewTypeNoPodcast:
//                processedStoryList = fullStoryList.filter { $0.PodcastURL == "" && $0.Status == "Posted" }
//
//            case viewTypeNoYoutube:
//                processedStoryList = fullStoryList.filter { $0.YoutubeLink == "" && $0.Status == "Posted"}
//
//            case viewTypeReadyToStart:
//                processedStoryList = fullStoryList.filter { $0.Status == "Ready To Start" }
//
//            case viewTypePosted:
//                processedStoryList = fullStoryList.filter { $0.Status == "Posted"}
//
//            case viewTypeReadyToPost:
//                processedStoryList = fullStoryList.filter { $0.Status == "Ready To Record"}
//
//            default:
//                processedStoryList = fullStoryList
//        }
    }
}

class airtableInk: NSObject, ObservableObject, Identifiable {
    let ID = UUID()
    
    var recordID: String = ""
    var name: String = ""
    var manufacturer: String = ""
    
    override init() {
        
    }
    
    init(newRecordID: String,
        newname: String,
        newmanufacturer: String) {
        
       // super.init()
        
        recordID = newRecordID
        name = newname
        manufacturer = newmanufacturer

    }
    
    init(newname: String,
         newmanufacturer: String) {
        super.init()
        
        name = newname
        manufacturer = newmanufacturer
        save()
    }
    
    init(action: String) {
        super.init()
        
        if action == "DELETE" {
            let deleteAction = airTableCommon()
            deleteAction.delete("Inks")
        }
    }
    
    func save() {
        if recordID == "" {
             // this is a new record so we POST
            
            let jsonObject: NSMutableDictionary = NSMutableDictionary()

            if name != "" {
                jsonObject.setValue(name, forKey: "Name")
              
            }
            
            if manufacturer != "" {
                jsonObject.setValue(manufacturer, forKey: "Manufacturer")
            }

            let jsonObject2: NSMutableDictionary = NSMutableDictionary()
            
            jsonObject2.setValue(jsonObject, forKey: "fields")
            
            let jsonObject4: NSMutableArray = NSMutableArray()
            
            jsonObject4.add(jsonObject2)
            
            let jsonObject3: NSMutableDictionary = NSMutableDictionary()
            
            jsonObject3.setValue(jsonObject4, forKey: "records")
            
            let jsonData: Data

            do {
                jsonData = try JSONSerialization.data(withJSONObject: jsonObject3, options: JSONSerialization.WritingOptions()) as Data
//                let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//                print("Garry String = \(jsonString)")
                
                 let urlString = "\(airtableDatabase)/Inks"
                 
                 let requestURL = URL(string: urlString)
                 
                 var urlRequest = URLRequest(url: requestURL!)
                 
                 urlRequest.httpMethod = "POST"
                 urlRequest.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
                 urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                 urlRequest.httpBody = jsonData
                 
                 let sem = DispatchSemaphore(value: 0)
                 
                 let session = URLSession.shared
                 let task = session.dataTask(with: urlRequest) {
                     (data, response, error) -> Void in
                     
                     let httpResponse = response as! HTTPURLResponse
                     let statusCode = httpResponse.statusCode
             
                     if (statusCode == 200) {
                         let json = try? JSON(data: data!)
                    
                         for record in json!["records"] {
                            self.recordID = record.1["id"].string!
                        }
                       
                        sem.signal()
                     } else  {
                         print("Failed to connect")
                         print("statusCode = \(statusCode)")
                         print("Error : \(error!.localizedDescription)")
                         sem.signal()
                     }
                 }
                 task.resume()
                 
                 sem.wait()
                } catch _ {
                    print ("JSON Failure")
                }
            } else {
                    // this is a new record so we PATCH
                
                let jsonObject: NSMutableDictionary = NSMutableDictionary()

                if name != "" {
                    jsonObject.setValue(name, forKey: "Name")
                  
                }
                
                if manufacturer != "" {
                    jsonObject.setValue(manufacturer, forKey: "Manufacturer")
                }

                let jsonObject2: NSMutableDictionary = NSMutableDictionary()
                
                jsonObject2.setValue(recordID, forKey: "id")
                jsonObject2.setValue(jsonObject, forKey: "fields")
                
                let jsonObject4: NSMutableArray = NSMutableArray()
                
                jsonObject4.add(jsonObject2)
                
                let jsonObject3: NSMutableDictionary = NSMutableDictionary()
                
                jsonObject3.setValue(jsonObject4, forKey: "records")
                
                let jsonData: Data

                do {
                    jsonData = try JSONSerialization.data(withJSONObject: jsonObject3, options: JSONSerialization.WritingOptions()) as Data
//                    let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//                    print("Garry2 String = \(jsonString)")
                    
                    let urlString = "\(airtableDatabase)/Inks"
                    
                    let requestURL = URL(string: urlString)
                    
                    var urlRequest = URLRequest(url: requestURL!)
                    
                    urlRequest.httpMethod = "PATCH"
                    urlRequest.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
                    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.httpBody = jsonData
                    
                    let sem = DispatchSemaphore(value: 0)
                    
                    let session = URLSession.shared
                    let task = session.dataTask(with: urlRequest) {
                        (data, response, error) -> Void in
                        
                        let httpResponse = response as! HTTPURLResponse
                        let statusCode = httpResponse.statusCode
                
                        if (statusCode == 200) {
                           sem.signal()
                        } else  {
                            print("Failed to connect")
                            print("statusCode = \(statusCode)")
                            if error !=  nil {
                                print("Error : \(error!.localizedDescription)")
                            }
                            
                            sem.signal()
                        }
                    }
                    task.resume()
                    
                    sem.wait()
                } catch _ {
                    print ("JSON Failure")
                }
             }
    }
}
