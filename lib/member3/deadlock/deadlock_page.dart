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
        title: const Text("Banker's Algorithm"),
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
              maxLines: 4,
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
              maxLines: 4,
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
                child: const Text('Check Safe State'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result!.isSafe ? 'System is in a SAFE state' : 'System is UNSAFE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        if (result!.isSafe)
          Text(
            'Safe Sequence: ${result!.safeSequence.map((p) => 'P$p').join(' → ')}',
            style: const TextStyle(fontSize: 17),
          ),
        const SizedBox(height: 20),
        const Text(
          'Need Matrix',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          result!.need.length,
          (i) => Text(
            'P$i: ${result!.need[i].join('   ')}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}