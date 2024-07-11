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
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var courseManager: CourseManager
    
    var body: some View {
        VStack {
            if let round = activeRound {
                RoundInProgressView(round: $activeRound, locationManager: locationManager)
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
}

struct RoundInProgressView: View {
    @Binding var round: GolfRound?
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack {
            Text(round?.courseName ?? "")
                .font(.title)
                .padding()
            
            Text("Total Score: \(round?.totalScore ?? 0)")
                .font(.headline)
                .padding()
            
            List {
                ForEach(round?.holes ?? [], id: \.id) { hole in
                    NavigationLink(destination: HoleDetailView(hole: binding(for: hole), locationManager: locationManager)) {
                        HoleRowView(hole: hole, currentHole: round?.holes.firstIndex(where: { $0.id == hole.id }) ?? 0 + 1)
                    }
                }
            }
            
            Button(action: {
                // End round logic here
                round = nil
            }) {
                Text("End Round")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
    
    private func binding(for hole: Hole) -> Binding<Hole> {
        Binding<Hole>(
            get: { hole },
            set: { newValue in
                if let index = round?.holes.firstIndex(where: { $0.id == hole.id }) {
                    round?.holes[index] = newValue
                }
            }
        )
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
