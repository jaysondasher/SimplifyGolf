import Foundation
import Firebase
import CoreLocation

class HoleDetailViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var round: GolfRound
    @Published var currentHole: Hole?
    @Published var course: Course?
    @Published var error: String?
    @Published var currentLocation: CLLocation?

    private let db = Firestore.firestore()
    private var locationManager: CLLocationManager

    init(round: GolfRound, holeNumber: Int) {
        self.round = round
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}
