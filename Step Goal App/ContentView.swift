//
//  ContentView.swift
//  Step Goal App
//
//  Created by Hareth Hmoud on 2025-04-12.
//

// In ContentView.swift

import SwiftUI
import MapKit
import UIKit // Needed for UIApplication.openSettingsURLString

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var stepGoalString: String = ""
    @State private var mapCenter: CLLocationCoordinate2D? = nil
    @State private var circleRadius: Double = 0
    @FocusState private var isInputFocused: Bool // For keyboard dismissal

    // State variable to control the presentation of the denial alert
    @State private var showingLocationDeniedAlert = false

    let averageMetersPerStep: Double = 0.75

    var body: some View {
        VStack(spacing: 0) {
            // --- Input Section ---
            HStack {
                Text("Total Steps Goal:")
                    .padding(.leading)
                TextField("e.g., 5000", text: $stepGoalString)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .focused($isInputFocused) // Bind focus state

                Button("Show Radius") {
                    isInputFocused = false // Dismiss keyboard

                     //Clear any previous error state
                    locationManager.clearError()

                    // REMOVED: locationManager.startUpdatingLocation()
                    // No longer needed here, as updates should be running continuously.

                    // Proceed directly to calculation using the latest known location
                    calculateAndShowRadius()
                }
                
                .padding(.trailing)
                .buttonStyle(.borderedProminent)
                .disabled(locationManager.lastKnownLocation == nil) // Disable if no location
            }
            .padding(.vertical)

            // --- Map Section ---
            MapView(centerCoordinate: $mapCenter, radius: $circleRadius)
                .ignoresSafeArea(.container, edges: .bottom)

        } // End VStack
        .onAppear {
            // Request authorization when the view first appears if status is undetermined
            if locationManager.authorizationStatus == nil || locationManager.authorizationStatus == .notDetermined {
                 locationManager.requestAuthorization()
            }
            // Attempt to start updating location (will only work if authorized)
             locationManager.startUpdatingLocation()
        }
        .onChange(of: locationManager.lastKnownLocation) { newLocation in
            // Update map center when location first becomes available or if radius is 0
            if let location = newLocation, mapCenter == nil || circleRadius == 0 {
                 mapCenter = location.coordinate
            }
        }
        // --- Add onChange to monitor authorization status ---
        .onChange(of: locationManager.authorizationStatus) { newStatus in
            if newStatus == .denied || newStatus == .restricted {
                // If status becomes denied or restricted, set state to show the alert
                showingLocationDeniedAlert = true
                // Optionally clear radius/center if location is denied
                // circleRadius = 0
                // mapCenter = nil // Or keep last known? Depends on desired UX
            } else if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                 // If status becomes authorized, ensure we try starting updates again
                locationManager.startUpdatingLocation()
            }
        }
        // --- Add the alert modifier ---
        .alert("Location Access Required", isPresented: $showingLocationDeniedAlert) {
            // Button to simply dismiss the alert
            Button("OK") { }

            // Button to deep-link the user to the app's settings
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        } message: {
            // Message explaining why location is needed and how to enable it
            Text("This app needs location access to center the map and calculate your walking radius. Please enable location services for this app in the Settings app.")
        }

    } // End body

    func calculateAndShowRadius() {
        guard let totalSteps = Int(stepGoalString), totalSteps > 0 else {
            print("Invalid step input")
            circleRadius = 0
            return
        }

        // Ensure we have location before calculating
        guard let currentLocation = locationManager.lastKnownLocation else {
            print("Current location not available for calculation.")
            // Optionally show a different alert if location isn't available yet
            return
        }

        let oneWaySteps = Double(totalSteps) / 2.0
        let calculatedRadius = oneWaySteps * averageMetersPerStep

        self.circleRadius = calculatedRadius
        self.mapCenter = currentLocation.coordinate
    }

} // End ContentView

// MARK: - Preview
#Preview {
    ContentView()
}
