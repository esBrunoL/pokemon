# Pokédex App 🃏

A Flutter cross-platform mobile application that allows users to browse, search, and view Pokémon using the official [PokeAPI](https://pokeapi.co/docs/v2). The app features a responsive design with a distinctive red frame, black background, and comprehensive search functionality.

## Bruno's Modifications 🔧

### **Complete App Redesign & Rebranding**
- **Rebranded to Pokédex**: Changed app name from "Pokémon Browser" to "Pokédex" throughout the application for better thematic consistency and authentic Pokédex experience.
- **Enhanced Frame Layout**: Upgraded from basic 4px border to 5% screen margin frame on sides and bottom, creating more immersive viewing experience with proper spacing from screen edges.
- **Revolutionary Menu Bar**: Converted top frame into functional menu bar containing:
  - **Pokédex Title**: Branded name on the left side
  - **Expandable Search**: Animated search functionality in the center that expands to new line when activated
  - **Battle Simulator**: Placeholder button for future battle functionality
  - **Refresh Button**: Easy access refresh functionality on the right

### **Advanced Search Experience**
- **Animated Search Expansion**: Implemented smooth search animation that expands the menu bar height from 60px to 100px when search is activated, providing better UX than overlay approaches.
- **Integrated Menu Design**: Search functionality seamlessly integrated into menu bar rather than separate overlay, maintaining clean design consistency.
- **Enhanced User Messages**: Updated loading message to "Your pokédx is waking up..." and error message to "Your pokédex lost contact with the server, try again later" for better thematic immersion.

### **Search Performance Optimization**
- **Smart Name-Based Search**: Revolutionized search algorithm to eliminate slow performance and 404 errors for partial queries. The new system:
  - **Preloads Pokemon Names**: Fetches complete list of 1008+ Pokemon names from PokeAPI on first search
  - **Client-Side Filtering**: Filters Pokemon names locally using partial matching (e.g., "pika" matches "pikachu")
  - **Targeted Detail Fetching**: Only requests detailed Pokemon data for names that match the search query
  - **Error Elimination**: Completely removes 404 errors that occurred when searching partial names
  - **Performance Boost**: Dramatically faster search response times by avoiding unnecessary API calls
- **Contextual Loading Messages**: Displays "waiting for pokédex server..." during search operations vs standard loading messages for regular browsing.

### **Complete API Overhaul**
- **API Migration**: Completely migrated from Pokémon TCG API to the official PokeAPI (pokeapi.co). This provides access to comprehensive Pokémon data including stats, abilities, types, height, weight, and official artwork.

- **Simplified Architecture**: Removed the need for API keys, environment variables, and proxy servers. PokeAPI is free, open, and doesn't require authentication.

### **Data Model Enhancements**
- **Enhanced Data Model**: Updated the PokemonCard model to include rich Pokémon data:
  - Individual stats (HP, Attack, Defense, Special Attack, Special Defense, Speed) with visual progress bars
  - Multiple abilities per Pokémon with proper formatting
  - Type information (Fire, Water, Grass, etc.) with color coding
  - Physical characteristics (height in meters, weight in kilograms)
  - Base experience and Pokédex numbers

### **Dependency Cleanup**
- **Removed Dependencies**: Eliminated flutter_dotenv dependency since no environment variables are needed. Cleaned up .env files and API key management code.
- **Removed Proxy**: Deleted the Node.js proxy server (proxy folder) since PokeAPI doesn't have CORS restrictions and works seamlessly in web browsers.

### **Data Management**
- **Removed All Mock Data**: Completely eliminated mock data fallbacks to ensure the application exclusively uses live PokeAPI data. This guarantees users always see authentic, up-to-date Pokémon information.
- **API-Only Architecture**: The app now fails gracefully with proper error messages when API is unavailable, rather than showing outdated mock data.
- **Fixed API Query Format**: Corrected state management to use PokeAPI's direct search format instead of legacy TCG API query syntax (removed `supertype:pokemon` filters).

### **Architecture Improvements**
- **Simplified Component Structure**: Removed complex search overlays and integrated all functionality into clean menu bar design.
- **Enhanced State Management**: Streamlined Provider pattern usage by removing unnecessary query transformation methods.
- **Clean Separation of Concerns**: Menu bar handles search/navigation, screen focuses purely on Pokémon display.

### **UI/UX Improvements**
- **Revolutionary Layout Design**: 
  - **5% Frame Margins**: Professional layout with 5% margins on sides and bottom, 0% on top for menu bar
  - **Menu Bar Integration**: Top area converted to functional menu bar instead of static frame
  - **Responsive Search Animation**: Smooth height transitions when search is activated/deactivated
  - **Battle Simulator Placeholder**: Ready for future battle system implementation

- **Enhanced Visual Experience**: 
  - **Updated Card Components**: Card grid items now display Pokémon ID, types (color-coded), and primary ability
  - **Comprehensive Detail Screens**: Show full Pokémon information including interactive stat bars
  - **Color-coded Stats**: HP=green, Attack=red, Defense=blue, etc. for easy identification
  - **EV Indicators**: Effort Value indicators for competitive players

- **Improved Search & Navigation**: 
  - **Integrated Search**: Search functionality built into menu bar rather than overlay
  - **Real-time Results**: Search by Pokémon names and Pokédex numbers directly from PokeAPI's endpoints
  - **Thematic Messages**: Custom loading and error messages that fit the Pokédex theme
  - **Consistent Branding**: Updated all "TCG Card" references to "Pokémon" throughout the application

### **Battle System Integration**
- **Battle Screen Implementation**: Added fully functional battle system from pokemon_v3 project:
  - **Random Pokemon Selection**: Fetches two random Pokemon from PokeAPI for head-to-head battles
  - **HP-Based Combat**: Winner determined by comparing HP stats between Pokemon
  - **Visual Battle Display**: Side-by-side Pokemon cards with VS indicator and winner declaration
  - **Battle Statistics**: Shows HP values, types, and Pokemon images during battle
  - **New Battle Button**: Instantly generates new random matchups
  - **Connected to Menu Bar**: Battle simulator button (lightning icon) now fully functional

- **Enhanced Pokemon Model**: Added battle-ready properties to PokemonCard:
  - `hp` getter extracts HP stat from stats array
  - `hpValue` alias for battle compatibility
  - Ensures all Pokemon have valid HP values for battle calculations

- **API Service Extensions**: Added `getRandomCards()` method with:
  - Random Pokemon ID generation from 898+ Pokemon pool
  - Fallback to popular Pokemon (Pikachu, Charmander, etc.) if random fails
  - Validation to ensure Pokemon have valid HP and images before use

### **Team Management System**
- **My Team Feature**: Complete team building system with persistent storage:
  - **Team Provider**: State management for up to 6 Pokemon team members
  - **Local Storage**: Team persists between app sessions using SharedPreferences
  - **Add to Team**: Dedicated button in Pokemon detail view to add Pokemon to team
  - **Team Counter**: Shows current team size (e.g., "3/6") throughout the app
  - **Team Full Protection**: Prevents adding more than 6 Pokemon with visual feedback

- **My Team Screen**: Dedicated screen for team management:
  - **Grid Layout**: 2-column responsive grid displaying team members
  - **Pokemon Cards**: Shows image, Pokedex number, name, and type badges
  - **Remove Functionality**: Each Pokemon has "Remove from Team" button with confirmation dialog
  - **Empty State**: Friendly message when team is empty with guidance to add Pokemon
  - **Detail Navigation**: Tap any team Pokemon to view full details (same as main Pokedex)

- **Tournament Integration Points**: Preparation for future tournament system:
  - **Tournament Entry Button**: Prominently placed at top of My Team screen
  - **Secondary Tournament Button**: Available in Pokemon detail view for quick access
  - **Team Size Validation**: Tournament buttons show team count and disabled when team is empty
  - **Future-Ready**: Placeholder messages indicate "Tournament feature coming soon!"

- **Menu Bar Update**: Replaced refresh button with team management:
  - **Team Icon**: Group/people icon represents My Team feature
  - **Badge Indicator**: Orange circular badge shows current team count
  - **Quick Access**: Direct navigation to My Team screen from any page
  - **Visual Feedback**: Badge updates in real-time as Pokemon are added/removed

- **Enhanced Detail Screen**: Added team management buttons:
  - **Add to Team Button**: Green button below stats, shows team capacity (e.g., "3/6")
  - **Smart States**: Button disabled when Pokemon already in team or team is full
  - **Enter Tournament Button**: Orange button for future tournament functionality
  - **Position**: Both buttons placed above "Tap outside to close" instruction
  - **User Feedback**: SnackBar notifications confirm successful adds/removes

### **Code Quality & Architecture**
- **Provider Pattern Enhancement**: Added TeamProvider to existing Provider structure
- **Persistent Storage**: Implemented JSON serialization for team data persistence
- **Error Handling**: Comprehensive try-catch blocks with user-friendly error messages
- **Type Safety**: Full type checking with null safety throughout new features
- **Confirmation Dialogs**: User confirmation required before removing Pokemon from team
- **Accessibility**: Semantic labels for all new buttons and interactive elements

---

## 📱 Features

### Core Functionality
- **Browse All Pokémon**: View all Pokémon ordered by National Pokédex numbers
- **Search & Filter**: Search by Pokémon name or Pokédex number with real-time results
- **Pokémon Details**: Tap any Pokémon to view detailed information including stats, abilities, and types
- **Responsive Grid**: Adaptive grid layout based on screen size (1 card per row on <500px, dynamic columns on larger screens)
- **Infinite Scroll**: Automatically loads more Pokémon as you scroll
- **Offline Support**: Basic caching for previously viewed Pokémon

### Design Features
- **Red Frame**: Distinctive red border around the entire app
- **Black Background**: Dark theme throughout the application
- **Pokémon Images as Buttons**: Tap Pokémon images to open detailed view
- **Responsive Layout**: Optimized for mobile, tablet, and desktop
- **Accessibility**: Full screen reader support and keyboard navigation

### User Experience
- **Pull to Refresh**: Refresh Pokémon list by pulling down
- **Search Bar Toggle**: Toggle search visibility with search icon
- **Escape Key Support**: Press Escape to close search or detail modal
- **Loading States**: Clear loading indicators and error handling
- **Offline Fallback**: Cached data available when offline

## 🛠 Technical Architecture

### State Management
- **Provider Pattern**: Clean separation of concerns with Provider
- **CardListProvider**: Manages Pokémon list, search, and loading states
- **API Service**: Dedicated service for PokeAPI integration

### Key Components
- **PokemonCard Model**: Type-safe data model with JSON serialization for Pokémon data
- **API Service**: HTTP client with error handling, rate limiting, and caching
- **Card Grid Item**: Reusable Pokémon display widget
- **Search Bar**: Debounced search input with clear functionality
- **Detail Dialog**: Modal overlay for Pokémon details

### API Integration
- **Base URL**: `https://pokeapi.co/api/v2/`
- **No Authentication**: PokeAPI is free and open, no API key required
- **Rate Limiting**: Respects API limits with exponential backoff
- **Efficient Requests**: Fetches individual Pokémon data as needed
- **Local Search**: Search by name or Pokédex number

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

3. **Run the application**
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
│   ├── pokemon_card.dart     # Pokémon data model with stats, types, abilities
│   └── api_models.dart       # API response models
├── services/
│   └── api_service.dart      # PokeAPI integration
├── state/
│   └── card_list_provider.dart # State management for Pokémon list
├── screens/
│   ├── card_list_screen.dart    # Main grid view screen
│   └── card_detail_screen.dart  # Modal detail view
└── widgets/
    ├── card_grid_item.dart      # Individual Pokémon display
    └── search_bar.dart          # Search input widget
```

## 🎮 Usage Guide

### Navigation
1. **Browse Pokémon**: Scroll through the grid to see all Pokémon
2. **Search**: Tap the search icon to toggle search bar
3. **View Details**: Tap any Pokémon image to see detailed information
4. **Close Details**: Tap outside the modal or press Escape key
5. **Refresh**: Pull down to refresh or tap the refresh icon

### Search Functionality
- **Text Search**: Type Pokémon name for partial matching
- **Number Search**: Enter Pokédex number for exact matching
- **Real-time Results**: Results update as you type (debounced)
- **Clear Search**: Use the clear button or close search bar

### Responsive Behavior
- **Small Screens** (<500px): 1 Pokémon per row
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
- **shared_preferences**: Local data persistence

### Development Dependencies
- **flutter_test**: Testing framework
- **mockito**: Mocking for unit tests
- **flutter_lints**: Dart/Flutter linting rules

## 🔒 Security & Privacy

### Data Collection
- No personal data collection
- No tracking or analytics
- Uses publicly available Pokémon data only

### Offline Support
- Local caching of Pokémon data for offline viewing
- No sensitive data stored locally
- Cache can be cleared through app settings

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

### Build Configuration
- **Development**: Debug builds with hot reload
- **Production**: Optimized release builds
- **Web**: PWA-ready configuration

## 📈 Performance Optimizations

### API Optimizations
- **Direct PokeAPI Integration**: No intermediary services or mock data - direct communication with PokeAPI
- **Efficient Pagination**: Load Pokémon in optimized chunks using PokeAPI's limit/offset system
- **Smart Caching**: Memory and persistent cache for API responses to reduce network requests
- **Rate Limiting**: Respects API limits with exponential backoff strategies
- **Graceful Failures**: Proper error handling when API is unavailable (no mock data fallback)

### UI Optimizations
- **Image Caching**: Efficient image loading with `cached_network_image`
- **Lazy Loading**: Infinite scroll with automatic loading
- **Widget Optimization**: Efficient rebuilds with Provider
- **Memory Management**: Proper disposal of resources

## 🐛 Troubleshooting

### Common Issues

1. **Network/API Errors**
   - Verify internet connectivity
   - Check if PokeAPI (pokeapi.co) is accessible
   - Retry the request after a brief wait

2. **Build Errors**
   - Run `flutter clean && flutter pub get`
   - Verify Flutter SDK version compatibility
   - Check platform-specific requirements

3. **Performance Issues**
   - Clear app cache and restart
   - Check available storage space
   - Ensure stable internet connection

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

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [PokeAPI](https://pokeapi.co/) for the excellent free and open Pokémon API
- [Flutter](https://flutter.dev/) for the amazing cross-platform framework
- [Pokémon Company](https://www.pokemon.com/) for creating the Pokémon universe

**Happy coding! 🚀**