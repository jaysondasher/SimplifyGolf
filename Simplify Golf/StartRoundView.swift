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
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var courseManager: CourseManager
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        ZStack {
            GolfAppBackground()
            
            if let round = activeRound {
                RoundInProgressView(
                    activeRound: $activeRound,
                    locationManager: locationManager,
                    dataController: dataController
                )
            } else {
                VStack(spacing: 30) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Ready to start a new round?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        showingCourseSelection = true
                    }) {
                        Text("Start New Round")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .navigationTitle("Start Round")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCourseSelection) {
            CourseSelectionView(activeRound: $activeRound)
        }
        .sheet(isPresented: $showingRoundSummary) {
            if let round = activeRound {
                RoundSummaryView(round: round)
            }
        }
    }
}
