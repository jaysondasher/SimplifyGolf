import SwiftUI

struct RoundDetailView: View {
    @State private var round: GolfRound
    @State private var showingEditRound = false
    @StateObject private var viewModel: RoundDetailViewModel
    @Environment(\.presentationMode) var presentationMode

    init(round: GolfRound) {
        _round = State(initialValue: round)
        _viewModel = StateObject(wrappedValue: RoundDetailViewModel(round: round))
    }

    var body: some View {
        ZStack {
            MainMenuBackground()

            ScrollView {
                VStack(spacing: 20) {
                    Text(viewModel.course?.name ?? "Unknown Course")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    VStack(spacing: 10) {
                        Text("Date: \(formatDate(round.date))")
                            .font(.headline)
                        Text("Total Score: \(round.totalScore) (\(scoreDifferenceToPar()))")
                            .font(.headline)
                    }
                    .foregroundColor(.white)

                    Divider().background(Color.white)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20)
                    {
                        ForEach(
                            Array(zip(round.scores.indices, viewModel.course?.holes ?? [])), id: \.0
                        ) { index, hole in
                            VStack(alignment: .leading) {
                                Text("Hole \(index + 1)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                HStack {
                                    Text("Par: \(hole.par)")
                                    Spacer()
                                    Text("Score: \(round.scores[index] ?? 0)")
                                }
                                .font(.subheadline)
                            }
                            .padding(10)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                    .foregroundColor(.white)

                    Divider().background(Color.white)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Round Statistics")
                            .font(.headline)
                            .foregroundColor(.white)

                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10
                        ) {
                            StatView(title: "Eagles", value: viewModel.eagleCount)
                            StatView(title: "Birdies", value: viewModel.birdieCount)
                            StatView(title: "Pars", value: viewModel.parCount)
                            StatView(title: "Bogeys", value: viewModel.bogeyCount)
                            StatView(title: "Double Bogeys+", value: viewModel.doubleBogeyPlusCount)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Round Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Edit") { showingEditRound = true })
        .sheet(isPresented: $showingEditRound) {
            EditRoundView(round: $round) { updatedRound in
                viewModel.updateRound(updatedRound)
                round = updatedRound
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func scoreDifferenceToPar() -> String {
        guard let course = viewModel.course else { return "" }
        let totalPar = course.holes.reduce(0) { $0 + $1.par }
        let difference = round.totalScore - totalPar
        return difference == 0 ? "E" : (difference > 0 ? "+\(difference)" : "\(difference)")
    }
}

struct StatView: View {
    let title: String
    let value: Int

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color.black.opacity(0.2))
        .cornerRadius(10)
        .foregroundColor(.white)
    }
}
