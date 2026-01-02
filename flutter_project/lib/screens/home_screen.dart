import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../providers/log_provider.dart';
import '../widgets/log_card.dart';
import 'log_detail_screen.dart';
import 'log_editor_screen.dart';
import 'settings_screen.dart';
import 'all_logs_grid_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8D4E8), // Pastel purple background
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildLogGrid(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LogEditorScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF98D8C8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Consumer<LogProvider>(
            builder: (context, provider, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      provider.setSelectedYear(provider.selectedYear - 1);
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    '${provider.selectedYear}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      provider.setSelectedYear(provider.selectedYear + 1);
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogGrid(BuildContext context) {
    return Consumer<LogProvider>(
      builder: (context, provider, _) {
        if (provider.logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No logs yet',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to create your first log',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ReorderableGridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: provider.logs.length,
          onReorder: (oldIndex, newIndex) {
            provider.reorderLogs(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final log = provider.logs[index];
            return _buildLogCard(context, log, log.id);
          },
        );
      },
    );
  }

  Widget _buildLogCard(BuildContext context, log, String key) {
    return GestureDetector(
      key: ValueKey(key),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LogDetailScreen(log: log),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji icon
            Text(
              log.emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            // Log name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                log.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.home),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllLogsGridScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.grid_view),
                tooltip: 'All Logs Grid',
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
              )
            ],
          ),
        ),
      ),
    );
  }
}
