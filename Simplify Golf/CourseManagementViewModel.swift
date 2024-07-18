//
//  CourseManagementViewModel.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//

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
        
        db.collection("courses").getDocuments { [weak self] (querySnapshot, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.error = "Error fetching courses: \(error.localizedDescription)"
                    return
                }
                
                self?.courses = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    guard let name = data["name"] as? String,
                          let location = data["location"] as? String,
                          let courseRating = data["courseRating"] as? Double,
                          let slopeRating = data["slopeRating"] as? Int,
                          let creatorId = data["creatorId"] as? String,
                          let holesData = data["holes"] as? [[String: Any]] else {
                        return nil
                    }
                    
                    let holes = holesData.compactMap { holeData -> Hole? in
                        guard let number = holeData["number"] as? Int,
                              let par = holeData["par"] as? Int,
                              let yardage = holeData["yardage"] as? Int,
                              let teeBoxData = holeData["teeBox"] as? [String: Double],
                              let greenData = holeData["green"] as? [String: [String: Double]] else {
                            return nil
                        }
                        
                        let teeBox = Coordinate(latitude: teeBoxData["latitude"] ?? 0, longitude: teeBoxData["longitude"] ?? 0)
                        let green = Hole.Green(
                            front: Coordinate(latitude: greenData["front"]?["latitude"] ?? 0, longitude: greenData["front"]?["longitude"] ?? 0),
                            center: Coordinate(latitude: greenData["center"]?["latitude"] ?? 0, longitude: greenData["center"]?["longitude"] ?? 0),
                            back: Coordinate(latitude: greenData["back"]?["latitude"] ?? 0, longitude: greenData["back"]?["longitude"] ?? 0)
                        )
                        
                        return Hole(number: number, par: par, yardage: yardage, teeBox: teeBox, green: green)
                    }
                    
                    return Course(id: document.documentID, name: name, location: location, holes: holes, courseRating: courseRating, slopeRating: slopeRating, creatorId: creatorId)
                } ?? []
            }
        }
    }
    
    func addCourse(_ course: Course) {
        isLoading = true
        error = nil
        
        do {
            _ = try db.collection("courses").addDocument(from: course)
            fetchCourses()  // Refresh the list after adding
        } catch {
            self.error = "Error adding course: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func updateCourse(_ course: Course) {
        isLoading = true
        error = nil
        
        db.collection("courses").document(course.id).setData(course.toFirestore()) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.error = "Error updating course: \(error.localizedDescription)"
                } else {
                    self?.fetchCourses()  // Refresh the list after updating
                }
                self?.isLoading = false
            }
        }
    }
    
    func deleteCourse(_ course: Course) {
        isLoading = true
        error = nil
        
        db.collection("courses").document(course.id).delete { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.error = "Error deleting course: \(error.localizedDescription)"
                } else {
                    self?.fetchCourses()  // Refresh the list after deleting
                }
                self?.isLoading = false
            }
        }
    }
}
