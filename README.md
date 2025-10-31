# 🎮 Pokédex iOS App

A modern, production-ready iOS application built with **Clean Architecture**, **MVVM**, and **SwiftUI** that showcases Pokémon data from the [PokéAPI](https://pokeapi.co/).

[![Swift Version](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS Version](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://www.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📸 Screenshots

| Pokemon List | Pokemon Detail |
|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/c6fe2f0e-ae6a-49ea-b15e-397192f70ad9" alt="Pokemon List" width="250"/> | <img src="https://github.com/user-attachments/assets/ce9c8cbc-3f01-4d30-a635-f83381e02e4e" alt="Pokemon Detail" width="250"/> |
| Browse all Pokemon with beautiful cards | Notifications |

| Search Functionality | Stats Visualization |
|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/24bee613-da96-4d03-bed2-1a977e0dc3a7" alt="Search" width="250"/> | <img src="https://github.com/user-attachments/assets/080bb2b3-5d83-47d1-be3f-00f7166990ff" alt="Stats View" width="250"/> |
| Real-time search  | Animated stat bars  |

---

## ✨ Features

### Core Functionality
- 📋 **Pokemon List** - Browse Pokemon with images, names, and types
- 🔍 **Real-time Search** - Debounced search with instant filtering
- 📱 **Detail View** - Rich Pokemon information with stats, abilities, and physical attributes
- 🔊 **Audio Player** - Play Pokemon cries directly from the app
- 💾 **Offline Support** - Core Data persistence for offline access
- 🔄 **Pull to Refresh** - Refresh Pokemon data from API
- 🎨 **Dynamic Type Colors** - Beautiful gradients based on Pokemon types

### Advanced Features
- 🔔 **Push Notifications** - Get notified when new Pokemon are added
- ⏰ **Background Fetch** - Automatic Pokemon updates every 15 minutes (iOS-controlled)
- 📊 **Stats Visualization** - Animated stat bars with color-coded values
- 🎭 **Haptic Feedback** - Tactile response for better UX
- 🌓 **Dark Mode Support** - Automatic light/dark theme adaptation

---

## 🏗️ Architecture

This project demonstrates **senior-level iOS development** practices with a focus on **Clean Architecture** and **SOLID principles**.

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                     PRESENTATION                        │
│  (Views, ViewModels, Coordinators - SwiftUI)            │
│  • PokemonListView, PokemonDetailView                   │
│  • PokemonListViewModel (MVVM)                          │
│  • Coordinators (Navigation)                            │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                      DOMAIN                             │
│  (Business Logic, Entities, Use Cases)                  │
│  • Pokemon, PokemonStat, PokemonType                    │
│  • FetchPokemonListUseCase                              │
│  • BackgroundFetchUseCase                               │
│  • Repository Protocols                                 │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                       DATA                              │
│  (Repositories, Data Sources, DTOs)                     │
│  • PokemonRepository (Network)                          │
│  • LocalStorageRepository (Core Data)                   │
│  • NetworkClient (URLSession)                           │
│  • DTOs (API Response Models)                           │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                  INFRASTRUCTURE                         │
│  (Framework-specific implementations)                   │
│  • CoreDataStack                                        │
│  • NotificationManager                                  │
│  • BackgroundTaskManager                                │
│  • AppLogger                                            │
└─────────────────────────────────────────────────────────┘
```

### Architecture Patterns

#### 1. **MVVM (Model-View-ViewModel)**
- **View**: SwiftUI views that observe ViewModels
- **ViewModel**: `@Published` properties with Combine for reactive updates
- **Model**: Domain entities (Pokemon, PokemonStat)

```swift
// Example: PokemonListViewModel
@MainActor
final class PokemonListViewModel: ObservableObject {
    @Published var pokemon: [Pokemon] = []
    @Published var isLoading: Bool = false
    @Published var searchQuery: String = ""
    
    private let fetchPokemonUseCase: FetchPokemonListUseCase
    
    func loadPokemon() {
        Task {
            await fetchPokemon()
        }
    }
}
```

#### 2. **Coordinator Pattern**
Manages navigation flow, keeping ViewModels free of navigation logic.

```swift
final class PokemonListCoordinator: Coordinator {
    func start() -> some View {
        let viewModel = PokemonListViewModel(...)
        return PokemonListView(viewModel: viewModel, coordinator: self)
    }
    
    func showPokemonDetail(pokemon: Pokemon) -> some View {
        PokemonDetailView(pokemon: pokemon)
    }
}
```

#### 3. **Repository Pattern**
Abstracts data sources (API, Database) behind protocols.

```swift
protocol PokemonRepositoryProtocol {
    func fetchPokemonList(offset: Int, limit: Int) async throws -> [Pokemon]
}

final class PokemonRepository: PokemonRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    // Implementation...
}
```

#### 4. **Use Case Pattern**
Encapsulates business logic in reusable, testable units.

```swift
final class FetchPokemonListUseCase {
    func execute(offset: Int, limit: Int) async throws -> [Pokemon] {
        // Cache-first strategy
        if !forceRefresh && await localRepository.hasStoredData() {
            return try await localRepository.fetchAllPokemon()
        }
        // Fetch from API and cache
    }
}
```

---

## 🎯 SOLID Principles

### ✅ **S**ingle Responsibility Principle
Each class has one reason to change:
- `PokemonRepository` → Only handles API requests
- `LocalStorageRepository` → Only handles Core Data operations
- `PokemonListViewModel` → Only handles presentation logic

### ✅ **O**pen/Closed Principle
Code is open for extension, closed for modification:
- Protocol-based design allows adding new features without changing existing code
- New Pokemon types can be added to enum without modifying existing logic

### ✅ **L**iskov Substitution Principle
Any implementation can replace its abstraction:
- `MockPokemonRepository` can replace `PokemonRepository` in tests
- All repositories implement protocols, enabling seamless substitution

### ✅ **I**nterface Segregation Principle
Clients depend only on methods they use:
- `PokemonRepositoryProtocol` - Only API methods
- `LocalStorageRepositoryProtocol` - Only storage methods
- Small, focused protocols instead of one large interface

### ✅ **D**ependency Inversion Principle
Depend on abstractions, not concretions:
- ViewModels depend on `UseCases` (abstractions)
- UseCases depend on `RepositoryProtocols` (abstractions)
- Easy to swap implementations for testing

```swift
// High-level module depends on abstraction
final class FetchPokemonListUseCase {
    private let pokemonRepository: PokemonRepositoryProtocol  // ← Protocol
    private let localRepository: LocalStorageRepositoryProtocol  // ← Protocol
}
```

---

## 🔄 Background Fetch

### Implementation
Implements both **modern (BGTaskScheduler)** and **legacy (UIApplication)** background fetch APIs for maximum compatibility.

```swift
// Modern API (iOS 13+)
BGTaskScheduler.shared.register(
    forTaskWithIdentifier: "com.pokeapi2.fetchPokemon",
    using: nil
) { task in
    self.handleBackgroundFetch(task: task as! BGAppRefreshTask)
}

// Legacy API (iOS 7+)
func application(_ application: UIApplication,
                performFetchWithCompletionHandler completionHandler: ...) {
    // Fetch new Pokemon
}
```

### How It Works
1. **Initial Load**: App fetches first 5 Pokemon
2. **Background Fetch**: iOS triggers fetch based on usage patterns
3. **Incremental Updates**: Fetches 5 new Pokemon each time
4. **Offset Tracking**: Persists offset in UserDefaults
5. **Notification**: User receives notification about new Pokemon

### Testing Background Fetch
```bash
# Simulator: Trigger manually via debug menu
Debug → Simulate Background Fetch

# Or use manual trigger button in app
```

---

## 💾 Data Persistence

### Core Data Implementation
- **Entity**: `PokemonEntity` with all attributes
- **Storage**: Stats stored as JSON string for flexibility
- **Migration**: Lightweight migration enabled
- **Performance**: Background context for save operations

### Caching Strategy
1. **Cache-First**: Check local storage before API call
2. **Force Refresh**: Pull-to-refresh bypasses cache
3. **Background Sync**: Updates cache automatically
4. **Search**: Queries local database for instant results

---

## 🧪 Testing

### Unit Tests Coverage
- ✅ **26+ Unit Tests** covering critical logic
- ✅ **Repository Tests** - Storage operations
- ✅ **Use Case Tests** - Business logic with mocks
- ✅ **ViewModel Tests** - State management
- ✅ **Background Fetch Tests** - Offset tracking

### Test Architecture
```swift
// Mock objects for dependency injection
final class MockPokemonRepository: PokemonRepositoryProtocol {
    var mockPokemonList: [Pokemon] = []
    var shouldThrowError = false
    // Test implementation...
}
```

Run tests: `⌘ + U`

---

## 🎨 UI/UX Design

### Design System
- **Typography**: San Francisco (system font) with semantic sizing
- **Colors**: Dynamic colors based on Pokemon types
- **Spacing**: Consistent 8px grid system
- **Shadows**: Subtle depth for cards and elements

### Gradients
Each Pokemon card features a gradient based on its type(s):
- Fire → Red/Orange gradient
- Water → Blue gradient
- Grass/Poison → Green/Purple gradient

### Animations
- Card entrance animations
- Shimmer loading states
- Haptic feedback on interactions
- Smooth transitions

### Accessibility
- Dynamic Type support
- VoiceOver labels
- High contrast colors
- Proper semantic structure

---

## 🛠️ Tech Stack

### Core
- **Language**: Swift 5.9
- **UI Framework**: SwiftUI
- **Minimum iOS**: 15.0
- **Architecture**: Clean Architecture + MVVM

### Networking
- **URLSession** - Native HTTP client
- **async/await** - Modern concurrency
- **Codable** - JSON parsing

### Persistence
- **Core Data** - Local database
- **UserDefaults** - Simple key-value storage

### Reactive Programming
- **Combine** - Reactive framework for search debouncing

### Background Tasks
- **BGTaskScheduler** - Modern background execution
- **UIApplication Background Fetch** - Legacy support

### Audio
- **AVFoundation** - Audio playback for Pokemon cries

### Testing
- **XCTest** - Unit testing framework
- **Mock Objects** - Test doubles for isolation

---

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 15.0+
- Swift 5.9+

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/pokeapi2.git
cd pokeapi2
```

2. **Open in Xcode**
```bash
open pokeapi2.xcodeproj
```

3. **Build and Run**
- Select your target device/simulator
- Press `⌘ + R`

### Configuration

#### Background Fetch Setup
1. Enable **Background Modes** capability
2. Check **Background fetch** and **Background processing**
3. Add to `Info.plist`:
```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.pokeapi2.fetchPokemon</string>
</array>
```

#### Notifications Setup
- Notification permissions are requested automatically on first launch
- User can enable/disable in iOS Settings

---

## 📊 Performance

- **First Load**: ~2-3 seconds (fetches 5 Pokemon with details)
- **Search**: Real-time (queries local database)
- **Background Fetch**: Minimal battery impact (iOS-controlled)
- **Memory**: Efficient image caching with AsyncImage
- **Storage**: ~5KB per Pokemon (including stats)

---

## 🔮 Future Enhancements

- [ ] Filter by Pokemon generation
- [ ] Filter by type
- [ ] Favorite Pokemon
- [ ] Pokemon comparison
- [ ] Shiny Pokemon variants
- [ ] Evolution chain visualization
- [ ] Moves and abilities details
- [ ] Battle simulator
- [ ] Dark mode customization
- [ ] iPad optimization with split view

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **PokéAPI** - [https://pokeapi.co/](https://pokeapi.co/)
- **Pokemon Sprites** - [https://github.com/PokeAPI/sprites](https://github.com/PokeAPI/sprites)
- **Pokemon Cries** - [https://github.com/PokeAPI/cries](https://github.com/PokeAPI/cries)

---

## 📧 Contact

**Javier Lorenzana** -  lopez.javier0412@gmail.com

**Project Link**: [https://github.com/lopez0412/pokeapi2](https://github.com/lopez0412/pokeapi2)

---

## 🌟 Show Your Support

If you found this project helpful, please give it a ⭐️!

---

**Built with ❤️ using Clean Architecture, SOLID Principles, and Modern Swift**
