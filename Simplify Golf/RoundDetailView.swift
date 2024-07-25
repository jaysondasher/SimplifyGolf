import SwiftUI

struct RoundDetailView: View {
    let round: GolfRound
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            MainMenuBackground()
            
            VStack(spacing: 20) {
                Text("Date: \(formatDate(round.date))")
                    .foregroundColor(.white)
                
                Text("Total Score: \(round.totalScore)")
                    .foregroundColor(.white)
                
                List(round.scores.indices, id: \.self) { index in
                    HStack {
                        Text("Hole \(index + 1)")
                        Spacer()
                        Text("Score: \(round.scores[index] ?? 0)")
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
            }
            .padding()
        }
        .navigationTitle("Round Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
