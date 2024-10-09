//
//  ContentViewModel.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//


import Foundation
import Combine

class ContentViewModel: ObservableObject {
    // We'll add more properties and methods here as we develop more features
    
    init() {
        // Initialize any necessary data or services
    }
    
    func signOut(completion: @escaping (Bool) -> Void) {
        do {
            try AuthenticationService.shared.signOut()
            completion(true)
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            completion(false)
        }
    }
}