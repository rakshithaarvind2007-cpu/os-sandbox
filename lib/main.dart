import 'package:flutter/material.dart';
import 'member3/memory/memory_page.dart';
import 'member3/deadlock/deadlock_page.dart';
import 'member3/disk/disk_page.dart';

void main() {
  runApp(const OSSandboxApp());
}

class OSSandboxApp extends StatelessWidget {
  const OSSandboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OS Simulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operating System Simulator'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Member 3 Modules',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              title: 'Memory Management',
              description: 'First Fit, Best Fit, and Worst Fit visual allocations',
              icon: Icons.memory,
              color: Colors.blue,
              page: const MemoryPage(),
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              context,
              title: 'Deadlock Detection',
              description: "Banker's Algorithm & Safe Sequence Visualizer",
              icon: Icons.lock_clock,
              color: Colors.orange,
              page: const DeadlockPage(),
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              context,
              title: 'Disk Scheduling',
              description: 'FCFS, SSTF, SCAN, C-SCAN, LOOK, and C-LOOK head movement',
              icon: Icons.disc_full,
              color: Colors.teal,
              page: const DiskPage(),
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
    required Color color,
    required Widget page,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          radius: 28,
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(description),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}