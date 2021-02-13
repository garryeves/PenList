//
//  EDCReviewPhotoView.swift
//  PenList
//
//  Created by Garry Eves on 13/2/21.
//  Copyright © 2021 Garry Eves. All rights reserved.
//

import SwiftUI

struct EDCPhotosView: View {
    @Binding var showChild: Bool
    @ObservedObject var workingVariables: currentUse
    
    @State var showCaptureImageView: Bool = true
    @State var passedPhoto: UIImage?
    @State var reload = false

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
         
            if workingVariables.loadedImages.count > 0 {
                List {
                    ScrollView(.horizontal, content: {
                        HStack(spacing: 10) {
                            ForEach(workingVariables.loadedImages) { item in
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

                            workingVariables.addPhoto(displayImage!)

                            self.reload.toggle()
                        }
                        .padding()
                    }
                }
                
                if (showCaptureImageView) {
                    CaptureImageView(isShown: $showCaptureImageView, image: $passedPhoto)
                }
            }
            
            Spacer()
        }
    }
}


