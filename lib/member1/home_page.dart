
import 'package:flutter/material.dart';

import 'module_placeholder_page.dart';
import 'widgets/module_card.dart';
import 'widgets/sidebar.dart';

import '../member3/memory/memory_page.dart';
import '../member3/deadlock/deadlock_page.dart';
import '../member3/disk/disk_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 1:
        return const ModulePlaceholderPage(
          title: 'CPU Scheduling',
          description: 'FCFS, SJF, Priority, Round Robin and SRTF',
        );
      case 2:
        return const ModulePlaceholderPage(
          title: 'Page Replacement',
          description: 'FIFO, LRU and Optimal Page Replacement',
        );
      case 3:
        return const MemoryPage();
      case 4:
        return const DeadlockPage();
      case 5:
        return const DiskPage();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary,
                      colors.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.memory_rounded,
                      size: 42,
                      color: colors.onPrimary,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Operating System Simulator',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Learn, explore and visualize Operating System algorithms.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            color: colors.onPrimary
                                .withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _sectionTitle('CPU Scheduling', Icons.speed_rounded),
              const SizedBox(height: 12),

              ModuleCard(
                title: 'CPU Scheduling',
                description:
                    'FCFS, SJF, Priority, Round Robin and SRTF',
                icon: Icons.memory_rounded,
                onTap: () => _selectPage(1),
              ),

              const SizedBox(height: 28),

              _sectionTitle(
                'Memory & Process Management',
                Icons.layers_rounded,
              ),
              const SizedBox(height: 12),

              ModuleCard(
                title: 'Page Replacement',
                description:
                    'FIFO, LRU and Optimal Page Replacement',
                icon: Icons.layers_rounded,
                onTap: () => _selectPage(2),
              ),

              ModuleCard(
                title: 'Memory Management',
                description: 'First Fit, Best Fit and Worst Fit',
                icon: Icons.storage_rounded,
                onTap: () => _selectPage(3),
              ),

              ModuleCard(
                title: 'Deadlock',
                description: "Banker's Algorithm",
                icon: Icons.lock_rounded,
                onTap: () => _selectPage(4),
              ),

              const SizedBox(height: 28),

              _sectionTitle('Disk Scheduling', Icons.album_rounded),
              const SizedBox(height: 12),

              ModuleCard(
                title: 'Disk Scheduling',
                description:
                    'FCFS, SSTF, SCAN, C-SCAN, LOOK and C-LOOK',
                icon: Icons.album_rounded,
                onTap: () => _selectPage(5),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 22, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }

  String _pageTitle() {
    const titles = [
      'Dashboard',
      'CPU Scheduling',
      'Page Replacement',
      'Memory Management',
      'Deadlock',
      'Disk Scheduling',
    ];

    return titles[_selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle()),
      ),

      // On smaller screens, the sidebar is available as a drawer.
      drawer: isWide
          ? null
          : Drawer(
              child: SafeArea(
                child: Sidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    Navigator.pop(context);
                    _selectPage(index);
                  },
                ),
              ),
            ),

      body: Row(
        children: [
          // On wider screens, keep the sidebar permanently visible.
          if (isWide)
            Sidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _selectPage,
            ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey<int>(_selectedIndex),
                child: _buildSelectedPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
