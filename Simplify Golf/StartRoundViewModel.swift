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
        
        DispatchQueue.main.async {
            self.courses = LocalStorageManager.shared.getAllCourses()
            self.isLoading = false
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
        
        print("Starting round for course: \(course.name), ID: \(course.id)")
        
        // Check if the course is in local storage
        if let storedCourse = LocalStorageManager.shared.getCourse(by: course.id) {
            print("Course found in local storage: \(storedCourse.name), ID: \(storedCourse.id)")
        } else {
            print("Warning: Course not found in local storage. Saving it now.")
            LocalStorageManager.shared.saveCourse(course)
        }
        
        let newRound = GolfRound(
            id: UUID().uuidString,
            date: Date(),
            courseId: course.id,
            userId: Auth.auth().currentUser?.uid ?? "",
            scores: Array(repeating: nil, count: course.holes.count)
        )
        
        print("New round created: ID: \(newRound.id), CourseID: \(newRound.courseId)")
        
        LocalStorageManager.shared.saveRound(newRound)
        completion(.success(newRound))
    }
}
