import MapKit
import SwiftUI

struct HoleDetailMapView: UIViewRepresentable {
    @ObservedObject var viewModel: RoundInProgressViewModel
    let hole: Hole
    @Binding var mapType: MKMapType
    @Binding var layupPosition: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true

        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

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

        // Add custom annotations
        let greenAnnotation = GreenAnnotation(coordinate: green)
        mapView.addAnnotation(greenAnnotation)

        if let layupPosition = layupPosition {
            let layupAnnotation = LayupAnnotation(coordinate: layupPosition)
            mapView.removeAnnotations(mapView.annotations.filter { $0 is LayupAnnotation })
            mapView.addAnnotation(layupAnnotation)
        } else {
            // Initialize layup position at the center of the green
            layupPosition = green
        }

        // Add overlay for lines and distance labels
        mapView.removeOverlays(mapView.overlays)
        if let userLocation = mapView.userLocation.location?.coordinate,
            let layupPosition = layupPosition
        {
            let userToLayupLine = shortenedPolyline(
                from: userLocation, to: layupPosition, shortenEnd: true)
            let layupToGreenLine = shortenedPolyline(
                from: layupPosition, to: green, shortenStart: true)

            mapView.addOverlays([userToLayupLine, layupToGreenLine])

            // Add distance labels
            let userToLayupDistance = calculateDistance(from: userLocation, to: layupPosition)
            let layupToGreenDistance = calculateDistance(from: layupPosition, to: green)

            let userToLayupMidpoint = midpoint(start: userLocation, end: layupPosition)
            let layupToGreenMidpoint = midpoint(start: layupPosition, end: green)

            let userToLayupLabel = DistanceAnnotation(
                coordinate: userToLayupMidpoint, distance: userToLayupDistance)
            let layupToGreenLabel = DistanceAnnotation(
                coordinate: layupToGreenMidpoint, distance: layupToGreenDistance)

            mapView.addAnnotations([userToLayupLabel, layupToGreenLabel])
        }

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

    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Int
    {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        let distanceInMeters = fromLocation.distance(from: toLocation)
        return Int(distanceInMeters * 1.09361)  // Convert meters to yards
    }

    private func midpoint(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D)
        -> CLLocationCoordinate2D
    {
        let lat = (start.latitude + end.latitude) / 2
        let lon = (start.longitude + end.longitude) / 2
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
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

    private func shortenedPolyline(
        from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D,
        shortenStart: Bool = false, shortenEnd: Bool = false
    ) -> MKPolyline {
        let startPoint = MKMapPoint(start)
        let endPoint = MKMapPoint(end)

        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let distance = sqrt(dx * dx + dy * dy)

        let shortenDistance = 15.0  // Adjust this value to change how much the line is shortened
        let shortenFraction = shortenDistance / distance

        var adjustedStart = start
        var adjustedEnd = end

        if shortenStart {
            adjustedStart = CLLocationCoordinate2D(
                latitude: start.latitude + (end.latitude - start.latitude) * shortenFraction,
                longitude: start.longitude + (end.longitude - start.longitude) * shortenFraction
            )
        }

        if shortenEnd {
            adjustedEnd = CLLocationCoordinate2D(
                latitude: end.latitude - (end.latitude - start.latitude) * shortenFraction,
                longitude: end.longitude - (end.longitude - start.longitude) * shortenFraction
            )
        }

        return MKPolyline(coordinates: [adjustedStart, adjustedEnd], count: 2)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: HoleDetailMapView

        init(_ parent: HoleDetailMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            switch annotation {
            case is GreenAnnotation:
                let identifier = "GreenMarker"
                var view: MKAnnotationView
                if let dequeuedView = mapView.dequeueReusableAnnotationView(
                    withIdentifier: identifier)
                {
                    view = dequeuedView
                } else {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                }
                let imageView = UIHostingController(
                    rootView:
                        Image(systemName: "smallcircle.filled.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.accentColor)
                ).view!
                imageView.backgroundColor = .clear
                view.addSubview(imageView)
                view.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                imageView.frame = view.bounds
                view.centerOffset = .zero
                return view
            case is LayupAnnotation:
                let identifier = "LayupMarker"
                var view: MKAnnotationView
                if let dequeuedView = mapView.dequeueReusableAnnotationView(
                    withIdentifier: identifier)
                {
                    view = dequeuedView
                } else {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                }

                let imageView = UIHostingController(
                    rootView:
                        Image(systemName: "scope")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.accentColor)
                ).view!

                imageView.backgroundColor = .clear
                imageView.isUserInteractionEnabled = false  // ✅ Disable interaction on imageView

                view.addSubview(imageView)
                view.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                imageView.frame = view.bounds
                view.centerOffset = .zero
                view.isDraggable = true  // ✅ Enable dragging
                view.canShowCallout = false  // ✅ Disable callouts to prevent interference

                return view
            case is DistanceAnnotation:
                let identifier = "DistanceLabel"
                var view: MKAnnotationView
                if let dequeuedView = mapView.dequeueReusableAnnotationView(
                    withIdentifier: identifier)
                {
                    view = dequeuedView
                } else {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                }
                if let distanceAnnotation = annotation as? DistanceAnnotation {
                    let label = UIHostingController(
                        rootView:
                            Text("\(distanceAnnotation.distance) yds")
                            .padding(4)
                            .background(.ultraThinMaterial)
                            .cornerRadius(4)
                            .foregroundColor(.white)
                    ).view!
                    label.backgroundColor = .clear
                    view.addSubview(label)
                    label.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
                    view.frame = label.frame
                }
                view.centerOffset = CGPoint(x: 0, y: -15)
                return view
            default:
                return nil
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .white
                renderer.lineWidth = 2
                renderer.lineDashPattern = [NSNumber(value: 3), NSNumber(value: 6)]  // 6 points on, 3 points off

                if polyline.pointCount == 2 {
                    let point1 = polyline.points()[0]
                    let point2 = polyline.points()[1]

                    if point1.coordinate.latitude == parent.layupPosition?.latitude
                        && point1.coordinate.longitude == parent.layupPosition?.longitude
                    {
                        // This is the line from layup to green
                        renderer.lineDashPhase = 9  // Start with a gap
                    } else if point2.coordinate.latitude == parent.layupPosition?.latitude
                        && point2.coordinate.longitude == parent.layupPosition?.longitude
                    {
                        // This is the line from user to layup
                        renderer.lineDashPhase = 0  // Start with a dash
                    }
                }

                return renderer
            }
            return MKOverlayRenderer()
        }

        func mapView(
            _ mapView: MKMapView, annotationView view: MKAnnotationView,
            didChange newState: MKAnnotationView.DragState,
            fromOldState oldState: MKAnnotationView.DragState
        ) {
            guard let layupAnnotation = view.annotation as? LayupAnnotation else { return }

            switch newState {
            case .starting:
                view.dragState = .dragging  // 🔄 Update drag state to dragging
            case .dragging:
                break  // 🔄 Continue dragging
            case .ending, .canceling:
                parent.layupPosition = layupAnnotation.coordinate
                view.dragState = .none  // 🔄 Reset drag state
                parent.updateMapView(mapView)
            default:
                view.dragState = .none  // 🔄 Ensure drag state is reset
            }
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            parent.layupPosition = coordinate
            parent.updateMapView(mapView)
        }
    }
}

class GreenAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class LayupAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

class DistanceAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let distance: Int
    let title: String?

    init(coordinate: CLLocationCoordinate2D, distance: Int) {
        self.coordinate = coordinate
        self.distance = distance
        self.title = "\(distance) yds"
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

extension UILabel {
    var padding: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        set {
            layoutMargins = newValue
        }
    }
}

class CustomGradientPolylineRenderer: MKOverlayPathRenderer {
    var startColor: UIColor = .white
    var endColor: UIColor = .white
    var gradientLength: CGFloat = 1.0

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let cgPath = self.path else { return }

        let baseWidth = self.lineWidth / zoomScale
        context.setLineWidth(baseWidth)
        context.setLineCap(.round)

        context.addPath(cgPath)

        context.replacePathWithStrokedPath()
        context.clip()

        let boundingBox = cgPath.boundingBox
        let gradientStart = boundingBox.origin
        let gradientEnd = CGPoint(x: boundingBox.maxX, y: boundingBox.maxY)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(
            colorsSpace: colorSpace, colors: [startColor.cgColor, endColor.cgColor] as CFArray,
            locations: [0, gradientLength])!

        context.drawLinearGradient(gradient, start: gradientStart, end: gradientEnd, options: [])
    }
}
