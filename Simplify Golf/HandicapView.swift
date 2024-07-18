//
//  HandicapView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//


import SwiftUI

struct HandicapView: View {
    @StateObject private var viewModel = HandicapViewModel()
    
    var body: some View {
        ZStack {
            MainMenuBackground()
            
            VStack(spacing: 20) {
                Text("Your Handicap")
                    .font(.title)
                    .foregroundColor(.white)
                
                if viewModel.isLoading {
                    ProgressView()
                } else if let handicap = viewModel.handicapIndex {
                    Text(String(format: "%.1f", handicap))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Handicap Index")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Divider().background(Color.white)
                    
                    Text("Recent Scores")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 15) {
                        ForEach(viewModel.recentScores, id: \.self) { score in
                            Text("\(score)")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(25)
                        }
                    }
                } else {
                    Text("Not enough rounds to calculate handicap")
                        .foregroundColor(.white.opacity(0.8))
                }
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchHandicapData()
        }
    }
}
