import Foundation
import Firebase

class StartRoundViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var searchText: String = ""
    @Published var selectedCourse: Course?
    @Published var isLoading: Bool = false
    @Published var error: String?

    var filteredCourses: [Course] {
        if searchText.isEmpty {
            return courses
        } else {
            return courses.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    func fetchCourses() {
        isLoading = true
        error = nil
        
        let localCourses = LocalStorageManager.shared.getCourses().values
        self.courses = Array(localCourses)
        self.isLoading = false
        
        // Optionally, you can add an error message if no local courses are found
        if courses.isEmpty {
            self.error = "No downloaded courses found"
        }
    }

    func startRound(completion: @escaping (Result<GolfRound, Error>) -> Void) {
        guard let course = selectedCourse else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No course selected"])))
            return
        }
        
        createNewRound(course: course, completion: completion)
    }

    private func createNewRound(course: Course, completion: @escaping (Result<GolfRound, Error>) -> Void) {
        let newRound = GolfRound(
            id: UUID().uuidString,
            date: Date(),
            courseId: course.id,
            userId: Auth.auth().currentUser?.uid ?? "",
            scores: Array(repeating: nil, count: course.holes.count)
        )
        
        let db = Firestore.firestore()
        db.collection("rounds").document(newRound.id).setData(newRound.toFirestore()) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(newRound))
            }
        }
    }
}
