//
//  Hole.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import Foundation
import CoreLocation

struct Hole: Identifiable {
    let id: UUID
    let number: Int
    let par: Int
    var score: Int?
    let teeBox: CLLocationCoordinate2D
    let green: GreenCoordinates
    
    var distanceToFront: Double?
    var distanceToCenter: Double?
    var distanceToBack: Double?
}

struct GreenCoordinates {
    let front: CLLocationCoordinate2D
    let center: CLLocationCoordinate2D
    let back: CLLocationCoordinate2D
}

struct GolfRound: Identifiable {
    let id: UUID
    let date: Date
    let courseName: String
    let courseRating: Double
    let slopeRating: Int
    var holes: [Hole]
    
    var totalScore: Int {
        holes.compactMap { $0.score }.reduce(0, +)
    }
}
