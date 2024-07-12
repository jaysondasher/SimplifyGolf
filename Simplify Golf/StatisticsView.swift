//
//  StatisticsView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/12/24.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var dataController: DataController
    @State private var rounds: [GolfRound] = []
    
    var body: some View {
        List {
            Section(header: Text("Overall Statistics")) {
                InfoRow(title: "Rounds Played", value: "\(rounds.count)")
                InfoRow(title: "Average Score", value: String(format: "%.1f", calculateAverageScore()))
                InfoRow(title: "Best Round", value: bestRound())
            }
            
            Section(header: Text("Scoring Breakdown")) {
                InfoRow(title: "Eagles", value: "\(totalScores(equalTo: -2))")
                InfoRow(title: "Birdies", value: "\(totalScores(equalTo: -1))")
                InfoRow(title: "Pars", value: "\(totalScores(equalTo: 0))")
                InfoRow(title: "Bogeys", value: "\(totalScores(equalTo: 1))")
                InfoRow(title: "Double Bogeys+", value: "\(totalScores(greaterThan: 1))")
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Statistics")
        .onAppear {
            rounds = dataController.fetchRounds()
        }
    }
    
    private func calculateAverageScore() -> Double {
        let totalScore = rounds.reduce(0) { $0 + $1.totalScore }
        return Double(totalScore) / Double(rounds.count)
    }
    
    private func bestRound() -> String {
        guard let bestRound = rounds.min(by: { $0.totalScore < $1.totalScore }) else {
            return "N/A"
        }
        return "\(bestRound.totalScore) at \(bestRound.courseName)"
    }
    
    private func totalScores(equalTo value: Int) -> Int {
        rounds.reduce(0) { $0 + $1.holes.filter { ($0.score ?? 0) - $0.par == value }.count }
    }
    
    private func totalScores(greaterThan value: Int) -> Int {
        rounds.reduce(0) { $0 + $1.holes.filter { ($0.score ?? 0) - $0.par > value }.count }
    }
}
