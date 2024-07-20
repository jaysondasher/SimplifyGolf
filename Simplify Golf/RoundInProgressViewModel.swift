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
        round.isCompleted = true
        saveRound()
        updateUserStatistics()
    }

    private func updateUserStatistics() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("userStats").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let error = error {
                self.error = "Error fetching user stats: \(error.localizedDescription)"
                return
            }

            var stats: [String: Any] = document?.data() ?? [:]
            stats["roundsPlayed"] = (stats["roundsPlayed"] as? Int ?? 0) + 1

            let totalScore = self.round.scores.compactMap { $0 }.reduce(0, +)
            stats["totalScore"] = (stats["totalScore"] as? Int ?? 0) + totalScore

            let averageScore = Double(stats["totalScore"] as? Int ?? 0) / Double(stats["roundsPlayed"] as? Int ?? 1)
            stats["averageScore"] = averageScore

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

    private func saveRound() {
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
