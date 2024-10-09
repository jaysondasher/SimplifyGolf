import Firebase
import SwiftUI

struct EditRoundView: View {
    @Binding var round: GolfRound
    @State private var course: Course?
    var onSave: (GolfRound) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Scores")) {
                    ForEach(0..<round.scores.count, id: \.self) { index in
                        HStack {
                            Text("Hole \(index + 1)")
                            Spacer()
                            if let holePar = course?.holes[index].par {
                                Text("Par: \(holePar)")
                            }
                            Stepper(
                                value: Binding(
                                    get: { round.scores[index] ?? 0 },
                                    set: { newValue in
                                        round.scores[index] = newValue
                                    }
                                ), in: 1...20
                            ) {
                                Text("Score: \(round.scores[index] ?? 0)")
                            }
                        }
                    }
                }
                Section {
                    Text("Total Score: \(round.totalScore)")
                        .font(.headline)
                }
            }
            .navigationTitle("Edit Scores")
            .navigationBarItems(
                trailing: Button("Save") {
                    onSave(round)
                    presentationMode.wrappedValue.dismiss()
                })
        }
        .onAppear {
            fetchCourse()
        }
    }

    private func fetchCourse() {
        let db = Firestore.firestore()
        db.collection("courses").document(round.courseId).getDocument { (document, error) in
            if let document = document, document.exists,
                let courseData = document.data(),
                let fetchedCourse = Course.fromFirestore(courseData)
            {
                self.course = fetchedCourse
            } else {
                print("Error fetching course: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
