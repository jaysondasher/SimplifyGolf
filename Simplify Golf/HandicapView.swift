//
//  HandicapView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/12/24.
//

import SwiftUI

struct HandicapView: View {
    @EnvironmentObject var dataController: DataController
    @State private var handicapIndex: Double = 0.0
    @State private var rounds: [GolfRound] = []

    var body: some View {
        List {
            Section(header: Text("Current Handicap")) {
                HStack {
                    Text("Handicap Index")
                    Spacer()
                    Text(handicapIndex == 0 ? "N/A" : String(format: "%.1f", handicapIndex))
                        .fontWeight(.bold)
                }
            }

            Section(header: Text("Recent Rounds")) {
                if rounds.isEmpty {
                    Text("No rounds recorded yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(rounds.prefix(20)) { round in
                        HStack {
                            Text(round.courseName)
                            Spacer()
                            Text("Score: \(round.totalScore)")
                            Text("Differential: \(String(format: "%.1f", dataController.calculateDifferential(round: round)))")
                        }
                    }
                }
            }

            Section(header: Text("Handicap Information")) {
                Text("Your handicap index is calculated based on your recent scores, using the USGA handicap system. A minimum of 3 rounds is required to establish a handicap.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Handicap")
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        rounds = dataController.fetchRounds().sorted(by: { $0.date > $1.date })
        handicapIndex = dataController.calculateHandicapIndex()
    }
}
