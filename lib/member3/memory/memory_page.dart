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
        .map((value) => int.parse(value.trim()))
        .where((value) => value > 0)
        .toList();
  }

  void runAlgorithm() {
    try {
      final blocks = parseInput(blocksController.text);
      final processes = parseInput(processesController.text);

      if (blocks.isEmpty || processes.isEmpty) {
        throw Exception();
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
          content: Text(
            'Please enter valid positive numbers separated by commas.',
          ),
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
        title: const Text('Memory Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Memory Blocks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedAlgorithm,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'First Fit',
                  child: Text('First Fit'),
                ),
                DropdownMenuItem(
                  value: 'Best Fit',
                  child: Text('Best Fit'),
                ),
                DropdownMenuItem(
                  value: 'Worst Fit',
                  child: Text('Worst Fit'),
                ),
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
                child: const Text('Run Algorithm'),
              ),
            ),
            const SizedBox(height: 25),
            if (result != null) buildResult(),
          ],
        ),
      ),
    );
  }

  Widget buildResult() {
    final allocation = result!.allocation;
    final remainingBlocks = result!.remainingBlocks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$selectedAlgorithm Result',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          allocation.length,
          (index) {
            final block = allocation[index];

            return Card(
              child: ListTile(
                title: Text('Process ${index + 1}'),
                subtitle: Text(
                  block == -1
                      ? 'Not Allocated'
                      : 'Allocated to Block ${block + 1}',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 15),
        const Text(
          'Remaining Block Sizes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          remainingBlocks.length,
          (index) {
            return Text(
              'Block ${index + 1}: ${remainingBlocks[index]}',
              style: const TextStyle(fontSize: 16),
            );
          },
        ),
      ],
    );
  }
}