//
//  RoundDetailView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/20/24.
//


import SwiftUI

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
