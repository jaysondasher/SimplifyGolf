//
//  RoundDetailViewModel.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 10/5/24.
//

import Firebase
import Foundation

class RoundDetailViewModel: ObservableObject {
    @Published var course: Course?
    @Published var parCount: Int = 0
    @Published var birdieCount: Int = 0
    @Published var bogeyCount: Int = 0
    @Published var eagleCount: Int = 0
    @Published var doubleBogeyPlusCount: Int = 0
    private let db = Firestore.firestore()
    private var round: GolfRound

    init(round: GolfRound) {
        self.round = round
        fetchCourse(for: round.courseId)
    }

    private func fetchCourse(for courseId: String) {
        db.collection("courses").document(courseId).getDocument { [weak self] (document, error) in
            if let document = document, document.exists,
                let courseData = document.data(),
                let course = Course.fromFirestore(courseData)
            {
                DispatchQueue.main.async {
                    self?.course = course
                    self?.calculateStats()
                }
            } else {
                print("Error fetching course: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func calculateStats() {
        guard let course = course else { return }

        parCount = 0
        birdieCount = 0
        bogeyCount = 0
        eagleCount = 0
        doubleBogeyPlusCount = 0

        for (index, score) in round.scores.enumerated() {
            guard let score = score, index < course.holes.count else { continue }
            let par = course.holes[index].par
            let difference = score - par

            switch difference {
            case ..<(-2):
                eagleCount += 1  // This includes eagles and better (e.g., albatross)
            case -2:
                eagleCount += 1
            case -1:
                birdieCount += 1
            case 0:
                parCount += 1
            case 1:
                bogeyCount += 1
            case 2...:
                doubleBogeyPlusCount += 1
            default:
                break
            }
        }
    }

    func updateRound(_ updatedRound: GolfRound) {
        db.collection("rounds").document(updatedRound.id).setData(updatedRound.toFirestore()) {
            [weak self] error in
            if let error = error {
                print("Error updating round: \(error.localizedDescription)")
            } else {
                print("Round updated successfully")
                self?.round = updatedRound
                self?.calculateStats()
            }
        }
    }
}
