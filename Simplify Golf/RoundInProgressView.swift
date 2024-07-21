import SwiftUI

struct RoundInProgressView: View {
    @StateObject private var viewModel: RoundInProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var currentHoleIndex: Int = 0

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
                    
                    Text("Total Score: \(viewModel.round.totalScore)")
                        .font(.headline)
                        .foregroundColor(.white)

                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.course?.holes.indices ?? 0..<18, id: \.self) { index in
                                NavigationLink(destination: HoleDetailView(viewModel: viewModel, currentHoleIndex: $currentHoleIndex)) {
                                    HoleRow(holeNumber: index + 1,
                                            par: viewModel.course?.holes[index].par ?? 0,
                                            score: viewModel.round.scores[index])
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onTapGesture {
                                    currentHoleIndex = index
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
                Text("Score: \(score)")
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
