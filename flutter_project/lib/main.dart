import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'models/log.dart';
import 'models/log_category.dart';
import 'models/day_entry.dart';
import 'providers/log_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/workmanager_callback.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(LogCategoryAdapter());
  Hive.registerAdapter(DayEntryAdapter());
  Hive.registerAdapter(LogAdapter());

  // Open boxes
  await Hive.openBox<Log>('logs');

  // Initialize Workmanager for background tasks
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Enable to see background task logs
  );

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LogProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Year in Pixels',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF98C1A3),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

