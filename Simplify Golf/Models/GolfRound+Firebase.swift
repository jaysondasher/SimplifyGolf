#if !os(watchOS)
    import FirebaseFirestore

    extension GolfRound {
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
#endif
