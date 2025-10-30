//
//  Color+Extensions.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import SwiftUI

extension Color {
    /// Creates a Color from a hex string (e.g., "#FF5733")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    // MARK: - Pokemon Type Colors (Enhanced)
    
    struct PokemonType {
        static let normal = Color(hex: "#A8A878")
        static let fire = Color(hex: "#F08030")
        static let water = Color(hex: "#6890F0")
        static let electric = Color(hex: "#F8D030")
        static let grass = Color(hex: "#78C850")
        static let ice = Color(hex: "#98D8D8")
        static let fighting = Color(hex: "#C03028")
        static let poison = Color(hex: "#A040A0")
        static let ground = Color(hex: "#E0C068")
        static let flying = Color(hex: "#A890F0")
        static let psychic = Color(hex: "#F85888")
        static let bug = Color(hex: "#A8B820")
        static let rock = Color(hex: "#B8A038")
        static let ghost = Color(hex: "#705898")
        static let dragon = Color(hex: "#7038F8")
        static let dark = Color(hex: "#705848")
        static let steel = Color(hex: "#B8B8D0")
        static let fairy = Color(hex: "#EE99AC")
    }
    
    // MARK: - Gradient Generator
        
        /// Creates a gradient based on Pokemon type
        static func gradientFor(type: pokeapi2.PokemonType) -> LinearGradient {
            let baseColor = colorFor(type: type)
            let lighterColor = baseColor.opacity(0.7)
            
            return LinearGradient(
                colors: [lighterColor, baseColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        /// Creates a gradient for multiple types
        static func gradientFor(types: [pokeapi2.PokemonType]) -> LinearGradient {
            guard !types.isEmpty else {
                return LinearGradient(
                    colors: [PokemonType.normal.opacity(0.7), PokemonType.normal],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            if types.count == 1 {
                return gradientFor(type: types[0])
            }
            
            // Multiple types - blend them
            let colors = types.map { colorFor(type: $0) }
            return LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
    
    /// Returns solid color for Pokemon type
    static func colorFor(type: pokeapi2.PokemonType) -> Color {
        switch type {
        case .normal: return PokemonType.normal
        case .fire: return PokemonType.fire
        case .water: return PokemonType.water
        case .electric: return PokemonType.electric
        case .grass: return PokemonType.grass
        case .ice: return PokemonType.ice
        case .fighting: return PokemonType.fighting
        case .poison: return PokemonType.poison
        case .ground: return PokemonType.ground
        case .flying: return PokemonType.flying
        case .psychic: return PokemonType.psychic
        case .bug: return PokemonType.bug
        case .rock: return PokemonType.rock
        case .ghost: return PokemonType.ghost
        case .dragon: return PokemonType.dragon
        case .dark: return PokemonType.dark
        case .steel: return PokemonType.steel
        case .fairy: return PokemonType.fairy
        }
    }
    
    // MARK: - Fallback Initializer
    
    /// Creates a color with a fallback if the named color doesn't exist
    init(_ name: String, fallback: Color) {
        if let _ = UIColor(named: name) {
            self.init(name)
        } else {
            self = fallback
        }
    }
}
