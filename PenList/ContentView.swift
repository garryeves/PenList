//
//  ContentView.swift
//  PenList
//
//  Created by Garry Eves on 20/3/20.
//  Copyright © 2020 Garry Eves. All rights reserved.
//

import SwiftUI
import Reachability

class contentViewWorkingVariables: ObservableObject {

    @Published var selectedPen = myPen()
    @Published var selectedInk = myInk()

    @Published var reloadScreen = false
    
    var EDCItem = currentUse()
    
    @Published var rating: Int64 = 0
    
    @Published var showManufacturers = false
    
    let columnWidth = 300
    
    @Published var imagesLoaded = false
    
    func showPhotoButton() {
        DispatchQueue.main.async {
            self.imagesLoaded = true
        }
    }
}

enum internetConnectionStatus {
    case iCloudConnected
    case iCloudNotConnected
    case noInternet
    case Initiating
}

class internetCheckClass: ObservableObject {
    
    @Published var isConnectedState = internetConnectionStatus.Initiating
    
    init() {
        connect()
    }
    
    func connect() {
        let reachability = try! Reachability()

        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
            if FileManager.default.ubiquityIdentityToken != nil {
                self.isConnectedState = .iCloudConnected
            } else {
                self.isConnectedState = .iCloudNotConnected
            }
            
            reachability.stopNotifier()
        }
        reachability.whenUnreachable = { _ in
            reachability.stopNotifier()
            print("Not reachable")
            self.isConnectedState = .noInternet
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}

struct ContentView: View {
    
    @ObservedObject var internetCheck = internetCheckClass()
    
    var body: some View {
        return VStack {
            if internetCheck.isConnectedState == internetConnectionStatus.iCloudConnected {
                myTabView()
            } else if internetCheck.isConnectedState == internetConnectionStatus.Initiating {
                checkingConnection(internetCheck: internetCheck)
            } else if internetCheck.isConnectedState == internetConnectionStatus.noInternet {
                notConnected()
            } else {
                noiCloud()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct myTabView: View {
    @ObservedObject var workingVariables = mainWorkingVariables()
    
    @ObservedObject var tempVars = contentViewWorkingVariables()

    var body: some View {
            
        self.workingVariables.reloadData()
    
        if manufacturerList.manufacturers.count == 0 && !self.tempVars.showManufacturers {
            self.tempVars.showManufacturers = true
        }
        
        // The following is used to populate the decodes table.  only uncomment for the first time to be run
        
     //   workingVariables.loadDecodes()
        return TabView {
            
            EDCView(workingVariables: workingVariables, tempVars: tempVars)
                .tabItem {
                    Image(systemName: "pencil.tip")
                    Text("Pens")
                }
        
            inkView(workingVariables: workingVariables, tempVars: tempVars)
                .tabItem {
                    Image(systemName: "eyedropper")
                    Text("Ink")
                }
            
            notepadView(workingVariables: workingVariables, tempVars: tempVars)
                .tabItem {
                    Image(systemName: "book")
                    Text("Notepads")
                }
            
            ManufacturersListView(workingVariables: self.workingVariables)
                .tabItem {
                    Image(systemName: "bag")
                    Text("Manufacturers")
                }
            
            toBuyView()
                .tabItem {
                    Image(systemName: "cart")
                    Text("To Buy")
                }
        }
    }
}

struct checkingConnection: View {
    
    @ObservedObject var internetCheck: internetCheckClass
    var body: some View {
        return VStack (alignment: .leading){
            Text("Connecting.....")
                .font(.title)
                .padding()
        }
    }
}

struct notConnected: View {
    var body: some View {
        return VStack (alignment: .leading){
            Text("You are not connected to the internet")
                .font(.title)
                .padding()
            
            Text("This is needed for the App to store and retrieve your collection details")
                .font(.title)
                .padding()
            
            
            Text("Please connect to the internet")
                .font(.title)
                .padding()
        }
    }
}

struct noiCloud: View {
    var body: some View {
        return VStack (alignment: .leading){
            Text("You are not connected to iCloud")
                .font(.title)
                .padding()
            
            Text("This is needed for the App to store and retrieve your collection details")
                .font(.title)
                .padding()
            
            
            Text("Please connect to iCloud")
                .font(.title)
                .padding()
        }
    }
}
