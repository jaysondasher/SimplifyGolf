//
//  GolfRound.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//
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
}
