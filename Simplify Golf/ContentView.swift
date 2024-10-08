//
//  ContentView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 5/15/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ZStack {
                MainMenuBackground()

                VStack(spacing: 30) {
                    Text("Simplify Golf")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.bottom, 100)

                    VStack(spacing: 20) {
                        NavigationLink(
                            destination: StartRoundView(), tag: .startRound,
                            selection: $appState.activeScreen
                        ) {
                            MenuButton(title: "Start Round", icon: "flag.fill")
                        }

                        NavigationLink(
                            destination: CourseManagementView(), tag: .manageCourses,
                            selection: $appState.activeScreen
                        ) {
                            MenuButton(title: "Manage Courses", icon: "map")
                        }

                        NavigationLink(
                            destination: PastRoundsView(), tag: .pastRounds,
                            selection: $appState.activeScreen
                        ) {
                            MenuButton(title: "Past Rounds", icon: "list.bullet")
                        }

                        NavigationLink(
                            destination: StatisticsView(), tag: .statistics,
                            selection: $appState.activeScreen
                        ) {
                            MenuButton(title: "Statistics", icon: "chart.bar")
                        }

                        NavigationLink(
                            destination: HandicapView(), tag: .handicap,
                            selection: $appState.activeScreen
                        ) {
                            MenuButton(title: "Handicap", icon: "number")
                        }

                        NavigationLink(
                            destination: AccountView(), tag: .account,
                            selection: $appState.activeScreen
                        ) {
                            MenuButton(title: "Account", icon: "person.circle")
                        }
                    }

                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MenuButton: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.title2)
                .frame(width: 30)
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
}

struct MainMenuBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(
                        #colorLiteral(
                            red: 0.1568627451, green: 0.3137254902, blue: 0.1882352941, alpha: 1)),
                    Color(
                        #colorLiteral(
                            red: 0.2352941176, green: 0.4705882353, blue: 0.2823529412, alpha: 1)),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)

            GeometryReader { geometry in
                Path { path in
                    for index in stride(from: 0, to: geometry.size.width, by: 30) {
                        path.move(to: CGPoint(x: index, y: 0))
                        path.addLine(
                            to: CGPoint(x: index + geometry.size.height, y: geometry.size.height))
                    }
                }
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
    }
}

//git test
