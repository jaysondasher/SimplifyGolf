//
//  UserViewModel.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 10/5/24.
//

import Firebase
import Foundation

class UserViewModel: ObservableObject {
    static let shared = UserViewModel()

    @Published var errorMessage: String?
    private let db = Firestore.firestore()

    func saveUserEmail(email: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not logged in"
            return
        }

        let userData: [String: Any] = [
            "email": email,
            "userId": userId,
        ]
        db.collection("users").document(userId).setData(userData, merge: true) {
            [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            }
        }
    }

    func getUserEmail(for userId: String) -> String? {
        var email: String?
        let semaphore = DispatchSemaphore(value: 0)

        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                email = document.data()?["email"] as? String
            }
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + 5)
        return email
    }
}
