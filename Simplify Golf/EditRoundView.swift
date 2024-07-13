//
//  EditRoundView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/12/24.
//

import SwiftUI

struct EditRoundView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataController: DataController
    @State private var editedRound: GolfRound
    @State private var holeScores: [Int?]
    
    init(round: GolfRound) {
        _editedRound = State(initialValue: round)
        _holeScores = State(initialValue: round.holes.map { $0.score })
        print("EditRoundView initialized with round: \(round.id)")
    }
    
    var body: some View {
        ZStack {
            GolfAppBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Edit Round Scores")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        InfoRow(title: "Course", value: editedRound.courseName)
                        InfoRow(title: "Date", value: formatDate(editedRound.date))
                        InfoRow(title: "Course Rating", value: String(format: "%.1f", editedRound.courseRating))
                        InfoRow(title: "Slope Rating", value: "\(editedRound.slopeRating)")
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Hole Scores")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ForEach(editedRound.holes.indices, id: \.self) { index in
                            HStack {
                                Text("Hole \(editedRound.holes[index].number)")
                                Spacer()
                                Text("Par \(editedRound.holes[index].par)")
                                TextField("Score", value: Binding(
                                    get: { self.holeScores[index] ?? 0 },
                                    set: { self.holeScores[index] = $0 }
                                ), formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 50)
                                .foregroundColor(.black)
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    
                    Button("Save") {
                        print("Save button tapped")
                        saveRound()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationBarItems(leading: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        })
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("EditRoundView appeared for round: \(editedRound.id)")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func saveRound() {
        for (index, score) in holeScores.enumerated() {
            editedRound.holes[index].score = score
        }
        dataController.updateRound(editedRound)
    }
}
