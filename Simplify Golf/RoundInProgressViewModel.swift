import Foundation
import Firebase

class RoundInProgressViewModel: ObservableObject {
    @Published var round: GolfRound
    @Published var currentHoleIndex: Int = 0
    @Published var course: Course?
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedHoleIndex: Int?

    private let db = Firestore.firestore()

    init(round: GolfRound) {
        self.round = round
        print("RoundInProgressViewModel initialized with round ID: \(round.id), CourseID: \(round.courseId)")
        fetchCourse()
    }

    func fetchCourse() {
        print("Attempting to fetch course with ID: \(round.courseId)")
        isLoading = true
        error = nil

        if let course = LocalStorageManager.shared.getCourse(by: round.courseId) {
            self.course = course
            isLoading = false
            print("Course fetch result: Success - Course name: \(course.name), Holes: \(course.holes.count)")
        } else {
            error = "Course not found in local storage"
            isLoading = false
            print("Course fetch result: Failure - Course not found in local storage")
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
            objectWillChange.send()
            saveRound()
        }

        private func saveRound() {
            LocalStorageManager.shared.saveRound(round)
            
            db.collection("rounds").document(round.id).setData(round.toFirestore()) { [weak self] error in
                if let error = error {
                    self?.error = "Error saving round: \(error.localizedDescription)"
                    print("Error saving round to Firestore: \(error.localizedDescription)")
                } else {
                    print("Round successfully saved to Firestore")
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
