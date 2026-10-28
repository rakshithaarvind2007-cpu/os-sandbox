import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'memory_algorithms.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});
  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  final blocksController = TextEditingController(
    text: '100, 500, 200, 300, 600',
  );
  final processesController = TextEditingController(text: '212, 417, 112, 426');
  String selectedAlgorithm = 'First Fit';
  MemoryAllocationResult? result;
  String? errorMessage;
  int _animationRun = 0;

  List<int> _parseSizes(String input, String field) {
    if (input.trim().isEmpty) throw FormatException('$field is required.');
    final values = input.split(',').map((v) => v.trim()).toList();
    if (values.length > 12)
      throw FormatException('$field can contain at most 12 values.');
    final parsed = <int>[];
    for (var i = 0; i < values.length; i++) {
      final size = int.tryParse(values[i]);
      if (size == null)
        throw FormatException('$field: item ${i + 1} must be a whole number.');
      if (size <= 0)
        throw FormatException('$field: sizes must be greater than zero.');
      if (size > 100000)
        throw FormatException('$field: each size must be 100,000 or less.');
      parsed.add(size);
    }
    return parsed;
  }

  void runAlgorithm() {
    HapticFeedback.selectionClick();
    try {
      final blocks = _parseSizes(blocksController.text, 'Memory blocks');
      final processes = _parseSizes(processesController.text, 'Process sizes');
      final allocation = switch (selectedAlgorithm) {
        'First Fit' => firstFit(blocks, processes),
        'Best Fit' => bestFit(blocks, processes),
        _ => worstFit(blocks, processes),
      };
      setState(() {
        result = allocation;
        errorMessage = null;
        _animationRun++;
      });
    } on FormatException catch (e) {
      setState(() {
        result = null;
        errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        result = null;
        errorMessage =
            'Could not run the allocator. Check the values and try again.';
      });
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
      appBar: AppBar(title: const Text('Memory Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Heading(),
                const SizedBox(height: 22),
                _inputCard(),
                if (result != null) ...[
                  const SizedBox(height: 22),
                  _buildVisualResult(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputCard() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final fieldWidth = screenWidth < 720
        ? screenWidth - 100
        : screenWidth < 1100
        ? 330.0
        : 430.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF263149)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configure memory',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            'Enter positive whole-number sizes, separated by commas (up to 12 each).',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: .55),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              SizedBox(
                width: fieldWidth,
                child: TextField(
                  controller: blocksController,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Memory block sizes',
                    hintText: '100, 500, 200, 300, 600',
                  ),
                ),
              ),
              SizedBox(
                width: fieldWidth,
                child: TextField(
                  controller: processesController,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Process sizes',
                    hintText: '212, 417, 112, 426',
                  ),
                ),
              ),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  value: selectedAlgorithm,
                  decoration: const InputDecoration(
                    labelText: 'Placement strategy',
                  ),
                  items: const ['First Fit', 'Best Fit', 'Worst Fit']
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedAlgorithm = v);
                  },
                ),
              ),
              FilledButton.icon(
                onPressed: runAlgorithm,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Allocate processes'),
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3A1C2B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEF7188).withValues(alpha: .4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFFF8292),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Color(0xFFFFB4BF)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVisualResult() {
    final allocation = result!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$selectedAlgorithm allocation',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _animationRun++),
              tooltip: 'Replay allocation animation',
              icon: const Icon(Icons.replay_rounded, color: Color(0xFF62F4D4)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...List.generate(allocation.blocks.length, (blockIndex) {
          final block = allocation.blocks[blockIndex];
          return TweenAnimationBuilder<double>(
            key: ValueKey(
              '$_animationRun-$selectedAlgorithm-$blockIndex-${block.originalSize}',
            ),
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 450 + blockIndex * 140),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) => Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - progress)),
                child: child,
              ),
            ),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 13),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111A2B),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF263149)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Block ${blockIndex + 1}  ·  ${block.originalSize} units',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 11),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: SizedBox(
                      height: 42,
                      child: Row(
                        children: [
                          for (final segment in block.segments)
                            Expanded(
                              flex: segment.size,
                              child: AnimatedContainer(
                                duration: Duration(
                                  milliseconds: 500 + blockIndex * 120,
                                ),
                                curve: Curves.easeOutCubic,
                                color: segment.isAllocated
                                    ? const Color(0xFF62F4D4)
                                    : segment.isFragmented
                                    ? const Color(0xFFFFB86B)
                                    : const Color(0xFF344158),
                                alignment: Alignment.center,
                                child: Text(
                                  segment.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: segment.isAllocated
                                        ? const Color(0xFF07111B)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (allocation.unallocatedProcesses.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF3A1C2B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Could not allocate: ${allocation.unallocatedProcesses.map((p) => 'P$p').join(', ')}. Try larger blocks or a different strategy.',
              style: const TextStyle(
                color: Color(0xFFFFB4BF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Icon(Icons.storage_rounded, color: Color(0xFFB78CFF), size: 32),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MEMORY ALLOCATION',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: Color(0xFFB78CFF),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Memory management',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    ],
  );
}
