//
//  RoundInProgressViewModel.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//


import Foundation
import Firebase

class RoundInProgressViewModel: ObservableObject {
    @Published var round: GolfRound
    @Published var currentHoleIndex: Int = 0
    @Published var course: Course?
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    init(round: GolfRound) {
        self.round = round
        fetchCourse()
    }
    
    func fetchCourse() {
        isLoading = true
        error = nil
        
        db.collection("courses").document(round.courseId).getDocument { [weak self] (document, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.error = "Error fetching course: \(error.localizedDescription)"
                } else if let document = document, document.exists {
                    self?.course = Course.fromFirestore(document.data() ?? [:])
                } else {
                    self?.error = "Course not found"
                }
            }
        }
    }
    
    func finishRound() {
        // Mark the round as completed
        round.isCompleted = true
        
        // Save the completed round
        saveRound()
        
        // Update user statistics
        updateUserStatistics()
    }

    private func updateUserStatistics() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Fetch current user statistics
        db.collection("userStats").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.error = "Error fetching user stats: \(error.localizedDescription)"
                return
            }
            
            var stats: [String: Any] = document?.data() ?? [:]
            
            // Update rounds played
            stats["roundsPlayed"] = (stats["roundsPlayed"] as? Int ?? 0) + 1
            
            // Update total score
            let totalScore = self.round.scores.compactMap { $0 }.reduce(0, +)
            stats["totalScore"] = (stats["totalScore"] as? Int ?? 0) + totalScore
            
            // Calculate and update average score
            let averageScore = Double(stats["totalScore"] as? Int ?? 0) / Double(stats["roundsPlayed"] as? Int ?? 1)
            stats["averageScore"] = averageScore
            
            // Save updated stats
            self.db.collection("userStats").document(userId).setData(stats, merge: true) { error in
                if let error = error {
                    self.error = "Error updating user stats: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func updateScore(for holeIndex: Int, score: Int) {
        round.scores[holeIndex] = score
        saveRound()
    }
    
    func saveRound() {
        db.collection("rounds").document(round.id).setData(round.toFirestore()) { [weak self] error in
            if let error = error {
                self?.error = "Error saving round: \(error.localizedDescription)"
            }
        }
    }
    
    func moveToNextHole() {
        if currentHoleIndex < (course?.holes.count ?? 0) - 1 {
            currentHoleIndex += 1
        }
    }
    
    func moveToPreviousHole() {
        if currentHoleIndex > 0 {
            currentHoleIndex -= 1
        }
    }
}
