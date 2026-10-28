import 'dart:async';
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
  String? errorMessage;
  int _visibleSequence = 0;
  Timer? _sequenceTimer;

  List<List<int>> parseMatrix(String input, String field) {
    if (input.trim().isEmpty) throw FormatException('$field is required.');
    final rows = input.split(';').map((row) => row.trim()).toList();
    if (rows.length > 12)
      throw FormatException('$field can contain at most 12 process rows.');
    if (rows.any((row) => row.isEmpty))
      throw FormatException(
        '$field has an empty row. Separate process rows with semicolons.',
      );
    final matrix = <List<int>>[];
    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final tokens = rows[rowIndex].split(RegExp(r'\s+'));
      if (tokens.length > 8)
        throw FormatException('$field can use at most 8 resource types.');
      final row = <int>[];
      for (var col = 0; col < tokens.length; col++) {
        final value = int.tryParse(tokens[col]);
        if (value == null)
          throw FormatException(
            '$field: process P${rowIndex + 1}, resource ${col + 1} must be a whole number.',
          );
        if (value < 0)
          throw FormatException(
            '$field values cannot be negative (P${rowIndex + 1}, resource ${col + 1}).',
          );
        if (value > 100000)
          throw FormatException('$field values must be 100,000 or less.');
        row.add(value);
      }
      matrix.add(row);
    }
    return matrix;
  }

  List<int> parseVector(String input) {
    if (input.trim().isEmpty)
      throw const FormatException('Available resources are required.');
    final tokens = input.trim().split(RegExp(r'\s+'));
    if (tokens.length > 8)
      throw const FormatException('Use at most 8 resource values.');
    return List<int>.generate(tokens.length, (i) {
      final value = int.tryParse(tokens[i]);
      if (value == null)
        throw FormatException(
          'Available resource ${i + 1} must be a whole number.',
        );
      if (value < 0)
        throw FormatException(
          'Available resources cannot be negative (value ${i + 1}).',
        );
      if (value > 100000)
        throw const FormatException(
          'Available resource values must be 100,000 or less.',
        );
      return value;
    });
  }

  void runBankersAlgorithm() {
    _sequenceTimer?.cancel();
    try {
      final allocation = parseMatrix(
        allocationController.text,
        'Allocation matrix',
      );
      final maximum = parseMatrix(maximumController.text, 'Maximum matrix');
      final available = parseVector(availableController.text);
      if (allocation.length != maximum.length)
        throw const FormatException(
          'Allocation and maximum matrices must have the same number of processes.',
        );
      final resourceCount = available.length;
      if (allocation.any((row) => row.length != resourceCount) ||
          maximum.any((row) => row.length != resourceCount)) {
        throw FormatException(
          'Each matrix row must contain exactly $resourceCount resource values, matching Available Resources.',
        );
      }
      for (var process = 0; process < allocation.length; process++) {
        for (var resource = 0; resource < resourceCount; resource++) {
          if (allocation[process][resource] > maximum[process][resource]) {
            throw FormatException(
              'Allocation for P${process + 1}, resource ${resource + 1} cannot exceed its maximum claim.',
            );
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
        errorMessage = null;
        _visibleSequence = 0;
      });
      if (newResult.isSafe) _playSequence();
    } on FormatException catch (e) {
      setState(() {
        result = null;
        errorMessage = e.message;
        _visibleSequence = 0;
      });
    } catch (_) {
      setState(() {
        result = null;
        errorMessage =
            'Could not evaluate this resource state. Check the matrices and try again.';
        _visibleSequence = 0;
      });
    }
  }

  void _playSequence() {
    _sequenceTimer?.cancel();
    final current = result;
    if (current == null || !current.isSafe) return;
    setState(() => _visibleSequence = 0);
    _sequenceTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(
        () => _visibleSequence = (_visibleSequence + 1)
            .clamp(0, current.safeSequence.length)
            .toInt(),
      );
      if (_visibleSequence >= current.safeSequence.length) timer.cancel();
    });
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    allocationController.dispose();
    maximumController.dispose();
    availableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Banker's Algorithm Simulator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Allocation Matrix',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Use non-negative whole numbers. Separate processes with ; and resource values with spaces.',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: allocationController,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '0 1 0; 2 0 0; ...',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Maximum Matrix',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: maximumController,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '7 5 3; 3 2 2; ...',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Available Resources',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  child: Text(
                    'Run Safety Algorithm',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            if (errorMessage != null) _errorBanner(),
            if (result != null) buildVisualResult(),
          ],
        ),
      ),
    );
  }

  Widget _errorBanner() => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFF3A1C2B),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEF7188).withValues(alpha: .4)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFFF8292)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Color(0xFFFFB4BF)),
          ),
        ),
      ],
    ),
  );
  Widget buildVisualResult() {
    final bool isSafe = result!.isSafe;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // System Status Card
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
                        isSafe
                            ? 'System Status: SAFE'
                            : 'System Status: DEADLOCK / UNSAFE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSafe
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSafe
                            ? 'A safe execution sequence exists to prevent deadlock.'
                            : 'The current resource allocation cannot guarantee process completion.',
                        style: TextStyle(
                          color: isSafe
                              ? Colors.green.shade800
                              : Colors.red.shade800,
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

        // Safe Sequence Timeline Visualizer
        if (isSafe) ...[
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Execution Safe Sequence',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _playSequence,
                tooltip: 'Replay safe sequence',
                icon: const Icon(
                  Icons.replay_rounded,
                  color: Color(0xFF62F4D4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_visibleSequence, (index) {
                final processId = result!.safeSequence[index];
                return Row(
                  children: [
                    Chip(
                      avatar: CircleAvatar(
                        backgroundColor: Colors.blue.shade700,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      label: Text(
                        'P$processId',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.blue.shade50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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

        // Need Matrix Table
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
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Process',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                          child: Text('$val', textAlign: TextAlign.center),
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
