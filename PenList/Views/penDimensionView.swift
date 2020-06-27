//
//  penDimensionView.swift
//  PenList
//
//  Created by Garry Eves on 18/4/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct penDimensionView: View {
    @ObservedObject var workingVariables: mainWorkingVariables
    @ObservedObject var kbDetails = KeyboardResponder()
    @Binding var showChild: Bool
    
    var body: some View {
        return VStack {
            Text("Diameter")
                .font(.headline)
                .padding()

            HStack {
                Text("Body")
                    .padding(.trailing, 5)
                
                TextField("Body", text: $workingVariables.selectedPen.diameterBody)
                    .padding(.trailing, 10)
                
                Text("Grip")
                    .padding(.trailing, 5)
                
                TextField("Grip", text: $workingVariables.selectedPen.diameterGrip)
                    .padding(.trailing, 10)
                
                Text("Cap")
                    .padding(.trailing, 5)
                
                TextField("Cap", text: $workingVariables.selectedPen.diameterCap)
                    .padding(.trailing, 10)
            }
            .padding()
            
            Text("Length")
                .font(.headline)
            
            HStack {
                Text("Body")
                    .padding(.trailing, 5)
                
                TextField("Body", text: $workingVariables.selectedPen.lengthBody)
                    .padding(.trailing, 10)
                
                Text("Cap")
                    .padding(.trailing, 5)
                
                TextField("Cap", text: $workingVariables.selectedPen.lengthCap)
                    .padding(.trailing, 10)
                
                Text("Closed")
                    .padding(.trailing, 5)
                
                TextField("Closed", text: $workingVariables.selectedPen.lengthClosed)
                    .padding(.trailing, 10)
            }
            .padding()
            
            
            Text("Weight")
                .font(.headline)

            HStack {
                Text("Body")
                    .padding(.trailing, 5)
                
                TextField("Body", text: $workingVariables.selectedPen.weightBody)
                    .padding(.trailing, 10)
                
                Text("Cap")
                    .padding(.trailing, 5)
                
                TextField("Cap", text: $workingVariables.selectedPen.weightCap)
                    .padding(.trailing, 10)
                
                Text("Total")
                    .padding(.trailing, 5)
                
                TextField("Total", text: $workingVariables.selectedPen.weightTotal)
                    .padding(.trailing, 10)
            }
            .padding()
            
            Button("Close") {
                self.showChild = false
            }
            .padding()
            
            Spacer()
        }
        .padding(.bottom, kbDetails.currentHeight)
    }
}
