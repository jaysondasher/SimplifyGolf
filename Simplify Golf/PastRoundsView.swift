import SwiftUI

struct PastRoundsView: View {
    @StateObject private var viewModel = PastRoundsViewModel()
    @State private var searchText = ""

    var body: some View {
        ZStack {
            MainMenuBackground()

            VStack {
                SearchBar(text: $searchText, placeholder: "Search by course or date") {
                    viewModel.filterRounds(searchText: searchText)
                }
                .padding()

                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.filteredRounds.isEmpty {
                    List {
                        ForEach(viewModel.filteredRounds.indices, id: \.self) { index in
                            let round = viewModel.filteredRounds[index]
                            if let courseName = viewModel.courseNames[round.courseId] {
                                NavigationLink(destination: RoundDetailView(round: round)) {
                                    PastRoundRow(
                                        round: round, courseName: courseName,
                                        coursePar: viewModel.coursePars[round.courseId] ?? 0)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteRound(round)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        viewModel.editingRoundIndex = viewModel.rounds.firstIndex(
                                            where: { $0.id == round.id })
                                        viewModel.showingEditRound = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    Text("No past rounds found")
                        .foregroundColor(.white)
                }
            }
        }
        .navigationTitle("Past Rounds")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchPastRounds()
        }
        .onChange(of: searchText) { newValue in
            viewModel.filterRounds(searchText: newValue)
        }
        .sheet(isPresented: $viewModel.showingEditRound) {
            if let editingIndex = viewModel.editingRoundIndex {
                EditRoundView(round: $viewModel.rounds[editingIndex]) { updatedRound in
                    viewModel.updateRound(updatedRound)
                }
            }
        }
    }
}

struct PastRoundRow: View {
    let round: GolfRound
    let courseName: String
    let coursePar: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(courseName)
                    .font(.headline)
                Text(formatDate(round.date))
                    .font(.subheadline)
                HStack {
                    Text("Total Score:")
                        .font(.subheadline)
                    Text("\(round.totalScore)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text(scoreToPar())
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .foregroundColor(.white)
            Spacer()
        }
        .background(Color.black.opacity(0.2))
        .cornerRadius(10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, M/d/yy"
        return formatter.string(from: date)
    }

    private func scoreToPar() -> String {
        let difference = round.totalScore - coursePar
        if difference == 0 {
            return "(E)"
        } else if difference > 0 {
            return "(+\(difference))"
        } else {
            return "(\(difference))"
        }
    }
}

struct PastRoundsView_Previews: PreviewProvider {
    static var previews: some View {
        PastRoundsView()
            .environmentObject(AuthenticationViewModel())
    }
}
