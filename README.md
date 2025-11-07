# Pokémon TCG Browser App 🃏

A Flutter cross-platform mobile application that allows users to browse, search, and view Pokémon trading cards using the official [Pokémon TCG API](https://docs.pokemontcg.io/). The app features a responsive design with a distinctive red frame, black background, and comprehensive search functionality.

## 📱 Features

### Core Functionality
- **Browse All Cards**: View all Pokémon TCG cards ordered by National Pokédex numbers
- **Search & Filter**: Search by card name or National Pokédex number with real-time results
- **Card Details**: Tap any card to view detailed information in a modal dialog
- **Responsive Grid**: Adaptive grid layout based on screen size (1 card per row on <500px, dynamic columns on larger screens)
- **Infinite Scroll**: Automatically loads more cards as you scroll
- **Offline Support**: Basic caching for previously viewed cards

### Design Features
- **Red Frame**: Distinctive red border around the entire app
- **Black Background**: Dark theme throughout the application
- **Card Images as Buttons**: Tap card images to open detailed view
- **Responsive Layout**: Optimized for mobile, tablet, and desktop
- **Accessibility**: Full screen reader support and keyboard navigation

### User Experience
- **Pull to Refresh**: Refresh card list by pulling down
- **Search Bar Toggle**: Toggle search visibility with search icon
- **Escape Key Support**: Press Escape to close search or detail modal
- **Loading States**: Clear loading indicators and error handling
- **Offline Fallback**: Cached data available when offline

## 🛠 Technical Architecture

### State Management
- **Provider Pattern**: Clean separation of concerns with Provider
- **CardListProvider**: Manages card list, search, and loading states
- **API Service**: Dedicated service for Pokémon TCG API integration

### Key Components
- **PokemonCard Model**: Type-safe data model with JSON serialization
- **API Service**: HTTP client with error handling, rate limiting, and caching
- **Card Grid Item**: Reusable card display widget
- **Search Bar**: Debounced search input with clear functionality
- **Detail Dialog**: Modal overlay for card details

### API Integration
- **Base URL**: `https://api.pokemontcg.io/v2/`
- **Authentication**: API key in X-Api-Key header
- **Rate Limiting**: Respects API limits with exponential backoff
- **Field Selection**: Optimized requests with selected fields only
- **Server-side Filtering**: Efficient search using API query parameters

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- VS Code or Android Studio
- Android SDK (for Android development)
- Xcode (for iOS development on macOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pokemon_v2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up API key**
   - The API key is already configured in the `.env` file
   - For production, replace with your own API key from [Pokémon TCG API](https://dev.pokemontcg.io/)

4. **Run the application**
   ```bash
   # For development
   flutter run
   
   # For specific platforms
   flutter run -d chrome    # Web
   flutter run -d android   # Android
   flutter run -d ios       # iOS (macOS only)
   ```

### Building for Release

#### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point with red frame wrapper
├── models/
│   ├── pokemon_card.dart     # Card data model
│   └── api_models.dart       # API response models
├── services/
│   └── api_service.dart      # Pokémon TCG API integration
├── state/
│   └── card_list_provider.dart # State management for card list
├── screens/
│   ├── card_list_screen.dart    # Main grid view screen
│   └── card_detail_screen.dart  # Modal detail view
└── widgets/
    ├── card_grid_item.dart      # Individual card display
    └── search_bar.dart          # Search input widget
```

## 🎮 Usage Guide

### Navigation
1. **Browse Cards**: Scroll through the grid to see all Pokémon cards
2. **Search**: Tap the search icon to toggle search bar
3. **View Details**: Tap any card image to see detailed information
4. **Close Details**: Tap outside the modal or press Escape key
5. **Refresh**: Pull down to refresh or tap the refresh icon

### Search Functionality
- **Text Search**: Type Pokémon name for partial matching
- **Number Search**: Enter Pokédex number for exact matching
- **Real-time Results**: Results update as you type (debounced)
- **Clear Search**: Use the clear button or close search bar

### Responsive Behavior
- **Small Screens** (<500px): 1 card per row
- **Large Screens** (≥500px): Dynamic columns (minimum 250px per card)
- **Touch Targets**: All interactive elements meet accessibility guidelines

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Test Structure
- **Unit Tests**: Model parsing, API service logic
- **Widget Tests**: UI component behavior and accessibility
- **Integration Tests**: End-to-end user flows

## 📦 Dependencies

### Core Dependencies
- **flutter**: Cross-platform UI framework
- **provider**: State management solution
- **http**: HTTP client for API requests
- **cached_network_image**: Efficient image loading and caching
- **flutter_dotenv**: Environment variable management
- **shared_preferences**: Local data persistence

### Development Dependencies
- **flutter_test**: Testing framework
- **mockito**: Mocking for unit tests
- **flutter_lints**: Dart/Flutter linting rules

## 🔒 Security & API Key Management

### API Key Security
- API key stored in `.env` file (excluded from version control)
- Never hardcode API keys in source code
- Use `--dart-define` for production builds
- Consider API key rotation for production applications

### Best Practices
- Environment-specific configurations
- Secure storage for sensitive data
- Rate limiting and error handling
- Input validation and sanitization

## 🌐 Platform Support

### Mobile
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+

### Desktop
- **Windows**: Windows 10+
- **macOS**: macOS 10.14+
- **Linux**: Ubuntu 18.04+

### Web
- **Modern browsers with Flutter Web support**
- **Responsive design for all screen sizes**

## 🎨 Design System

### Color Scheme
- **Primary**: Red (`Colors.red`)
- **Background**: Black (`Colors.black`)
- **Text**: White (`Colors.white`)
- **Secondary Text**: Grey (`Colors.grey`)
- **Accent**: Red with opacity variations

### Typography
- **Headers**: Bold, white text
- **Body**: Regular, white text
- **Captions**: Grey text for secondary information
- **Accessibility**: Sufficient contrast ratios

### Layout Principles
- **Red Frame**: 4px red border around entire app
- **Card Design**: Black background with red borders
- **Responsive Grid**: Dynamic columns based on screen width
- **Touch Targets**: Minimum 48px for accessibility

## 🔧 Configuration

### Environment Variables (.env)
```env
POKEMON_TCG_API_KEY=your_api_key_here
```

### Build Configuration
- **Development**: Debug builds with hot reload
- **Production**: Optimized release builds
- **Web**: PWA-ready configuration

## 📈 Performance Optimizations

### API Optimizations
- **Field Selection**: Request only required fields
- **Pagination**: Load cards in chunks of 250
- **Caching**: Memory and persistent cache for API responses
- **Rate Limiting**: Respect API limits with backoff strategies

### UI Optimizations
- **Image Caching**: Efficient image loading with `cached_network_image`
- **Lazy Loading**: Infinite scroll with automatic loading
- **Widget Optimization**: Efficient rebuilds with Provider
- **Memory Management**: Proper disposal of resources

## 🐛 Troubleshooting

### Common Issues

1. **API Key Errors**
   - Verify `.env` file exists and contains valid API key
   - Check network connectivity
   - Ensure API key has proper permissions

2. **Build Errors**
   - Run `flutter clean && flutter pub get`
   - Verify Flutter SDK version compatibility
   - Check platform-specific requirements

3. **Network Issues**
   - Verify internet connectivity
   - Check firewall settings
   - Consider using VPN if API is blocked

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Run lints and tests
5. Submit pull request

### Code Standards
- Follow Flutter/Dart style guidelines
- Use provided linting configuration
- Write tests for new features
- Document public APIs

## Bruno's modifications

- Modified the search functionality to search for Pokémon by name only. The search query now uses `name:"*$query*"` to perform a fuzzy search on the card name.
- The application now exclusively fetches Pokémon cards by default, filtering out other card types like "Trainer" or "Energy". This is achieved by adding `supertype:pokemon` to all API queries.
- The application fetches data through the following Cloudflare Worker URL: [https://late-glitter-4565.brunolobo-14.workers.dev/](https://late-glitter-4565.brunolobo-14.workers.dev/)

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Pokémon TCG API](https://docs.pokemontcg.io/) for the excellent API
- [Flutter](https://flutter.dev/) for the amazing cross-platform framework
- [Pokémon Company](https://www.pokemon.com/) for the trading card game



**Happy coding! 🚀**

# Pokémon TCG Browser

This project is a Flutter application that allows users to browse Pokémon cards fetched from the Pokémon TCG API. The application uses a Cloudflare Worker to handle CORS issues and fetch data efficiently.



## Features

- Browse Pokémon cards
- Search for specific cards
- View card details

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/esBrunoL/pokemon.git
   ```
2. Navigate to the project directory:
   ```bash
   cd pokemon
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## Hosting

The project is hosted on GitHub Pages. Ensure the repository is set up correctly for deployment.