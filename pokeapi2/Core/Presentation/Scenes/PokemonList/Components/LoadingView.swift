//
//  LoadingView.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import SwiftUI

/// Reusable loading view with progress indicator
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                
                Text("Loading Pokemon...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 10)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    LoadingView()
}
