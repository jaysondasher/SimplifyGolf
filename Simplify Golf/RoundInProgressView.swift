import SwiftUI

struct RoundInProgressView: View {
    @StateObject private var viewModel: RoundInProgressViewModel
    @Environment(\.presentationMode) var presentationMode

    init(round: GolfRound) {
        _viewModel = StateObject(wrappedValue: RoundInProgressViewModel(round: round))
    }

    var body: some View {
        ZStack {
            MainMenuBackground()

            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                } else if let course = viewModel.course {
                    Text(course.name)
                        .font(.title)
                        .foregroundColor(.white)

                    Text("Total Score: \(viewModel.round.totalScore)")
                        .font(.headline)
                        .foregroundColor(.white)

                    List {
                        ForEach(course.holes.indices, id: \.self) { index in
                            HStack {
                                Text("Hole \(index + 1)")
                                    .foregroundColor(.orange)
                                Spacer()
                                Text("Par \(course.holes[index].par)")
                                    .foregroundColor(.white)
                                Spacer()
                                if let score = viewModel.round.scores[index] {
                                    Text("Score: \(score)")
                                        .foregroundColor(.orange)
                                } else {
                                    Text("Not played")
                                        .foregroundColor(.gray)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.currentHoleIndex = index
                            }
                        }
                    }
                    .background(Color.clear)
                    .listStyle(PlainListStyle())

                    Button("End Round") {
                        viewModel.finishRound()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
    }
}
