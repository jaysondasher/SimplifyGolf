//
//  CourseManager.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import Foundation
import CloudKit

class CourseManager: ObservableObject {
    @Published var courses: [Course] = []
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    private let userManager: UserManager
    
    init(userManager: UserManager) {
        self.userManager = userManager
        container = CKContainer(identifier: "iCloud.com.jaysondasher.Simplify-Golf")
        publicDatabase = container.publicCloudDatabase
        loadCourses()
    }
    
    func loadCourses() {
        // First, load courses from local storage
        if let savedCourses = UserDefaults.standard.data(forKey: "SavedCourses"),
           let decodedCourses = try? JSONDecoder().decode([Course].self, from: savedCourses) {
            courses = decodedCourses
        }
        
        // Then, fetch courses from CloudKit
        let query = CKQuery(recordType: "Course", predicate: NSPredicate(value: true))
        publicDatabase.perform(query, inZoneWith: nil) { [weak self] (records, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching courses: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                if let records = records {
                    let cloudCourses = records.compactMap { Course(record: $0) }
                    self.courses = Array(Set(self.courses + cloudCourses))
                    self.saveCourses()
                }
            }
        }
    }
    
    func addCourse(_ course: Course) {
        courses.append(course)
        saveCourses()
        
        // Save to CloudKit
        let record = course.cloudKitRecord
        publicDatabase.save(record) { (record, error) in
            if let error = error {
                print("Error saving course to CloudKit: \(error.localizedDescription)")
            } else {
                print("Course successfully saved to CloudKit")
            }
        }
    }
    
    func deleteCourse(_ course: Course, currentUserID: String) {
            guard course.creatorID == currentUserID else {
                print("User not authorized to delete this course")
                return
            }
            
            if let index = courses.firstIndex(where: { $0.id == course.id }) {
                courses.remove(at: index)
                
                // Delete from CloudKit
                let recordID = CKRecord.ID(recordName: course.id)
                publicDatabase.delete(withRecordID: recordID) { (recordID, error) in
                    if let error = error {
                        print("Error deleting course from CloudKit: \(error.localizedDescription)")
                    } else {
                        print("Course successfully deleted from CloudKit")
                    }
                }
                
                saveCourses()
            }
        }
    
    func reportCourse(_ course: Course) {
        if let index = courses.firstIndex(where: { $0.id == course.id }) {
            courses[index].isReported = true
            saveCourses()
            
            // Update in CloudKit
            let record = courses[index].cloudKitRecord
            publicDatabase.save(record) { (record, error) in
                if let error = error {
                    print("Error updating course in CloudKit: \(error.localizedDescription)")
                } else {
                    print("Course successfully reported in CloudKit")
                }
            }
        }
    }
    
    private func saveCourses() {
        if let encoded = try? JSONEncoder().encode(courses) {
            UserDefaults.standard.set(encoded, forKey: "SavedCourses")
        }
    }
    
    private func isAdmin() -> Bool {
            // Implement your admin check logic here
            // For example, you could have a list of admin user IDs
            let adminIDs = ["ADMIN_USER_ID_1", "ADMIN_USER_ID_2"]
            return adminIDs.contains(userManager.getCurrentUserID())
        }
}
