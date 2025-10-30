//
//  AppCoordinator.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import Foundation
import SwiftUI

/// Main app coordinator that manages the entire app navigation flow
final class AppCoordinator: Coordinator {
    func start() -> some View {
        PokemonListCoordinator().start()
    }
}
