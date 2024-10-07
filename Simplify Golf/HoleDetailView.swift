import MapKit
import SwiftUI

struct HoleDetailView: View {
    @ObservedObject var viewModel: RoundInProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var currentScore: Int
    @State private var mapType: MKMapType = .standard

    var hole: Hole {
        viewModel.currentHole
            ?? Hole(
                number: 0, par: 0, yardage: 0, teeBox: Coordinate(latitude: 0, longitude: 0),
                green: Hole.Green(
                    front: Coordinate(latitude: 0, longitude: 0),
                    center: Coordinate(latitude: 0, longitude: 0),
                    back: Coordinate(latitude: 0, longitude: 0)))
    }

    init(viewModel: RoundInProgressViewModel) {
        self.viewModel = viewModel
        let initialScore =
            viewModel.round.scores[viewModel.currentHoleIndex] ?? viewModel.course?.holes[
                viewModel.currentHoleIndex
            ].par ?? 0
        self._currentScore = State(initialValue: initialScore)
    }

    var body: some View {
        ZStack {
            HoleDetailMapView(viewModel: viewModel, hole: hole, mapType: $mapType)
                .id(hole.id)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    // Reset the initialSetupDone flag when the view appears
                    if let mapView =
                        (UIApplication.shared.windows.first?.rootViewController
                        as? UIHostingController<HoleDetailView>)?.view.subviews.first as? MKMapView,
                        let coordinator = mapView.delegate as? HoleDetailMapView.Coordinator
                    {
                        coordinator.initialSetupDone = false
                    }
                }

            VStack {
                Spacer()

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: {
                            mapType = mapType == .standard ? .satellite : .standard
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text(mapType == .standard ? "Satellite" : "Standard")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }

                        DistancesView(
                            back: calculateDistance(to: hole.green.back),
                            center: calculateDistance(to: hole.green.center),
                            front: calculateDistance(to: hole.green.front)
                        )
                    }
                    .padding(.leading)
                    Spacer()
                }

                Spacer()

                // Scoring Box
                VStack(spacing: 10) {
                    Text("Hole \(hole.number): Your Score")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack {
                        Button(action: {
                            if currentScore > 0 {
                                currentScore -= 1
                                viewModel.updateScore(
                                    for: viewModel.currentHoleIndex, score: currentScore)
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }

                        Text("\(currentScore)")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .frame(width: 80)

                        Button(action: {
                            currentScore += 1
                            viewModel.updateScore(
                                for: viewModel.currentHoleIndex, score: currentScore)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }
                    }

                    HStack {
                        NavigationButton(
                            text: "Last Hole",
                            action: {
                                saveCurrentScore()
                                viewModel.moveToHole(index: viewModel.currentHoleIndex - 1)
                                updateCurrentScore()
                            },
                            disabled: viewModel.currentHoleIndex == 0
                        )

                        Spacer()

                        if viewModel.currentHoleIndex < (viewModel.course?.holes.count ?? 1) - 1 {
                            NavigationButton(
                                text: "Next Hole",
                                action: {
                                    saveCurrentScore()
                                    viewModel.moveToHole(index: viewModel.currentHoleIndex + 1)
                                    updateCurrentScore()
                                }
                            )
                        } else {
                            NavigationButton(
                                text: "Finish",
                                action: {
                                    saveCurrentScore()
                                    viewModel.finishRound()
                                    presentationMode.wrappedValue.dismiss()
                                }
                            )
                        }
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 40)  // Add horizontal padding to push edges in
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .padding(.horizontal, 20)  // Add padding around the entire box
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitle("Scorecard", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
        .onDisappear {
            saveCurrentScore()
        }
        .onChange(of: viewModel.currentHoleIndex) { _ in
            updateCurrentScore()
        }
    }

    // MARK: - Helper Methods

    private func saveCurrentScore() {
        viewModel.updateScore(for: viewModel.currentHoleIndex, score: currentScore)
    }

    private func updateCurrentScore() {
        currentScore = viewModel.round.scores[viewModel.currentHoleIndex] ?? hole.par
    }

    private func calculateDistance(to coordinate: Coordinate) -> Int {
        guard let userLocation = viewModel.currentLocation else { return 0 }
        let targetLocation = CLLocation(
            latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distanceInMeters = userLocation.distance(from: targetLocation)
        return Int(distanceInMeters * 1.09361)  // Convert meters to yards
    }
}

struct DistancesView: View {
    let back: Int
    let center: Int
    let front: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            DistanceRow(label: "Back", distance: back, isCenter: false)
            DistanceRow(label: "Center", distance: center, isCenter: true)
            DistanceRow(label: "Front", distance: front, isCenter: false)
        }
        .padding(15)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}

struct DistanceRow: View {
    let label: String
    let distance: Int
    let isCenter: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(isCenter ? .title : .title3)  // Reduced font size for Back and Front
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("\(distance)")
                .font(isCenter ? .largeTitle : .title)  // Reduced font size for Back and Front
                .fontWeight(.bold)
                .foregroundColor(isCenter ? .orange : .white)  // Orange color for Center
        }
    }
}

struct NavigationButton: View {
    let text: String
    let action: () -> Void
    var disabled: Bool = false

    var body: some View {
        Button(action: action) {
            Text(text)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.6), Color.blue.opacity(0.8),
                        ]), startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
    }
}
