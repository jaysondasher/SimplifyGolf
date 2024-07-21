import SwiftUI

struct PastRoundsView: View {
    @StateObject private var viewModel = PastRoundsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                MainMenuBackground()
                
                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if !viewModel.rounds.isEmpty {
                        List {
                            ForEach(viewModel.rounds) { round in
                                if let courseName = viewModel.courseNames[round.courseId] {
                                    NavigationLink(destination: RoundDetailView(round: round)) {
                                        PastRoundRow(round: round, courseName: courseName)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.deleteRound(round)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            viewModel.editingRound = round
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
                .navigationTitle("Past Rounds")
            }
            .onAppear {
                viewModel.fetchPastRounds()
            }
            .sheet(isPresented: $viewModel.showingEditRound) {
                if let round = viewModel.editingRound {
                    EditRoundView(round: round) { updatedRound in
                        viewModel.updateRound(updatedRound)
                    }
                }
            }
        }
    }
}

struct PastRoundRow: View {
    let round: GolfRound
    let courseName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(courseName)
                .font(.headline)
            Text("Date: \(formatDate(round.date))")
                .font(.subheadline)
            Text("Total Score: \(round.totalScore)")
                .font(.subheadline)
        }
        .foregroundColor(.white)
        .padding(.vertical, 8)
        .background(Material.thin)
        .cornerRadius(10)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
