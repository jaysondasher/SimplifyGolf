// SearchBar.swift
// Simplify Golf
//
// Created by Jayson Dasher on 7/20/24.

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var onCommit: (() -> Void)?

    var body: some View {
        HStack {
            TextField(placeholder, text: $text, onCommit: onCommit ?? {})
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                                onCommit?()
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
        }
    }
}
