//
//  HoleDetailView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import SwiftUI
import CoreLocation

struct HoleDetailView: View {
    @Binding var hole: Hole
    @ObservedObject var locationManager: LocationManager
    @State private var distanceToFront: Double = 0
    @State private var distanceToCenter: Double = 0
    @State private var distanceToBack: Double = 0
    
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
            
            HStack {
                Button("-") {
                    if let score = hole.score, score > 1 {
                        hole.score = score - 1
                    } else {
                        hole.score = 1
                    }
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Text("\(hole.score ?? hole.par)")
                    .font(.title)
                    .frame(width: 50)
                
                Button("+") {
                    if let score = hole.score {
                        hole.score = score + 1
                    } else {
                        hole.score = hole.par + 1
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
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
                print("Updating distances for Hole \(hole.number)")
                print("Current location: \(locationManager.location?.coordinate ?? CLLocationCoordinate2D())")
                
                print("Front coordinates: \(hole.green.front)")
                print("Center coordinates: \(hole.green.center)")
                print("Back coordinates: \(hole.green.back)")
                
                if let frontDistance = locationManager.calculateDistance(to: hole.green.front) {
                    distanceToFront = frontDistance
                    print("Distance to front: \(distanceToFront) meters")
                }
                
                if let centerDistance = locationManager.calculateDistance(to: hole.green.center) {
                    distanceToCenter = centerDistance
                    print("Distance to center: \(distanceToCenter) meters")
                }
                
                if let backDistance = locationManager.calculateDistance(to: hole.green.back) {
                    distanceToBack = backDistance
                    print("Distance to back: \(distanceToBack) meters")
                }
            }
        }
