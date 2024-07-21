import SwiftUI

struct StartRoundView: View {
    @StateObject private var viewModel = StartRoundViewModel()
    @State private var showingRoundInProgress = false
    @State private var activeRound: GolfRound?

    var body: some View {
        ZStack {
            MainMenuBackground()

            VStack(spacing: 20) {
                Text("Select a Course")
                    .font(.title)
                    .foregroundColor(.white)

                SearchBar(text: $viewModel.searchText, onCommit: viewModel.fetchCourses)

                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.filteredCourses.isEmpty {
                    List(viewModel.filteredCourses) { course in
                        StartRoundCourseRow(course: course, isSelected: viewModel.selectedCourse?.id == course.id) {
                            viewModel.selectedCourse = course
                        }
                        .listRowBackground(Color.clear)  // Ensure background is clear
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    Text("No courses available")
                        .foregroundColor(.white)
                }

                Button("Start Round") {
                    viewModel.startRound { result in
                        switch result {
                        case .success(let round):
                            activeRound = round
                            print("About to show RoundInProgressView for round ID: \(round.id)")
                            showingRoundInProgress = true
                        case .failure(let error):
                            viewModel.error = error.localizedDescription
                        }
                    }
                }
                .disabled(viewModel.selectedCourse == nil)
                .padding()
                .background(viewModel.selectedCourse == nil ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchCourses()
        }
        .fullScreenCover(isPresented: $showingRoundInProgress) {
            if let round = activeRound {
                RoundInProgressView(round: round)
            } else {
                Text("Error: No active round")
                    .foregroundColor(.red)
            }
        }
        .onChange(of: showingRoundInProgress) { newValue in
            print("showingRoundInProgress changed to: \(newValue)")
        }
    }
}

struct StartRoundCourseRow: View {
    var course: Course
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(course.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("\(course.holes.count) holes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(isSelected ? Color.green.opacity(0.3) : Color.clear)
        .cornerRadius(10)
        .onTapGesture {
            action()
        }
    }
}
