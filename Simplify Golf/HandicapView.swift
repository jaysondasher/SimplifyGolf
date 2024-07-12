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
        ZStack {
            GolfAppBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    HandicapCard(handicapIndex: handicapIndex)
                    
                    RecentRoundsSection(rounds: rounds, dataController: dataController)
                    
                    HandicapInfoSection()
                }
                .padding()
            }
        }
        .navigationTitle("Handicap")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        rounds = dataController.fetchRounds().sorted(by: { $0.date > $1.date })
        handicapIndex = dataController.calculateHandicapIndex()
    }
}

struct HandicapCard: View {
    let handicapIndex: Double
    
    var body: some View {
        VStack {
            Text("Current Handicap")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(handicapIndex == 0 ? "N/A" : String(format: "%.1f", handicapIndex))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct RecentRoundsSection: View {
    let rounds: [GolfRound]
    let dataController: DataController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Rounds")
                .font(.headline)
                .foregroundColor(.white)
            
            if rounds.isEmpty {
                Text("No rounds recorded yet")
                    .foregroundColor(.white.opacity(0.6))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
            } else {
                ForEach(rounds.prefix(20)) { round in
                    RoundRow(round: round, dataController: dataController)
                }
            }
        }
    }
}

struct RoundRow: View {
    let round: GolfRound
    let dataController: DataController
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(round.courseName)
                    .foregroundColor(.white)
                Text("Score: \(round.totalScore)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            Text("Diff: \(String(format: "%.1f", dataController.calculateDifferential(round: round)))")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

struct HandicapInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Handicap Information")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Your handicap index is calculated based on your recent scores, using the USGA handicap system. A minimum of 3 rounds is required to establish a handicap.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}
