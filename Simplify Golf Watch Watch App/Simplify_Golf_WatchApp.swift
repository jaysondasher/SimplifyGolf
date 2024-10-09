//
//  Simplify_Golf_WatchApp.swift
//  Simplify Golf Watch Watch App
//
//  Created by Jayson Dasher on 5/15/24.
//

import SwiftUI
import WatchConnectivity
import Firebase

@main
struct Simplify_Golf_Watch_Watch_AppApp: App {
    @StateObject private var viewModel = WatchViewModel()
    
    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(viewModel)
        }
    }
}
