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
        mapView.mapType = mapType

        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.mapType = mapType
        context.coordinator.updateMapView(uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: HoleDetailMapView
        var initialSetupDone = false

        init(_ parent: HoleDetailMapView) {
            self.parent = parent
        }

        func updateMapView(_ mapView: MKMapView) {
            let tee = parent.hole.teeBox.clLocationCoordinate2D
            let green = parent.hole.green.center.clLocationCoordinate2D

            // Remove existing annotations and overlays
            let annotationsToRemove = mapView.annotations.filter { !($0 is MKUserLocation) }
            mapView.removeAnnotations(annotationsToRemove)
            mapView.removeOverlays(mapView.overlays)

            // Add green annotation
            let greenAnnotation = MKPointAnnotation()
            greenAnnotation.coordinate = green
            greenAnnotation.title = "Green"
            mapView.addAnnotation(greenAnnotation)

            // Add layup annotation if it exists
            if let layupPosition = parent.viewModel.getLayupPosition(for: parent.hole) {
                let layupAnnotation = MKPointAnnotation()
                layupAnnotation.coordinate = layupPosition
                layupAnnotation.title = "Layup"
                mapView.addAnnotation(layupAnnotation)

                // Add distance lines and labels
                if let userLocation = mapView.userLocation.location?.coordinate {
                    addDistanceOverlaysAndAnnotations(
                        mapView, from: userLocation, via: layupPosition, to: green)
                }
            }

            // Set the initial map region only if it hasn't been set before
            if !initialSetupDone {
                setInitialMapRegion(mapView, tee: tee, green: green)
                initialSetupDone = true
            }
        }

        func setInitialMapRegion(
            _ mapView: MKMapView, tee: CLLocationCoordinate2D, green: CLLocationCoordinate2D
        ) {
            let bearing = calculateBearing(from: tee, to: green)
            let centerLatitude = tee.latitude * 0.65 + green.latitude * 0.35
            let centerLongitude = tee.longitude * 0.65 + green.longitude * 0.35
            let center = CLLocationCoordinate2D(
                latitude: centerLatitude, longitude: centerLongitude)

            let distance = CLLocation(latitude: tee.latitude, longitude: tee.longitude).distance(
                from: CLLocation(latitude: green.latitude, longitude: green.longitude))

            let camera = MKMapCamera(
                lookingAtCenter: center,
                fromDistance: distance * 3.2,
                pitch: 0,
                heading: bearing
            )
            mapView.setCamera(camera, animated: false)
        }

        func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D)
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

        func addDistanceOverlaysAndAnnotations(
            _ mapView: MKMapView, from start: CLLocationCoordinate2D,
            via middle: CLLocationCoordinate2D, to end: CLLocationCoordinate2D
        ) {
            let startToMiddleLine = MKPolyline(coordinates: [start, middle], count: 2)
            let middleToEndLine = MKPolyline(coordinates: [middle, end], count: 2)

            mapView.addOverlays([startToMiddleLine, middleToEndLine])

            let startToMiddleDistance = calculateDistance(from: start, to: middle)
            let middleToEndDistance = calculateDistance(from: middle, to: end)

            addCustomDistanceLabel(
                mapView,
                midpoint(start: start, end: middle),
                distance: startToMiddleDistance
            )
            addCustomDistanceLabel(
                mapView,
                midpoint(start: middle, end: end),
                distance: middleToEndDistance
            )
        }

        func addCustomDistanceLabel(
            _ mapView: MKMapView,
            _ coordinate: CLLocationCoordinate2D,
            distance: Int
        ) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(distance)"
            mapView.addAnnotation(annotation)
        }

        func pointBeforeCoordinate(
            start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, distance: Double
        ) -> CLLocationCoordinate2D {
            let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
            let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)

            let bearing = startLocation.bearing(to: endLocation)
            let distanceFromEnd = endLocation.distance(from: startLocation) - distance

            return endLocation.destinationPoint(bearing: bearing + 180, distance: distanceFromEnd)
        }

        func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Int {
            let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
            let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
            let distanceInMeters = fromLocation.distance(from: toLocation)
            return Int(distanceInMeters * 1.09361)  // Convert meters to yards
        }

        func midpoint(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D)
            -> CLLocationCoordinate2D
        {
            let lat = (start.latitude + end.latitude) / 2
            let lon = (start.longitude + end.longitude) / 2
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil  // Return nil to use the default blue dot
            }

            let accentColor = UIColor(named: "AccentColor") ?? .orange

            switch annotation.title ?? "" {
            case "Green":
                return createAnnotationView(
                    for: mapView, identifier: "GreenPin", image: "flag",
                    color: accentColor)
            case "Layup":
                return createAnnotationView(
                    for: mapView, identifier: "LayupPin", image: "scope", color: accentColor)
            default:
                return createDistanceLabelAnnotationView(for: mapView, annotation: annotation)
            }
        }

        func createAnnotationView(
            for mapView: MKMapView, identifier: String, image: String, color: UIColor
        ) -> MKAnnotationView {
            let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: identifier)

            let size: CGFloat = image == "scope" ? 50 : 30  // Increase size for "scope" icon
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
            let pointSize: CGFloat = image == "scope" ? 40 : 20  // Increase point size for "scope" icon
            let configuration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)

            if let sfSymbol = UIImage(systemName: image, withConfiguration: configuration) {
                let coloredImage = sfSymbol.withTintColor(color, renderingMode: .alwaysOriginal)
                imageView.image = coloredImage
            }

            annotationView.addSubview(imageView)
            annotationView.frame = imageView.frame
            annotationView.canShowCallout = true

            return annotationView
        }

        func createDistanceLabelAnnotationView(for mapView: MKMapView, annotation: MKAnnotation)
            -> MKAnnotationView
        {
            let identifier = "DistanceLabel"
            var view: MKAnnotationView

            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKAnnotationView
            {
                view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }

            let distanceLabel = UILabel()
            if let distance = annotation.title ?? nil, let distanceInt = Int(distance) {
                distanceLabel.text = "\(distanceInt) yds"
            } else {
                distanceLabel.text = "N/A"
            }
            distanceLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            distanceLabel.textAlignment = .center
            distanceLabel.textColor = .white
            distanceLabel.sizeToFit()

            let padding: CGFloat = 6
            let backgroundView = UIView(
                frame: CGRect(
                    x: 0, y: 0, width: distanceLabel.frame.width + padding * 2,
                    height: distanceLabel.frame.height + padding * 2))
            backgroundView.backgroundColor = .clear

            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = backgroundView.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurView.layer.cornerRadius = 6
            blurView.clipsToBounds = true

            backgroundView.addSubview(blurView)
            backgroundView.addSubview(distanceLabel)
            distanceLabel.center = backgroundView.center

            view.addSubview(backgroundView)
            view.frame = backgroundView.frame
            view.centerOffset = CGPoint(x: 0, y: -view.frame.size.height / 2)

            return view
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .white.withAlphaComponent(0.6)  // Make it translucent
                renderer.lineWidth = 1  // Make the line thinner

                // Simplified dash pattern
                renderer.lineDashPattern = [4, 4]  // 4 points on, 4 points off

                return renderer
            }
            return MKOverlayRenderer()
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            parent.viewModel.setLayupPosition(coordinate, for: parent.hole)
            updateMapView(mapView)
        }
    }
}

extension CLLocation {
    func bearing(to destination: CLLocation) -> Double {
        let lat1 = self.coordinate.latitude.radians
        let lon1 = self.coordinate.longitude.radians
        let lat2 = destination.coordinate.latitude.radians
        let lon2 = destination.coordinate.longitude.radians

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return (radiansBearing.degrees + 360).truncatingRemainder(dividingBy: 360)
    }

    func destinationPoint(bearing: Double, distance: Double) -> CLLocationCoordinate2D {
        let distanceRadians = distance / 6371000.0  // Earth radius in meters

        let bearingRadians = bearing.radians
        let lat1 = self.coordinate.latitude.radians
        let lon1 = self.coordinate.longitude.radians

        let lat2 = asin(
            sin(lat1) * cos(distanceRadians) + cos(lat1) * sin(distanceRadians)
                * cos(bearingRadians))
        let lon2 =
            lon1
            + atan2(
                sin(bearingRadians) * sin(distanceRadians) * cos(lat1),
                cos(distanceRadians) - sin(lat1) * sin(lat2))

        return CLLocationCoordinate2D(latitude: lat2.degrees, longitude: lon2.degrees)
    }
}

extension Double {
    var radians: Double { return self * .pi / 180 }
    var degrees: Double { return self * 180 / .pi }
}
