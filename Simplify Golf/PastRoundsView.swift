//
//  PastRoundsView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import SwiftUI

struct PastRoundsView: View {
    @EnvironmentObject var dataController: DataController
    @State private var rounds: [GolfRound] = []
    
    var body: some View {
        List(rounds) { round in
            NavigationLink(destination: RoundSummaryView(round: round)) {
                VStack(alignment: .leading) {
                    Text(round.courseName)
                        .font(.headline)
                    Text("Date: \(formatDate(round.date))")
                        .font(.subheadline)
                    Text("Total Score: \(calculateTotalScore(round))")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Past Rounds")
        .onAppear {
            rounds = dataController.fetchRounds()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func calculateTotalScore(_ round: GolfRound) -> Int {
        round.holes.reduce(0) { $0 + ($1.score ?? 0) }
    }
}
