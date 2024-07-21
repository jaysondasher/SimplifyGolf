import SwiftUI

struct EditRoundView: View {
    @State var round: GolfRound
    var onSave: (GolfRound) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Scores")) {
                    ForEach(0..<round.scores.count, id: \.self) { index in
                        Stepper(value: Binding(
                            get: { round.scores[index] ?? 0 },
                            set: { round.scores[index] = $0 }
                        ), in: 1...20) {
                            Text("Hole \(index + 1): \(round.scores[index] ?? 0)")
                        }
                    }
                }
            }
            .navigationTitle("Edit Scores")
            .navigationBarItems(trailing: Button("Save") {
                onSave(round)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
