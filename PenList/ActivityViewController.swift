//
//  ActivityViewController.swift
//  evesShared
//
//  Created by Garry Eves on 28/7/19.
//  Copyright © 2019 Garry Eves. All rights reserved.
//

import SwiftUI

var sharingPDF: Data!
var sharingText: String!
var sharingImage: UIImage!
var fileSharingURL: URL!

public let shareExclutionArray = [ UIActivity.ActivityType.addToReadingList,
                                   //UIActivityType.airDrop,
    UIActivity.ActivityType.assignToContact,
    //        UIActivityType.CopyToPasteboard,
    //        UIActivityType.message,
    //        UIActivityType.Mail,
    UIActivity.ActivityType.openInIBooks,
    UIActivity.ActivityType.postToFlickr,
    UIActivity.ActivityType.postToTwitter,
    UIActivity.ActivityType.postToFacebook,
    UIActivity.ActivityType.postToTencentWeibo,
    UIActivity.ActivityType.postToVimeo,
    UIActivity.ActivityType.postToWeibo,
    //        Print,
    UIActivity.ActivityType.saveToCameraRoll
]

struct SwiftUIActivityViewController : UIViewControllerRepresentable {

    let activityViewController = ActivityViewController()

    func makeUIViewController(context: Context) -> ActivityViewController {
        activityViewController
    }
    func updateUIViewController(_ uiViewController: ActivityViewController, context: Context) {
        //
    }
    func shareImage(uiImage: UIImage) {
        activityViewController.uiImage = uiImage
        activityViewController.shareImage()
    }
    
    func shareText(textEntry: String) {
        activityViewController.textEntry = textEntry
        activityViewController.shareText()
    }
    
    func sharePDF(pdfData: Data) {
        activityViewController.pdfData = pdfData
        activityViewController.sharePDF()
    }
}


struct SwiftUIActivityViewControllerText : UIViewControllerRepresentable {
    
    let activityViewController = ActivityViewController()

    init() {
        activityViewController.textEntry = sharingText
        activityViewController.shareText()
    }
    
    func makeUIViewController(context: Context) -> ActivityViewController {
        activityViewController
    }
    func updateUIViewController(_ uiViewController: ActivityViewController, context: Context) {
        //
    }
}

struct SwiftUIActivityViewControllerImage : UIViewControllerRepresentable {

    var pdfData: Data!
    
    let activityViewController = ActivityViewController()

    init() {
        activityViewController.uiImage = sharingImage
        activityViewController.shareImage()
    }
    
    func makeUIViewController(context: Context) -> ActivityViewController {
        activityViewController
    }
    func updateUIViewController(_ uiViewController: ActivityViewController, context: Context) {
        //
    }
}


class ActivityViewController : UIViewController {
//struct ActivityViewController : UIViewControllerRepresentable {
     
    
    var pdfData: Data?
    var textEntry: String?
    var uiImage:UIImage!
    var urlEntry: URL?

//    override func viewDidAppear(_ animated: Bool) {
//        sharePDF()
//    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        if pdfData != nil {
//            sharePDF()
//        } else if uiImage != nil {
//            shareImage()
//        } else if urlEntry != nil {
//            shareFile()
//        } else {
//            shareText()
//        }
//    }
    
    func shareImage() {
        let vc = UIActivityViewController(activityItems: [uiImage!], applicationActivities: nil)
        vc.excludedActivityTypes = shareExclutionArray
        present(vc,
                animated: true,
                completion: nil)
        vc.popoverPresentationController?.sourceView = self.view
    }
    
    func shareText() {
        let vc = UIActivityViewController(activityItems: [textEntry!], applicationActivities: nil)
        vc.excludedActivityTypes = shareExclutionArray
        present(vc,
                animated: true,
                completion: nil)
        vc.popoverPresentationController?.sourceView = self.view
    }
    
    func sharePDF() {
        let vc = UIActivityViewController(activityItems: [pdfData!], applicationActivities: nil)
        vc.excludedActivityTypes = shareExclutionArray
        present(vc,
                animated: true,
                completion: nil)
//        vc.popoverPresentationController?.sourceView = self.view
    }
    
    func shareFile() {
        let vc = UIActivityViewController(activityItems: [urlEntry!], applicationActivities: nil)
        vc.excludedActivityTypes = shareExclutionArray
        present(vc,
                animated: true,
                completion: nil)
        vc.popoverPresentationController?.sourceView = self.view
    }
}

struct ActivityViewControllerNew: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewControllerNew>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewControllerNew>) {}

}
