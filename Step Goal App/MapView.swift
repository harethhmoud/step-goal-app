//
//  MapView.swift
//  Step Goal App
//
//  Created by Hareth Hmoud on 2025-04-12.
//

import Foundation
import SwiftUI
import MapKit // For map views and coordinates
import CoreLocation // For user location

struct MapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D? // Center of the map (user location)
    @Binding var radius: Double
    var mapRegionSpanDegrees: Double = 0.02 // Controls initial zoom level

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true // Show the blue dot for the user
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Clear previous overlays
        uiView.removeOverlays(uiView.overlays)

        if let coordinate = centerCoordinate, radius > 0 {
            // Create the circle overlay
            let circle = MKCircle(center: coordinate, radius: radius)
            uiView.addOverlay(circle)

            // Set the map region to show the user and the circle
            let regionRadius = radius * 1.5 // Show slightly more than the circle radius
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: regionRadius * 2,
                longitudinalMeters: regionRadius * 2
            )
             // Only set region if it's significantly different to avoid jitter
            if uiView.region.center.latitude != region.center.latitude || uiView.region.center.longitude != region.center.longitude || abs(uiView.region.span.latitudeDelta - region.span.latitudeDelta) > 0.001 {
                uiView.setRegion(region, animated: true)
            }

        } else if let coordinate = centerCoordinate, uiView.overlays.isEmpty {
            // If we have a location but no radius yet, just center on the user
             let initialRegion = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: mapRegionSpanDegrees, longitudeDelta: mapRegionSpanDegrees)
            )
             uiView.setRegion(initialRegion, animated: true)
        }
        // If no coordinate yet, the map might show a default location or remain blank until location is available
    }


    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator (Handles MapView Delegate methods)
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        // --- MKMapViewDelegate Methods ---

        // Style the circle overlay
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circleOverlay)
                renderer.fillColor = UIColor.blue.withAlphaComponent(0.2) // Semi-transparent blue fill
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 1
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay) // Default renderer for other overlays (like user location dot)
        }
    }
}
