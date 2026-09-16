import 'package:flutter/material.dart';
import 'module_placeholder_page.dart';
import '../member3/memory/memory_page.dart';
import '../member3/deadlock/deadlock_page.dart';
import '../member3/disk/disk_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OS Sandbox'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Operating System Simulator',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Learn and visualize Operating System algorithms',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            const Text(
              'CPU Scheduling',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildModuleCard(
              context,
              title: 'CPU Scheduling',
              description: 'FCFS, SJF, Priority, Round Robin and SRTF',
              icon: Icons.memory,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModulePlaceholderPage(
                      title: 'CPU Scheduling',
                      description: 'FCFS, SJF, Priority, Round Robin and SRTF',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Memory & Process Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildModuleCard(
              context,
              title: 'Page Replacement',
              description: 'FIFO, LRU and Optimal Page Replacement',
              icon: Icons.layers,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModulePlaceholderPage(
                      title: 'Page Replacement',
                      description: 'FIFO, LRU and Optimal Page Replacement',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildModuleCard(
              context,
              title: 'Memory Management',
              description: 'First Fit, Best Fit and Worst Fit',
              icon: Icons.storage,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MemoryPage()),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildModuleCard(
              context,
              title: 'Deadlock',
              description: "Banker's Algorithm",
              icon: Icons.lock,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DeadlockPage()),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Disk Scheduling',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildModuleCard(
              context,
              title: 'Disk Scheduling',
              description: 'FCFS, SSTF, SCAN, C-SCAN, LOOK and C-LOOK',
              icon: Icons.album,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DiskPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 40),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(description, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
