import Foundation
import FirebaseFirestore
import CoreLocation

struct Course: Identifiable, Codable {
    let id: String
    let name: String
    let location: String
    let holes: [Hole]
    let courseRating: Double
    let slopeRating: Int
    let creatorId: String
    
    init(id: String = UUID().uuidString, name: String, location: String, holes: [Hole], courseRating: Double, slopeRating: Int, creatorId: String) {
        self.id = id
        self.name = name
        self.location = location
        self.holes = holes
        self.courseRating = courseRating
        self.slopeRating = slopeRating
        self.creatorId = creatorId
    }
    
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "location": location,
            "holes": holes.map { $0.toFirestore() },
            "courseRating": courseRating,
            "slopeRating": slopeRating,
            "creatorId": creatorId
        ]
    }
    
    static func fromFirestore(_ data: [String: Any]) -> Course? {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String,
              let location = data["location"] as? String,
              let holesData = data["holes"] as? [[String: Any]],
              let courseRating = data["courseRating"] as? Double,
              let slopeRating = data["slopeRating"] as? Int,
              let creatorId = data["creatorId"] as? String else {
            return nil
        }
        
        let holes = holesData.compactMap { Hole.fromFirestore($0) }
        
        return Course(id: id, name: name, location: location, holes: holes, courseRating: courseRating, slopeRating: slopeRating, creatorId: creatorId)
    }
}
