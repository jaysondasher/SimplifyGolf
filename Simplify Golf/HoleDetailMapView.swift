import MapKit
import SwiftUI

struct HoleDetailMapView: UIViewRepresentable {
    @ObservedObject var viewModel: RoundInProgressViewModel
    let hole: Hole
    @Binding var mapType: MKMapType

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.mapType = mapType
        updateMapView(uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func updateMapView(_ mapView: MKMapView) {
        let tee = hole.teeBox.clLocationCoordinate2D
        let green = hole.green.center.clLocationCoordinate2D

        // Remove existing annotations
        mapView.removeAnnotations(mapView.annotations)

        // Add tee and green annotations
        let teeAnnotation = MKPointAnnotation()
        teeAnnotation.coordinate = tee
        teeAnnotation.title = "Tee"

        let greenAnnotation = MKPointAnnotation()
        greenAnnotation.coordinate = green
        greenAnnotation.title = "Green"

        mapView.addAnnotations([teeAnnotation, greenAnnotation])

        // Calculate the bearing from tee to green
        let bearing = calculateBearing(from: tee, to: green)

        // Calculate the center point (weighted more towards the tee)
        let centerLatitude = tee.latitude * 0.65 + green.latitude * 0.35
        let centerLongitude = tee.longitude * 0.65 + green.longitude * 0.35
        let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)

        // Calculate the distance between tee and green
        let distance = CLLocation(latitude: tee.latitude, longitude: tee.longitude).distance(
            from: CLLocation(latitude: green.latitude, longitude: green.longitude))

        // Set the camera
        let camera = MKMapCamera(
            lookingAtCenter: center,
            fromDistance: distance * 3.2,  // Increased from 2.8 to 3.2 to zoom out more
            pitch: 0,  // Straight down view
            heading: bearing
        )
        mapView.setCamera(camera, animated: true)
    }

    private func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D)
        -> CLLocationDirection
    {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return (radiansBearing * 180 / .pi + 360).truncatingRemainder(dividingBy: 360)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: HoleDetailMapView

        init(_ parent: HoleDetailMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "HoleMarker"
            var view: MKMarkerAnnotationView

            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKMarkerAnnotationView
            {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            if annotation.title == "Tee" {
                view.markerTintColor = .blue
            } else if annotation.title == "Green" {
                view.markerTintColor = .green
            }

            return view
        }
    }
}

struct AnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: Coordinate
    let isTee: Bool
}

struct MapCompass: UIViewRepresentable {
    func makeUIView(context: Context) -> MKCompassButton {
        MKCompassButton(mapView: MKMapView())
    }

    func updateUIView(_ view: MKCompassButton, context: Context) {
        view.compassVisibility = .visible
    }
}
