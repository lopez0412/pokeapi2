//
//  PhysicalStatView.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/30/25.
//
import SwiftUI

struct PhysicalStatView: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accent)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondaryText)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.primaryText)
        }
    }
}
