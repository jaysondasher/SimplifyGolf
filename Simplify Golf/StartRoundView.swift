//
//  StartRoundView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import SwiftUI
import CoreLocation

struct StartRoundView: View {
    @State private var activeRound: GolfRound?
    @State private var showingCourseSelection = false
    @State private var showingRoundSummary = false
    @State private var currentHoleIndex = 0
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var courseManager: CourseManager
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        VStack {
            if let round = activeRound {
                Text(round.courseName)
                    .font(.title)
                    .padding()
                
                Text("Total Score: \(round.totalScore)")
                    .font(.headline)
                    .padding()
                
                List {
                    ForEach(round.holes.indices, id: \.self) { index in
                        NavigationLink(destination: HoleDetailView(
                            round: Binding(
                                get: { round },
                                set: { newValue in
                                    self.activeRound = newValue
                                }
                            ),
                            currentHoleIndex: Binding(
                                get: { self.currentHoleIndex },
                                set: { newValue in
                                    if newValue < round.holes.count {
                                        self.currentHoleIndex = newValue
                                    } else {
                                        self.finishRound()
                                    }
                                }
                            ),
                            locationManager: locationManager,
                            onFinishRound: finishRound
                        )) {
                            HoleRowView(hole: round.holes[index], currentHole: currentHoleIndex + 1)
                        }
                    }
                }
                
                Button("View Round Summary") {
                    showingRoundSummary = true
                }
                .padding()
                .sheet(isPresented: $showingRoundSummary) {
                    if let round = activeRound {
                        RoundSummaryView(round: round)
                    }
                }
                
                Button("End Round") {
                    finishRound()
                }
                .padding()
            } else {
                VStack {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        .padding()
                    
                    Text("Ready to start a new round?")
                        .font(.title2)
                        .padding()
                    
                    Button(action: {
                        showingCourseSelection = true
                    }) {
                        Text("Start New Round")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .navigationTitle("Start Round")
        .sheet(isPresented: $showingCourseSelection) {
            CourseSelectionView(activeRound: $activeRound)
        }
    }
    
    private func binding(for index: Int) -> Binding<Hole> {
        return Binding(
            get: { self.activeRound!.holes[index] },
            set: { self.activeRound!.holes[index] = $0 }
        )
    }
    
    private func finishRound() {
        if let round = activeRound {
            dataController.saveRound(round)
            showingRoundSummary = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.activeRound = nil
                self.currentHoleIndex = 0
            }
        }
    }
}
    
    struct HoleRowView: View {
        let hole: Hole
        let currentHole: Int
        
        var body: some View {
            HStack {
                Text("Hole \(hole.number)")
                Spacer()
                Text("Par \(hole.par)")
                Spacer()
                if let score = hole.score {
                    Text("Score: \(score)")
                } else {
                    Text("Not played")
                }
                if hole.number == currentHole {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                }
            }
        }
    }
