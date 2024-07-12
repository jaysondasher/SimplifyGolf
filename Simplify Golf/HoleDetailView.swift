//
//  HoleDetailView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import SwiftUI
import CoreLocation

struct HoleDetailView: View {
    @Binding var round: GolfRound?
    @Binding var currentHoleIndex: Int
    @ObservedObject var locationManager: LocationManager
    @State private var distanceToFront: Double = 0
    @State private var distanceToCenter: Double = 0
    @State private var distanceToBack: Double = 0
    @State private var score: Int
    var onFinishRound: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var hole: Hole? {
        round?.holes[safe: currentHoleIndex]
    }
    
    init(round: Binding<GolfRound?>, currentHoleIndex: Binding<Int>, locationManager: LocationManager, onFinishRound: @escaping () -> Void) {
        self._round = round
        self._currentHoleIndex = currentHoleIndex
        self.locationManager = locationManager
        self._score = State(initialValue: round.wrappedValue?.holes[safe: currentHoleIndex.wrappedValue]?.par ?? 0)
        self.onFinishRound = onFinishRound
    }
    
    var body: some View {
        ZStack {
            GolfAppBackground()
            
            if let hole = hole, let round = round {
                VStack(spacing: 24) {
                    HoleInfoView(holeNumber: hole.number, par: hole.par)
                    
                    ScoreView(score: $score)
                    
                    DistanceView(front: distanceToFront, center: distanceToCenter, back: distanceToBack)
                    
                    Spacer()
                    
                    NavigationButtons(
                        currentHoleIndex: currentHoleIndex,
                        totalHoles: round.holes.count,
                        onPrevious: { saveAndNavigate(to: currentHoleIndex - 1) },
                        onNext: {
                            if currentHoleIndex == round.holes.count - 1 {
                                saveAndFinish()
                            } else {
                                saveAndNavigate(to: currentHoleIndex + 1)
                            }
                        }
                    )
                }
                .padding()
            } else {
                Text("Hole data not available")
                    .foregroundColor(.white)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton(action: {
            saveCurrentHoleScore()
            presentationMode.wrappedValue.dismiss()
        }))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { updateDistances() }
        .onReceive(locationManager.$location) { _ in updateDistances() }
    }
    
    private func updateDistances() {
        if let hole = hole {
            distanceToFront = locationManager.calculateDistance(to: hole.green.front) ?? 0
            distanceToCenter = locationManager.calculateDistance(to: hole.green.center) ?? 0
            distanceToBack = locationManager.calculateDistance(to: hole.green.back) ?? 0
        }
    }
    
    private func saveAndNavigate(to index: Int) {
        saveCurrentHoleScore()
        currentHoleIndex = index
    }
    
    private func saveAndFinish() {
        saveCurrentHoleScore()
        onFinishRound()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func saveCurrentHoleScore() {
        guard var currentRound = round else { return }
        if currentHoleIndex < currentRound.holes.count {
            currentRound.holes[currentHoleIndex].score = score
            round = currentRound
        }
    }
}

struct HoleInfoView: View {
    let holeNumber: Int
    let par: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hole \(holeNumber)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                Text("Par \(par)")
                    .font(.title3)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
    }
}

struct ScoreView: View {
    @Binding var score: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Your Score")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 20) {
                Button(action: { score = max(1, score - 1) }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 32))
                }
                
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .frame(width: 80)
                
                Button(action: { score += 1 }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                }
            }
            .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
    }
}

struct DistanceView: View {
    let front: Double
    let center: Double
    let back: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distance to Green")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 12) {
                DistanceCard(label: "Front", distance: front)
                DistanceCard(label: "Center", distance: center)
                DistanceCard(label: "Back", distance: back)
            }
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(15)
    }
}

struct DistanceCard: View {
    let label: String
    let distance: Double
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
            Text("\(Int(distance * 1.09361))")
                .font(.title2)
                .fontWeight(.bold)
            Text("yards")
                .font(.caption2)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

struct NavigationButtons: View {
    let currentHoleIndex: Int
    let totalHoles: Int
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack {
            if currentHoleIndex > 0 {
                Button(action: onPrevious) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Spacer()
            
            Button(action: onNext) {
                HStack {
                    Text(currentHoleIndex == totalHoles - 1 ? "Finish Round" : "Next Hole")
                    Image(systemName: "chevron.right")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.white)
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
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

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
