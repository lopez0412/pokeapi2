//
//  StatBar.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/30/25.
//
import SwiftUI

struct StatBar: View {
    let stat: PokemonStat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(stat.displayName)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primaryText)
                    .frame(width: 80, alignment: .leading)
                
                Text("\(stat.baseStat)")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.secondaryText)
                    .frame(width: 40, alignment: .trailing)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(colorForStat(stat.baseStat))
                            .frame(width: geometry.size.width * stat.percentage, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
    }
    
    private func colorForStat(_ value: Int) -> Color {
        switch value {
        case 0..<50: return Color.red
        case 50..<80: return Color.orange
        case 80..<100: return Color.yellow
        case 100..<120: return Color.green
        default: return Color.blue
        }
    }
}
