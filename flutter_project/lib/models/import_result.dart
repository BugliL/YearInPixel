class ImportResult {
  final bool success;
  final String message;
  final int logsImported;
  final int logsSkipped;

  ImportResult({
    required this.success,
    required this.message,
    required this.logsImported,
    this.logsSkipped = 0,
  });
}
