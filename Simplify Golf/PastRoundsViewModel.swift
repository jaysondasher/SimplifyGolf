import Foundation
import Firebase

class PastRoundsViewModel: ObservableObject {
    @Published var rounds: [GolfRound] = []
    @Published var courseNames: [String: String] = [:]
    @Published var isLoading = false
    @Published var error: String?
    @Published var showingEditRound = false
    @Published var editingRound: GolfRound?
    
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
                    
                    let rounds = querySnapshot?.documents.compactMap { document -> GolfRound? in
                        return GolfRound.fromFirestore(document.data())
                    } ?? []
                    
                    self?.rounds = rounds
                    
                    self?.fetchCourseNames(for: rounds)
                }
            }
    }
    
    private func fetchCourseNames(for rounds: [GolfRound]) {
        let courseIds = Set(rounds.map { $0.courseId })
        
        courseIds.forEach { courseId in
            db.collection("courses").document(courseId).getDocument { [weak self] (document, error) in
                if let document = document, document.exists, let courseData = document.data(),
                   let courseName = courseData["name"] as? String {
                    DispatchQueue.main.async {
                        self?.courseNames[courseId] = courseName
                    }
                } else {
                    print("Error fetching course: \(error?.localizedDescription ?? "Unknown error")")
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
        db.collection("rounds").document(updatedRound.id).setData(updatedRound.toFirestore()) { [weak self] error in
            if let error = error {
                self?.error = "Error updating round: \(error.localizedDescription)"
            } else {
                if let index = self?.rounds.firstIndex(where: { $0.id == updatedRound.id }) {
                    self?.rounds[index] = updatedRound
                }
                self?.showingEditRound = false
            }
        }
    }
}
