//
//  StatisticsViewModel.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//


import Foundation
import Firebase

class StatisticsViewModel: ObservableObject {
    @Published var roundsPlayed: Int = 0
    @Published var averageScore: Double = 0
    @Published var bestScore: Int = 0
    @Published var worstScore: Int = 0
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    func fetchStatistics() {
        guard let userId = Auth.auth().currentUser?.uid else {
            error = "User not logged in"
            return
        }
        
        isLoading = true
        error = nil
        
        db.collection("userStats").document(userId).getDocument { [weak self] (document, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.error = "Error fetching statistics: \(error.localizedDescription)"
                    return
                }
                
                guard let data = document?.data() else {
                    self?.error = "No statistics found"
                    return
                }
                
                self?.roundsPlayed = data["roundsPlayed"] as? Int ?? 0
                self?.averageScore = data["averageScore"] as? Double ?? 0
                
                // Fetch best and worst scores
                self?.fetchBestAndWorstScores(userId: userId)
            }
        }
    }
    
    private func fetchBestAndWorstScores(userId: String) {
        db.collection("rounds")
            .whereField("userId", isEqualTo: userId)
            .whereField("isCompleted", isEqualTo: true)
            .order(by: "totalScore")
            .limit(to: 1)
            .getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    self?.error = "Error fetching best score: \(error.localizedDescription)"
                    return
                }
                
                self?.bestScore = querySnapshot?.documents.first?.data()["totalScore"] as? Int ?? 0
                
                // Now fetch the worst score
                self?.db.collection("rounds")
                    .whereField("userId", isEqualTo: userId)
                    .whereField("isCompleted", isEqualTo: true)
                    .order(by: "totalScore", descending: true)
                    .limit(to: 1)
                    .getDocuments { (querySnapshot, error) in
                        if let error = error {
                            self?.error = "Error fetching worst score: \(error.localizedDescription)"
                            return
                        }
                        
                        self?.worstScore = querySnapshot?.documents.first?.data()["totalScore"] as? Int ?? 0
                    }
            }
    }
}