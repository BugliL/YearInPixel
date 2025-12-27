# Plan: Year in Pixels Tracker App

Transform the default Flutter counter app into a comprehensive year-tracking application with multiple customizable log types (mood, health, habits, etc.), pixel-grid calendar visualization, and note-taking capabilities.

## Steps

1. **Define data models and architecture** - Create models for `Log` (with name, emoji, color scheme), `DayEntry` (date, color/value, optional note), and `LogCategory`. Set up a repository pattern with local storage using `shared_preferences` or `hive` for persistence. Build a state management layer using `provider` or `riverpod`.

2. **Build the home screen** - Implement the main dashboard in lib/main.dart showing a grid of log cards with year selector (2025), each card displaying a miniature pixel grid. Add FAB for creating new logs, navigation to profile screen, and handle empty state.

3. **Create the pixel calendar detail view** - Build the detailed log screen showing full-year grid (12 months × 31 days), month headers (J F M A M J J A S O N D), day numbers (1-31), and color legend on the right. Implement tap-to-select day functionality with color picker/category selector dialog, and handle different calendar layouts (leap years, months with varying days).

4. **Implement note-taking and data entry** - Create modal/dialog for adding notes to specific days, showing selected date, current color/value, text input field, and save/cancel actions. Enable long-press on pixels to view/edit notes, and display note indicators on the calendar grid.

5. **Add log customization and persistence** - Build log creation/editing screen for naming logs with emoji, defining color schemes (2-8 colors with labels), choosing tracking categories, and setting log type (rating, binary, health symptoms, etc.). Implement data serialization/deserialization, CRUD operations for logs and entries, and export/import functionality.

6. **Polish UI and navigation** - Implement navigation structure with back buttons, bottom navigation bar (home/profile icons visible in screenshots), theme matching the pastel aesthetic from images (green, pink, purple, coral, blue backgrounds). Add animations for pixel selection, smooth transitions between screens, and statistics/overview features.

## Further Considerations

1. **Data storage approach** - Use `hive` for efficient local storage with typed boxes, or `shared_preferences` for simpler JSON persistence, or `sqflite` for relational data? Hive recommended for performance with 365+ entries per log.

2. **Dependencies to add** - `provider`/`riverpod` for state management, `table_calendar` or custom grid widget, `hive`/`hive_flutter` for storage, `intl` for date formatting, `fl_chart` for optional statistics views?

3. **Custom log templates** - Pre-populate common logs (mood, period, health, anxiety, training) as shown in images, or start empty and let users create from scratch?
