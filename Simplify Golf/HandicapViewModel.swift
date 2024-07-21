import Foundation
import Firebase

class HandicapViewModel: ObservableObject {
    @Published var handicapIndex: Double?
    @Published var recentScores: [Int] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    func fetchHandicapData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            error = "User not logged in"
            return
        }
        
        isLoading = true
        error = nil
        
        db.collection("rounds")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .limit(to: 20)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.error = "Error fetching rounds: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.error = "No rounds found"
                    }
                    return
                }
                
                print("Fetched documents: \(documents.count)")
                
                for document in documents {
                    print("Document data: \(document.data())")
                }
                
                let rounds = documents.compactMap { document -> (id: String, score: Int, courseId: String)? in
                    if let scores = document.data()["scores"] as? [Int],
                       let courseId = document.data()["courseId"] as? String {
                        let totalScore = scores.reduce(0, +)
                        return (document.documentID, totalScore, courseId)
                    }
                    return nil
                }
                
                print("Parsed rounds: \(rounds)")
                
                if rounds.isEmpty {
                    print("No rounds parsed")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.error = "No rounds found"
                    }
                    return
                }
                
                print("Fetched rounds: \(rounds)")
                self.fetchCourseData(for: rounds)
            }
    }
    
    private func fetchCourseData(for rounds: [(id: String, score: Int, courseId: String)]) {
        let courseIds = Array(Set(rounds.map { $0.courseId }))
        let group = DispatchGroup()
        var coursesData: [String: (rating: Double, slope: Int)] = [:]
        
        for courseId in courseIds {
            group.enter()
            db.collection("courses").document(courseId).getDocument { (document, error) in
                defer { group.leave() }
                if let document = document, document.exists,
                   let data = document.data(),
                   let rating = data["courseRating"] as? Double,
                   let slope = data["slopeRating"] as? Int {
                    coursesData[courseId] = (rating, slope)
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            let completeRounds = rounds.compactMap { round -> (score: Int, rating: Double, slope: Int)? in
                guard let courseData = coursesData[round.courseId] else { return nil }
                return (round.score, courseData.rating, courseData.slope)
            }
            
            print("Complete rounds with course data: \(completeRounds)")
            self.calculateHandicap(rounds: completeRounds)
            self.isLoading = false
        }
    }
    
    private func calculateHandicap(rounds: [(score: Int, rating: Double, slope: Int)]) {
        guard !rounds.isEmpty else {
            error = "Not enough rounds to calculate handicap"
            return
        }
        
        let differentials = rounds.map { (113.0 / Double($0.slope)) * (Double($0.score) - $0.rating) }
        print("Differentials: \(differentials)")
        
        let sortedDifferentials = differentials.sorted()
        print("Sorted differentials: \(sortedDifferentials)")
        
        let numberOfDifferentialsToUse: Int
        switch rounds.count {
        case 5...6: numberOfDifferentialsToUse = 1
        case 7...8: numberOfDifferentialsToUse = 2
        case 9...10: numberOfDifferentialsToUse = 3
        case 11...12: numberOfDifferentialsToUse = 4
        case 13...14: numberOfDifferentialsToUse = 5
        case 15...16: numberOfDifferentialsToUse = 6
        case 17: numberOfDifferentialsToUse = 7
        case 18: numberOfDifferentialsToUse = 8
        case 19: numberOfDifferentialsToUse = 9
        case 20: numberOfDifferentialsToUse = 10
        default: numberOfDifferentialsToUse = 0
        }
        
        guard numberOfDifferentialsToUse > 0 else {
            error = "Not enough rounds to calculate handicap"
            return
        }
        
        let relevantDifferentials = Array(sortedDifferentials.prefix(numberOfDifferentialsToUse))
        print("Relevant differentials: \(relevantDifferentials)")
        
        let averageDifferential = relevantDifferentials.reduce(0, +) / Double(relevantDifferentials.count)
        print("Average differential: \(averageDifferential)")
        
        handicapIndex = (averageDifferential * 0.96).rounded(to: 1)
        recentScores = rounds.prefix(5).map { $0.score }
        print("Handicap index: \(String(describing: handicapIndex)), Recent scores: \(recentScores)")
    }
}

extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
