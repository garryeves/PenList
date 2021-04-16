//
//  myPenImagesView.swift
//  PenList
//
//  Created by Garry Eves on 12/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

let compressionFactor: CGFloat = 0.2

class tempImages: NSObject, Identifiable {
    var id = UUID()
//    var image: Image
    private var savedimage: Data?
//    private var savedimage: UIImage?
    private var savedcompressedImage: UIImage?
    
    var image: UIImage? {
        get {
            if savedimage != nil {
                return UIImage(data: savedimage!)
              //  return savedimage
            } else {
                return nil
            }
        }
    }
    
//    var compressedImage: UIImage? {
//        get {
//            if savedcompressedImage != nil {
//                return UIImage(data: savedimage!)
//               // return savedcompressedImage
//            } else {
//                return nil
//            }
//        }
//    }
    
    
    override init() {
        print(">> inited")
    }
    
//    init(inId: UUID,
//         inImage: UIImage,
//         inCompress: UIImage) {
//
//        super.init()
//        print(">> inited with params")
//
//print("step 1 \(Date())")
//        let imgData = NSData(data: inImage.jpegData(compressionQuality: 1)!)
//print("step 2 \(Date())")
//        var imageSize: Int = imgData.count
//print("step 3 \(Date())")
//        print("actual size of image in KB: %f ", Double(imageSize) / 1000.0)
//
//
//        let imgData2 = NSData(data: inCompress.jpegData(compressionQuality: 1)!)
//        var imageSize2: Int = imgData2.count
//        print("actual size of image in KB: %f ", Double(imageSize2) / 1000.0)
//
//        id = inId
//        savedimage = inImage
//        savedcompressedImage = inCompress
//    }
    
//    init(passedId: UUID,
//         image: UIImage) {
//        
//        super.init()
//
//                let imgData = NSData(data: image.jpegData(compressionQuality: 1)!)
//                let imageSize: Int = imgData.count
//                print("actual size of image in KB: %f ", Double(imageSize) / 1000.0)
//    
//        
//        id = passedId
//        savedimage = image.jpegData(compressionQuality: 1)
//        
//        savedcompressedImage = UIImage(data: image.jpegData(compressionQuality: compressionFactor)!)
//    }
    
    init(passedId: UUID,
         image: Data) {
        
        super.init()

        //     let imgData = NSData(data: image.jpegData(compressionQuality: 1)!)
                let imageSize: Int = image.count
                print("actual size of image in KB: %f ", Double(imageSize) / 1000.0)
        
//                let imgData2 = NSData(data: image.jpegData(compressionQuality: compressionFactor)!)
//                let imageSize2: Int = imgData2.count
//                print("actual size of image in KB: %f ", Double(imageSize2) / 1000.0)
//
        
        id = passedId
        savedimage = image
        
  //      savedcompressedImage = UIImage(data: image.jpegData(compressionQuality: compressionFactor)!)
    }
    

    deinit {
        print("[x] destroyed")
    }
}

struct myPenImagesView: View {
    @Binding var showChild: Bool
 //   @ObservedObject var workingVariables: mainWorkingVariables
    @Binding var selectedMyPen: myPen
    
    @State var showCaptureImageView: Bool = true
    @State var passedPhoto: UIImage?
    @State var reload = false
    
    @State var saveCalled = false
 //   @State var viewPhoto: UIImage?
    @State var selectedPhoto: tempImages?

    var body: some View {
        var displayImage: Image?
        
        if passedPhoto != nil {
            displayImage = Image(uiImage: passedPhoto!)
        }
        
        return VStack {
            HStack {
                Spacer()
                Text("Photos")
                    .font(.title)
                Spacer()
                
                Button("Close") {
                    self.showChild = false
                }
            }
            .padding(.bottom, 10)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 15)
         
         //   if workingVariables.selectedMyPen.loadedImages.count > 0 {
            if selectedMyPen.loadedImages.count > 0 {
                List {
                    ScrollView(.horizontal, content: {
                        HStack(spacing: 10) {
                       //     ForEach(workingVariables.selectedMyPen.loadedImages) { item in
                            ForEach(selectedMyPen.loadedImages) { item in
                                ListImageView(selectedImageFile: item)
//
//                                Image(uiImage: item.compressedImage!)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 125)
                                    .onTapGesture {
                                        selectedPhoto = item
                                    }
                            }
                        }
                        .padding(.leading, 10)
                    })
                }
                .frame(height: 140)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            }
            
            ZStack {
                if selectedPhoto != nil {
                    VStack {
                        Image(uiImage: selectedPhoto!.image!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        HStack {
                            Spacer()
                            
                            Button("Show Photo picker") {
                                selectedPhoto = nil
                            }
                            
                            Spacer()
                            
                            
                            if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad {
                                Button("Save to Photos") {
                                    let imageSaver = ImageSaver()
                                    imageSaver.writeToPhotoAlbum(image: selectedPhoto!.image!)
                                }
                            } else {
                                Button("Save to Photos") {
                                    let imageSaver = ImageSaver()
                                    
                                    imageSaver.insertImageMac(image: selectedPhoto!.image!, albumName: "PenList")
                                }
                            }
                            
                            Spacer()
                        }
                    }
                } else {
                    if displayImage != nil {
                        VStack {
                            displayImage?.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 250)
                                .shadow(radius: 10)
                            HStack {
                                if !saveCalled {
                                    Spacer()
                                    Button("Save") {

    //                                    workingVariables.selectedMyPen.addPhoto(displayImage!)
    //                                    workingVariables.selectedMyPen.addPhoto(displayImage!.asUIImage())
                                       selectedMyPen.addPhoto(displayImage!.asUIImage())
                                        saveCalled = true
                                        self.reload.toggle()
                                    }
                                }
                                
                                Spacer()

                                Button("Pick Again") {

                                    passedPhoto = nil

                                    self.reload.toggle()
                                }
                                Spacer()
                            }
                        }
                    } else {
                        CaptureImageView(isShown: $showCaptureImageView, image: $passedPhoto)
                    }
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
            Spacer()
        }
    }
}


struct ListImageView: View {
    var selectedImageFile: tempImages
 
    var body: some View {
       return Image(uiImage: selectedImageFile.image!)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
