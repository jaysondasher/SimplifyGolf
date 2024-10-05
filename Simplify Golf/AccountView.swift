import Firebase
import SwiftUI

struct AccountView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var userViewModel = UserViewModel()
    @State private var showingDeleteConfirmation = false
    @State private var email: String = ""
    @State private var showEmailInput = false
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
                } else if showEmailInput {
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding()

                    Button("Save Email") {
                        userViewModel.saveUserEmail(email: email)
                        showEmailInput = false
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
                    Button("Add Email") {
                        showEmailInput = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
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
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                Text("Back")
                    .foregroundColor(.white)
            }
        )
        .onAppear {
            if authViewModel.getCurrentUserEmail() == nil {
                showEmailInput = true
            }
        }
        .alert(
            isPresented: Binding<Bool>(
                get: { userViewModel.errorMessage != nil },
                set: { _ in userViewModel.errorMessage = nil }
            )
        ) {
            Alert(
                title: Text("Error"),
                message: Text(userViewModel.errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Account"),
                message: Text(
                    "Are you sure you want to delete your account? This action cannot be undone."),
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
                userViewModel.errorMessage = "Error deleting account: \(error.localizedDescription)"
            }
        }
    }
}
