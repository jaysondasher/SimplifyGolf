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
    @State private var roundToEdit: GolfRound?
    
    var body: some View {
        ZStack {
            GolfAppBackground()
            
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(rounds) { round in
                        NavigationLink(destination: RoundSummaryView(round: round)) {
                            PastRoundRow(round: round)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteRound(round)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                self.roundToEdit = round
                                print("Edit button tapped for round: \(round.id)")
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Past Rounds")
        .onAppear {
            loadRounds()
        }
        .fullScreenCover(item: $roundToEdit, onDismiss: loadRounds) { round in
            NavigationView {
                EditRoundView(round: round)
            }
        }
    }
    
    private func loadRounds() {
        rounds = dataController.fetchRounds().sorted(by: { $0.date > $1.date })
    }
    
    private func deleteRound(_ round: GolfRound) {
        dataController.deleteRound(round)
        loadRounds()
    }
}

struct PastRoundRow: View {
    let round: GolfRound
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(round.courseName)
                .font(.headline)
                .foregroundColor(.white)
            Text("Date: \(formatDate(round.date))")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            Text("Total Score: \(round.totalScore)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
