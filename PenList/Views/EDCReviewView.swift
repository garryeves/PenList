//
//  EDCReviewView.swift
//  PenList
//
//  Created by Garry Eves on 11/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct EDCReviewView: View {
    @ObservedObject var tempVars: contentViewWorkingVariables
    
    @Binding var showChild: Bool
    
    @ObservedObject var kbDetails = KeyboardResponder()
    
    var body: some View {
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
            
            Text("Notes")
                .font(.headline)
                .padding(.bottom, 10)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            TextView(text: $tempVars.EDCItem.notes)
                .padding(.bottom, 10)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            Button("Save") {
                self.tempVars.EDCItem.rating = self.tempVars.rating
                self.tempVars.EDCItem.save()
            }
                .padding(.bottom, 15)
            
            Spacer()
        }
        .onTapGesture {
            let keyWindow = UIApplication.shared.connectedScenes
                               .filter({$0.activationState == .foregroundActive})
                               .map({$0 as? UIWindowScene})
                               .compactMap({$0})
                               .first?.windows
                               .filter({$0.isKeyWindow}).first
            keyWindow!.endEditing(true)
        }
    }
}

