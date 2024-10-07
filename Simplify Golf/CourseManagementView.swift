import Firebase
import SwiftUI

struct CourseManagementView: View {
    @StateObject private var viewModel = CourseManagementViewModel()
    @State private var searchText = ""
    @State private var showingAddCourse = false
    @State private var courseToDelete: Course?
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                MainMenuBackground()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    SearchBar(text: $searchText, onCommit: {})
                        .padding(.horizontal)

                    if viewModel.isLoading {
                        ProgressView()
                            .padding()

                    } else {
                        ScrollView {
                            LazyVStack {
                                Section(
                                    header: Text("Downloaded Courses").font(.headline)
                                        .foregroundColor(.white)
                                ) {
                                    if filteredDownloadedCourses.isEmpty {
                                        Text(
                                            "Add / Download courses by clicking on the blue download icons below."
                                        )
                                        .foregroundColor(.gray)
                                        .italic()
                                        .padding()
                                    } else {
                                        ForEach(filteredDownloadedCourses) { course in
                                            CourseRow(course: course, isSelected: true) {
                                                courseToDelete = course
                                                showingDeleteAlert = true
                                            }
                                        }
                                    }
                                }

                                Spacer(minLength: 20)

                                Section(
                                    header: Text("Available Courses").font(.headline)
                                        .foregroundColor(.white)
                                ) {
                                    ForEach(filteredAvailableCourses) { course in
                                        CourseRow(course: course, isSelected: false) {
                                            viewModel.downloadCourse(course) { result in
                                                switch result {
                                                case .success:
                                                    viewModel.fetchCourses()
                                                case .failure(let error):
                                                    viewModel.error = error.localizedDescription
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .refreshable {
                            viewModel.fetchCourses()
                        }
                    }

                    Button(action: {
                        showingAddCourse = true
                    }) {
                        Text("Add New Course")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Manage Courses")
            .onAppear {
                viewModel.fetchCourses()
            }
            .sheet(isPresented: $showingAddCourse) {
                AddNewCourseView()
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Course"),
                    message: Text(
                        "Are you sure you want to delete this course?"
                    ),
                    primaryButton: .destructive(Text("Delete")) {
                        if let course = courseToDelete {
                            viewModel.removeDownloadedCourse(course)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    var filteredDownloadedCourses: [Course] {
        if searchText.isEmpty {
            return viewModel.downloadedCourses
        } else {
            return viewModel.downloadedCourses.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var filteredAvailableCourses: [Course] {
        if searchText.isEmpty {
            return viewModel.availableCourses
        } else {
            return viewModel.availableCourses.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

struct CourseRow: View {
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
            Button(action: action) {
                Image(systemName: isSelected ? "trash" : "arrow.down.circle")
                    .foregroundColor(isSelected ? .red : .blue)
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
