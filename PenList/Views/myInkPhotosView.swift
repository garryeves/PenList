//
//  myInkPhotosView.swift
//  PenList
//
//  Created by Garry Eves on 13/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct myInkPhotosView: View {
    @Binding var showChild: Bool
    @ObservedObject var workingVariables: mainWorkingVariables
    
    @State var showCaptureImageView: Bool = true
    @State var passedPhoto: UIImage?
    @State var reload = false
//    @State var viewPhoto: UIImage?
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
         
            if workingVariables.selectedMyInk.loadedImages.count > 0 {
                List {
                    ScrollView(.horizontal, content: {
                        HStack(spacing: 10) {
                            ForEach(workingVariables.selectedMyInk.loadedImages) { item in
                             //   item.image.resizable()
                                ListImageView(selectedImageFile: item)
//                                Image(uiImage: item.image!)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 125)
                                    .onTapGesture {
                                        selectedPhoto = item
//                                        viewPhoto = item.image.asUIImage()
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
                                Spacer()
                                
                                Button("Save") {

           //                         workingVariables.selectedMyInk.addPhoto(displayImage!)

                                    workingVariables.selectedMyInk.addPhoto(displayImage!.asUIImage())

                                    self.reload.toggle()
                                }
                                
                                Spacer()

                                Button("Pick Again") {

                                    passedPhoto = nil

                                    self.reload.toggle()
                                }
                                Spacer()
                            }
                        }
                    }
                    
                    if (showCaptureImageView) {
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

