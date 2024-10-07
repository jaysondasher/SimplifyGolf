import SwiftUI

class AppState: ObservableObject {
    @Published var activeScreen: ActiveScreen?
}

enum ActiveScreen {
    case mainMenu
    case startRound
    case manageCourses
    case pastRounds
    case statistics
    case handicap
    case account
}
