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

### **Tournament System & Battle Features**
- **Gym Tournament Screen**: Implemented complete tournament-style battle system with 3-section layout:
  - **Player Team Grid (2x3)**: Displays user's Pokemon team as clickable images on the left side
  - **Battle Arena**: Central combat area with VS display and battle controls
  - **Opponent Team Grid (2x3)**: Shows opponent's Pokemon types (not images) on the right side
- **Sequential Tournament Battles**: Opponents battle in order (1v1, 1v2, 2v1, 2v2, 3v1, 3v2) automatically advancing when player wins
- **Defeated Pokemon Tracking**: Pokemon that lose battles become unavailable for subsequent tournament battles with visual gray mask overlay and "DEFEATED" indicator
- **Draw Battle Mechanics**: When both Pokemon have equal attack power, the battle results in a draw:
  - **Both Pokemon Defeated**: In case of equal attack (e.g., both have 20 attack vs 100 HP), both Pokemon are considered defeated
  - **Visual Indication**: Orange background with handshake icon displays "DRAW! BOTH POKÉMON DEFEATED!"
  - **Tournament Impact**: Player's Pokemon becomes unavailable for future battles, same as a loss
  - **Strategic Element**: Forces players to consider Pokemon with different attack values for tournament progression
- **Team Management Integration**: "Enter a Tournament" button in My Team screen provides direct access to Gym Challenge functionality
- **Battle Screen**: Separate Try-out battle system for individual Pokemon testing with "Keep Going" and "Try Opponent" options for continuous battles

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
  - **Try outs! Button**: Orange button for battle system functionality
  - **Position**: Both buttons placed above "Tap outside to close" instruction
  - **User Feedback**: SnackBar notifications confirm successful adds/removes

### **Advanced Battle System with Type Effectiveness** ⚔️
- **Try Outs Battle Mechanics**: Revolutionary battle system with sophisticated damage calculations:
  - **Simple Attack Comparison**: In Tournament mode, winner determined by direct attack stat comparison
    - Player wins if: `player.attack > opponent.attack`
    - Opponent wins if: `opponent.attack > player.attack`
    - **Draw (Both Defeated)**: If `player.attack = opponent.attack`, both Pokemon are defeated and removed from tournament
  - **Tournament Strategy**: Equal attack values create strategic draws where no Pokemon advances
    - Example: Pokemon A (Attack: 50) vs Pokemon B (Attack: 50) = Both defeated
    - Forces diverse team building with varied attack stats
  - **Type Effectiveness System**: Integrated real Pokemon type matchup data from PokeAPI
    - **Super Effective**: +50% attack bonus (1.5x multiplier) when type advantage
    - **Not Very Effective**: -30% attack reduction (0.7x multiplier) when type disadvantage
    - **No Effect**: Attack becomes 0 when type immunity applies
  - **Visual Feedback**: Color-coded effectiveness messages
    - Green background: "It's super effective!"
    - Red background: "It's not very effective..."
    - Gray background: "It doesn't affect the opponent!"

- **Type Effectiveness Data Integration**:
  - **PokeAPI Type Endpoint**: Fetches comprehensive type relationships from `/type/{type-name}`
  - **Damage Relations**: Complete type matchup data including:
    - `double_damage_to`: Types this Pokemon is super effective against
    - `half_damage_to`: Types this Pokemon is not very effective against
    - `no_damage_to`: Types this Pokemon has no effect on
    - `double_damage_from`: Weaknesses (types super effective against this Pokemon)
    - `half_damage_from`: Resistances (types not very effective against this Pokemon)
    - `no_damage_from`: Immunities (types that have no effect on this Pokemon)
  - **Smart Caching**: Type data cached in both memory and SharedPreferences
  - **Offline Support**: Type effectiveness works offline after initial load
  - **All 18 Types**: Fire, Water, Grass, Electric, Psychic, Ice, Fighting, Poison, Ground, Flying, Bug, Rock, Ghost, Dragon, Dark, Steel, Fairy, Normal

- **Battle Screen Features**:
  - **Player vs Random Opponent**: Selected Pokemon faces random opponent from all 1008+ Pokemon
  - **Interactive Pokemon Cards**: Tap any Pokemon during battle to view full details
  - **Real-Time Stats Display**: Shows effective attack values with type multipliers applied
  - **Battle Results Banner**: Displays winner with detailed breakdown:
    - Winner name and icon (trophy for win, X for loss, scales for draw)
    - Both Pokemon's effective attack vs opponent HP
    - Type effectiveness messages for both combatants
  - **Smart Battle Flow**:
    - **Win**: "Keep going!" button - keep player, get new opponent
    - **Loss**: "Try [opponent name]" button - defeated Pokemon becomes new player
    - **Draw**: "Try again!" button - rematch with new random opponent
  - **Frame & Menu Integration**: Battle screen uses same 2% red border and top menu bar as main app

- **TypeEffectiveness Calculator**:
  - **Damage Multiplier Engine**: Sophisticated calculation system
  - **Multi-Type Support**: Handles Pokemon with dual types correctly
  - **Compound Multipliers**: Stacks type advantages (e.g., Fire vs Grass/Bug = 1.5x × 1.5x = 2.25x)
  - **Effectiveness Messages**: Dynamic battle commentary based on type matchups
  - **Zero Damage Detection**: Properly handles immunity scenarios

- **Battle UI Enhancements**:
  - **ON TRIAL Label**: Player Pokemon highlighted with blue border
  - **OPPONENT Label**: Random opponent with appropriate border coloring
  - **VS Indicator**: Central red circle with white border between combatants
  - **Color-Coded Borders**: Green for winner, red for loser, orange for draw
  - **Loading States**: Circular progress indicators while fetching opponent
  - **Error Handling**: Clear error messages if opponent fetch fails

### **Code Quality & Architecture**
- **Provider Pattern Enhancement**: Added TeamProvider to existing Provider structure
- **Type Effectiveness Models**: New `TypeEffectiveness` and `TypeEffectivenessCalculator` classes
- **API Service Extensions**: Added type data fetching methods with caching
- **Persistent Storage**: Implemented JSON serialization for team data and type effectiveness persistence
- **Error Handling**: Comprehensive try-catch blocks with user-friendly error messages
- **Type Safety**: Full type checking with null safety throughout new features
- **Confirmation Dialogs**: User confirmation required before removing Pokemon from team
- **Async Battle Logic**: Non-blocking type effectiveness loading with fallback to basic calculations
- **Accessibility**: Semantic labels for all new buttons and interactive elements

### **Menu System Refactoring & Code Organization** 🔄
- **Reusable Menu Components**: Complete refactoring to eliminate code duplication across screens:
  - **PokedexTopMenu**: Centralized menu component with dynamic title, optional search functionality, and navigation buttons
  - **PokedexFrameWrapper**: Unified wrapper combining red frame border with reusable top menu
  - **Consistent Navigation**: All screens now use identical menu system with contextual button states (disabled for current screen)
  - **Team Badge Integration**: Dynamic team size indicator works across all screens consistently
  - **Search Integration**: Unified search functionality available where needed through `showSearch` parameter

- **Code Maintainability Improvements**:
  - **Single Source of Truth**: Menu changes now require updates in only one location
  - **Eliminated Duplication**: Removed repetitive Scaffold+AppBar+Container structures from all screens
  - **Consistent Styling**: All screens guaranteed to have identical menu appearance and behavior
  - **Simplified Screen Structure**: Each screen now focuses purely on content with menu handled by wrapper
  - **Type-Safe Parameters**: Dynamic screen titles and search functionality through well-defined widget parameters

- **Screen Updates**: Refactored all major screens to use new menu system:
  - **CardListScreen**: Uses PokedexFrameWrapper with search enabled
  - **BattleScreen**: Completely rewritten to use new menu system, streamlined battle logic
  - **GymScreen**: Updated tournament screen to use unified menu
  - **MyTeamScreen**: Integrated with new reusable menu components
  - **Main App**: Simplified entry point using new component architecture

### **Responsive Tournament Layout & Advanced UI** 📱💻
- **Revolutionary Responsive Design**: Complete redesign of gym tournament screen for optimal experience across all screen sizes:
  - **Fixed 500px Center Container**: Battle area (selected Pokemon vs opponent + VS symbol) maintains consistent width for optimal gameplay focus
  - **Collapsible Side Panels**: Player team (left) and gym team (right) panels automatically collapse on smaller screens to preserve battle area visibility
  - **Intelligent Hover Expansion**: Side panels expand smoothly when hovering mouse over them, providing full team access without permanently consuming screen space
  - **Click-to-Lock Mechanism**: Single click on any side panel locks it in expanded state, second click unlocks - perfect for touch devices and permanent team viewing
  - **Smart Container Scaling**: When screen width falls below minimum requirements, center container scales down proportionally while maintaining usability

- **Adaptive Layout Intelligence**:
  - **Breakpoint Detection**: Automatically switches layout behavior based on available screen width (minimum 620px recommended)
  - **Dynamic Warning System**: Displays informative banner when screen is below optimal size, suggesting exact pixel width needed for best experience
  - **Smooth Animations**: 250ms CSS transitions for all panel expansions/contractions providing polished, professional feel
  - **Touch-Friendly Design**: All interactive elements sized appropriately for both mouse and touch input
  - **Visual Lock Indicators**: Orange border and lock icon clearly show when panels are locked in expanded state

- **Enhanced User Experience**:
  - **Preserved Core Functionality**: All tournament features (sequential battles, defeated Pokemon tracking, team selection) maintained in new responsive layout
  - **Improved Mobile Experience**: Touch devices can easily access team panels without losing battle area focus
  - **Desktop Optimization**: Larger screens benefit from efficient use of space with instant hover access to full team information
  - **Accessibility Enhancements**: Clear visual feedback for all interactive states (collapsed, expanded, locked)
  - **Progressive Enhancement**: Layout degrades gracefully on very small screens while maintaining core tournament functionality

- **Technical Implementation**:
  - **LayoutBuilder Integration**: Uses Flutter's LayoutBuilder for real-time screen size detection and responsive behavior
  - **MouseRegion Hover Detection**: Precise hover state management for desktop/web platforms
  - **GestureDetector Touch Support**: Native touch gesture support for mobile platforms  
  - **AnimatedContainer Transitions**: Smooth, performant animations using Flutter's built-in animation system
  - **State Management**: Separate state tracking for each panel (expanded/collapsed, locked/unlocked)

### **Advanced Tournament Overlay System** 🎮✨
- **Hybrid Layout Intelligence**: Revolutionary dual-mode layout system providing optimal experience for all screen sizes:
  - **Large Screen Mode** (≥1200px): Preserves original classic 3-column tournament layout for desktop users with ample screen space
  - **Responsive Mode** (<1200px): Activates advanced overlay system for smaller screens and mobile devices
  - **Automatic Detection**: Seamlessly switches between modes based on real-time screen width detection

- **Dynamic Team Overlays**: Sophisticated overlay system that expands team information over the central battle area:
  - **Center-Screen Expansion**: Teams overlay expands to cover the selected Pokemon area in the center, maximizing information visibility
  - **Hover Activation**: Mouse hover over collapsed panels triggers smooth overlay expansion without disrupting battle flow
  - **Touch Support**: Native touch gestures for mobile devices with same overlay functionality
  - **Smart Positioning**: Overlays positioned precisely between collapsed side panels (60px margins) for optimal coverage

- **Enhanced Team Visualization**:
  - **Expanded Grid Layout**: Overlay displays teams in 3-column grid (vs 2-column in side panels) for better Pokemon visibility
  - **Detailed Pokemon Cards**: Enhanced cards showing Pokemon images, Pokedex numbers, names, type badges, and status indicators
  - **Visual Status System**: Clear visual feedback for selected Pokemon, defeated Pokemon, current opponent, and waiting opponents
  - **Interactive Selection**: Full Pokemon selection functionality maintained in overlay view with improved visual feedback

- **Professional UI/UX Design**:
  - **Semi-Transparent Overlay**: Black background with 85% opacity preserves battle area context while highlighting team information
  - **Color-Coded Borders**: Blue borders for player team overlay, red for opponent team overlay for instant recognition
  - **Smooth Animations**: 250ms animated transitions for all overlay appearances/disappearances providing polished experience
  - **Header Identification**: Clear "MY TEAM - DETAILED VIEW" and "GYM TEAM - DETAILED VIEW" headers in overlay mode

- **Advanced Interaction Model**:
  - **Non-Intrusive Activation**: Overlays only appear on hover when panels are not locked, preserving battle focus
  - **Lock Bypass**: Locked panels (clicked to stay open) do not trigger overlays, maintaining user's preferred layout choice
  - **Battle Flow Preservation**: All tournament mechanics (sequential battles, defeat tracking, Pokemon selection) work identically in overlay mode
  - **Responsive Fallback**: Graceful degradation to side panels when overlays cannot be displayed

---

## 📱 Features   (All this was created by copilot, using claude sonnet 4, most of my interventions were improvements)

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