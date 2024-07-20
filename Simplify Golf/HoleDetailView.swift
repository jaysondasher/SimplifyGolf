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
                Text("Hole \(hole.number)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text("Par \(hole.par)")
                    .font(.title)
                    .foregroundColor(.white)
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
                        .font(.title)
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
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Distances to Green")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Front: \(calculateDistance(to: hole.green.front)) yards")
                        .foregroundColor(.white)
                    Text("Center: \(calculateDistance(to: hole.green.center)) yards")
                        .foregroundColor(.white)
                    Text("Back: \(calculateDistance(to: hole.green.back)) yards")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Material.thin)
                .cornerRadius(10)
                
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
                .padding()
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
        let teeBox = CLLocation(latitude: hole.teeBox.latitude, longitude: hole.teeBox.longitude)
        let target = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distanceInMeters = teeBox.distance(from: target)
        return Int(distanceInMeters * 1.09361) // Convert meters to yards
    }
}
