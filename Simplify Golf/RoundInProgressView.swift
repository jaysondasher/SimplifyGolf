import SwiftUI

struct RoundInProgressView: View {
    @StateObject private var viewModel: RoundInProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedHoleIndex: Int?

    init(round: GolfRound) {
        _viewModel = StateObject(wrappedValue: RoundInProgressViewModel(round: round))
    }

    var body: some View {
        NavigationView {
            ZStack {
                MainMenuBackground()

                VStack(spacing: 20) {
                    Text("Course: \(viewModel.course?.name ?? "")")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Total Score: \(viewModel.round.totalScore) (\(calculateTotalScoreToPar()))")
                        .font(.headline)
                        .foregroundColor(.white)

                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.course?.holes.indices ?? 0..<18, id: \.self) { index in
                                NavigationLink(
                                    destination: HoleDetailView(viewModel: viewModel, holeIndex: index),
                                    tag: index,
                                    selection: $selectedHoleIndex
                                ) {
                                    HoleRow(holeNumber: index + 1,
                                            par: viewModel.course?.holes[index].par ?? 0,
                                            score: viewModel.round.scores[index])
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onTapGesture {
                                    selectedHoleIndex = index
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Button("End Round") {
                        viewModel.finishRound()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }

    private func calculateTotalScoreToPar() -> String {
        guard let course = viewModel.course else { return "" }
        let playedScores = viewModel.round.scores.compactMap { $0 }
        let playedPars = course.holes.prefix(playedScores.count).map { $0.par }
        let totalPar = playedPars.reduce(0, +)
        let totalScore = playedScores.reduce(0, +)
        let difference = totalScore - totalPar
        return difference == 0 ? "E" : (difference > 0 ? "+\(difference)" : "\(difference)")
    }
}

struct HoleRow: View {
    let holeNumber: Int
    let par: Int
    let score: Int?
    
    var body: some View {
        HStack {
            Text("Hole \(holeNumber)")
                .foregroundColor(.orange)
            Spacer()
            Text("Par \(par)")
                .foregroundColor(.white)
            Spacer()
            if let score = score {
                let difference = score - par
                let scoreString = difference == 0 ? "E" : (difference > 0 ? "+\(difference)" : "\(difference)")
                Text("Score: \(score) (\(scoreString))")
                    .foregroundColor(.orange)
            } else {
                Text("Not played")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Material.thin)
        .cornerRadius(10)
    }
}
