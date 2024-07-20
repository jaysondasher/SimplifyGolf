import Foundation

class LocalStorageManager {
    static let shared = LocalStorageManager()
    
    private let coursesKey = "downloadedCourses"
    private let roundsKey = "savedRounds"

    private init() {}

    // Courses
    func getCourses() -> [String: Course] {
        guard let data = UserDefaults.standard.data(forKey: coursesKey),
              let courses = try? JSONDecoder().decode([String: Course].self, from: data) else {
            return [:]
        }
        return courses
    }

    func saveCourse(_ course: Course) {
        var courses = getCourses()
        courses[course.id] = course
        if let data = try? JSONEncoder().encode(courses) {
            UserDefaults.standard.set(data, forKey: coursesKey)
            print("Course saved to local storage: \(course.name), ID: \(course.id)")
        } else {
            print("Failed to save course: \(course.name), ID: \(course.id)")
        }
    }

    func getCourse(by id: String) -> Course? {
        let course = getCourses()[id]
        print("Getting course by ID: \(id), Result: \(course != nil ? "Found" : "Not found")")
        return course
    }

    func getAllCourses() -> [Course] {
        return Array(getCourses().values)
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

    // Rounds
    func saveRound(_ round: GolfRound) {
        var rounds = getRounds()
        rounds[round.id] = round
        if let data = try? JSONEncoder().encode(rounds) {
            UserDefaults.standard.set(data, forKey: roundsKey)
            print("Round saved to local storage: ID: \(round.id), CourseID: \(round.courseId)")
        } else {
            print("Failed to save round: ID: \(round.id), CourseID: \(round.courseId)")
        }
    }

    func getRounds() -> [String: GolfRound] {
        guard let data = UserDefaults.standard.data(forKey: roundsKey),
              let rounds = try? JSONDecoder().decode([String: GolfRound].self, from: data) else {
            return [:]
        }
        return rounds
    }

    func getRound(by id: String) -> GolfRound? {
        return getRounds()[id]
    }
}
