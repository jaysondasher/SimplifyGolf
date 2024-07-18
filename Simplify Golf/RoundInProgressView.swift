//
//  RoundInProgressView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//


import SwiftUI

struct RoundInProgressView: View {
    @StateObject private var viewModel: RoundInProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(round: GolfRound) {
        _viewModel = StateObject(wrappedValue: RoundInProgressViewModel(round: round))
    }
    
    var body: some View {
        ZStack {
            MainMenuBackground()
            
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                } else if let course = viewModel.course {
                    Text(course.name)
                        .font(.title)
                        .foregroundColor(.white)
                    
                    if viewModel.currentHoleIndex < course.holes.count {
                        let hole = course.holes[viewModel.currentHoleIndex]
                        HoleView(hole: hole, score: Binding(
                            get: { viewModel.round.scores[viewModel.currentHoleIndex] ?? 0 },
                            set: { viewModel.updateScore(for: viewModel.currentHoleIndex, score: $0) }
                        ))
                    }
                    
                    HStack {
                        Button("Previous") {
                            viewModel.moveToPreviousHole()
                        }
                        .disabled(viewModel.currentHoleIndex == 0)
                        
                        Spacer()
                        
                        Button(viewModel.currentHoleIndex == course.holes.count - 1 ? "Finish Round" : "Next") {
                            if viewModel.currentHoleIndex == course.holes.count - 1 {
                                viewModel.finishRound()
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                viewModel.moveToNextHole()
                            }
                        }
                    }
                    .padding()
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
    }
}

struct HoleView: View {
    let hole: Hole
    @Binding var score: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Hole \(hole.number)")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Par \(hole.par)")
                .foregroundColor(.white)
            
            Text("Yardage: \(hole.yardage)")
                .foregroundColor(.white)
            
            Stepper(value: $score, in: 1...20) {
                Text("Score: \(score)")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}
