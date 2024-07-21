import SwiftUI
import CoreLocation

struct HoleDetailView: View {
    @ObservedObject var viewModel: RoundInProgressViewModel
    @Binding var currentHoleIndex: Int
    @State private var currentScore: Int
    
    var hole: Hole {
        viewModel.course?.holes[currentHoleIndex] ?? Hole(number: 0, par: 0, yardage: 0, teeBox: Coordinate(latitude: 0, longitude: 0), green: Hole.Green(front: Coordinate(latitude: 0, longitude: 0), center: Coordinate(latitude: 0, longitude: 0), back: Coordinate(latitude: 0, longitude: 0)))
    }
    
    init(viewModel: RoundInProgressViewModel, currentHoleIndex: Binding<Int>) {
        self.viewModel = viewModel
        self._currentHoleIndex = currentHoleIndex
        let holeIndex = currentHoleIndex.wrappedValue
        let initialScore = viewModel.round.scores[holeIndex] ?? viewModel.course?.holes[holeIndex].par ?? 0
        self._currentScore = State(initialValue: initialScore)
    }
    
    var body: some View {
        ZStack {
            MainMenuBackground()
            
            VStack(spacing: 20) {
                VStack(spacing: 5) {
                    Text("Hole \(hole.number)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("Par \(hole.par)")
                        .font(.title)
                        .foregroundColor(.white)
                }

                VStack(alignment: .center, spacing: 30) {
                    Text("Distances to Green")
                        .font(.title)
                        .foregroundColor(.white)
                    VStack(spacing: 20) {
                        VStack {
                            Text("Front")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("\(calculateDistance(to: hole.green.front)) yards")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        VStack {
                            Text("Center")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("\(calculateDistance(to: hole.green.center)) yards")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        VStack {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("\(calculateDistance(to: hole.green.back)) yards")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(Material.thin)
                .cornerRadius(10)
                
                Spacer()

                VStack(spacing: 10) {
                    Text("Your Score")
                        .font(.title2)
                        .foregroundColor(.white)
                    HStack {
                        Button("-") {
                            if currentScore > 1 {
                                currentScore -= 1
                            }
                        }
                        .foregroundColor(.white)
                        Text("\(currentScore)")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        Button("+") {
                            currentScore += 1
                        }
                        .foregroundColor(.white)
                    }
                    .font(.largeTitle)
                    .padding()
                    .background(Material.thin)
                    .cornerRadius(10)
                }

                HStack {
                    if currentHoleIndex > 0 {
                        Button("Previous Hole") {
                            saveCurrentScore()
                            currentHoleIndex -= 1
                            updateCurrentScore()
                        }
                        .foregroundColor(.white)
                    }
                    Spacer()
                    if currentHoleIndex < (viewModel.course?.holes.count ?? 0) - 1 {
                        Button("Next Hole") {
                            saveCurrentScore()
                            currentHoleIndex += 1
                            updateCurrentScore()
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.bottom)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            saveCurrentScore()
        }
    }
    
    private func saveCurrentScore() {
        viewModel.updateScore(for: currentHoleIndex, score: currentScore)
    }
    
    private func updateCurrentScore() {
        currentScore = viewModel.round.scores[currentHoleIndex] ?? hole.par
    }
    
    func calculateDistance(to coordinate: Coordinate) -> Int {
        guard let userLocation = viewModel.currentLocation else { return 0 }
        let target = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distanceInMeters = userLocation.distance(from: target)
        return Int(distanceInMeters * 1.09361) // Convert meters to yards
    }
}
