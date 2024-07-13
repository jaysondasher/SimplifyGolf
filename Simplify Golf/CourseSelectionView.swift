//
//  CourseSelectionView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/11/24.
//

import SwiftUI

struct CourseSelectionView: View {
    @Binding var activeRound: GolfRound?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var courseManager: CourseManager
    @EnvironmentObject var userManager: UserManager
    @State private var searchText = ""
    @State private var showingAddCourse = false
    @State private var showingDeleteAlert = false
    @State private var courseToDelete: Course?
    
    var filteredCourses: [Course] {
        if searchText.isEmpty {
            return courseManager.courses
        } else {
            return courseManager.courses.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearchButtonClicked: {})
                    .padding()
                
                List {
                    if filteredCourses.isEmpty {
                        Text("No courses found. Try a different search or add a new course.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(filteredCourses) { course in
                            CourseRow(course: course, onStartRound: { startRound(course: course) }, onDelete: { confirmDelete(course: course) })
                        }
                    }
                }
            }
            .navigationTitle("Select Course")
            .navigationBarItems(trailing: Button(action: {
                showingAddCourse = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddCourse) {
                AddCourseView()
                    .environmentObject(courseManager)
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Course"),
                    message: Text("Are you sure you want to delete this course? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let course = courseToDelete {
                            courseManager.deleteCourse(course, currentUserID: userManager.getCurrentUserID())
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    func startRound(course: Course) {
        let holes = course.holes.map { courseHole in
            Hole(id: UUID(),
                 number: courseHole.number,
                 par: courseHole.par,
                 score: nil,
                 teeBox: courseHole.teeBox.clLocationCoordinate2D,
                 green: GreenCoordinates(
                    front: courseHole.green.front.clLocationCoordinate2D,
                    center: courseHole.green.center.clLocationCoordinate2D,
                    back: courseHole.green.back.clLocationCoordinate2D
                 ))
        }
        activeRound = GolfRound(id: UUID(), date: Date(), courseName: course.name, courseRating: course.courseRating, slopeRating: course.slopeRating, holes: holes)
        presentationMode.wrappedValue.dismiss()
    }
    
    func confirmDelete(course: Course) {
        courseToDelete = course
        showingDeleteAlert = true
    }
}

struct CourseRow: View {
    let course: Course
    let onStartRound: () -> Void
    let onDelete: () -> Void
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(course.name)
                    .font(.headline)
                Text(course.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onStartRound) {
                Text("Start Round")
                    .foregroundColor(.blue)
            }
        }
        .contextMenu {
            if course.creatorID == userManager.getCurrentUserID() {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete Course", systemImage: "trash")
                }
            }
            Button {
                // Implement report functionality
            } label: {
                Label("Report Course", systemImage: "exclamationmark.triangle")
            }
        }
    }
}

struct CourseSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSelectionView(activeRound: .constant(nil))
            .environmentObject(CourseManager(userManager: UserManager()))
            .environmentObject(UserManager())
    }
}
