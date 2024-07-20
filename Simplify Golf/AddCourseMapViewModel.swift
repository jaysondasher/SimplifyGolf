//
//  AddCourseMapViewModel.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/20/24.
//

import Foundation
import MapKit
import Firebase
import SwiftUI

class AddCourseMapViewModel: ObservableObject {
    @Published var centerCoordinate: CLLocationCoordinate2D
    @Published var annotations: [MKPointAnnotation] = []
    @Published var currentHole = 1
    @Published var currentMarker: HoleMarker = .teeBox
    @Published var parSelection: ParSelection?
    @Published var zoomLevel: Double = 0.02
    
    private var holes: [Hole] = []
    private var currentHoleMarkers: [HoleMarker: CLLocationCoordinate2D] = [:]
    private let courseName: String
    private let courseRating: Double
    private let slopeRating: Int
    
    enum HoleMarker: CaseIterable {
        case teeBox, frontGreen, backGreen
        
        var description: String {
            switch self {
            case .teeBox: return "Tee Box"
            case .frontGreen: return "Front of Green"
            case .backGreen: return "Back of Green"
            }
        }
    }
    
    struct ParSelection: Identifiable {
        let id = UUID()
        let holeNumber: Int
    }
    
    init(initialCoordinate: CLLocationCoordinate2D, courseName: String, courseRating: Double, slopeRating: Int) {
        self.centerCoordinate = initialCoordinate
        self.courseName = courseName
        self.courseRating = courseRating
        self.slopeRating = slopeRating
    }
    
    var canGoBack: Bool {
        !(currentHole == 1 && currentMarker == .teeBox)
    }
    
    var canGoNext: Bool {
        currentMarker == .backGreen
    }
    
    var canFinish: Bool {
        currentHole == 18 && currentMarker == .backGreen
    }
    
    func markLocation() {
        currentHoleMarkers[currentMarker] = centerCoordinate
        
        if currentMarker == .backGreen {
            parSelection = ParSelection(holeNumber: currentHole)
        } else {
            goToNextMarker()
        }
    }
    
    func goToNextMarker() {
        if currentMarker == .backGreen {
            currentHole += 1
            currentMarker = .teeBox
            currentHoleMarkers = [:]
        } else {
            currentMarker = HoleMarker.allCases[HoleMarker.allCases.firstIndex(of: currentMarker)! + 1]
        }
    }
    
    func goBack() {
        if currentMarker == .teeBox && currentHole > 1 {
            currentHole -= 1
            currentMarker = .backGreen
        } else if currentMarker != .teeBox {
            currentMarker = HoleMarker.allCases[HoleMarker.allCases.firstIndex(of: currentMarker)! - 1]
        }
    }
    
    func setPar(_ par: Int) {
        guard let teeBox = currentHoleMarkers[.teeBox],
              let frontGreen = currentHoleMarkers[.frontGreen],
              let backGreen = currentHoleMarkers[.backGreen] else {
            return
        }
        
        let hole = Hole(number: currentHole,
                        par: par,
                        yardage: calculateYardage(from: teeBox, to: frontGreen),
                        teeBox: Coordinate(latitude: teeBox.latitude, longitude: teeBox.longitude),
                        green: Hole.Green(front: Coordinate(latitude: frontGreen.latitude, longitude: frontGreen.longitude),
                                          center: calculateCenterGreen(front: frontGreen, back: backGreen),
                                          back: Coordinate(latitude: backGreen.latitude, longitude: backGreen.longitude)))
        
        holes.append(hole)
        
        if currentHole < 18 {
            currentHole += 1
            currentMarker = .teeBox
            currentHoleMarkers = [:]
        } else {
            finishCourse()
        }
        
        parSelection = nil
    }
    
    func cancelParSelection() {
        // Handle cancel action if necessary
        parSelection = nil
    }
    
    func finishCourse() {
        let newCourse = Course(id: UUID().uuidString,
                               name: courseName,
                               location: "",
                               holes: holes,
                               courseRating: courseRating,
                               slopeRating: slopeRating,
                               creatorId: Auth.auth().currentUser?.uid ?? "")
        
        let db = Firestore.firestore()
        do {
            try db.collection("courses").document(newCourse.id).setData(from: newCourse)
            // Navigate back to the course management screen
            if let window = UIApplication.shared.windows.first {
                window.rootViewController?.dismiss(animated: true, completion: nil)
            }
        } catch {
            print("Error saving course: \(error.localizedDescription)")
        }
    }
    
    private func calculateYardage(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Int {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        let distanceInMeters = fromLocation.distance(from: toLocation)
        return Int(distanceInMeters * 1.09361)
    }
    
    private func calculateCenterGreen(front: CLLocationCoordinate2D, back: CLLocationCoordinate2D) -> Coordinate {
        let centerLatitude = (front.latitude + back.latitude) / 2
        let centerLongitude = (front.longitude + back.longitude) / 2
        return Coordinate(latitude: centerLatitude, longitude: centerLongitude)
    }
}

struct MapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var annotations: [MKPointAnnotation]
    @Binding var zoomLevel: Double
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didDrag(_:)))
        panGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didPinch(_:)))
        pinchGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(pinchGesture)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(MKCoordinateRegion(center: centerCoordinate, span: MKCoordinateSpan(latitudeDelta: zoomLevel, longitudeDelta: zoomLevel)), animated: true)
        
        if annotations.count != view.annotations.count {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        @objc func didDrag(_ gesture: UIPanGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            
            if gesture.state == .ended {
                parent.centerCoordinate = mapView.centerCoordinate
            }
        }
        
        @objc func didPinch(_ gesture: UIPinchGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            
            if gesture.state == .ended {
                let span = mapView.region.span
                parent.zoomLevel = max(span.latitudeDelta, span.longitudeDelta)
            }
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
}

