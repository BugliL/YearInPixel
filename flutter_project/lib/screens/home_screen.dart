import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';
import '../widgets/log_card.dart';
import 'log_detail_screen.dart';
import 'log_editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 24,
                height: 24,
                errorBuilder: (_, __, ___) => Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.grid_4x4, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
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
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {
                      // Settings/Menu
                    },
                    icon: const Icon(Icons.more_horiz),
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: provider.logs.length,
          itemBuilder: (context, index) {
            final log = provider.logs[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LogDetailScreen(log: log),
                  ),
                );
              },
              child: LogCard(
                log: log,
                year: provider.selectedYear,
              ),
            );
          },
        );
      },
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
                icon: const Icon(Icons.home, color: Color(0xFF98D8C8)),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_outline, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
