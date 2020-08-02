//
//  aboutScreenView.swift
//  PenList
//
//  Created by Garry Eves on 2/8/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI

struct aboutScreenView: View {
    @Binding var showChild: Bool
    
    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        
        return VStack {
            HStack {
                Spacer()
                Text("")
                Spacer()
                
                Button("Close") {
                    self.showChild = false
                }
            }
            .padding()
            
            Text("Icon Business vector created by rawpixel.com - www.freepik.com - https://www.freepik.com/free-photos-vectors/business")
            
            Text("Version \(version) - \(build)")
            
            Spacer()
        }
    }
}
