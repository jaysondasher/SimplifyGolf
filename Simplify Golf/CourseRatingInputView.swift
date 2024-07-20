//
//  CourseRatingInputView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/20/24.
//


import SwiftUI
import MapKit

struct CourseRatingInputView: View {
    let course: MKMapItem
    @State private var courseRating: String = ""
    @State private var slopeRating: String = ""
    var onContinue: (Double, Int) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Details")) {
                    Text(course.name ?? "Unknown Course")
                        .font(.headline)
                    Text(course.placemark.locality ?? "Unknown Location")
                        .font(.subheadline)
                }
                
                Section(header: Text("Ratings")) {
                    TextField("Course Rating", text: $courseRating)
                        .keyboardType(.decimalPad)
                    TextField("Slope Rating", text: $slopeRating)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button("Continue to Add Holes") {
                        if let courseRating = Double(courseRating), let slopeRating = Int(slopeRating) {
                            onContinue(courseRating, slopeRating)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(courseRating.isEmpty || slopeRating.isEmpty)
                }
            }
            .navigationTitle("Course Ratings")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
