//
//  RoundInProgressView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/12/24.
//

import SwiftUI

struct RoundInProgressView: View {
    @Binding var activeRound: GolfRound?
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var dataController: DataController
    @State private var currentHoleIndex = 0
    @State private var showingRoundSummary = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            GolfAppBackground()
            
            VStack(spacing: 20) {
                if let round = activeRound {
                    Text(round.courseName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Total Score: \(round.totalScore)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(round.holes.indices, id: \.self) { index in
                                NavigationLink(destination: HoleDetailView(
                                    round: $activeRound,
                                    currentHoleIndex: $currentHoleIndex,
                                    locationManager: locationManager,
                                    onFinishRound: finishRound
                                )) {
                                    HoleRowView(hole: round.holes[index], currentHole: currentHoleIndex + 1)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Button("End Round") {
                        finishRound()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingRoundSummary) {
            if let round = activeRound {
                RoundSummaryView(round: round)
            }
        }
    }
    
    private func finishRound() {
        if let round = activeRound {
            dataController.saveRound(round)
            showingRoundSummary = true
            activeRound = nil
            currentHoleIndex = 0
        }
    }
    
    struct HoleRowView: View {
        let hole: Hole
        let currentHole: Int
        
        var body: some View {
            HStack {
                Text("Hole \(hole.number)")
                    .fontWeight(.medium)
                Spacer()
                Text("Par \(hole.par)")
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                if let score = hole.score {
                    Text("Score: \(score)")
                        .fontWeight(.semibold)
                } else {
                    Text("Not played")
                        .foregroundColor(.white.opacity(0.5))
                }
                if hole.number == currentHole {
                    Image(systemName: "location.fill")
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
        }
    }
}

