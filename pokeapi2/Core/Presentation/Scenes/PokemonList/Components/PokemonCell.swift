//
//  PokemonCell.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import SwiftUI

/// Reusable cell component for displaying a Pokemon in the list
struct PokemonCell: View {
    let viewData: PokemonViewData
    
    var body: some View {
        HStack(spacing: 24) {
            // Pokemon Info
            VStack(alignment: .leading, spacing: 8) {
                Text("#\(viewData.id)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
                
                Text(viewData.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !viewData.types.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(viewData.types, id: \.self) { type in
                            TypeBadge(type: type)
                        }
                    }
                }
            }.padding(.leading, 16)
            
            Spacer()
            
            // Pokemon Image
            AsyncImage(url: URL(string: viewData.imageURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 80, height: 80)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .padding()
            .background(
                ZStack {
                    Image("pokeball_bg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .opacity(0.15)
                
                }
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.colorFor(type: viewData.types[0]))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

/// Badge component for Pokemon types
struct TypeBadge: View {
    let type: PokemonType
    var cardType: PokemonType? = nil // el tipo principal del card
    var style: BadgeStyle = .default
    
    enum BadgeStyle {
        case `default`
        case light
        case outlined
    }
    
    var body: some View {
        Label {
            Text(type.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
        } icon: {
            Image(type.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
        }
        .labelStyle(.automatic)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.50), radius: 2, x: 0, y: 1)
    }
    
    private var backgroundColor: Color {
        if style == .outlined {
            return .clear
        }
        if type == cardType {
            // Usa fondo más claro si coincide con el tipo principal del card
            return Color.white.opacity(0.2)
        } else {
            return Color.colorFor(type: type)
        }
    }
    
    private var foregroundColor: Color {
        if style == .outlined {
            return Color.colorFor(type: type)
        }
        if type == cardType {
            return .white
        } else {
            return .white
        }
    }
    
    private var borderColor: Color {
        if style == .outlined {
            return Color.colorFor(type: type)
        } else {
            return .clear
        }
    }
}


// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        PokemonCell(viewData: PokemonViewData(
            id: 1,
            name: "Bulbasaur",
            imageURL: Constants.baseSpriteShinyURLString + "1.png",
            types: [.grass, .poison]
        ))
        
        PokemonCell(viewData: PokemonViewData(
            id: 25,
            name: "Pikachu",
            imageURL: Constants.baseSpriteURLString + "25.png",
            types: [.electric]
        ))
    }
    .padding()
}
