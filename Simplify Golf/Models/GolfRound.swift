//
//  GolfRound.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//

import FirebaseFirestore
import Foundation

struct GolfRound: Identifiable, Codable {
    let id: String
    let date: Date
    let courseId: String
    let userId: String
    var scores: [Int?]
    var isCompleted: Bool = false
    var totalScore: Int {
        scores.compactMap { $0 }.reduce(0, +)
    }

    init(
        id: String = UUID().uuidString, date: Date, courseId: String, userId: String, scores: [Int?]
    ) {
        self.id = id
        self.date = date
        self.courseId = courseId
        self.userId = userId
        self.scores = scores
    }

    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "date": Timestamp(date: date),
            "courseId": courseId,
            "userId": userId,
            "scores": scores.map { $0 as Any },
        ]
    }

    static func fromFirestore(_ data: [String: Any]) -> GolfRound? {
        guard let id = data["id"] as? String,
            let timestamp = data["date"] as? Timestamp,
            let courseId = data["courseId"] as? String,
            let userId = data["userId"] as? String,
            let scoresData = data["scores"] as? [Any]
        else {
            return nil
        }

        let date = timestamp.dateValue()
        let scores = scoresData.map { ($0 as? Int) }

        return GolfRound(id: id, date: date, courseId: courseId, userId: userId, scores: scores)
    }
}
