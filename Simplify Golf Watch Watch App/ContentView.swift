//
//  ContentView.swift
//  Simplify Golf Watch Watch App
//
//  Created by Jayson Dasher on 5/15/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                Text("Simplify Golf")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
