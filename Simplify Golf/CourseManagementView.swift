//
//  CourseManagementView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//


import SwiftUI
import Firebase

struct CourseManagementView: View {
    @StateObject private var viewModel = CourseManagementViewModel()
    @State private var showingAddCourse = false
    @State private var selectedCourse: Course?
    
    var body: some View {
        ZStack {
            MainMenuBackground()
            
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(viewModel.courses) { course in
                            CourseRow(course: course)
                                .onTapGesture {
                                    selectedCourse = course
                                }
                        }
                        .onDelete(perform: deleteCourse)
                    }
                    .listStyle(PlainListStyle())
                }
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
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
            AddEditCourseView(mode: .add, course: nil) { newCourse in
                viewModel.addCourse(newCourse)
            }
        }
        .sheet(item: $selectedCourse) { course in
            AddEditCourseView(mode: .edit, course: course) { updatedCourse in
                viewModel.updateCourse(updatedCourse)
            }
        }
    }
    
    private func deleteCourse(at offsets: IndexSet) {
        offsets.forEach { index in
            let course = viewModel.courses[index]
            viewModel.deleteCourse(course)
        }
    }
}

struct CourseRow: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(course.name)
                .font(.headline)
            Text("\(course.holes.count) holes")
                .font(.subheadline)
        }
    }
}

struct AddEditCourseView: View {
    enum Mode {
        case add
        case edit
    }
    
    let mode: Mode
    let course: Course?
    let onSave: (Course) -> Void
    
    @State private var name: String
    @State private var location: String
    @State private var holeCount: Int
    @State private var courseRating: Double
    @State private var slopeRating: Int
    
    @Environment(\.presentationMode) var presentationMode
    
    init(mode: Mode, course: Course?, onSave: @escaping (Course) -> Void) {
        self.mode = mode
        self.course = course
        self.onSave = onSave
        
        _name = State(initialValue: course?.name ?? "")
        _location = State(initialValue: course?.location ?? "")
        _holeCount = State(initialValue: course?.holes.count ?? 18)
        _courseRating = State(initialValue: course?.courseRating ?? 72.0)
        _slopeRating = State(initialValue: course?.slopeRating ?? 113)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Course Name", text: $name)
                TextField("Location", text: $location)
                Stepper("Holes: \(holeCount)", value: $holeCount, in: 9...18, step: 9)
                TextField("Course Rating", value: $courseRating, formatter: NumberFormatter())
                TextField("Slope Rating", value: $slopeRating, formatter: NumberFormatter())
            }
            .navigationTitle(mode == .add ? "Add Course" : "Edit Course")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                let newCourse = Course(
                    id: course?.id ?? UUID().uuidString,
                    name: name,
                    location: location,
                    holes: (1...holeCount).map {
                        Hole(number: $0,
                             par: 4,
                             yardage: 0,
                             teeBox: Coordinate(latitude: 0, longitude: 0),
                             green: Hole.Green(
                                front: Coordinate(latitude: 0, longitude: 0),
                                center: Coordinate(latitude: 0, longitude: 0),
                                back: Coordinate(latitude: 0, longitude: 0)
                             ))
                    },
                    courseRating: courseRating,
                    slopeRating: slopeRating,
                    creatorId: course?.creatorId ?? Auth.auth().currentUser?.uid ?? ""
                )
                onSave(newCourse)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
