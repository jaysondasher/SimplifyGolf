//
//  Simplify_GolfApp.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 5/15/24.
//

import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct SimplifyGolfApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // State objects for our view models
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var courseViewModel = CourseViewModel()
    @StateObject private var appState = AppState()  // Add this line

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                ContentView()
                    .environmentObject(authViewModel)
                    .environmentObject(courseViewModel)
                    .environmentObject(appState)  // Add this line
                    .preferredColorScheme(.dark)

            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
