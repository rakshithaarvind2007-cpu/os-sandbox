import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../member1/app_theme.dart';
import 'memory_algorithms.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});
  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  final _blocks = TextEditingController(text: '100, 500, 200, 300, 600');
  final _processes = TextEditingController(text: '212, 417, 112, 426');
  String _algorithm = 'First Fit';
  MemoryAllocationResult? _result;
  String? _error;
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
        throw FormatException('$field item ${i + 1} must be a whole number.');
      if (size <= 0)
        throw FormatException('$field sizes must be greater than zero.');
      if (size > 100000)
        throw FormatException('$field values must be 100,000 or less.');
      parsed.add(size);
    }
    return parsed;
  }

  void _run() {
    HapticFeedback.selectionClick();
    try {
      final blocks = _parseSizes(_blocks.text, 'Memory blocks');
      final processes = _parseSizes(_processes.text, 'Process sizes');
      final result = switch (_algorithm) {
        'First Fit' => firstFit(blocks, processes),
        'Best Fit' => bestFit(blocks, processes),
        _ => worstFit(blocks, processes),
      };
      setState(() {
        _result = result;
        _error = null;
        _animationRun++;
      });
    } on FormatException catch (e) {
      setState(() {
        _result = null;
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _result = null;
        _error = 'Could not run the allocator. Check the values and try again.';
      });
    }
  }

  @override
  void dispose() {
    _blocks.dispose();
    _processes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SingleChildScrollView(
      padding: EdgeInsets.all(width < 700 ? 18 : 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PageHeading(),
              const SizedBox(height: 22),
              _inputPanel(width),
              if (_result != null) ...[
                const SizedBox(height: 16),
                _summary(_result!),
                const SizedBox(height: 16),
                _allocationView(_result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputPanel(double screenWidth) {
    final fieldWidth = screenWidth < 700
        ? screenWidth - 72
        : screenWidth < 1050
        ? 320.0
        : 390.0;
    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            'Allocation setup',
            'Use positive whole-number sizes separated by commas (up to 12 each).',
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: fieldWidth,
                child: TextField(
                  controller: _blocks,
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
                  controller: _processes,
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
                width: 200,
                child: DropdownButtonFormField<String>(
                  value: _algorithm,
                  decoration: const InputDecoration(
                    labelText: 'Placement strategy',
                  ),
                  items: const ['First Fit', 'Best Fit', 'Worst Fit']
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _algorithm = value);
                  },
                ),
              ),
              FilledButton.icon(
                onPressed: _run,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Run allocation'),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _errorBanner(_error!),
          ],
        ],
      ),
    );
  }

  Widget _summary(MemoryAllocationResult result) {
    final total = result.blocks.fold<int>(
      0,
      (sum, block) => sum + block.originalSize,
    );
    final allocated = result.blocks
        .expand((block) => block.segments)
        .where((segment) => segment.isAllocated)
        .fold<int>(0, (sum, segment) => sum + segment.size);
    final fragmented = result.blocks
        .expand((block) => block.segments)
        .where((segment) => segment.isFragmented)
        .fold<int>(0, (sum, segment) => sum + segment.size);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _metric('TOTAL MEMORY', '$total units', AppTheme.blue),
        _metric('ALLOCATED', '$allocated units', AppTheme.cyan),
        _metric('FRAGMENTATION', '$fragmented units', const Color(0xFFFFB86B)),
        _metric(
          'UNALLOCATED',
          '${result.unallocatedProcesses.length} processes',
          const Color(0xFFFF7FA6),
        ),
      ],
    );
  }

  Widget _allocationView(MemoryAllocationResult result) {
    const palette = [
      AppTheme.cyan,
      AppTheme.blue,
      AppTheme.violet,
      Color(0xFFFF7FA6),
      Color(0xFF72D1FF),
    ];
    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _PanelTitle(
                  'Live RAM map',
                  'RAM availability scales this teaching workload; blocks fill top to bottom.',
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _animationRun++),
                tooltip: 'Replay animation',
                icon: const Icon(Icons.replay_rounded, color: AppTheme.cyan),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              _legend('Process allocation', AppTheme.cyan),
              _legend('Internal fragmentation', const Color(0xFFFFB86B)),
              _legend('Free space', const Color(0xFF344158)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 330,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < result.blocks.length; i++)
                    TweenAnimationBuilder<double>(
                      key: ValueKey('$_animationRun-$_algorithm-$i'),
                      tween: Tween(begin: .82, end: 1),
                      duration: Duration(milliseconds: 450 + i * 100),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) => Transform.scale(
                        scale: scale,
                        alignment: Alignment.bottomCenter,
                        child: child,
                      ),
                      child: _ramBlock(i, result.blocks[i], palette),
                    ),
                ],
              ),
            ),
          ),
          if (result.unallocatedProcesses.isNotEmpty) ...[
            const SizedBox(height: 12),
            _errorBanner(
              'Could not allocate ${result.unallocatedProcesses.map((p) => 'P$p').join(', ')}. Try larger blocks or another strategy.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _ramBlock(int index, MemoryBlockState block, List<Color> palette) {
    final allocated = block.segments
        .where((s) => s.isAllocated)
        .fold<int>(0, (sum, s) => sum + s.size);
    return Container(
      width: 154,
      margin: const EdgeInsets.only(right: 11),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1423),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF263149)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BLOCK ${index + 1}',
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 1.1,
              color: AppTheme.blue,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${block.originalSize} units',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 9),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: [
                  for (final segment in block.segments)
                    Expanded(
                      flex: segment.size,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 480),
                        curve: Curves.easeOutCubic,
                        width: double.infinity,
                        color: segment.isFragmented
                            ? const Color(0xFFFFB86B)
                            : !segment.isAllocated
                            ? const Color(0xFF344158)
                            : palette[(int.tryParse(
                                        RegExp(r'^P(\d+)')
                                                .firstMatch(segment.label)
                                                ?.group(1) ??
                                            '1',
                                      )! -
                                      1) %
                                  palette.length],
                        alignment: Alignment.center,
                        child: segment.size / block.originalSize > .1
                            ? Text(
                                segment.label.split(' ').first,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: segment.isAllocated
                                      ? AppTheme.ink
                                      : Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: allocated / block.originalSize,
              minHeight: 5,
              backgroundColor: const Color(0xFF29364B),
              valueColor: const AlwaysStoppedAnimation(AppTheme.cyan),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${(allocated * 100 / block.originalSize).round()}% allocated',
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withValues(alpha: .55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color color) => Container(
    width: 205,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF111A2B),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: color.withValues(alpha: .23)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.15,
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
  Widget _legend(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: Colors.white.withValues(alpha: .62),
        ),
      ),
    ],
  );
  Widget _errorBanner(String message) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFF3A1C2B),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFFEF7188).withValues(alpha: .4)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFFF8292)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFFFFB4BF)),
          ),
        ),
      ],
    ),
  );
  Widget _panel(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF111A2B),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF263149)),
    ),
    child: child,
  );
}

class _PageHeading extends StatelessWidget {
  const _PageHeading();
  @override
  Widget build(BuildContext context) => const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _HeadingBadge(),
      SizedBox(width: 15),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MEMORY MANAGEMENT',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.6,
                color: AppTheme.violet,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Memory allocation',
              style: TextStyle(
                fontSize: 28,
                letterSpacing: -.6,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Compare placement strategies and watch memory blocks fill.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9DAAC4)),
            ),
          ],
        ),
      ),
    ],
  );
}

class _HeadingBadge extends StatelessWidget {
  const _HeadingBadge();
  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: AppTheme.violet.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Icon(Icons.storage_rounded, color: AppTheme.violet),
  );
}

class _PanelTitle extends StatelessWidget {
  final String title, subtitle;
  const _PanelTitle(this.title, this.subtitle);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: TextStyle(
          fontSize: 11,
          color: Colors.white.withValues(alpha: .48),
        ),
      ),
    ],
  );
}
