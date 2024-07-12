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
        ZStack {
            GolfAppBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    RoundInfoSection(round: round)
                    HoleScoresSection(holes: round.holes)
                    StatisticsSection(round: round)
                }
                .padding()
            }
        }
        .navigationTitle("Round Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Keep the private functions as they are
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

struct RoundInfoSection: View {
    let round: GolfRound
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Round Information")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                InfoRow(title: "Course", value: round.courseName)
                InfoRow(title: "Date", value: formatDate(round.date))
                InfoRow(title: "Total Score", value: "\(round.totalScore)")
                InfoRow(title: "To Par", value: scoreToPar())
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
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
}

struct HoleScoresSection: View {
    let holes: [Hole]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hole Scores")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 1) {
                ForEach(holes) { hole in
                    HoleScoreRow(hole: hole)
                }
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

struct StatisticsSection: View {
    let round: GolfRound
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                InfoRow(title: "Pars", value: "\(countScores(equalTo: 0))")
                InfoRow(title: "Birdies", value: "\(countScores(equalTo: -1))")
                InfoRow(title: "Eagles", value: "\(countScores(equalTo: -2))")
                InfoRow(title: "Bogeys", value: "\(countScores(equalTo: 1))")
                InfoRow(title: "Double Bogeys+", value: "\(countScores(greaterThan: 1))")
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
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
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

struct HoleScoreRow: View {
    let hole: Hole
    
    var body: some View {
        HStack {
            Text("Hole \(hole.number)")
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text("Par \(hole.par)")
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text("Score: \(hole.score ?? 0)")
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color.white.opacity(0.05))
    }
}
