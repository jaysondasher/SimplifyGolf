import SwiftUI

struct NavigationViewWithVersion<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationView {
            ZStack {
                content

                VStack {
                    Spacer()
                    HStack {
                        BuildVersionView()
                        Spacer()
                    }
                    .padding(.leading, 10)
                    .padding(.bottom, 5)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
