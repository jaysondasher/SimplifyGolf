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
    
    init(round: GolfRound) {
        _editedRound = State(initialValue: round)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Round Information")) {
                TextField("Course Name", text: $editedRound.courseName)
                DatePicker("Date", selection: $editedRound.date, displayedComponents: .date)
                HStack {
                    Text("Course Rating")
                    Spacer()
                    TextField("Rating", value: $editedRound.courseRating, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Slope Rating")
                    Spacer()
                    TextField("Slope", value: $editedRound.slopeRating, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section(header: Text("Hole Scores")) {
                ForEach($editedRound.holes) { $hole in
                    HStack {
                        Text("Hole \(hole.number)")
                        Spacer()
                        Text("Par \(hole.par)")
                        TextField("Score", value: $hole.score, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 50)
                    }
                }
            }
        }
        .navigationTitle("Edit Round")
        .navigationBarItems(trailing: Button("Save") {
            dataController.updateRound(editedRound)
            presentationMode.wrappedValue.dismiss()
        })
    }
}
