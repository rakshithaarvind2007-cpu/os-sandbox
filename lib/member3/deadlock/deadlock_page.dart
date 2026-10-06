import 'package:flutter/material.dart';
import 'banker_algorithm.dart';

class DeadlockPage extends StatefulWidget {
  const DeadlockPage({super.key});

  @override
  State<DeadlockPage> createState() => _DeadlockPageState();
}

class _DeadlockPageState extends State<DeadlockPage> {
  final TextEditingController allocationController = TextEditingController(
    text: '0 1 0; 2 0 0; 3 0 2; 2 1 1; 0 0 2',
  );

  final TextEditingController maximumController = TextEditingController(
    text: '7 5 3; 3 2 2; 9 0 2; 2 2 2; 4 3 3',
  );

  final TextEditingController availableController = TextEditingController(
    text: '3 3 2',
  );

  BankersResult? result;

  List<List<int>> parseMatrix(String input) {
    return input
        .split(';')
        .map(
          (row) => row
              .trim()
              .split(RegExp(r'\s+'))
              .map((value) => int.parse(value))
              .toList(),
        )
        .toList();
  }

  List<int> parseVector(String input) {
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .map((value) => int.parse(value))
        .toList();
  }

  void runBankersAlgorithm() {
    try {
      final allocation = parseMatrix(allocationController.text);
      final maximum = parseMatrix(maximumController.text);
      final available = parseVector(availableController.text);

      if (allocation.isEmpty ||
          maximum.isEmpty ||
          available.isEmpty ||
          allocation.length != maximum.length) {
        throw Exception();
      }

      final resourceCount = available.length;

      for (final row in allocation) {
        if (row.length != resourceCount) {
          throw Exception();
        }
      }

      for (final row in maximum) {
        if (row.length != resourceCount) {
          throw Exception();
        }
      }

      for (int i = 0; i < allocation.length; i++) {
        for (int j = 0; j < resourceCount; j++) {
          if (allocation[i][j] > maximum[i][j]) {
            throw Exception();
          }
        }
      }

      final newResult = bankersAlgorithm(
        allocation: allocation,
        maximum: maximum,
        available: available,
      );

      setState(() {
        result = newResult;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid matrices with matching dimensions.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    allocationController.dispose();
    maximumController.dispose();
    availableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Banker's Algorithm Simulator"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Allocation Matrix',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Separate processes with ; and resources with spaces.',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: allocationController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '0 1 0; 2 0 0; ...',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Maximum Matrix',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: maximumController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '7 5 3; 3 2 2; ...',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Available Resources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: availableController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '3 3 2',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: runBankersAlgorithm,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Run Safety Algorithm', style: TextStyle(fontSize: 16)),
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
    final bool isSafe = result!.isSafe;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: isSafe ? Colors.green.shade50 : Colors.red.shade50,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isSafe ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: isSafe ? Colors.green.shade700 : Colors.red.shade700,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSafe ? 'System Status: SAFE' : 'System Status: DEADLOCK / UNSAFE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSafe ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSafe
                            ? 'A safe execution sequence exists to prevent deadlock.'
                            : 'The current resource allocation cannot guarantee process completion.',
                        style: TextStyle(
                          color: isSafe ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (isSafe) ...[
          const Text(
            'Execution Safe Sequence',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(result!.safeSequence.length, (index) {
                final processId = result!.safeSequence[index];
                return Row(
                  children: [
                    Chip(
                      avatar: CircleAvatar(
                        backgroundColor: Colors.blue.shade700,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      label: Text(
                        'P$processId',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.blue.shade50,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    if (index < result!.safeSequence.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.blue.shade400,
                          size: 20,
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
        ],
        const Text(
          'Computed Need Matrix [Max - Allocation]',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300, width: 1),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Process', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...List.generate(
                      result!.need.isNotEmpty ? result!.need[0].length : 0,
                      (resIndex) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'R$resIndex',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                ...List.generate(result!.need.length, (pIndex) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'P$pIndex',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...result!.need[pIndex].map(
                        (val) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '$val',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
