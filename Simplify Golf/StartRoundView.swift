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
                        CourseRow(course: course, isDownloaded: viewModel.isCourseDownloaded(course)) {
                            if viewModel.isCourseDownloaded(course) {
                                // Do nothing or show an alert that the course is already downloaded
                            } else {
                                viewModel.downloadCourse(course) { result in
                                    switch result {
                                    case .success:
                                        print("Course downloaded successfully")
                                    case .failure(let error):
                                        print("Error downloading course: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                        .onTapGesture {
                            viewModel.selectedCourse = course
                        }
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
            }
        }
    }
}
