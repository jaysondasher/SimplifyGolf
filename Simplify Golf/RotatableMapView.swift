//
//  RotatableMapView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 10/5/24.
//

import MapKit
import SwiftUI

struct RotatableMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var heading: CLLocationDirection

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        mapView.mapType = .standard  // Set to standard
        mapView.showsUserLocation = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = false  // Optional: Disable pitch for a flat map
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update region if it has changed
        if uiView.region.center.latitude != region.center.latitude
            || uiView.region.center.longitude != region.center.longitude
            || uiView.region.span.latitudeDelta != region.span.latitudeDelta
            || uiView.region.span.longitudeDelta != region.span.longitudeDelta
        {
            uiView.setRegion(region, animated: true)
        }

        // Update camera heading if it has changed
        if uiView.camera.heading != heading {
            let camera = MKMapCamera(
                lookingAtCenter: region.center, fromDistance: 500, pitch: 0, heading: heading)
            uiView.setCamera(camera, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RotatableMapView

        init(_ parent: RotatableMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
        }
    }
}
