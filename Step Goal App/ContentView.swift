import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var stepGoalString: String = ""
    @State private var mapCenter: CLLocationCoordinate2D?
    @State private var circleRadius: Double = 0
    @State private var showLocationError: Bool = false

    private let averageMetersPerStep: Double = 0.75

    var body: some View {
        ZStack {
            // Background color for the entire view
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Input Section (Card-like design)
                VStack(spacing: 16) {
                    Text("Set Your Step Goal")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                        
                        TextField("Enter steps (e.g., 5000)", text: $stepGoalString)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }

                    Button(action: {
                        calculateAndShowRadius()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Text("Show Radius")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    }
                }
                .padding()
                .background(
                    Color(.systemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
                .padding(.top, 20)

                // Map Section
                if mapCenter == nil {
                    ProgressView("Fetching your location...")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGray6))
                } else {
                    MapView(centerCoordinate: $mapCenter, radius: $circleRadius)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .ignoresSafeArea(.container, edges: .bottom)
                }
            }
        }
        .onAppear {
            locationManager.requestAuthorization()
            locationManager.startUpdatingLocation()
        }
        .onChange(of: locationManager.lastKnownLocation) { newValue in
            if let location = newValue {
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
            showLocationError = true
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
