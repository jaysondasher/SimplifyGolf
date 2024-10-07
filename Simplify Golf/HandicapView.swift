import SwiftUI

struct HandicapView: View {
    @StateObject private var viewModel = HandicapViewModel()

    var body: some View {
        ZStack {
            MainMenuBackground()

            VStack(spacing: 20) {
                Text("Your Handicap")
                    .font(.title)
                    .foregroundColor(.white)

                if viewModel.isLoading {
                    ProgressView()
                } else if let handicap = viewModel.handicapIndex {
                    Text(String(format: "%.1f", handicap))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Handicap Index")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))

                    // Add disclaimer
                    Text("*This is not an official USGA Handicap Index")
                        .font(.caption)
                        .foregroundColor(.yellow)
                        .padding(.top, 5)

                    Divider().background(Color.white)

                    Text("Recent Scores")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 15) {
                        ForEach(viewModel.recentScores, id: \.self) { score in
                            Text("\(score)")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(25)
                        }
                    }
                } else {
                    Text("Not enough rounds to calculate handicap")
                        .foregroundColor(.white.opacity(0.8))
                }

                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }

                // Add USGA partnership information
                Text("We are working with the USGA to provide official handicaps in the future.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchHandicapData()
        }
    }
}
