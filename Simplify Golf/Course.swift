//
//  Course.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import Foundation
import CloudKit
import CoreLocation

struct Course: Codable, Identifiable, Hashable {
    let id: String
    var name: String
    var location: String
    var courseRating: Double
    var slopeRating: Int
    var holes: [CourseHole]
    var creatorID: String
    var isReported: Bool
    
    init(id: String, name: String, location: String, courseRating: Double, slopeRating: Int, holes: [CourseHole], creatorID: String) {
        self.id = id
        self.name = name
        self.location = location
        self.courseRating = courseRating
        self.slopeRating = slopeRating
        self.holes = holes
        self.creatorID = creatorID
        self.isReported = false
    }
    
    init?(record: CKRecord) {
        guard let name = record["name"] as? String,
              let location = record["location"] as? String,
              let courseRating = record["courseRating"] as? Double,
              let slopeRating = record["slopeRating"] as? Int,
              let holesData = record["holes"] as? Data,
              let holes = try? JSONDecoder().decode([CourseHole].self, from: holesData),
              let creatorID = record["creatorID"] as? String else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.name = name
        self.location = location
        self.courseRating = courseRating
        self.slopeRating = slopeRating
        self.holes = holes
        self.creatorID = creatorID
        self.isReported = record["isReported"] as? Bool ?? false
    }
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: "Course")
        record["name"] = name
        record["location"] = location
        record["courseRating"] = courseRating
        record["slopeRating"] = slopeRating
        if let holesData = try? JSONEncoder().encode(holes) {
            record["holes"] = holesData
        }
        record["creatorID"] = creatorID
        record["isReported"] = isReported
        return record
    }
    
    // Conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Course, rhs: Course) -> Bool {
        lhs.id == rhs.id
    }
}

struct CourseHole: Codable, Identifiable, Hashable {
    let id: Int
    let number: Int
    let par: Int
    let yardage: Int
    let teeBox: Coordinate
    let green: Green
    
    struct Green: Codable, Hashable {
        let front: Coordinate
        let center: Coordinate
        let back: Coordinate
    }
}

struct Coordinate: Codable, Hashable {
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
