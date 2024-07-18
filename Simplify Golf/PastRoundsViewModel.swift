//
//  PastRoundsViewModel.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//

import Foundation
import Firebase

class PastRoundsViewModel: ObservableObject {
    @Published var rounds: [GolfRound] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    func fetchPastRounds() {
        guard let userId = Auth.auth().currentUser?.uid else {
            error = "User not logged in"
            return
        }
        
        isLoading = true
        error = nil
        
        db.collection("rounds")
            .whereField("userId", isEqualTo: userId)
            .whereField("isCompleted", isEqualTo: true)
            .order(by: "date", descending: true)
            .getDocuments { [weak self] (querySnapshot, err) in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let err = err {
                        self?.error = "Error fetching rounds: \(err.localizedDescription)"
                        return
                    }
                    
                    self?.rounds = querySnapshot?.documents.compactMap { document -> GolfRound? in
                        return GolfRound.fromFirestore(document.data())
                    } ?? []
                }
            }
    }
}
