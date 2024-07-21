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

        // Adjusted the query to match the expected data structure
        db.collection("rounds")
            .whereField("userId", isEqualTo: userId)
            //.whereField("isCompleted", isEqualTo: true) // Remove this filter if not using isCompleted field
            .getDocuments { [weak self] (querySnapshot, error) in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.error = "Error fetching rounds: \(error.localizedDescription)"
                        print("Error fetching rounds: \(error.localizedDescription)")
                        return
                    }

                    guard let documents = querySnapshot?.documents else {
                        self?.error = "No rounds found"
                        print("No rounds found")
                        return
                    }

                    let rounds = documents.compactMap { document -> GolfRound? in
                        print("Document data: \(document.data())")
                        return GolfRound.fromFirestore(document.data())
                    }
                    
                    print("Fetched rounds: \(rounds.count)")
                    
                    self?.calculateStatistics(from: rounds)
                }
            }
    }

    private func calculateStatistics(from rounds: [GolfRound]) {
        roundsPlayed = rounds.count

        guard roundsPlayed > 0 else {
            averageScore = 0
            bestScore = 0
            worstScore = 0
            return
        }

        let totalScores = rounds.map { round -> Int in
            let totalScore = round.scores.compactMap { $0 }.reduce(0, +)
            print("Total score for round \(round.id): \(totalScore)")
            return totalScore
        }
        
        averageScore = Double(totalScores.reduce(0, +)) / Double(roundsPlayed)
        bestScore = totalScores.min() ?? 0
        worstScore = totalScores.max() ?? 0
        
        print("Total scores: \(totalScores)")
        print("Average score: \(averageScore)")
        print("Best score: \(bestScore)")
        print("Worst score: \(worstScore)")
    }
}
