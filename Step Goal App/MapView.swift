import Foundation
import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D?
    @Binding var radius: Double
    var mapRegionSpanDegrees: Double = 0.02

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true // Keep the blue dot for reference
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Clear previous overlays and annotations
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)

        if let coordinate = centerCoordinate {
            // Add a pin (annotation) at the user's location
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "You Are Here"
            uiView.addAnnotation(annotation)

            // Add the radius circle if radius > 0
            if radius > 0 {
                let circle = MKCircle(center: coordinate, radius: radius)
                uiView.addOverlay(circle)

                // Set the map region to show the user and the circle
                let regionRadius = radius * 1.5
                let region = MKCoordinateRegion(
                    center: coordinate,
                    latitudinalMeters: regionRadius * 2,
                    longitudinalMeters: regionRadius * 2
                )
                if uiView.region.center.latitude != region.center.latitude || uiView.region.center.longitude != region.center.longitude || abs(uiView.region.span.latitudeDelta - region.span.latitudeDelta) > 0.001 {
                    uiView.setRegion(region, animated: true)
                }
            } else {
                // If no radius, just center on the user
                let initialRegion = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: mapRegionSpanDegrees, longitudeDelta: mapRegionSpanDegrees)
                )
                uiView.setRegion(initialRegion, animated: true)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        // Style the circle overlay
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circleOverlay)
                renderer.fillColor = UIColor.blue.withAlphaComponent(0.2)
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 1
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        // Optional: Customize the annotation view (pin)
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Don't customize the user location dot (blue dot)
            if annotation is MKUserLocation {
                return nil
            }

            let identifier = "UserLocationPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true // Show the "You Are Here" title in a callout
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
        }
    }
}
