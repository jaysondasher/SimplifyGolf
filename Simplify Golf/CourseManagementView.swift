import SwiftUI
import Firebase


struct CourseManagementView: View {
    @StateObject private var viewModel = CourseManagementViewModel()
    @State private var searchText = ""
    @State private var showingAddCourse = false
    
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
                    } else {
                        ScrollView {
                            LazyVStack {
                                Section(header: Text("Downloaded Courses").font(.headline).foregroundColor(.white)) {
                                    ForEach(filteredDownloadedCourses) { course in
                                        CourseRow(course: course, isDownloaded: true) {
                                            viewModel.removeDownloadedCourse(course)
                                        }
                                    }
                                }
                                
                                Section(header: Text("Available Courses").font(.headline).foregroundColor(.white)) {
                                    ForEach(filteredAvailableCourses) { course in
                                        CourseRow(course: course, isDownloaded: false) {
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
        }
    }
    
    var filteredDownloadedCourses: [Course] {
        if searchText.isEmpty {
            return viewModel.downloadedCourses
        } else {
            return viewModel.downloadedCourses.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var filteredAvailableCourses: [Course] {
        if searchText.isEmpty {
            return viewModel.availableCourses
        } else {
            return viewModel.availableCourses.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}


struct CourseRow: View {
    var course: Course
    var isDownloaded: Bool
    var action: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(course.name)
                    .font(.headline)
                Text("\(course.holes.count) holes")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            if isDownloaded {
                Text("Downloaded")
                    .font(.caption)
                    .foregroundColor(.green)
            } else {
                Button(action: action) {
                    Image(systemName: "arrow.down.circle")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Material.thin)
        .cornerRadius(10)
        .padding(.vertical, 4)
    }
}






