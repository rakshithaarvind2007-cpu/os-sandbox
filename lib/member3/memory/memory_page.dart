import 'package:flutter/material.dart';
import 'memory_algorithms.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  final TextEditingController blocksController =
      TextEditingController(text: '100, 500, 200, 300, 600');
  final TextEditingController processesController =
      TextEditingController(text: '212, 417, 112, 426');

  String selectedAlgorithm = 'First Fit';
  MemoryAllocationResult? result;

  List<int> parseInput(String input) {
    return input
        .split(',')
        .map((value) => int.tryParse(value.trim()) ?? 0)
        .where((value) => value > 0)
        .toList();
  }

  void runAlgorithm() {
    try {
      final blocks = parseInput(blocksController.text);
      final processes = parseInput(processesController.text);

      if (blocks.isEmpty || processes.isEmpty) {
        throw Exception('Inputs cannot be empty.');
      }

      MemoryAllocationResult newResult;
      if (selectedAlgorithm == 'First Fit') {
        newResult = firstFit(blocks, processes);
      } else if (selectedAlgorithm == 'Best Fit') {
        newResult = bestFit(blocks, processes);
      } else {
        newResult = worstFit(blocks, processes);
      }

      setState(() {
        result = newResult;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid positive numbers separated by commas.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    blocksController.dispose();
    processesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Management Simulator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Memory Blocks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: blocksController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Example: 100, 500, 200, 300, 600',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Process Sizes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: processesController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Example: 212, 417, 112, 426',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Algorithm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedAlgorithm,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'First Fit', child: Text('First Fit')),
                DropdownMenuItem(value: 'Best Fit', child: Text('Best Fit')),
                DropdownMenuItem(value: 'Worst Fit', child: Text('Worst Fit')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedAlgorithm = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: runAlgorithm,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Run Algorithm', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 25),
            if (result != null) buildVisualResult(),
          ],
        ),
      ),
    );
  }

  Widget buildVisualResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$selectedAlgorithm Visual Allocation',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...List.generate(result!.blocks.length, (blockIndex) {
          final blockState = result!.blocks[blockIndex];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Block ${blockIndex + 1} (Total Size: ${blockState.originalSize})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        children: blockState.segments.map((seg) {
                          Color color;
                          if (seg.isAllocated) {
                            color = Colors.blue.shade600;
                          } else if (seg.isFragmented) {
                            color = Colors.orange.shade400;
                          } else {
                            color = Colors.grey.shade300;
                          }

                          return Expanded(
                            flex: seg.size,
                            child: Container(
                              color: color,
                              alignment: Alignment.center,
                              child: Text(
                                seg.label,
                                style: TextStyle(
                                  color: seg.isAllocated || seg.isFragmented
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (result!.unallocatedProcesses.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Unallocated Processes: ${result!.unallocatedProcesses.map((p) => 'P$p').join(', ')}',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
