import Foundation

class LocalStorageManager {
    static let shared = LocalStorageManager()
    
    private let coursesKey = "downloadedCourses"

    private init() {}

    func saveCourse(_ course: Course) {
        var courses = getCourses()
        courses[course.id] = course
        if let data = try? JSONEncoder().encode(courses) {
            UserDefaults.standard.set(data, forKey: coursesKey)
        }
    }

    func getCourses() -> [String: Course] {
        guard let data = UserDefaults.standard.data(forKey: coursesKey),
              let courses = try? JSONDecoder().decode([String: Course].self, from: data) else {
            return [:]
        }
        return courses
    }

    func getCourse(by id: String) -> Course? {
        return getCourses()[id]
    }

    func isCourseDownloaded(_ id: String) -> Bool {
        return getCourses()[id] != nil
    }

    func removeCourse(_ id: String) {
        var courses = getCourses()
        courses.removeValue(forKey: id)
        if let data = try? JSONEncoder().encode(courses) {
            UserDefaults.standard.set(data, forKey: coursesKey)
        }
    }
}
