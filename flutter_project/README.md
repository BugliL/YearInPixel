# Year in Pixels - Flutter App

A comprehensive year-tracking application that allows you to visualize your entire year in pixels. Track mood, health, habits, anxiety, period, training, reading, and more with customizable color-coded pixel calendars.

## Features

- **Multiple Custom Logs**: Create unlimited tracking logs for different aspects of your life
- **Year-at-a-Glance**: View your entire year in a pixel grid format (12 months × 31 days)
- **Color-Coded Categories**: Each log can have 2-8 customizable categories with colors
- **Note Taking**: Add notes to any day with long-press functionality
- **Pre-loaded Templates**: Includes sample logs for:
  - Rate my day (5-star rating)
  - Health log (tracking symptoms)
  - Anxiety log (5 levels)
  - Period tracker
  - Training log (distance tracking)
  - Reading log

## Getting Started

### Prerequisites
- Flutter SDK (>= 3.10.4)
- Dart SDK
- Chrome (for web) or macOS/iOS device

### Installation

1. Navigate to the flutter_project directory:
```bash
cd flutter_project
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For Chrome/Web
flutter run -d chrome

# For macOS
flutter run -d macos

# For Android
flutter run -d <android-device-id>
```

## Architecture

The app follows a clean architecture pattern with:

- **Models**: Data models with Hive storage adapters
  - `Log`: Container for a tracking log with categories and entries
  - `LogCategory`: Category with label and color
  - `DayEntry`: Individual day entry with category and optional note

- **Providers**: State management using Provider package
  - `LogProvider`: Manages all logs and CRUD operations

- **Screens**:
  - `HomeScreen`: Dashboard with all log cards
  - `LogDetailScreen`: Full year pixel calendar view
  - `LogEditorScreen`: Create/edit logs and categories

- **Widgets**:
  - `LogCard`: Mini pixel grid preview card
  - `DayEntryDialog`: Entry selection and note-taking dialog

## Data Persistence

The app uses **Hive** for local storage:
- All data is stored locally on the device
- Data persists between app sessions
- Fast and efficient NoSQL database

## Customization

### Creating a New Log
1. Tap the + (FAB) button on the home screen
2. Enter a name and emoji for your log
3. Add categories with custom names and colors
4. Save the log

### Adding Entries
1. Tap on any log card to open the detail view
2. Tap on any day pixel to open the entry dialog
3. Select a category color
4. Optionally add a note
5. Save the entry

### Navigation
- **Left/Right arrows**: Navigate between years
- **Back button**: Return to previous screen
- **Long press**: View/edit notes on entries

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Hive**: Fast, key-value database
- **Provider**: State management
- **Intl**: Date formatting
- **Material Design 3**: Modern UI components

## License

This project is a demonstration app for year tracking in pixel format.

