//
//  AuthenticationView.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 7/18/24.
//


import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @State private var isSignUp = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image("AppIcon") // Changed from AppLogo to AppIcon
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            Text("Simplify Golf")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(isSignUp ? "Sign Up" : "Sign In") {
                if isSignUp {
                    viewModel.signUp()
                } else {
                    viewModel.signIn()
                }
            }
            .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
            
            Button(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
                isSignUp.toggle()
            }
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all))
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthenticationViewModel())
    }
}
