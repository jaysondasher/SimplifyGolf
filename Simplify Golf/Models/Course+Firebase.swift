#if !os(watchOS)
    import FirebaseFirestore

    extension Course {
        func toFirestore() -> [String: Any] {
            return [
                "id": id,
                "name": name,
                "location": location,
                "holes": holes.map { $0.toFirestore() },
                "courseRating": courseRating,
                "slopeRating": slopeRating,
                "creatorId": creatorId,
            ]
        }

        static func fromFirestore(_ data: [String: Any]) -> Course? {
            guard let id = data["id"] as? String,
                let name = data["name"] as? String,
                let location = data["location"] as? String,
                let holesData = data["holes"] as? [[String: Any]],
                let courseRating = data["courseRating"] as? Double,
                let slopeRating = data["slopeRating"] as? Int,
                let creatorId = data["creatorId"] as? String
            else {
                return nil
            }

            let holes = holesData.compactMap { Hole.fromFirestore($0) }

            return Course(
                id: id, name: name, location: location, holes: holes, courseRating: courseRating,
                slopeRating: slopeRating, creatorId: creatorId)
        }
    }
#endif
