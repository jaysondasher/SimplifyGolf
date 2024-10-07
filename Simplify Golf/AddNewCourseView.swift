import Firebase
import Foundation
import MapKit
import SwiftUI

struct AddNewCourseView: View {
    @StateObject private var viewModel = AddNewCourseViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                MapView(
                    centerCoordinate: $viewModel.centerCoordinate,
                    annotations: $viewModel.annotations, zoomLevel: $viewModel.zoomLevel,
                    mapType: $viewModel.mapType
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    SearchBar(text: $viewModel.searchText, placeholder: "Search courses") {
                        viewModel.performSearch()
                    }
                    .padding()
                    .onChange(of: viewModel.searchText) { newValue in
                        viewModel.performSearch()  // Perform search as text changes
                    }

                    if !viewModel.searchResults.isEmpty {
                        List(viewModel.searchResults) { result in
                            Button(action: {
                                viewModel.selectSearchResult(result)
                                print("Button pressed for course: \(result.title)")
                            }) {
                                VStack(alignment: .leading) {
                                    Text(result.title)
                                    Text(result.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .frame(height: 200)
                    }

                    Spacer()

                    if let course = viewModel.selectedCourse {
                        Text(course.name ?? "Course name unavailable")
                            .font(.title)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)

                        Button("Select This Course") {
                            viewModel.showingCourseRatingInput = true
                            // Dismiss the keyboard
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                                for: nil)
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Add New Course")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
        .sheet(isPresented: $viewModel.showingCourseRatingInput) {
            if let selectedCourse = viewModel.selectedCourse {
                CourseRatingInputView(course: selectedCourse) { courseRating, slopeRating in
                    viewModel.startAddingHoles(courseRating: courseRating, slopeRating: slopeRating)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingAddHoles) {
            if let selectedCourse = viewModel.selectedCourse {
                AddCourseMapView(
                    course: selectedCourse, courseRating: viewModel.courseRating,
                    slopeRating: viewModel.slopeRating)
            }
        }
    }
}

class AddNewCourseViewModel: NSObject, ObservableObject {
    @Published var centerCoordinate = CLLocationCoordinate2D(
        latitude: 37.3314, longitude: -122.0325)
    @Published var searchText = ""
    @Published var selectedCourse: MKMapItem?
    @Published var showingCourseRatingInput = false
    @Published var showingAddHoles = false
    @Published var searchResults: [SearchResult] = []
    @Published var annotations: [MKPointAnnotation] = []
    @Published var zoomLevel: Double = 0.02
    @Published var mapType: MKMapType = .standard

    var courseRating: Double = 0
    var slopeRating: Int = 0

    private var searchCompleter = MKLocalSearchCompleter()

    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .pointOfInterest
    }

    func performSearch() {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        searchRequest.pointOfInterestFilter = .includingAll
        searchRequest.resultTypes = .pointOfInterest

        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error performing search: \(error.localizedDescription)")
                return
            }

            if let response = response {
                self.searchResults = response.mapItems.map {
                    SearchResult(
                        title: $0.name ?? "", subtitle: $0.placemark.title ?? "", mapItem: $0)
                }

                self.annotations = response.mapItems.map {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = $0.placemark.coordinate
                    annotation.title = $0.name
                    return annotation
                }

                if let firstItem = response.mapItems.first {
                    self.centerCoordinate = firstItem.placemark.coordinate
                }
            }
        }
    }

    func selectSearchResult(_ result: SearchResult) {
        print("selectSearchResult called")

        guard let mapItem = result.mapItem else {
            print("No mapItem found for the selected result")
            return
        }

        print("Selected course: \(mapItem.name ?? "Unknown Course")")
        selectedCourse = mapItem
        centerCoordinate = mapItem.placemark.coordinate

        let annotation = MKPointAnnotation()
        annotation.coordinate = mapItem.placemark.coordinate
        annotation.title = mapItem.name
        annotations = [annotation]

        print("Annotations: \(annotations)")
    }

    func updateSearchText(_ newText: String) {
        searchText = newText
        searchCompleter.queryFragment = newText
    }

    func startAddingHoles(courseRating: Double, slopeRating: Int) {
        self.courseRating = courseRating
        self.slopeRating = slopeRating
        showingCourseRatingInput = false
        showingAddHoles = true
    }
}

extension AddNewCourseViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results.map { completion in
            SearchResult(title: completion.title, subtitle: completion.subtitle, mapItem: nil)
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error updating search results: \(error.localizedDescription)")
    }
}

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let mapItem: MKMapItem?
}
