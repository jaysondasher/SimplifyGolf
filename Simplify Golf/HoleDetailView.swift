//
//  HoleDetailView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import SwiftUI
import CoreLocation

struct HoleDetailView: View {
    @Binding var round: GolfRound
    @Binding var currentHoleIndex: Int
    @ObservedObject var locationManager: LocationManager
    @State private var distanceToFront: Double = 0
    @State private var distanceToCenter: Double = 0
    @State private var distanceToBack: Double = 0
    @State private var score: Int
    @Environment(\.presentationMode) var presentationMode
    var onFinishRound: () -> Void
    
    var hole: Hole {
        round.holes[currentHoleIndex]
    }
    
    init(round: Binding<GolfRound>, currentHoleIndex: Binding<Int>, locationManager: LocationManager, onFinishRound: @escaping () -> Void) {
        self._round = round
        self._currentHoleIndex = currentHoleIndex
        self.locationManager = locationManager
        self._score = State(initialValue: round.wrappedValue.holes[currentHoleIndex.wrappedValue].score ?? round.wrappedValue.holes[currentHoleIndex.wrappedValue].par)
        self.onFinishRound = onFinishRound
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Hole \(hole.number)")
                .font(.title)
            
            Text("Par \(hole.par)")
                .font(.headline)
            
            VStack(alignment: .leading) {
                Text("Distance to green:")
                    .font(.headline)
                Text(String(format: "Front: %.1f yards", distanceToFront * 1.09361))
                Text(String(format: "Center: %.1f yards", distanceToCenter * 1.09361))
                Text(String(format: "Back: %.1f yards", distanceToBack * 1.09361))
            }
            .padding()
            
            Spacer()
            
            VStack {
                Text("Your Score")
                    .font(.headline)
                
                HStack {
                    Button(action: {
                        score = max(1, score - 1)
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.title)
                    }
                    
                    Text("\(score)")
                        .font(.title)
                        .frame(width: 50)
                    
                    Button(action: {
                        score += 1
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.title)
                    }
                }
            }
            .padding()
            
            Button(action: saveAndAdvance) {
                Text(currentHoleIndex == round.holes.count - 1 ? "Finish Round" : "Next Hole")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Hole \(hole.number)")
                .onAppear {
                    updateDistances()
                }
                .onReceive(locationManager.$location) { _ in
                    updateDistances()
                }
            }
    
    private func updateDistances() {
        distanceToFront = locationManager.calculateDistance(to: hole.green.front) ?? 0
        distanceToCenter = locationManager.calculateDistance(to: hole.green.center) ?? 0
        distanceToBack = locationManager.calculateDistance(to: hole.green.back) ?? 0
    }
    
    private func saveAndAdvance() {
            round.holes[currentHoleIndex].score = score
            if currentHoleIndex < round.holes.count - 1 {
                currentHoleIndex += 1
            } else {
                onFinishRound()
                presentationMode.wrappedValue.dismiss()
            }
        }
}
