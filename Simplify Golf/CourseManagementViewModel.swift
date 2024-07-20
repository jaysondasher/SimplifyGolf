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
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            LocalStorageManager.shared.saveCourse(course)
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
    }
    
    func removeDownloadedCourse(_ course: Course) {
        LocalStorageManager.shared.removeCourse(course.id)
    }
    
    var downloadedCourses: [Course] {
        return LocalStorageManager.shared.getCourses().values.sorted { $0.name < $1.name }
    }
    
    var availableCourses: [Course] {
        return courses.filter { !LocalStorageManager.shared.isCourseDownloaded($0.id) }
    }
}
