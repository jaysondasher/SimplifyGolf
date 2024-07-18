//
//  StartRoundView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//


import SwiftUI

struct StartRoundView: View {
    @StateObject private var viewModel = StartRoundViewModel()
    @State private var showingRoundInProgress = false
    @State private var activeRound: GolfRound?
    
    var body: some View {
        ZStack {
            MainMenuBackground()
            
            VStack(spacing: 20) {
                Text("Select a Course")
                    .font(.title)
                    .foregroundColor(.white)
                
                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.courses.isEmpty {
                    List(viewModel.courses) { course in
                        CourseRow(course: course)
                            .onTapGesture {
                                viewModel.selectedCourse = course
                            }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    Text("No courses available")
                        .foregroundColor(.white)
                }
                
                Button("Start Round") {
                    viewModel.startRound { result in
                        switch result {
                        case .success(let round):
                            activeRound = round
                            showingRoundInProgress = true
                        case .failure(let error):
                            viewModel.error = error.localizedDescription
                        }
                    }
                }
                .disabled(viewModel.selectedCourse == nil)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchCourses()
        }
        .fullScreenCover(isPresented: $showingRoundInProgress, content: {
            if let round = activeRound {
                RoundInProgressView(round: round)
            }
        })
    }
}

