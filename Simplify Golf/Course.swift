//
//  Course.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import Foundation
import CoreLocation

struct Course: Codable, Identifiable {
    let id: String
    let name: String
    let location: String
    let courseRating: Double
    let slopeRating: Int
    let holes: [CourseHole]
}

struct CourseHole: Codable, Identifiable {
    let id: Int
    let number: Int
    let par: Int
    let yardage: Int
    let teeBox: Coordinate
    let green: Green
    
    struct Green: Codable {
        let front: Coordinate
        let center: Coordinate
        let back: Coordinate
    }
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension CourseHole {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        number = try container.decode(Int.self, forKey: .number)
        par = try container.decode(Int.self, forKey: .par)
        yardage = try container.decode(Int.self, forKey: .yardage)
        teeBox = try container.decode(Coordinate.self, forKey: .teeBox)
        green = try container.decode(Green.self, forKey: .green)
        id = number // Use hole number as ID
    }
}
