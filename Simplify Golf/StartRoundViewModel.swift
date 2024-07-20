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
        
        let db = Firestore.firestore()
        db.collection("courses").getDocuments { [weak self] (querySnapshot, err) in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let err = err {
                    self?.error = "Error fetching courses: \(err.localizedDescription)"
                    return
                }
                
                self?.courses = querySnapshot?.documents.compactMap { document -> Course? in
                    Course.fromFirestore(document.data())
                } ?? []
            }
        }
    }

    func isCourseDownloaded(_ course: Course) -> Bool {
        return LocalStorageManager.shared.isCourseDownloaded(course.id)
    }

    func downloadCourse(_ course: Course, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("courses").document(course.id).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let courseData = document.data() else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Course not found"])))
                return
            }
            
            do {
                let downloadedCourse = Course.fromFirestore(courseData)!
                LocalStorageManager.shared.saveCourse(downloadedCourse)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func startRound(completion: @escaping (Result<GolfRound, Error>) -> Void) {
        guard let course = selectedCourse else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No course selected"])))
            return
        }
        
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
