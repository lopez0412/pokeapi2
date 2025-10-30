//
//  PokemonDetailViewModel.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//
import SwiftUI
import AVFoundation

final class PokemonDetailViewModel: ObservableObject {
    @Published var isPlayingCry = false
    @Published var isTouched = false
    private var audioPlayer: AVPlayer?

    func playCry(from urlString: String?) {
        guard let urlString, let audioURL = URL(string: urlString) else { return }
        isPlayingCry = true

        let playerItem = AVPlayerItem(url: audioURL)
        audioPlayer = AVPlayer(playerItem: playerItem)

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.isPlayingCry = false
        }

        audioPlayer?.play()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.isPlayingCry = false
        }
    }

    func formattedHeight(_ height: Int?) -> String {
        guard let height else { return "N/A" }
        return "\(Double(height) / 10) m"
    }

    func formattedWeight(_ weight: Int?) -> String {
        guard let weight else { return "N/A" }
        return "\(Double(weight) / 10) kg"
    }
}

extension PokemonDetailViewModel {
    struct StatViewData: Identifiable {
        let id = UUID()
        let name: String
        let value: Int
        let percentage: CGFloat
        let color: Color
    }

    func makeStats(from stats: [PokemonStat]?) -> [StatViewData] {
        guard let stats else { return [] }

        let maxStat = max(stats.map(\.baseStat).max() ?? 100, 100)
        return stats.map { stat in
            StatViewData(
                name: stat.displayName,
                value: stat.baseStat,
                percentage: CGFloat(stat.baseStat) / CGFloat(maxStat),
                color: color(for: stat.baseStat)
            )
        }
    }

    private func color(for value: Int) -> Color {
        switch value {
        case 0..<50: return Color(hex: "#FF5959")
        case 50..<80: return Color(hex: "#FFA500")
        case 80..<100: return Color(hex: "#FFD700")
        case 100..<120: return Color(hex: "#7EC845")
        default: return Color(hex: "#4A90E2")
        }
    }
}


