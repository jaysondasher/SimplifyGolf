//
//  RoundSummaryView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import SwiftUI

struct RoundSummaryView: View {
    let round: GolfRound
    
    var body: some View {
        List {
            Section(header: Text("Round Summary")) {
                Text("Course: \(round.courseName)")
                Text("Date: \(formatDate(round.date))")
                Text("Total Score: \(calculateTotalScore())")
            }
            
            Section(header: Text("Hole Scores")) {
                ForEach(round.holes) { hole in
                    HStack {
                        Text("Hole \(hole.number)")
                        Spacer()
                        Text("Par \(hole.par)")
                        Spacer()
                        Text("Score: \(hole.score ?? 0)")
                    }
                }
            }
        }
        .navigationTitle("Round Summary")
        .onAppear {
            print("Round Summary: \(round.courseName), Holes: \(round.holes.count)")
            round.holes.forEach { hole in
                print("Hole: \(hole.number), Par: \(hole.par), Score: \(hole.score ?? 0)")
            }
        }
    }
    
    private func calculateTotalScore() -> Int {
        round.holes.reduce(0) { $0 + ($1.score ?? 0) }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
