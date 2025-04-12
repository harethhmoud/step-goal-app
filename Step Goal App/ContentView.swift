import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var stepGoalString: String = ""
    @State private var mapCenter: CLLocationCoordinate2D?
    @State private var circleRadius: Double = 0
    @State private var showLocationError: Bool = false // New state for location error alert

    private let averageMetersPerStep: Double = 0.75

    var body: some View {
        VStack(spacing: 0) {
            // Input Section
            HStack {
                Text("Total Steps Goal:")
                    .padding(.leading)
                TextField("e.g., 5000", text: $stepGoalString)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button("Show Radius") {
                    calculateAndShowRadius()
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .padding(.trailing)
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical)

            // Map Section
            MapView(centerCoordinate: $mapCenter, radius: $circleRadius)
                .ignoresSafeArea(.container, edges: .bottom)
        }
        .onAppear {
            locationManager.requestAuthorization()
            locationManager.startUpdatingLocation()
            // Set a default location for testing if none exists
            if locationManager.lastKnownLocation == nil {
                let defaultLocation = CLLocation(latitude: 45.499895, longitude: -73.575582) // 1200 Maisonneuve
                locationManager.lastKnownLocation = defaultLocation
                mapCenter = defaultLocation.coordinate
            }
        }
        .onChange(of: locationManager.lastKnownLocation) { newValue in
            if let location = newValue, mapCenter == nil || circleRadius == 0 {
                mapCenter = location.coordinate
            }
        }
        .alert("Error", isPresented: .constant(locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted)) {
            Button("OK") {}
        } message: {
            Text("Location access is required to center the map and calculate the radius. Please enable location services for this app in Settings.")
        }
        .alert("Location Error", isPresented: $showLocationError) {
            Button("OK") {}
        } message: {
            Text("Unable to get your current location. Please ensure location services are enabled.")
        }
    }

    func calculateAndShowRadius() {
        guard let totalSteps = Int(stepGoalString), totalSteps > 0 else {
            print("Invalid step input")
            circleRadius = 0
            return
        }

        guard let currentLocation = locationManager.lastKnownLocation else {
            showLocationError = true // Show alert if location is nil
            return
        }

        let oneWaySteps = Double(totalSteps) / 2.0
        let calculatedRadius = oneWaySteps * averageMetersPerStep

        self.circleRadius = calculatedRadius
        self.mapCenter = currentLocation.coordinate
    }
}

#Preview {
    ContentView()
}
