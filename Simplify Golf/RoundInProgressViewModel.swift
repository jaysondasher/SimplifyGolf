import Foundation
import Firebase
import CoreLocation

class RoundInProgressViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var round: GolfRound
    @Published var currentHoleIndex: Int = 0
    @Published var course: Course?
    @Published var isLoading = false
    @Published var error: String?
    @Published var currentLocation: CLLocation?

    private let db = Firestore.firestore()
    private var locationManager: CLLocationManager

    init(round: GolfRound) {
        self.round = round
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
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

    func totalScoreRelativeToPar() -> String {
        guard let course = course else { return "N/A" }
        
        let totalPar = course.holes.reduce(0) { $0 + $1.par }
        let totalScore = round.scores.compactMap { $0 }.reduce(0, +)
        let relativeScore = totalScore - totalPar
        
        return "\(totalScore) (\(relativeScore >= 0 ? "+" : "")\(relativeScore))"
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

    func moveToHole(index: Int) {
        if index >= 0 && index < (course?.holes.count ?? 0) {
            currentHoleIndex = index
            objectWillChange.send()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}
