import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()

    var body: some View {
        ZStack {
            MainMenuBackground()

            VStack(spacing: 20) {
                Text("Your Golf Statistics")
                    .font(.title)
                    .foregroundColor(.white)

                if viewModel.isLoading {
                    ProgressView()
                } else {
                    StatCard(title: "Rounds Played", value: "\(viewModel.roundsPlayed)")
                    StatCard(title: "Average Score", value: String(format: "%.1f", viewModel.averageScore))
                    StatCard(title: "Best Score", value: "\(viewModel.bestScore)")
                    StatCard(title: "Worst Score", value: "\(viewModel.worstScore)")
                }

                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchStatistics()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}
