//
//  PickerDateView.swift
//  PenList
//
//  Created by Garry Eves on 27/6/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct pickerDateView: View {
    var displayTitle: String
    @Binding var showPicker: Bool
    @Binding var selectedDate: Date
    
    var body: some View {
        return VStack (alignment: .center) {
            Text(displayTitle)
                .font(.title)

            HStack {
                DatePicker(selection: $selectedDate, displayedComponents: .date) { Text("") }
                    .padding()
                .labelsHidden()
            }
            
            Button("Select") {
                self.showPicker = false
            }
        }
    }
}
