//
//  PokemonDetailView.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import SwiftUI
import AVFoundation

/// Detail view for a single Pokemon with premium design
struct PokemonDetailView: View {
    @StateObject private var viewModel = PokemonDetailViewModel()
    let pokemon: Pokemon
    
    var body: some View {
        ZStack {
            // Background gradient
            Color.gradientFor(types: pokemon.types ?? [.normal])
                .ignoresSafeArea()
            
                VStack(spacing: 0) {
                    // Top section with Pokemon image and info
                    headerSection
                        .padding(.top, 20)
                    
                    // White content card
                    contentCard
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        ZStack {
            // Large watermark text in background
            Text(pokemon.displayName.uppercased())
                .font(.system(size: 50, weight: .black))
                .foregroundColor(.white.opacity(0.1))
                .frame(maxWidth: .infinity)
                .offset(y: -20)
            
            VStack(spacing: 16) {
                // Pokemon number and name
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("#\(String(format: "%03d", pokemon.id))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(pokemon.displayName)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Types
                        if let types = pokemon.types, !types.isEmpty {
                            HStack(spacing: 8) {
                                ForEach(types, id: \.self) { type in
                                    TypeBadge(type: type, style: .light)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                
                // Pokemon Image
                AsyncImage(url: URL(string: pokemon.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 200, height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 220, height: 220)
                            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white.opacity(0.5))
                    @unknown default:
                        EmptyView()
                    }
                }
                .onTapGesture {
                    viewModel.isTouched.toggle()
                        viewModel.playCry(from: pokemon.cryURL)
                }
                .sensoryFeedback(.success, trigger: viewModel.isTouched)
            }
        }
        .frame(height: 450)
    }
    
    // MARK: - Content Card
    
    private var contentCard: some View {
        VStack(spacing: 0) {
            // Content
            VStack(spacing: 20) {
                physicalStatsView
                baseStatsView
                abilitiesView
                Spacer()
            }
            .padding(.vertical, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
        )
    }
    
    // MARK: - Physical Stats
    
    private var physicalStatsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 40) {
                StatItem(
                    label: "Height",
                    value: pokemon.height != nil ? "\(Double(pokemon.height!) / 10) m" : "N/A",
                    icon: "arrow.up.arrow.down"
                )
                
                StatItem(
                    label: "Weight",
                    value: pokemon.weight != nil ? "\(Double(pokemon.weight!) / 10) kg" : "N/A",
                    icon: "scalemass"
                )
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Base Stats
    
    private var baseStatsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Base Stats")
                .font(.headline)
                .foregroundColor(.primaryText)

            let statsViewData = viewModel.makeStats(from: pokemon.stats)

            if !statsViewData.isEmpty {
                VStack(spacing: 12) {
                    ForEach(statsViewData) { stat in
                        ModernStatBar(stat: stat)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Abilities
    
    private var abilitiesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Abilities")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            if let abilities = pokemon.abilities, !abilities.isEmpty {
                HStack(spacing: 12) {
                    ForEach(abilities, id: \.self) { ability in
                        Text(ability.capitalized)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(Color.colorFor(type: pokemon.types?.first ?? .normal))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.colorFor(type: pokemon.types?.first ?? .normal).opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .primaryText : .gray)
            
            if isSelected {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accent)
                    .frame(height: 3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.gray)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primaryText)
            }
        }
    }
}

struct ModernStatBar: View {
    let stat: PokemonDetailViewModel.StatViewData
    
    var body: some View {
        HStack(spacing: 12) {
            Text(stat.name)
                .font(.caption.weight(.medium))
                .foregroundColor(.secondaryText)
                .frame(width: 70, alignment: .leading)
            
            Text(String(format: "%03d", stat.value))
                .font(.caption.weight(.bold))
                .foregroundColor(.primaryText)
                .frame(width: 35)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(stat.color)
                        .frame(width: geometry.size.width * stat.percentage, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}


// MARK: - Preview

#Preview {
    NavigationView {
        PokemonDetailView(pokemon: Pokemon(
            id: 7,
            name: "squirtle",
            url: Constants.baseURLString + "pokemon/7",
            types: [.water],
            height: 5,
            weight: 90,
            abilities: ["torrent", "rain-dish"],
            stats: [
                PokemonStat(name: "hp", baseStat: 44, effort: 0),
                PokemonStat(name: "attack", baseStat: 48, effort: 0),
                PokemonStat(name: "defense", baseStat: 65, effort: 1),
                PokemonStat(name: "special-attack", baseStat: 50, effort: 0),
                PokemonStat(name: "special-defense", baseStat: 64, effort: 0),
                PokemonStat(name: "speed", baseStat: 43, effort: 0)
            ],
            cryURL: "https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/7.ogg"
        ))
    }
}
