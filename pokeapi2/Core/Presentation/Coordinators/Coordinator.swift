//
//  Coordinator.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import SwiftUI

/// Base protocol for all coordinators
/// Coordinators handle navigation flow, keeping ViewModels clean
@MainActor
protocol Coordinator: AnyObject {
    associatedtype ContentView: View
    
    /// Returns the root view for this coordinator
    @ViewBuilder func start() -> ContentView
}
