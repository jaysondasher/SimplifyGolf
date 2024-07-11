//
//  CourseManager.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import Foundation

class CourseManager: ObservableObject {
    @Published var courses: [Course] = []
    
    init() {
        loadCourses()
    }
    
    private func loadCourses() {
        guard let url = Bundle.main.url(forResource: "courses", withExtension: "json") else {
            print("Unable to find courses.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            courses = try JSONDecoder().decode([Course].self, from: data)
        } catch {
            print("Error loading courses: \(error.localizedDescription)")
        }
    }
}
