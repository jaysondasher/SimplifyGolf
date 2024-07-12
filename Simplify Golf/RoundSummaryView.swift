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
            Section(header: Text("Round Information")) {
                InfoRow(title: "Course", value: round.courseName)
                InfoRow(title: "Date", value: formatDate(round.date))
                InfoRow(title: "Total Score", value: "\(round.totalScore)")
                InfoRow(title: "To Par", value: scoreToPar())
            }
            
            Section(header: Text("Hole Scores")) {
                ForEach(round.holes) { hole in
                    HoleScoreRow(hole: hole)
                }
            }
            
            Section(header: Text("Statistics")) {
                InfoRow(title: "Pars", value: "\(countScores(equalTo: 0))")
                InfoRow(title: "Birdies", value: "\(countScores(equalTo: -1))")
                InfoRow(title: "Eagles", value: "\(countScores(equalTo: -2))")
                InfoRow(title: "Bogeys", value: "\(countScores(equalTo: 1))")
                InfoRow(title: "Double Bogeys+", value: "\(countScores(greaterThan: 1))")
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Round Summary")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func scoreToPar() -> String {
        let toPar = round.totalScore - round.holes.reduce(0) { $0 + $1.par }
        if toPar == 0 {
            return "Even"
        } else if toPar > 0 {
            return "+\(toPar)"
        } else {
            return "\(toPar)"
        }
    }
    
    private func countScores(equalTo value: Int) -> Int {
        round.holes.filter { ($0.score ?? 0) - $0.par == value }.count
    }
    
    private func countScores(greaterThan value: Int) -> Int {
        round.holes.filter { ($0.score ?? 0) - $0.par > value }.count
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct HoleScoreRow: View {
    let hole: Hole
    
    var body: some View {
        HStack {
            Text("Hole \(hole.number)")
            Spacer()
            Text("Par \(hole.par)")
            Spacer()
            Text("Score: \(hole.score ?? 0)")
                .fontWeight(.semibold)
        }
    }
}
