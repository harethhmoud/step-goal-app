//
//  LocationManager.swift
//  Step Goal App
//
//  Created by Hareth Hmoud on 2025-04-12.
// Focuses on managing location logic

import Foundation
import SwiftUI
import MapKit // For map views and coordinates
import CoreLocation // For user location

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager() // class to access location services
    @Published var lastKnownLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var locationError: Error? = nil

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization() // brings up the request location auth popup
    }

    func startUpdatingLocation() {
         // Only start if authorized
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        } else {
            requestAuthorization() // Ask again if not authorized yet
        }
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    // --- CLLocationManagerDelegate Methods ---

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            // Start updating location immediately if authorized
            manager.startUpdatingLocation()
        } //else if authorizationStatus == .denied || authorizationStatus == .restricted {
            // No else if needed here - ContentView will react to the status change
            //print("Location access denied or restricted.")
        //}
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lastKnownLocation = location
        } // Get the most recent location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
        // Handle error appropriately (e.g., show alert)
    }
}
