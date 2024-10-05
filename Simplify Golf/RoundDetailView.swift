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

            VStack(spacing: 20) {
                Text("Date: \(formatDate(round.date))")
                    .foregroundColor(.white)

                Text("Total Score: \(round.totalScore) (\(scoreDifferenceToPar()))")
                    .foregroundColor(.white)

                List {
                    ForEach(
                        Array(zip(round.scores.indices, viewModel.course?.holes ?? [])), id: \.0
                    ) { index, hole in
                        HStack {
                            Text("Hole \(index + 1)")
                            Spacer()
                            Text("Par: \(hole.par)")
                            Text("Score: \(round.scores[index] ?? 0)")
                        }
                        .foregroundColor(.white)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .padding()
        }
        .navigationTitle("Round Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Button("Edit") {
                showingEditRound = true
            }
        )
        .sheet(isPresented: $showingEditRound) {
            EditRoundView(round: $round) { updatedRound in
                viewModel.updateRound(updatedRound)
                round = updatedRound  // This should now work as round is @State
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
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
