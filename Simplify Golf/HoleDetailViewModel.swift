// HoleDetailViewModel.swift
// Simplify Golf
//
// Created by Jayson Dasher on 7/18/24.

import Foundation
import Firebase

class HoleDetailViewModel: ObservableObject {
    @Published var round: GolfRound
    @Published var currentHole: Hole?
    @Published var course: Course?
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    init(round: GolfRound, holeNumber: Int) {
        self.round = round
        fetchCourse()
        loadHole(number: holeNumber)
    }
    
    func fetchCourse() {
        db.collection("courses").document(round.courseId).getDocument { [weak self] (document, error) in
            if let error = error {
                self?.error = "Error fetching course: \(error.localizedDescription)"
            } else if let document = document, document.exists {
                self?.course = Course.fromFirestore(document.data() ?? [:])
            } else {
                self?.error = "Course not found"
            }
        }
    }
    
    func loadHole(number: Int) {
        guard let course = course else { return }
        if let hole = course.holes.first(where: { $0.number == number }) {
            currentHole = hole
        }
    }
    
    func updateScore(for holeNumber: Int, score: Int) {
        if round.scores.indices.contains(holeNumber - 1) {
            round.scores[holeNumber - 1] = score
            saveRound()
        }
    }
    
    private func saveRound() {
        db.collection("rounds").document(round.id).setData(round.toFirestore()) { [weak self] error in
            if let error = error {
                self?.error = "Error saving round: \(error.localizedDescription)"
            }
        }
    }
}
