//
//  PastRoundsView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//


import SwiftUI

struct PastRoundsView: View {
    @StateObject private var viewModel = PastRoundsViewModel()
    
    var body: some View {
        ZStack {
            MainMenuBackground()
            
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.rounds.isEmpty {
                    List(viewModel.rounds) { round in
                        NavigationLink(destination: RoundDetailView(round: round)) {
                            PastRoundRow(round: round)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    Text("No past rounds found")
                        .foregroundColor(.white)
                }
            }
            .navigationTitle("Past Rounds")
        }
        .onAppear {
            viewModel.fetchPastRounds()
        }
    }
}

struct PastRoundRow: View {
    let round: GolfRound
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Date: \(formatDate(round.date))")
                .font(.headline)
            Text("Total Score: \(round.totalScore)")
                .font(.subheadline)
        }
        .foregroundColor(.white)
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct RoundDetailView: View {
    let round: GolfRound
    
    var body: some View {
        ZStack {
            MainMenuBackground()
            
            VStack {
                Text("Round Details")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("Date: \(formatDate(round.date))")
                    .foregroundColor(.white)
                
                Text("Total Score: \(round.totalScore)")
                    .foregroundColor(.white)
                
                List(round.scores.indices, id: \.self) { index in
                    HStack {
                        Text("Hole \(index + 1)")
                        Spacer()
                        Text("Score: \(round.scores[index] ?? 0)")
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
            }
            .padding()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
