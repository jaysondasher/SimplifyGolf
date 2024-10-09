import CoreLocation
import Foundation

struct Course: Identifiable, Codable {
    let id: String
    let name: String
    let location: String
    let holes: [Hole]
    let courseRating: Double
    let slopeRating: Int
    let creatorId: String

    init(
        id: String = UUID().uuidString, name: String, location: String, holes: [Hole],
        courseRating: Double, slopeRating: Int, creatorId: String
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.holes = holes
        self.courseRating = courseRating
        self.slopeRating = slopeRating
        self.creatorId = creatorId
    }
}
