# Import/Export System

## Overview
The import/export system allows users to backup and transfer their logs between devices or app installations.

## Features

### Export
- Exports all logs to a JSON file
- Includes all log data: categories, entries, dates, and notes
- File format includes version information for compatibility
- File can be shared via any sharing method supported by the device

### Import
- Import logs from a JSON file
- Two merge strategies:
  - **Merge**: Updates existing logs with imported data, merging entries by date
  - **Keep Existing**: Skips logs that already exist, only imports new logs

### Data Format
The export file is a JSON file with the following structure:
```json
{
  "version": "1.0",
  "exportDate": "2025-12-27T12:00:00.000Z",
  "logs": [
    {
      "id": "log_id",
      "name": "log name",
      "emoji": "⭐",
      "categories": [
        {
          "label": "category name",
          "color": 4294198070
        }
      ],
      "entries": [
        {
          "date": "2025-12-27T00:00:00.000Z",
          "categoryIndex": 0,
          "note": "optional note"
        }
      ],
      "createdAt": "2025-12-27T12:00:00.000Z"
    }
  ]
}
```

## Usage

### Exporting Logs
1. Open the app and tap the menu icon (three dots) in the top right
2. Tap "Settings"
3. Under "Data Management", tap "Export Logs"
4. Choose where to save or share the file
5. The file will be named `_export_[timestamp].json`

### Importing Logs
1. Open the app and tap the menu icon (three dots) in the top right
2. Tap "Settings"
3. Under "Data Management", tap "Import Logs"
4. Choose import strategy:
   - **Merge**: Updates existing logs with imported data
   - **Keep Existing**: Only imports new logs
5. Select the JSON file to import
6. Review the import summary

## Files Modified/Created

### New Files
- `lib/services/import_export_service.dart` - Core import/export logic
- `lib/screens/settings_screen.dart` - Settings UI with import/export buttons
- `lib/models/import_result.dart` - Result model for import operations

### Modified Files
- `lib/providers/log_provider.dart` - Added import/export methods
- `lib/screens/home_screen.dart` - Added navigation to settings
- `pubspec.yaml` - Added file_picker and share_plus dependencies

## Technical Details

### Dependencies
- **file_picker**: Allows users to select files for import
- **share_plus**: Enables sharing export files
- **path_provider**: Gets temporary directory for export files

### Merge Strategy
When importing with merge enabled:
1. Existing log entries are preserved in a map by date
2. Imported entries are added to the map (overwriting duplicates)
3. Categories are updated if they differ
4. Log name and emoji are updated to match imported version

### Error Handling
- Validates file format before import
- Checks for required fields in JSON
- Reports detailed results (imported, updated, skipped counts)
- Shows user-friendly error messages
