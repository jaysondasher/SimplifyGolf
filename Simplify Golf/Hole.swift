//
//  Hole.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/20/24.
//

import CoreLocation
import Foundation

struct Hole: Identifiable, Codable, Equatable {  // Conformed to Equatable
    let id: String
    let number: Int
    let par: Int
    let yardage: Int
    let teeBox: Coordinate
    let green: Green

    struct Green: Codable, Equatable {  // Conformed to Equatable
        let front: Coordinate
        let center: Coordinate
        let back: Coordinate

        static func == (lhs: Green, rhs: Green) -> Bool {
            return lhs.front == rhs.front && lhs.center == rhs.center && lhs.back == rhs.back
        }
    }

    static func == (lhs: Hole, rhs: Hole) -> Bool {
        return lhs.id == rhs.id && lhs.number == rhs.number && lhs.par == rhs.par
            && lhs.yardage == rhs.yardage && lhs.teeBox == rhs.teeBox && lhs.green == rhs.green
    }

    init(
        id: String = UUID().uuidString, number: Int, par: Int, yardage: Int, teeBox: Coordinate,
        green: Green
    ) {
        self.id = id
        self.number = number
        self.par = par
        self.yardage = yardage
        self.teeBox = teeBox
        self.green = green
    }

    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "number": number,
            "par": par,
            "yardage": yardage,
            "teeBox": teeBox.toFirestore(),
            "green": [
                "front": green.front.toFirestore(),
                "center": green.center.toFirestore(),
                "back": green.back.toFirestore(),
            ],
        ]
    }

    static func fromFirestore(_ data: [String: Any]) -> Hole? {
        guard let id = data["id"] as? String,
            let number = data["number"] as? Int,
            let par = data["par"] as? Int,
            let yardage = data["yardage"] as? Int,
            let teeBoxData = data["teeBox"] as? [String: Any],
            let greenData = data["green"] as? [String: Any],
            let teeBox = Coordinate.fromFirestore(teeBoxData),
            let frontData = greenData["front"] as? [String: Any],
            let centerData = greenData["center"] as? [String: Any],
            let backData = greenData["back"] as? [String: Any],
            let front = Coordinate.fromFirestore(frontData),
            let center = Coordinate.fromFirestore(centerData),
            let back = Coordinate.fromFirestore(backData)
        else {
            return nil
        }

        let green = Green(front: front, center: center, back: back)

        return Hole(
            id: id, number: number, par: par, yardage: yardage, teeBox: teeBox, green: green)
    }
}

struct Coordinate: Codable, Equatable {  // Conformed to Equatable
    let latitude: Double
    let longitude: Double

    var clLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    func toFirestore() -> [String: Any] {
        return [
            "latitude": latitude,
            "longitude": longitude,
        ]
    }

    static func fromFirestore(_ data: [String: Any]) -> Coordinate? {
        guard let latitude = data["latitude"] as? Double,
            let longitude = data["longitude"] as? Double
        else {
            return nil
        }
        return Coordinate(latitude: latitude, longitude: longitude)
    }
}
