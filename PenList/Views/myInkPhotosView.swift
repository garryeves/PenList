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
//    @State var tempPhoto: UIImage?
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
         
            if workingVariables.selectedMyInk.loadedImages.count > 0 {
                List {
                    ScrollView(.horizontal, content: {
                        HStack(spacing: 10) {
                            ForEach(workingVariables.selectedMyInk.loadedImages) { item in
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

                            workingVariables.selectedMyInk.addPhoto(displayImage!)

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

