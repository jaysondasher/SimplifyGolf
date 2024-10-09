import Firebase
import Foundation

class PastRoundsViewModel: ObservableObject {
    @Published var rounds: [GolfRound] = []
    @Published var filteredRounds: [GolfRound] = []
    @Published var courseNames: [String: String] = [:]
    @Published var coursePars: [String: Int] = [:]  // New property
    @Published var isLoading = false
    @Published var error: String?
    @Published var showingEditRound = false
    @Published var editingRoundIndex: Int?

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
            .order(by: "date", descending: true)
            .getDocuments { [weak self] (querySnapshot, err) in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let err = err {
                        self?.error = "Error fetching rounds: \(err.localizedDescription)"
                        return
                    }

                    let rounds =
                        querySnapshot?.documents.compactMap { document -> GolfRound? in
                            return GolfRound.fromFirestore(document.data())
                        } ?? []

                    self?.rounds = rounds
                    self?.fetchCourseDetails(for: rounds)  // Call this method instead of fetchCourseNames
                    self?.filteredRounds = rounds
                }
            }
    }

    private func fetchCourseDetails(for rounds: [GolfRound]) {
        let courseIds = Set(rounds.map { $0.courseId })

        courseIds.forEach { courseId in
            db.collection("courses").document(courseId).getDocument {
                [weak self] (document, error) in
                if let document = document, document.exists, let courseData = document.data() {
                    DispatchQueue.main.async {
                        self?.courseNames[courseId] =
                            courseData["name"] as? String ?? "Unknown Course"

                        // Calculate and store the total par for the course
                        if let holes = courseData["holes"] as? [[String: Any]] {
                            let totalPar = holes.compactMap { $0["par"] as? Int }.reduce(0, +)
                            self?.coursePars[courseId] = totalPar
                        }
                    }
                } else {
                    print(
                        "Error fetching course: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }

    func deleteRound(_ round: GolfRound) {
        db.collection("rounds").document(round.id).delete { [weak self] error in
            if let error = error {
                self?.error = "Error deleting round: \(error.localizedDescription)"
            } else {
                self?.rounds.removeAll { $0.id == round.id }
            }
        }
    }

    func updateRound(_ updatedRound: GolfRound) {
        db.collection("rounds").document(updatedRound.id).setData(updatedRound.toFirestore()) {
            [weak self] error in
            if let error = error {
                self?.error = "Error updating round: \(error.localizedDescription)"
            } else {
                if let index = self?.rounds.firstIndex(where: { $0.id == updatedRound.id }) {
                    self?.rounds[index] = updatedRound
                }
                self?.showingEditRound = false
                self?.editingRoundIndex = nil
            }
        }
    }

    func filterRounds(searchText: String) {
        if searchText.isEmpty {
            filteredRounds = rounds
        } else {
            filteredRounds = rounds.filter { round in
                let courseName = courseNames[round.courseId] ?? ""
                let dateString = formatDate(round.date)
                return courseName.lowercased().contains(searchText.lowercased())
                    || dateString.lowercased().contains(searchText.lowercased())
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, M/d/yy"
        return formatter.string(from: date)
    }
}
