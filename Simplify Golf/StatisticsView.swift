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
        ZStack {
            GolfAppBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    StatSection(title: "Overall Statistics") {
                        StatRow(title: "Rounds Played", value: "\(rounds.count)")
                        StatRow(title: "Average Score", value: String(format: "%.1f", calculateAverageScore()))
                        StatRow(title: "Best Round", value: bestRound())
                    }
                    
                    StatSection(title: "Scoring Breakdown") {
                        StatRow(title: "Eagles", value: "\(totalScores(equalTo: -2))")
                        StatRow(title: "Birdies", value: "\(totalScores(equalTo: -1))")
                        StatRow(title: "Pars", value: "\(totalScores(equalTo: 0))")
                        StatRow(title: "Bogeys", value: "\(totalScores(equalTo: 1))")
                        StatRow(title: "Double Bogeys+", value: "\(totalScores(greaterThan: 1))")
                    }
                }
                .padding()
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

struct StatSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading)
            
            VStack(spacing: 1) {
                content
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color.white.opacity(0.05))
    }
}
