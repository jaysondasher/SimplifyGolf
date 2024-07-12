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
        ZStack {
            GolfAppBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    if let round = activeRound {
                        Text(round.courseName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Total Score: \(round.totalScore)")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
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
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Button("View Round Summary") {
                            showingRoundSummary = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Button("End Round") {
                            finishRound()
                        }
                        .buttonStyle(SecondaryButtonStyle())
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
                .padding()
            }
        }
        .navigationTitle("Start Round")
        .sheet(isPresented: $showingCourseSelection) {
            CourseSelectionView(activeRound: $activeRound)
        }
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
            .background(ThemeColors.primary)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(ThemeColors.secondary)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}


struct ModernBackground: View {
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9411764706, green: 0.9725490196, blue: 0.9803921569, alpha: 1)), Color(#colorLiteral(red: 0.8392156863, green: 0.8980392157, blue: 0.9215686275, alpha: 1))]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            
            // Subtle pattern overlay
            GeometryReader { geometry in
                Path { path in
                    for index in stride(from: 0, to: geometry.size.width, by: 20) {
                        path.move(to: CGPoint(x: index, y: 0))
                        path.addLine(to: CGPoint(x: index, y: geometry.size.height))
                    }
                    for index in stride(from: 0, to: geometry.size.height, by: 20) {
                        path.move(to: CGPoint(x: 0, y: index))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: index))
                    }
                }
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            }
        }
        .ignoresSafeArea()
    }
}
