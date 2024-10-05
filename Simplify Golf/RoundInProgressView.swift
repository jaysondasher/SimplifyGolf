import SwiftUI

struct RoundInProgressView: View {
    @StateObject private var viewModel: RoundInProgressViewModel
    @Environment(\.presentationMode) var presentationMode

    init(round: GolfRound) {
        _viewModel = StateObject(wrappedValue: RoundInProgressViewModel(round: round))
    }

    var body: some View {
        NavigationView {
            ZStack {
                MainMenuBackground()
                    .edgesIgnoringSafeArea(.all)  // Ensure background covers entire screen

                if viewModel.isLoading {
                    // Loading Indicator
                    ProgressView("Loading Course...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                } else if let error = viewModel.error {
                    // Error Message
                    VStack {
                        Text("Error")
                            .font(.title)
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Retry") {
                            viewModel.fetchCourse()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                } else if let course = viewModel.course {
                    VStack(spacing: 20) {
                        HeaderView(
                            courseName: course.name,
                            totalScore: viewModel.round.totalScore,
                            totalScoreToPar: calculateTotalScoreToPar()
                        )

                        HolesListView(course: course, viewModel: viewModel)

                        EndRoundButton {
                            viewModel.finishRound()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .padding()
                } else {
                    // Empty State
                    Text("No Course Data Available.")
                        .foregroundColor(.white)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())  // Ensures consistent appearance across devices
    }

    /// Calculates the total score relative to par
    private func calculateTotalScoreToPar() -> String {
        guard let course = viewModel.course else { return "N/A" }
        let playedScores = viewModel.round.scores.compactMap { $0 }
        let playedPars = course.holes.prefix(playedScores.count).map { $0.par }
        let totalPar = playedPars.reduce(0, +)
        let totalScore = playedScores.reduce(0, +)
        let difference = totalScore - totalPar
        return difference == 0 ? "E" : (difference > 0 ? "+\(difference)" : "\(difference)")
    }
}

/// Header View displaying course name and total score
struct HeaderView: View {
    let courseName: String
    let totalScore: Int
    let totalScoreToPar: String

    var body: some View {
        VStack(spacing: 5) {
            Text("Course: \(courseName)")
                .font(.title2)
                .foregroundColor(.white)

            Text("Total Score: \(totalScore) (\(totalScoreToPar))")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

/// Holes List View displaying all holes
struct HolesListView: View {
    let course: Course
    @ObservedObject var viewModel: RoundInProgressViewModel

    var body: some View {
        List(course.holes.indices, id: \.self) { index in
            NavigationLink(
                destination: HoleDetailView(viewModel: viewModel)
                    .onAppear {
                        viewModel.moveToHole(index: index)
                    }
            ) {
                HoleRow(
                    holeNumber: index + 1,
                    par: course.holes[index].par,
                    score: viewModel.round.scores[index]
                )
            }
            .listRowBackground(Color.clear)
            .buttonStyle(PlainButtonStyle())
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }
}

/// End Round Button View with Confirmation Alert
struct EndRoundButton: View {
    let action: () -> Void
    @State private var showConfirmation: Bool = false

    var body: some View {
        Button(action: {
            showConfirmation = true
        }) {
            Text("End Round")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("End Round"),
                message: Text("Are you sure you want to end the round?"),
                primaryButton: .destructive(Text("End")) {
                    action()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

/// Hole Row View displaying individual hole details
struct HoleRow: View {
    let holeNumber: Int
    let par: Int
    let score: Int?

    var difference: Int? {
        guard let score = score else { return nil }
        return score - par
    }

    var scoreString: String {
        guard let difference = difference else { return "N/A" }
        if difference == 0 {
            return "E"
        } else {
            return difference > 0 ? "+\(difference)" : "\(difference)"
        }
    }

    var body: some View {
        HStack {
            Text("Hole \(holeNumber)")
                .foregroundColor(.orange)
            Spacer()
            Text("Par \(par)")
                .foregroundColor(.white)
            Spacer()
            if let difference = difference {
                Text("Score: \(score!) (\(scoreString))")
                    .foregroundColor(.orange)
            } else {
                Text("Not played")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}
