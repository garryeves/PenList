//
//  myPenImagesView.swift
//  PenList
//
//  Created by Garry Eves on 12/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct tempImages: Identifiable {
    var id = UUID()
    var image: Image
}

struct myPenImagesView: View {
    @Binding var showChild: Bool
    @ObservedObject var workingVariables: mainWorkingVariables
    
    @State var showCaptureImageView: Bool = true
    @State var tempPhoto: UIImage?
    @State var reload = false

    var body: some View {
        var displayImage: Image?
        var images: [tempImages] = Array()
        
        if tempPhoto != nil {
            displayImage = Image(uiImage: tempPhoto!)
        }
        
        if workingVariables.selectedMyPen.images.photos.count > 0 {
            for item in workingVariables.selectedMyPen.images.photos {
                let temp = tempImages(id: item.myPhotoID, image: item.decodedImage)
                images.append(temp)
            }
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
         
            if images.count > 0 {
                List {
                    ScrollView(.horizontal, content: {
                        HStack(spacing: 10) {
                            ForEach(images) { item in
                                item.image.resizable()
                                .frame(width: 125, height: 125)
                            }
                        }
                        .padding(.leading, 10)
                    })
                }
                .frame(height: 190)
            }
            
            ZStack {
                if displayImage != nil {
                    VStack {
                        displayImage?.resizable()
                            .frame(width: 250, height: 250)
                            .shadow(radius: 10)
                        Button("Save") {
                            let temp = myPenPhoto(passedpenID: self.workingVariables.selectedMyPen.myPenID.uuidString, passedtype: "Pen", passedimage: self.tempPhoto)
                          //  self.showChild = false
                            
                            self.workingVariables.selectedMyPen.images.append(temp)
                            self.reload.toggle()
                        }
                        .padding()
                    }
                }
                
                if (showCaptureImageView) {
                    CaptureImageView(isShown: $showCaptureImageView, image: $tempPhoto)
                }
            }
            
            Spacer()
        }
    }
}
