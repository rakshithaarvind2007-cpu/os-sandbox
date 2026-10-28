import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 250,
      height: double.infinity,
      color: colors.surface,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.memory_rounded,
                        color: colors.onPrimaryContainer,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'OS Sandbox',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              const Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 16, 10),
                child: Text(
                  'WORKSPACE',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),

              _navItem(
                context,
                index: 0,
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
              ),

              _navItem(
                context,
                index: 1,
                icon: Icons.speed_rounded,
                label: 'CPU Scheduling',
              ),

              _navItem(
                context,
                index: 2,
                icon: Icons.layers_rounded,
                label: 'Page Replacement',
              ),

              _navItem(
                context,
                index: 3,
                icon: Icons.storage_rounded,
                label: 'Memory Management',
              ),

              _navItem(
                context,
                index: 4,
                icon: Icons.lock_rounded,
                label: 'Deadlock',
              ),

              _navItem(
                context,
                index: 5,
                icon: Icons.album_rounded,
                label: 'Disk Scheduling',
              ),

              const SizedBox(height: 24),
              const Divider(),

              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Operating System Simulator',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final colors = Theme.of(context).colorScheme;
    final selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onItemSelected(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: selected
                      ? colors.onPrimaryContainer
                      : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? colors.onPrimaryContainer
                          : colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
