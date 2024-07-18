//
//  AuthenticationViewModel.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//

import Foundation
import Firebase
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: User?
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?
    
    private let authService = AuthenticationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupFirebaseAuthStateListener()
    }
    
    private func setupFirebaseAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                self?.user = user
            }
        }
    }
    
    func signUp() {
        isLoading = true
        error = nil
        authService.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    func signIn() {
        isLoading = true
        error = nil
        authService.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
            isAuthenticated = false
            user = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}
