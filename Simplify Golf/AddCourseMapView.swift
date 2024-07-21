//
//  AddCourseMapView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/20/24.
//

import SwiftUI
import MapKit

struct AddCourseMapView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var viewModel: AddCourseMapViewModel
    
    init(course: MKMapItem, courseRating: Double, slopeRating: Int) {
        _viewModel = ObservedObject(wrappedValue: AddCourseMapViewModel(initialCoordinate: course.placemark.coordinate, courseName: course.name ?? "Unknown Course", courseRating: courseRating, slopeRating: slopeRating))
    }
    
    var body: some View {
        ZStack {
            MapView(centerCoordinate: $viewModel.centerCoordinate, annotations: $viewModel.annotations, zoomLevel: $viewModel.zoomLevel)
                .edgesIgnoringSafeArea(.all)
            
            Image(systemName: "scope")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            VStack {
                HStack {
                    Button("Back") {
                        viewModel.goBack()
                    }
                    .padding()
                    .background(Material.thin)
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Material.thin)
                    .cornerRadius(10)
                }
                .padding([.leading, .trailing, .top])
                
                Spacer()
                
                Text("Hole \(viewModel.currentHole) - \(viewModel.currentMarker.description)")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 40) // Move it higher above the "Mark Location" button
                
                Button("Mark Location") {
                    viewModel.markLocation()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom)
            }
        }
        .navigationTitle("Add Course Holes")
        .navigationBarHidden(true)
        .actionSheet(item: $viewModel.parSelection) { _ in
            ActionSheet(
                title: Text("Select Par"),
                message: Text("What is the par for hole \(viewModel.currentHole)?"),
                buttons: [
                    .default(Text("3")) { viewModel.setPar(3) },
                    .default(Text("4")) { viewModel.setPar(4) },
                    .default(Text("5")) { viewModel.setPar(5) },
                    .cancel { viewModel.cancelParSelection() }
                ]
            )
        }
    }
}

