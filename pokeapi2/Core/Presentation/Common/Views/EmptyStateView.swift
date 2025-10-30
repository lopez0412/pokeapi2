//
//  EmptyStateView.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import SwiftUI

/// Reusable empty state view
struct EmptyStateView: View {
    let message: String
    var icon: String = "tray"
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    EmptyStateView(message: "No Pokemon found")
}
