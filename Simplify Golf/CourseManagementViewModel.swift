import Foundation
import Firebase

class CourseManagementViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    func fetchCourses() {
        isLoading = true
        error = nil
        
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
    
    func downloadCourse(_ course: Course, completion: @escaping (Result<Void, Error>) -> Void) {
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
                DispatchQueue.main.async {
                    self.fetchCourses()
                    completion(.success(()))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func removeDownloadedCourse(_ course: Course) {
        LocalStorageManager.shared.removeCourse(course.id)
        fetchCourses()
    }
    
    var downloadedCourses: [Course] {
        return LocalStorageManager.shared.getCourses().values.sorted { $0.name < $1.name }
    }
    
    var availableCourses: [Course] {
        return courses.filter { !LocalStorageManager.shared.isCourseDownloaded($0.id) }
    }
    
    func addCourse(_ course: Course) {
        isLoading = true
        error = nil
        
        let newCourse = Course(id: UUID().uuidString, name: course.name, location: course.location, holes: course.holes, courseRating: course.courseRating, slopeRating: course.slopeRating, creatorId: Auth.auth().currentUser?.uid ?? "")
        
        db.collection("courses").document(newCourse.id).setData(newCourse.toFirestore()) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.error = "Error adding course: \(error.localizedDescription)"
                } else {
                    LocalStorageManager.shared.saveCourse(newCourse)
                    self?.fetchCourses()
                }
            }
        }
    }
}
