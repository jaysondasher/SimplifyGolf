//
//  Hole.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import Foundation
import CoreLocation

struct Hole: Identifiable {
    var id: UUID
    var number: Int
    var par: Int
    var score: Int?
    var teeBox: CLLocationCoordinate2D
    var green: GreenCoordinates
    
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
    var id: UUID
    var date: Date
    var courseName: String
    var courseRating: Double
    var slopeRating: Int
    var holes: [Hole]
    
    var totalScore: Int {
        holes.reduce(0) { $0 + ($1.score ?? 0) }
    }
}
