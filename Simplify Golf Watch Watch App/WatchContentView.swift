// Simplify Golf Watch Watch App/WatchContentView.swift

import SwiftUI

struct WatchContentView: View {
    @EnvironmentObject var viewModel: WatchViewModel
    
    var body: some View {
        if viewModel.isRoundActive {
            ActiveRoundView()
        } else {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Simplify Golf")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Waiting for round to start...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct ActiveRoundView: View {
    @EnvironmentObject var viewModel: WatchViewModel
    
    var body: some View {
        VStack {
            Text("Hole \(viewModel.currentHole)")
                .font(.headline)
            
            VStack(alignment: .leading) {
                Text("Front: \(viewModel.distances.front)y")
                Text("Middle: \(viewModel.distances.middle)y")
                Text("Back: \(viewModel.distances.back)y")
            }
            .font(.system(.body, design: .monospaced))
            
            Picker("Score", selection: $viewModel.score) {
                ForEach(1...10, id: \.self) { score in
                    Text("\(score)")
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            Button("Next Hole") {
                viewModel.nextHole()
            }
        }
        .onChange(of: viewModel.score) { _ in
            viewModel.sendScore()
        }
    }
}

#Preview {
    WatchContentView()
        .environmentObject(WatchViewModel())
}
