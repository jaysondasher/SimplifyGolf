//
//  CourseSelectionView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import SwiftUI

struct CourseSelectionView: View {
    @Binding var activeRound: GolfRound?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var courseManager: CourseManager
    
    var body: some View {
        List(courseManager.courses) { course in
            Button(action: {
                startRound(course: course)
            }) {
                VStack(alignment: .leading) {
                    Text(course.name)
                        .font(.headline)
                    Text(course.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Select Course")
    }
    
    func startRound(course: Course) {
        let holes = course.holes.map { courseHole in
            Hole(id: UUID(),
                 number: courseHole.number,
                 par: courseHole.par,
                 score: nil,
                 teeBox: courseHole.teeBox.clLocationCoordinate2D,
                 green: GreenCoordinates(
                    front: courseHole.green.front.clLocationCoordinate2D,
                    center: courseHole.green.center.clLocationCoordinate2D,
                    back: courseHole.green.back.clLocationCoordinate2D
                 ))
        }
        activeRound = GolfRound(id: UUID(), date: Date(), courseName: course.name, courseRating: course.courseRating, slopeRating: course.slopeRating, holes: holes)
        presentationMode.wrappedValue.dismiss()
    }
}
