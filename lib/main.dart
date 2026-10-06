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
      title: 'OS Cyber Sandbox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.purpleAccent,
          surface: Color(0xFF1E293B),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B).withOpacity(0.8),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.cyanAccent.withOpacity(0.3), width: 1),
          ),
        ),
      ),
      home: const CyberDashboard(),
    );
  }
}

class CyberDashboard extends StatelessWidget {
  const CyberDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '⚡ OS ALGORITHM SANDBOX',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.cyanAccent),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.cyan.shade900.withOpacity(0.5), Colors.purple.shade900.withOpacity(0.5)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.terminal_rounded, color: Colors.cyanAccent, size: 36),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MEMBER 3 SIMULATION HUB',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Interactive visual execution suites for OS memory, disk, and deadlock control.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildCyberCard(
              context,
              title: 'Memory Allocator',
              tagline: 'FIRST FIT • BEST FIT • WORST FIT',
              description: 'Dynamic RAM segment mapping with internal fragmentation analysis.',
              icon: Icons.memory_rounded,
              accentColor: Colors.cyanAccent,
              page: const MemoryPage(),
            ),
            const SizedBox(height: 16),
            _buildCyberCard(
              context,
              title: 'Deadlock Analyzer',
              tagline: "BANKER'S SAFETY ALGORITHM",
              description: 'Resource request matrix solver & animated safe execution sequence tracker.',
              icon: Icons.shield_rounded,
              accentColor: Colors.purpleAccent,
              page: const DeadlockPage(),
            ),
            const SizedBox(height: 16),
            _buildCyberCard(
              context,
              title: 'Disk Trajectory Engine',
              tagline: 'SCAN • C-SCAN • LOOK • SSTF • FCFS',
              description: 'Custom canvas cylinder track graph with live head trajectory sweep.',
              icon: Icons.disc_full_rounded,
              accentColor: Colors.tealAccent,
              page: const DiskPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberCard(
    BuildContext context, {
    required String title,
    required String tagline,
    required String description,
    required IconData icon,
    required Color accentColor,
    required Widget page,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor, width: 1.5),
                ),
                child: Icon(icon, color: accentColor, size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tagline,
                      style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_arrow_rounded, color: accentColor, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
