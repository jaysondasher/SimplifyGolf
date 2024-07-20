import SwiftUI

struct HoleDetailView: View {
    let hole: Hole
    let holeIndex: Int
    @Binding var round: GolfRound
    
    var body: some View {
        VStack {
            Text("Hole \(hole.number)")
                .font(.largeTitle)
            Text("Par \(hole.par)")
                .font(.title)
            Text("Your Score")
                .font(.title2)
            HStack {
                Button("-") {
                    if round.scores[holeIndex]! > 1 {
                        round.scores[holeIndex]! -= 1
                    }
                }
                Text("\(round.scores[holeIndex] ?? hole.par)")
                    .font(.title)
                Button("+") {
                    round.scores[holeIndex] = (round.scores[holeIndex] ?? hole.par) + 1
                }
            }
            .font(.largeTitle)
            .padding()
            
            Text("Distances to Green")
                .font(.headline)
            Text("Front: \(hole.green.front)")
            Text("Center: \(hole.green.center)")
            Text("Back: \(hole.green.back)")
            
            HStack {
                if holeIndex > 0 {
                    Button("Previous Hole") {
                        // Navigate to the previous hole
                    }
                }
                Spacer()
                if holeIndex < round.scores.count - 1 {
                    Button("Next Hole") {
                        // Navigate to the next hole
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Hole Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
