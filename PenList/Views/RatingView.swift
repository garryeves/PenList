//
//  RatingView.swift
//  PenList
//
//  Created by Garry Eves on 11/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct RatingView: View {
    @ObservedObject var tempVars: contentViewWorkingVariables

    var label = ""

    let maximumRating = 5

   // let offImage: Image?
    let offImage = Image(systemName: "star.fill")
    let onImage = Image(systemName: "star.fill")

    let offColor = Color.gray
    let onColor = Color.yellow
    
    var body: some View {
 
        return HStack {
            if label.isEmpty == false {
                Text(label)
            }

            ForEach(1..<maximumRating + 1) { number in
                self.image(for: number)
                    .foregroundColor(number > self.tempVars.rating ? self.offColor : self.onColor)
                    .onTapGesture {
                        self.tempVars.rating = Int64(number)
                    }
            }
        }
    }
    
    func image(for number: Int) -> Image {
        if number > tempVars.rating {
//            return offImage ?? onImage
            return onImage
        } else {
            return onImage
        }
    }
}
