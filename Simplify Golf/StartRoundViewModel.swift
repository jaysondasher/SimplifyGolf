//
//  StartRoundViewModel.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//


import Foundation
import Firebase

class StartRoundViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var selectedCourse: Course?
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
        
        db.collection("rounds").addDocument(data: newRound.toFirestore()) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(newRound))
            }
        }
    }
}
