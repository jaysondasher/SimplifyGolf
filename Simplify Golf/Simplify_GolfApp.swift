//
//  Simplify_GolfApp.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 5/15/24.
//

import SwiftUI

@main
struct SimplifyGolfApp: App {
    @StateObject private var dataController = DataController()
    @StateObject private var userManager: UserManager
    @StateObject private var courseManager: CourseManager
    @StateObject private var locationManager = LocationManager.shared
    
    init() {
        let userManager = UserManager()
        _userManager = StateObject(wrappedValue: userManager)
        _courseManager = StateObject(wrappedValue: CourseManager(userManager: userManager))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataController)
                .environmentObject(userManager)
                .environmentObject(courseManager)
                .environmentObject(locationManager)
        }
    }
}
