import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_io/io.dart';
import '../models/log.dart';

// Import web helper for download functionality
import 'import_export_web_helper.dart' if (dart.library.io) 'import_export_stub.dart';

class ImportExportService {
  // Export logs to JSON format
  static Future<bool> exportLogs(List<Log> logs) async {
    try {
      // Create export data structure
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'logs': logs.map((log) => log.toJson()).toList(),
      };

      // Convert to JSON string with pretty formatting
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final fileName = '_export_${DateTime.now().millisecondsSinceEpoch}.json';

      if (kIsWeb) {
        // Web platform: trigger download
        downloadFile(jsonString, fileName);
        return true;
      } else {
        // Desktop/Mobile: use directory picker
        final directoryPath = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select folder to save export',
        );

        if (directoryPath == null) {
          return false; // User cancelled
        }

        // Create file in selected directory
        final file = File('$directoryPath/$fileName');
        
        // Write to file
        await file.writeAsString(jsonString);

        return true;
      }
    } catch (e) {
      print('Error exporting logs: $e');
      return false;
    }
  }

  // Import logs from JSON file
  static Future<List<Log>?> importLogs() async {
    try {
      // Pick a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        withData: kIsWeb, // On web, we need the bytes
      );

      if (result == null || result.files.isEmpty) {
        return null; // User cancelled
      }

      String jsonString;
      
      if (kIsWeb) {
        // On web, read from bytes
        final bytes = result.files.single.bytes;
        if (bytes == null) {
          throw Exception('Could not read file');
        }
        jsonString = utf8.decode(bytes);
      } else {
        // On desktop/mobile, read from path
        final filePath = result.files.single.path;
        if (filePath == null) {
          return null;
        }
        final file = File(filePath);
        jsonString = await file.readAsString();
      }

      // Parse JSON
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Validate format
      if (!jsonData.containsKey('logs') || !jsonData.containsKey('version')) {
        throw FormatException('Invalid export file format');
      }

      // Parse logs
      final logsJson = jsonData['logs'] as List;
      final logs = logsJson
          .map((logJson) => Log.fromJson(logJson as Map<String, dynamic>))
          .toList();

      return logs;
    } catch (e) {
      print('Error importing logs: $e');
      rethrow;
    }
  }

  // Validate imported data structure
  static bool validateImportData(Map<String, dynamic> data) {
    try {
      // Check required fields
      if (!data.containsKey('version') || !data.containsKey('logs')) {
        return false;
      }

      // Check version compatibility
      final version = data['version'] as String;
      if (version != '1.0') {
        print('Warning: Import file version $version may not be compatible');
      }

      // Validate logs array
      final logs = data['logs'];
      if (logs is! List) {
        return false;
      }

      // Basic validation of first log if exists
      if (logs.isNotEmpty) {
        final firstLog = logs[0] as Map<String, dynamic>;
        if (!firstLog.containsKey('id') || 
            !firstLog.containsKey('name') ||
            !firstLog.containsKey('categories')) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Validation error: $e');
      return false;
    }
  }
}
