//
//  EDCReviewView.swift
//  PenList
//
//  Created by Garry Eves on 11/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct EDCReviewView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @ObservedObject var tempVars: contentViewWorkingVariables
    @ObservedObject var kbDetails = KeyboardResponder()
    @Binding var showChild: Bool
    
    @State var showPhotoPicker = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        var borderColour = Color.black
        
        if colorScheme == .dark {
            borderColour = Color.white
        }
        
        if !tempVars.imagesLoaded {
            DispatchQueue.global(qos: .background).async {
                tempVars.EDCItem.loadImages(tempVars: tempVars)
            }
        }
        
        return VStack {
            HStack {
                Spacer()
                Text("\(tempVars.EDCItem.penName) - \(tempVars.EDCItem.inkName)")
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
            
            Text("Rating")
                .font(.headline)
                .padding(.bottom, 10)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            RatingView(tempVars: tempVars)
                .padding(.bottom, 10)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            HStack {
            Text("Notes")
                .font(.headline)
                .padding(.bottom, 10)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            Spacer()
                
            if tempVars.imagesLoaded {
                Button("Photos") {
                    self.showPhotoPicker = true
                }
                    .padding(.trailing, 20)
                    .sheet(isPresented: self.$showPhotoPicker, onDismiss: { self.showPhotoPicker = false
                            self.tempVars.imagesLoaded = false }) {
                        EDCPhotosView(showChild: self.$showPhotoPicker, workingVariables: self.tempVars.EDCItem)
                    }
                }
            }
            .padding()
            
            GeometryReader { geometry in
                TextEditor(text: $tempVars.EDCItem.notes)
                    .border(borderColour, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    .frame(width: geometry.size.width - 40, alignment: .center)
                    .padding()
            }
            
            Button("Save") {
                self.tempVars.EDCItem.rating = self.tempVars.rating
                self.tempVars.EDCItem.save()
            }
                .padding(.bottom, 15)
            
            Spacer()
        }
        .padding(.bottom, kbDetails.currentHeight)
    }
}

