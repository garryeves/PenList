//
//  extensions.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 4/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import PDFKit

extension String
{
//    var html2String:String
//    {
//        do
//        {
//            return try NSAttributedString(data: data(using: String.Encoding.utf8)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:String.Encoding.utf8], documentAttributes: nil).string
//        }
//        catch let error as NSError
//        {
//            NSLog("Warning: failed to create plain text \(error)")
//            return ""
//        }
//        catch
//        {
//            NSLog("html2String unknown error")
//            return ""
//        }
//    }
    
    public var isNumber : Bool {
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
    
    public func isDouble() -> Bool {
        
        if let doubleValue = Double(self) {
            
            if doubleValue >= 0 {
                return true
            }
        }
        
        return false
    }
    
    public func characterAtIndex(index: Int) -> Character {
        var cur = 0
        var retVal: Character!
        for char in self {
            if cur == index {
                retVal = char
            }
            cur += 1
        }
        return retVal
    }
    
    public func stringByChangingChars(oldChar: String, newChar: String) -> String
    {
        let regex = try! NSRegularExpression(pattern:oldChar, options:.caseInsensitive)
        let myString = regex.stringByReplacingMatches(in: self, options:  NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, self.count), withTemplate:newChar)
        
        return myString
    }
    
    public var getFirstPartofString: String
    {
        let start = self.startIndex
        let end = self.firstIndex(of: ":")
        
        var selectedType: String = ""
        
        if end != nil
        {
            let myEnd = self.index(before: (end)!)
            selectedType = String(self[start...myEnd])
        }
        else
        { // no space found
            selectedType = self
        }
        return selectedType
    }
    
    public var formatStringToDateTime: Date
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "E dd MMM yy HH:mm"
        return myDateFormatter.date(from: self)!
    }
    
    public var formatAirTableStringToDateTime: Date
    {
        if self != ""
        {
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000ZZZZZ"
            return myDateFormatter.date(from: self)!
        }
        return Date()
    }
    
    public var formatSimplyBookingStringToDateTime: Date
    {
        if self != ""
        {
            let myDateFormatter = DateFormatter()
            
            myDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           // myDateFormatter.dateFormat = "DDD dd MMM yy HH:mm"
            return myDateFormatter.date(from: self)!
        }
        return Date()
    }
    
    public var monthYearDecoded: String
    {
        get
        {
            if self == ""
            {
                return "Month Not Set"
            }
            else
            {
                // Split out year and month
                let indexStartOfText = self.index(self.startIndex, offsetBy: 4)
                let indexEndOfText = self.index(self.endIndex, offsetBy: -2)
                
                let yearString = String(self[..<indexEndOfText])
                let monthString = String(self[indexStartOfText...])
                
                switch monthString
                {
                    case "01":
                        return "January \(yearString)"

                    case "02":
                        return "February \(yearString)"

                    case "03":
                        return "March \(yearString)"

                    case "04":
                        return "April \(yearString)"

                    case "05":
                        return "May \(yearString)"

                    case "06":
                        return "June \(yearString)"

                    case "07":
                        return "July \(yearString)"

                    case "08":
                        return "August \(yearString)"

                    case "09":
                        return "September \(yearString)"

                    case "10":
                        return "October \(yearString)"

                    case "11":
                        return "November \(yearString)"

                    case "12":
                        return "December \(yearString)"

                    default:
                        return "Not a valid value \(monthString)"
                }
            }
        }
    }
    
    public var monthNum: Int64
    {
        switch self
        {
        case "January":
            return 1
            
        case "February":
            return 2
            
        case "March":
            return 3
            
        case "April":
            return 4
            
        case "May":
            return 5
            
        case "June":
            return 6
            
        case "July":
            return 7
            
        case "August":
            return 8
            
        case "September":
            return 9
            
        case "October":
            return 10
            
        case "November":
            return 11
            
        case "December":
            return 12
            
        default:
            print("String - monthNum - Not a valid value \(self)")
            return 0
        }
    }
    
    public var formatCurrencyNoSign: Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.locale = Locale(identifier: Locale.current.identifier)
        
        var result = -1.0
        
        if self.isDouble() {
            result = Double(self)!
        } else {
            // Check to see if the inout has currency symbol
            formatter.numberStyle = .currency
            if let number = formatter.number(from: self) {
                return number.doubleValue
            }
        }

        return result
    }
}

extension Double
{
    public var formatHours: String
    {
        // Format the hours display
        
        if self == Double(Int(self))
        {
            return "\(Int(self))"
        }
        else
        {
            return "\(self)"
        }
    }
    
    public var formatPercent: String
    {
        // Format the hours display
        
        if self == Double(Int(self))
        {
            return "\(Int(self))%"
        }
        else
        {
            let doubleStr = String(format: "%.1f", self)
            // Need to format to only 1 decimal place
            return "\(doubleStr)%"
        }
    }
    
    public var formatPercentNoSign: String {
        if self == Double(Int(self)) {
            return "\(Int(self))"
        } else {
            let doubleStr = String(format: "%.1f", self)
            // Need to format to only 1 decimal place
            return doubleStr
        }
    }
    
    public var formatCurrency: String
    {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.locale = Locale(identifier: Locale.current.identifier)
        let result = formatter.string(from: self as NSNumber);
        return result!;
    }
    
    public var formatCurrencyNoDecimal: String
    {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: Locale.current.identifier)
        let result = formatter.string(from: self as NSNumber);
        return result!;
    }
    
    public var formatCurrencyNoSign: String
    {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.locale = Locale(identifier: Locale.current.identifier)
        let result = formatter.string(from: self as NSNumber);
        return result!;
    }
    
    public var formatIntString: String
    {
        return "\(Int(self))"
    }
}

extension Date
{
    public var formatDateToYYYYMMDD: String
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "YYYY-MM-dd"
        return myDateFormatter.string(from: self)
    }
    
    public var formatDateToString: String
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "E dd MMM yy"
        return myDateFormatter.string(from: self)
    }
    
    public var formatTimeString: String
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "HH:mm"
        return myDateFormatter.string(from: self)
    }
    
    public var formatDateAndTimeString: String
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "E dd MMM yy HH:mm"
        return myDateFormatter.string(from: self)
    }
    
    public var formatDateToShortString: String
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "E dd/MM"
        return myDateFormatter.string(from: self)
    }
    
    public var formatAirTableDateTimeToString: String
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000ZZZZZ"
        return myDateFormatter.string(from: self)
    }
    
    public func dateDifferenceHours(to: Date) -> Int
    {
        return Calendar.current.dateComponents([.hour], from: self, to: to).hour ?? 0
    }
    
    public func dateDifferenceMinutes(to: Date) -> Int
    {
        // Get number of hours
        
        let numHours = self.dateDifferenceHours(to: to)
        
        let numMins = Calendar.current.dateComponents([.minute], from: self, to: to).minute ?? 0
        
        return numMins - (numHours * 60)
    }
    
    public var getDayOfWeek: Int
    {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: self)
        return weekDay
    }
    
    public func add(_ unit: Calendar.Component, amount: Int) -> Date
    {
        let myCalendar = Calendar(identifier: .gregorian)
        
        return myCalendar.date(
            byAdding: unit,
            value: Int(amount),
            to: self)!
    }
    
    public var getWeekEndingDate: Date
    {
        let dateModifier = (7 - self.getDayOfWeek) + 1
        
        if dateModifier != 7
        {
            return self.add(.day, amount: dateModifier).startOfDay
        }
        else
        {
            return self.startOfDay
        }
    }
    
    public func calculateDateForWeekDay(dayToFind: Int) -> Date
    {
        var returnDate: Date!
        var daysToAdd: Int = 0
        
        let calendar = Calendar.current
        
        var currentDateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: self)
        currentDateComponents.timeZone = TimeZone(identifier: "UTC")
        
        // Need to work out the days to add
        
        if dayToFind == currentDateComponents.weekday
        {  // The date has hit the correct day of the week
            returnDate = self
            daysToAdd = 0
        }
        else if dayToFind > currentDateComponents.weekday!
        {
            daysToAdd = dayToFind - currentDateComponents.weekday!
        }
        else
        {
            daysToAdd = 7 - currentDateComponents.weekday! + dayToFind
        }
        
        if daysToAdd > 0
        {
            returnDate = calendar.date(
                byAdding: .day,
                value: daysToAdd,
                to: self)!
        }
        
        return returnDate
    }
    
    public func calculateNewDate(dateBase: String, interval: Int, period: String) -> Date
    {
        var addCalendarUnit: Calendar.Component!
        var tempInterval = interval
        var returnDate = Date()
        
        var calendar = Calendar.current
        
        switch period
        {
            case "Day":
                addCalendarUnit = .day
                
            case "Week":
                addCalendarUnit = .day
                tempInterval = interval * 7   // fudge a there is no easy week setting
                
            case "Month":
                addCalendarUnit = .month
                
            case "Quarter":
                addCalendarUnit = .month
                tempInterval = interval * 3   // fudge a there is no easy quarter setting
                
            case "Year":
                addCalendarUnit = .year
                
            default:
                NSLog("calculateNewDate inPeriod hit default")
                addCalendarUnit = .day
        }
        
        calendar.timeZone = TimeZone.current
        
        switch dateBase
        {
            case "Completion Date", "Start Date" :
                returnDate = self.add(addCalendarUnit, amount: Int(tempInterval))
            
            case "1st of month":
                // date math to get appropriate month
                
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                var currentDateComponents = calendar.dateComponents([.year, .month], from: tempDate)
                currentDateComponents.day = 1
                
                currentDateComponents.timeZone = TimeZone(identifier: "UTC")
                
                returnDate = calendar.date(from: currentDateComponents)!
                
            case "Monday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 2)
                
            case "Tuesday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 3)
                
            case "Wednesday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 4)
                
            case "Thursday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 5)
                
            case "Friday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 6)
                
            case "Saturday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 7)
                
            case "Sunday":
                let tempDate = self.add(addCalendarUnit, amount: Int(tempInterval))
                
                returnDate = tempDate.calculateDateForWeekDay(dayToFind: 1)
                
            default:
                NSLog("calculateNewDate Bases hit default")
        }
        
        return returnDate
    }
    
    public var startOfDay: Date
    {
       // let calendar = Calendar.current
        // get the start of the day of the selected date
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        return calendar.startOfDay(for: self)
    }
    
    public var year: Int
    {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.year, from: self)
        return weekDay
    }
    
    public var month: Int
    {
        let myCalendar = Calendar(identifier: .gregorian)
        return myCalendar.component(.month, from: self)
    }
    
    public var currentMonthYear: String
    {
        let myCalendar = Calendar(identifier: .gregorian)
        let myYear = myCalendar.component(.year, from: self)
        let myMonth = myCalendar.component(.month, from: self)
        
        return "\(myYear)" + String(format: "%02d", myMonth)
    }
    
    public var weekOfMonth: Int
    {
        let myCalendar = Calendar(identifier: .gregorian)
        return myCalendar.component(.weekOfMonth, from: self)
    }
    
    public var formatMonthString: String
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "MMMM"
        return myDateFormatter.string(from: self)
    }
    
    public var formatYearString: String
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "YYYY"
        return myDateFormatter.string(from: self)
    }
    
    public var getHour: Int
    {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "HH"
        let stringValue = myDateFormatter.string(from: self)
        
        return Int(stringValue)!
    }
}

public func calculateDate(month: Int64, year: Int64) -> Date
{
//    let myDateFormatter = DateFormatter()
//
//    myDateFormatter.dateFormat = "MM"
//
    let myCalendar = Calendar(identifier: .gregorian)
//
//    let tempdate = myDateFormatter.date(from: month)
//    let monthInt = myCalendar.component(.month , from: tempdate!)
    
    var workingDate = DateComponents()
    workingDate.day = 15
    workingDate.month = Int(month)
    workingDate.year = Int(year)

    return myCalendar.date(from: workingDate)!
}

extension Double {
    var twoDP: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: self))!
    }
    
    var oneDP: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        
        return formatter.string(from: NSNumber(value: self))!
    }
}

extension Int
{
    public var monthName: String
    {
        return "\(DateFormatter().monthSymbols![Int(self - 1)])"
//        switch self
//        {
//            case 1:
//                return "January"
//
//            case 2:
//                return "February"
//
//            case 3:
//                return "March"
//
//            case 4:
//                return "April"
//
//            case 5:
//                return "May"
//
//            case 6:
//                return "June"
//
//            case 7:
//                return "July"
//
//            case 8:
//                return "August"
//
//            case 9:
//                return "September"
//
//            case 10:
//                return "October"
//
//            case 11:
//                return "November"
//
//            case 12:
//                return "December"
//
//            default:
//                return "Not a valid value \(self)"
//        }
    }
}

extension Int64
{
    public var monthName: String
    {
        return "\(DateFormatter().monthSymbols![Int(self - 1)])"
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "AvenirNext-Medium", size: 20)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let url: URL

    init(_ url: URL) {
        self.url = url
    }

    func makeUIView(context: UIViewRepresentableContext<PDFKitRepresentedView>) -> PDFKitRepresentedView.UIViewType {
        // Create a `PDFView` and set its `PDFDocument`.
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.url)
        return pdfView
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PDFKitRepresentedView>) {
        // Update the view.
    }
}

struct PDFKitView: View {
    @Binding var showchild: Bool
    var url: URL
    
    @State var sharePDF = false
    
    let activityViewController = ActivityViewController()
    
    var body: some View {
        return VStack {
            
            HStack {
                #if targetEnvironment(macCatalyst)
                Button("Share") {
                    self.activityViewController.urlEntry = fileSharingURL
                    self.activityViewController.shareFile()
                }
                #else
                    Button("Share") {
                        self.sharePDF = true
                    }
                    .sheet(isPresented: $sharePDF, onDismiss: { self.sharePDF = false }) {
                        ActivityViewControllerNew(activityItems: [self.url]) }
                #endif
                
                Spacer()
                Button("Close") {
                    self.showchild = false
                }
            }
            .padding()
            
            PDFKitRepresentedView(url)
        }
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

var currencyFormatter: NumberFormatter = {
    let f = NumberFormatter()
    // allow no currency symbol, extra digits, etc
    f.isLenient = true
    f.numberStyle = .currency
    return f
}()
