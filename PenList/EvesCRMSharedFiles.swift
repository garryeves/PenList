//
//  EvesCRMSharedFiles.swift
//  EvesCRM
//
//  Created by Garry Eves on 19/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation


import UIKit

public let notificationCenter = NotificationCenter.default

public var myCloudDB: CloudKitInteraction!

public var debugMessages: Bool = false

public var myCurrentViewController: AnyObject!

public let greenColour = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
public let cyanColour = UIColor(red: 51/255, green: 255/255, blue: 255/255, alpha: 0.25)
public let redColour = UIColor(red: 190/255, green: 102/255, blue: 102/255, alpha: 0.25)
public let greyColour = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 0.25)
public let yellowColour = UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 0.25)
public let brownColour = UIColor(red: 255/255, green: 178/255, blue: 102/255, alpha: 0.25)
public let darkGreenColour = UIColor(red: 0.0, green: 100/255, blue: 0.0, alpha: 1.0)

public func getDeviceType() -> UIUserInterfaceIdiom
{
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    
    return deviceIdiom
}

    public class MyDocument: UIDocument
    {
        var userText: String? = "Some Sample Text"
    }

/*
 from http://stackoverflow.com/questions/24581517/read-a-file-url-line-by-line-in-swift

*/
public class StreamReader  {
    
    let encoding : UInt
    let chunkSize : Int
    
    var fileHandle : FileHandle!
    let buffer : NSMutableData!
    let delimData : Data!
    var atEof : Bool = false
    
//    init?(path: String, delimiter: String = "\r", encoding : UInt = String.Encoding.utf8, chunkSize : Int = 4096) {
    init?(path: String, delimiter: String = "\r", encoding : UInt = String.Encoding.utf8.rawValue, chunkSize : Int = 4096) {
        self.chunkSize = chunkSize
        self.encoding = encoding
        
        if let fileHandle = FileHandle(forReadingAtPath: path),
            let delimData = delimiter.data(using: String.Encoding(rawValue: encoding)),
            let buffer = NSMutableData(capacity: chunkSize)
        {
            self.fileHandle = fileHandle
            self.delimData = delimData
            self.buffer = buffer
        } else {
            self.fileHandle = nil
            self.delimData = nil
            self.buffer = nil
            return nil
        }
    }
    
    deinit {
        self.close()
    }
    
    /// Return next line, or nil on EOF.
    func nextLine() -> String? {
        precondition(fileHandle != nil, "Attempt to read from closed file")
        
        if atEof {
            return nil
        }
        
        // Read data chunks from file until a line delimiter is found:
        var range = buffer.range(of: delimData, options: [], in: NSMakeRange(0, buffer.length))
        while range.location == NSNotFound {
            let tmpData = fileHandle.readData(ofLength: chunkSize)
            if tmpData.count == 0 {
                // EOF or read error.
                atEof = true
                if buffer.length > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = NSString(data: buffer as Data, encoding: encoding)
                    
                    buffer.length = 0
                    return line as String?
                }
                // No more lines.
                return nil
            }
            buffer.append(tmpData)
            range = buffer.range(of: delimData, options: [], in: NSMakeRange(0, buffer.length))
        }
        
        // Convert complete line (excluding the delimiter) to a string:
        let line = NSString(data: buffer.subdata(with: NSMakeRange(0, range.location)),
            encoding: encoding)
        // Remove line (and the delimiter) from the buffer:
        buffer.replaceBytes(in: NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
        
        return line as String?
    }
    
    /// Start reading from the beginning of file.
    func rewind() -> Void {
        fileHandle.seek(toFileOffset: 0)
        buffer.length = 0
        atEof = false
    }
    
    /// Close the underlying file. No reading must be done after calling this method.
    func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}

    func setCellFormatting (_ cell: UITableViewCell, displayFormat: String) -> UITableViewCell
    {
        cell.textLabel!.numberOfLines = 0;
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping;
        
        if displayFormat != ""
        {
            switch displayFormat
            {
            case "Gray" :
                cell.textLabel!.textColor = .gray
                
            case "Red" :
                cell.textLabel!.textColor = .red
                
            case "Yellow" :
                cell.textLabel!.textColor = .yellow
                
            case "Orange" :
                cell.textLabel!.textColor = .orange
                
            case "Purple" :
                cell.textLabel!.textColor = .purple
                
            case "Header":
                cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 24.0)
                cell.accessoryType = .disclosureIndicator
                
            default:
                cell.textLabel!.font = UIFont.preferredFont(forTextStyle: .body)
                cell.textLabel!.textColor = .black
            }
        }
        else
        {
            cell.textLabel!.font = UIFont.preferredFont(forTextStyle: .body)
            cell.textLabel!.textColor = .black
        }
        
        return cell
    }

func fixStringForSearch(_ original: String) -> String
{
    let myTextReplacement = ";!@"  // using this as unlikely to occur naturally together
    
    let tempStr1 = original.replacingOccurrences(of: "https:", with:"https\(myTextReplacement)")
    let tempStr2 = tempStr1.replacingOccurrences(of: "http:", with:"http\(myTextReplacement)")
    let tempStr3 = tempStr2.replacingOccurrences(of: "onenote:", with:"onenote\(myTextReplacement)")
    let tempStr4 = tempStr3.replacingOccurrences(of: "0:", with:"0\(myTextReplacement)")
    let tempStr5 = tempStr4.replacingOccurrences(of: "1:", with:"1\(myTextReplacement)")
    let tempStr6 = tempStr5.replacingOccurrences(of: "2:", with:"2\(myTextReplacement)")
    let tempStr7 = tempStr6.replacingOccurrences(of: "3:", with:"3\(myTextReplacement)")
    let tempStr8 = tempStr7.replacingOccurrences(of: "4:", with:"4\(myTextReplacement)")
    let tempStr9 = tempStr8.replacingOccurrences(of: "5:", with:"5\(myTextReplacement)")
    let tempStr10 = tempStr9.replacingOccurrences(of: "6:", with:"6\(myTextReplacement)")
    let tempStr11 = tempStr10.replacingOccurrences(of: "7:", with:"7\(myTextReplacement)")
    let tempStr12 = tempStr11.replacingOccurrences(of: "8:", with:"8\(myTextReplacement)")
    let tempStr13 = tempStr12.replacingOccurrences(of: "9:", with:"9\(myTextReplacement)")
    let tempStr14 = tempStr13.replacingOccurrences(of: "(id,name,self)", with:"")
    let tempStr15 = tempStr14.replacingOccurrences(of: "/$entity,parentNotebook", with:"")
    let tempStr16 = tempStr15.replacingOccurrences(of: "\"", with:"")
    let tempStr17 = tempStr16.replacingOccurrences(of: "{", with:"")
    let tempStr18 = tempStr17.replacingOccurrences(of: "}", with:"")
    let tempStr19 = tempStr18.replacingOccurrences(of: "href:", with:"")
    let tempStr20 = tempStr19.replacingOccurrences(of: "links:", with:"")
    
    return tempStr20
}

func returnSearchStringToNormal(_ original: String) -> String
{
    let myTextReplacement = ";!@"  // using this as unlikely to occur naturally together
    
    let tempStr1 = original.replacingOccurrences(of: "https\(myTextReplacement)", with:"https:")
    let tempStr2 = tempStr1.replacingOccurrences(of: "http\(myTextReplacement)", with:"http:")
    let tempStr3 = tempStr2.replacingOccurrences(of: "onenote\(myTextReplacement)", with:"onenote:")
    let tempStr4 = tempStr3.replacingOccurrences(of: "0\(myTextReplacement)", with:"0:")
    let tempStr5 = tempStr4.replacingOccurrences(of: "1\(myTextReplacement)", with:"1:")
    let tempStr6 = tempStr5.replacingOccurrences(of: "2\(myTextReplacement)", with:"2:")
    let tempStr7 = tempStr6.replacingOccurrences(of: "3\(myTextReplacement)", with:"3:")
    let tempStr8 = tempStr7.replacingOccurrences(of: "4\(myTextReplacement)", with:"4:")
    let tempStr9 = tempStr8.replacingOccurrences(of: "5\(myTextReplacement)", with:"5:")
    let tempStr10 = tempStr9.replacingOccurrences(of: "6\(myTextReplacement)", with:"6:")
    let tempStr11 = tempStr10.replacingOccurrences(of: "7\(myTextReplacement)", with:"7:")
    let tempStr12 = tempStr11.replacingOccurrences(of: "8\(myTextReplacement)", with:"8:")
    let tempStr13 = tempStr12.replacingOccurrences(of: "9\(myTextReplacement)", with:"9:")
    
    return tempStr13
}

    public class MyDisplayCollectionViewCell: UICollectionViewCell
    {
        @IBOutlet var Label: UILabel! = UILabel()
        
        required public init?(coder aDecoder: NSCoder)
        {
            super.init(coder: aDecoder)
            Label.text = ""
        }
        
        override public init(frame: CGRect)
        {
            super.init(frame: frame)
            Label.text = ""
        }
    }

public func getDefaultDate() -> Date
{
    let dateStringFormatter = DateFormatter()
    dateStringFormatter.dateFormat = "yyyy-MM-dd"
    return dateStringFormatter.date(from: "9999-12-31")!
}

public func removeExistingViews(_ sourceView: UIView)
{
    for view in sourceView.subviews
    {
        view.removeFromSuperview()
    }
}

public func calculateAmount(numHours: Int, numMins: Double, rate: Double) -> Double
{
    var calcAmount: Double
    
    if numHours == 0 && numMins == 0
    {
        return 0.0
    }
    else
    {
        calcAmount = Double(numHours) + numMins
        return calcAmount * rate
    }
}

public class oneLabelTable: UITableViewCell
{
    @IBOutlet weak var lbl1: UILabel!
    
    override public func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

public class twoLabelTable: UITableViewCell
{
    @IBOutlet weak public var lbl1: UILabel!
    @IBOutlet weak public var lbl2: UILabel!
    
    override public func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

public class threeLabelTable: UITableViewCell
{
    @IBOutlet weak public var lbl1: UILabel!
    @IBOutlet weak public var lbl2: UILabel!
    @IBOutlet weak public var lbl3: UILabel!
    
    override public func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}
