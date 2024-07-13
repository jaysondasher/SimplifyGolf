//
//  AddCourseView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/12/24.
//

import SwiftUI
import MapKit

struct IdentifiableMapItem: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem
}

struct AddCourseView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var courseManager: CourseManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var searchQuery = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3314, longitude: -122.0304),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedPlace: IdentifiableMapItem?
    @State private var courseRating: String = ""
    @State private var slopeRating: String = ""
    @State private var showingAddHoles = false
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchQuery, onSearchButtonClicked: performSearch)
                
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: selectedPlace.map { [$0] } ?? []) { place in
                    MapMarker(coordinate: place.mapItem.placemark.coordinate)
                }
                
                if let selectedPlace = selectedPlace {
                    VStack(alignment: .leading) {
                        Text("Selected Course: \(selectedPlace.mapItem.name ?? "")")
                            .font(.headline)
                        Text("Location: \(selectedPlace.mapItem.placemark.locality ?? ""), \(selectedPlace.mapItem.placemark.administrativeArea ?? "")")
                            .font(.subheadline)
                        
                        TextField("Course Rating (Optional)", text: $courseRating)
                            .keyboardType(.decimalPad)
                        TextField("Slope Rating (Optional)", text: $slopeRating)
                            .keyboardType(.numberPad)
                        
                        NavigationLink(destination: AddHolesView(course: Course(
                            id: UUID().uuidString,
                            name: selectedPlace.mapItem.name ?? "",
                            location: "\(selectedPlace.mapItem.placemark.locality ?? ""), \(selectedPlace.mapItem.placemark.administrativeArea ?? "")",
                            courseRating: Double(courseRating) ?? 0,
                            slopeRating: Int(slopeRating) ?? 0,
                            holes: [],
                            creatorID: userManager.getCurrentUserID()
                        ), initialCoordinate: selectedPlace.mapItem.placemark.coordinate), isActive: $showingAddHoles) {
                            Button("Add Hole Details") {
                                showingAddHoles = true
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add New Course")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            if let userLocation = locationManager.location?.coordinate {
                region = MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
    
    func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            
            if let firstItem = response.mapItems.first {
                self.selectedPlace = IdentifiableMapItem(mapItem: firstItem)
                self.region = MKCoordinateRegion(center: firstItem.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            }
        }
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var onSearchButtonClicked: () -> Void
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, onSearchButtonClicked: onSearchButtonClicked)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        var onSearchButtonClicked: () -> Void
        
        init(text: Binding<String>, onSearchButtonClicked: @escaping () -> Void) {
            _text = text
            self.onSearchButtonClicked = onSearchButtonClicked
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            onSearchButtonClicked()
        }
    }
}
