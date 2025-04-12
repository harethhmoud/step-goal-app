import Foundation
import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastKnownLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var locationError: Error?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        } else {
            requestAuthorization()
        }
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate Methods

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("Authorization status changed: \(String(describing: authorizationStatus))")
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            lastKnownLocation = location
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
        locationError = error
    }
}
