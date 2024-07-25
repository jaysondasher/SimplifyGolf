import SwiftUI
import Firebase

struct AccountView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showingDeleteConfirmation = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            MainMenuBackground()

            VStack(spacing: 20) {
                Text("Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                if let email = authViewModel.getCurrentUserEmail() {
                    Text("Email: \(email)")
                        .foregroundColor(.white)
                } else {
                    Text("Signed in with Apple")
                        .foregroundColor(.white)
                }

                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Text("Delete Account")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationBarTitle("Account", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
            Text("Back")
                .foregroundColor(.white)
        })
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Account"),
                message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteAccount()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func deleteAccount() {
        authViewModel.deleteAccount { result in
            switch result {
            case .success:
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Error deleting account: \(error.localizedDescription)")
                // You might want to show an error alert here
            }
        }
    }
}
