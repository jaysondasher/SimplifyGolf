//
//  AddHolesView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/12/24.
//

import SwiftUI
import MapKit

struct AddHolesView: View {
    @State var course: Course
    @State private var currentHole = 1
    @State private var totalHoles = 18
    @State private var currentPar = 4
    @State private var currentStep: AddStep = .par
    @State private var holeDetails: [HoleDetail] = []
    @State private var region: MKCoordinateRegion
    @State private var showingConfirmation = false
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var mapType: MKMapType = .standard
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var courseManager: CourseManager
    
    init(course: Course, initialCoordinate: CLLocationCoordinate2D) {
        _course = State(initialValue: course)
        _region = State(initialValue: MKCoordinateRegion(
            center: initialCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if currentStep == .par {
                ParSelectionView(currentHole: currentHole, currentPar: $currentPar)
            } else {
                ZStack {
                    MapView(region: $region, selectedCoordinate: $selectedCoordinate, mapType: mapType)
                        .frame(height: UIScreen.main.bounds.height * 0.6)
                        .overlay(
                            VStack {
                                Spacer()
                                Text("Drag map to place \(currentStep.rawValue)")
                                    .font(.headline)
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.bottom)
                        )
                        .overlay(
                            Image(systemName: "scope")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                        )
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: toggleMapType) {
                                Image(systemName: mapType == .standard ? "map" : "globe")
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .padding()
                        }
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                }
            }
            
            VStack(spacing: 10) {
                Text("Hole \(currentHole) of \(totalHoles)")
                    .font(.headline)
                Text("Current step: \(currentStep.rawValue)")
                    .font(.subheadline)
                
                Button(action: moveToNextStep) {
                    Text(currentStep == .par ? "Set Par" : "Next")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitle("Add Hole Details", displayMode: .inline)
        .navigationBarItems(trailing: Button("Finish") {
            showingConfirmation = true
        })
        .alert(isPresented: $showingConfirmation) {
            Alert(
                title: Text("Finish Adding Course?"),
                message: Text("Are you sure you want to finish adding the course?"),
                primaryButton: .default(Text("Yes")) {
                    saveCourse()
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func toggleMapType() {
        mapType = mapType == .standard ? .satellite : .standard
    }
    
    private func moveToNextStep() {
        if currentStep == .par {
            let newDetail = HoleDetail(holeNumber: currentHole, step: .par, coordinate: CLLocationCoordinate2D(), par: currentPar)
            holeDetails.append(newDetail)
            currentStep = .teeBox
        } else if let selectedCoordinate = selectedCoordinate {
            let newDetail = HoleDetail(holeNumber: currentHole, step: currentStep, coordinate: selectedCoordinate)
            holeDetails.append(newDetail)
            
            if currentStep == .backGreen {
                if currentHole < totalHoles {
                    currentHole += 1
                    currentStep = .par
                    currentPar = 4
                    // Keep the current region when moving to the next hole
                } else {
                    showingConfirmation = true
                }
            } else {
                currentStep = currentStep.next()
            }
        }
    }
    
    private func saveCourse() {
        let holes = (1...totalHoles).map { holeNumber -> CourseHole in
            let holeDetails = self.holeDetails.filter { $0.holeNumber == holeNumber }
            let par = holeDetails.first { $0.step == .par }?.par ?? 4
            let teeBox = holeDetails.first { $0.step == .teeBox }?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
            let frontGreen = holeDetails.first { $0.step == .frontGreen }?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
            let backGreen = holeDetails.first { $0.step == .backGreen }?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
            
            let centerGreen = CLLocationCoordinate2D(
                latitude: (frontGreen.latitude + backGreen.latitude) / 2,
                longitude: (frontGreen.longitude + backGreen.longitude) / 2
            )
            
            let yardage = Int(teeBox.distance(to: centerGreen) * 1.09361) // Convert meters to yards
            
            return CourseHole(
                id: holeNumber,
                number: holeNumber,
                par: par,
                yardage: yardage,
                teeBox: Coordinate(latitude: teeBox.latitude, longitude: teeBox.longitude),
                green: CourseHole.Green(
                    front: Coordinate(latitude: frontGreen.latitude, longitude: frontGreen.longitude),
                    center: Coordinate(latitude: centerGreen.latitude, longitude: centerGreen.longitude),
                    back: Coordinate(latitude: backGreen.latitude, longitude: backGreen.longitude)
                )
            )
        }
        
        course.holes = holes
        courseManager.addCourse(course)
    }
}

struct ParSelectionView: View {
    let currentHole: Int
    @Binding var currentPar: Int
    
    var body: some View {
        VStack {
            Text("Enter Par for Hole \(currentHole)")
                .font(.headline)
            Picker("Par", selection: $currentPar) {
                ForEach(3...5, id: \.self) { par in
                    Text("\(par)").tag(par)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
    }
}

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    let mapType: MKMapType
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        mapView.mapType = mapType
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: false)
        uiView.mapType = mapType
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.parent.region = mapView.region
                self.parent.selectedCoordinate = mapView.centerCoordinate
            }
        }
    }
}

enum AddStep: String, CaseIterable {
    case par = "Enter Par"
    case teeBox = "Place Tee Box"
    case frontGreen = "Place Front of Green"
    case backGreen = "Place Back of Green"
    
    func next() -> AddStep {
        switch self {
        case .par: return .teeBox
        case .teeBox: return .frontGreen
        case .frontGreen: return .backGreen
        case .backGreen: return .par
        }
    }
}

struct HoleDetail: Identifiable {
    let id = UUID()
    let holeNumber: Int
    let step: AddStep
    let coordinate: CLLocationCoordinate2D
    var par: Int?
}

extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> CLLocationDistance {
        let thisLoc = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let otherLoc = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return thisLoc.distance(from: otherLoc)
    }
}
