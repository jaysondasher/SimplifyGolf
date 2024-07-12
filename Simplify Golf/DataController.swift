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
}
