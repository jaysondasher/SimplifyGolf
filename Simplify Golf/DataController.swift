//
//  DataController.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import CoreData
import CoreLocation

class DataController: ObservableObject {
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "GolfRoundModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func saveRound(_ round: GolfRound) {
        let context = container.viewContext
        
        let cdRound = CDGolfRound(context: context)
        cdRound.id = round.id
        cdRound.date = round.date
        cdRound.courseName = round.courseName
        cdRound.courseRating = round.courseRating
        cdRound.slopeRating = Int16(round.slopeRating)
        
        print("Saving round: \(round.courseName), Holes: \(round.holes.count)")
        
        for hole in round.holes {
            let cdHole = CDHole(context: context)
            cdHole.id = hole.id
            cdHole.number = Int16(hole.number)
            cdHole.par = Int16(hole.par)
            cdHole.score = Int16(hole.score ?? 0)
            cdHole.teeBoxLatitude = hole.teeBox.latitude
            cdHole.teeBoxLongitude = hole.teeBox.longitude
            cdHole.greenFrontLatitude = hole.green.front.latitude
            cdHole.greenFrontLongitude = hole.green.front.longitude
            cdHole.greenCenterLatitude = hole.green.center.latitude
            cdHole.greenCenterLongitude = hole.green.center.longitude
            cdHole.greenBackLatitude = hole.green.back.latitude
            cdHole.greenBackLongitude = hole.green.back.longitude
            
            cdHole.round = cdRound
            cdRound.addToHoles(cdHole)
            
            print("Saving hole: \(hole.number), Par: \(hole.par), Score: \(hole.score ?? 0)")
        }
        
        saveContext()
        print("Round saved")
    }
    
    func fetchRounds() -> [GolfRound] {
        let fetchRequest: NSFetchRequest<CDGolfRound> = CDGolfRound.fetchRequest()
        
        do {
            let cdRounds = try container.viewContext.fetch(fetchRequest)
            print("Fetched \(cdRounds.count) rounds")
            
            return cdRounds.map { cdRound in
                let holes = (cdRound.holes?.allObjects as? [CDHole])?.sorted(by: { $0.number < $1.number }).map { cdHole in
                    Hole(id: cdHole.id ?? UUID(),
                         number: Int(cdHole.number),
                         par: Int(cdHole.par),
                         score: Int(cdHole.score),
                         teeBox: CLLocationCoordinate2D(latitude: cdHole.teeBoxLatitude, longitude: cdHole.teeBoxLongitude),
                         green: GreenCoordinates(
                            front: CLLocationCoordinate2D(latitude: cdHole.greenFrontLatitude, longitude: cdHole.greenFrontLongitude),
                            center: CLLocationCoordinate2D(latitude: cdHole.greenCenterLatitude, longitude: cdHole.greenCenterLongitude),
                            back: CLLocationCoordinate2D(latitude: cdHole.greenBackLatitude, longitude: cdHole.greenBackLongitude)
                         ))
                } ?? []
                
                print("Round: \(cdRound.courseName ?? ""), Holes: \(holes.count)")
                holes.forEach { hole in
                    print("Hole: \(hole.number), Par: \(hole.par), Score: \(hole.score ?? 0)")
                }
                
                return GolfRound(id: cdRound.id ?? UUID(),
                                 date: cdRound.date ?? Date(),
                                 courseName: cdRound.courseName ?? "",
                                 courseRating: cdRound.courseRating,
                                 slopeRating: Int(cdRound.slopeRating),
                                 holes: holes)
            }
        } catch {
            print("Failed to fetch rounds: \(error)")
            return []
        }
    }
    
    func calculateHandicapIndex() -> Double {
            let allRounds = fetchRounds().sorted(by: { $0.date > $1.date })
            let recentRounds = Array(allRounds.prefix(20))
            
            if recentRounds.count < 3 {
                return 0 // Not enough rounds to calculate a handicap
            }
            
            let differentials = recentRounds.map { calculateDifferential(round: $0) }
            
            let numberOfDifferentialsToUse: Int
            if recentRounds.count <= 5 {
                numberOfDifferentialsToUse = 1
            } else if recentRounds.count <= 11 {
                numberOfDifferentialsToUse = 3
            } else if recentRounds.count <= 14 {
                numberOfDifferentialsToUse = 5
            } else if recentRounds.count <= 19 {
                numberOfDifferentialsToUse = 7
            } else {
                numberOfDifferentialsToUse = 8
            }
            
            let bestDifferentials = Array(differentials.sorted().prefix(numberOfDifferentialsToUse))
            let averageDifferential = bestDifferentials.reduce(0, +) / Double(bestDifferentials.count)
            
            // Apply the 0.96 multiplier and round to one decimal place
            return (averageDifferential * 0.96).rounded(to: 1)
        }
        
        func calculateDifferential(round: GolfRound) -> Double {
            let slope = Double(round.slopeRating)
            let rating = round.courseRating
            let score = Double(round.totalScore)
            return ((score - rating) * 113) / slope
        }
    
    func updateRound(_ round: GolfRound) {
            let context = container.viewContext
            let fetchRequest: NSFetchRequest<CDGolfRound> = CDGolfRound.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", round.id as CVarArg)
            
            do {
                let results = try context.fetch(fetchRequest)
                if let cdRound = results.first {
                    cdRound.courseName = round.courseName
                    cdRound.date = round.date
                    cdRound.courseRating = round.courseRating
                    cdRound.slopeRating = Int16(round.slopeRating)
                    
                    for hole in round.holes {
                        if let cdHole = cdRound.holes?.first(where: { ($0 as? CDHole)?.number == Int16(hole.number) }) as? CDHole {
                            cdHole.score = Int16(hole.score ?? 0)
                        }
                    }
                    
                    try context.save()
                }
            } catch {
                print("Failed to update round: \(error)")
            }
        }
        
        func deleteRound(_ round: GolfRound) {
            let context = container.viewContext
            let fetchRequest: NSFetchRequest<CDGolfRound> = CDGolfRound.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", round.id as CVarArg)
            
            do {
                let results = try context.fetch(fetchRequest)
                if let cdRound = results.first {
                    context.delete(cdRound)
                    try context.save()
                }
            } catch {
                print("Failed to delete round: \(error)")
            }
        }

}

extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
