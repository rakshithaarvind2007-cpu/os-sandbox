import 'dart:async';
import 'package:flutter/material.dart';
import '../../member1/app_theme.dart';
import 'banker_algorithm.dart';

class DeadlockPage extends StatefulWidget {
  const DeadlockPage({super.key});
  @override
  State<DeadlockPage> createState() => _DeadlockPageState();
}

class _DeadlockPageState extends State<DeadlockPage> {
  final _allocation = TextEditingController(
    text: '0 1 0; 2 0 0; 3 0 2; 2 1 1; 0 0 2',
  );
  final _maximum = TextEditingController(
    text: '7 5 3; 3 2 2; 9 0 2; 2 2 2; 4 3 3',
  );
  final _available = TextEditingController(text: '3 3 2');
  BankersResult? _result;
  String? _error;
  int _visibleSequence = 0;
  Timer? _sequenceTimer;

  List<List<int>> _parseMatrix(String input, String field) {
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
            '$field: P${rowIndex + 1}, resource ${col + 1} must be a whole number.',
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

  List<int> _parseVector(String input) {
    if (input.trim().isEmpty)
      throw const FormatException('Available resources are required.');
    final tokens = input.trim().split(RegExp(r'\s+'));
    if (tokens.length > 8)
      throw const FormatException('Use at most 8 available resource values.');
    return List<int>.generate(tokens.length, (index) {
      final value = int.tryParse(tokens[index]);
      if (value == null)
        throw FormatException(
          'Available resource ${index + 1} must be a whole number.',
        );
      if (value < 0)
        throw FormatException(
          'Available resources cannot be negative (value ${index + 1}).',
        );
      if (value > 100000)
        throw const FormatException(
          'Available resource values must be 100,000 or less.',
        );
      return value;
    });
  }

  void _run() {
    _sequenceTimer?.cancel();
    try {
      final allocation = _parseMatrix(_allocation.text, 'Allocation matrix');
      final maximum = _parseMatrix(_maximum.text, 'Maximum matrix');
      final available = _parseVector(_available.text);
      if (allocation.length != maximum.length)
        throw const FormatException(
          'Allocation and maximum matrices must have the same number of process rows.',
        );
      final resourceCount = available.length;
      if (allocation.any((row) => row.length != resourceCount) ||
          maximum.any((row) => row.length != resourceCount)) {
        throw FormatException(
          'Every matrix row must have $resourceCount values to match Available Resources.',
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
      final result = bankersAlgorithm(
        allocation: allocation,
        maximum: maximum,
        available: available,
      );
      setState(() {
        _result = result;
        _error = null;
        _visibleSequence = 0;
      });
      if (result.isSafe) _playSequence();
    } on FormatException catch (e) {
      setState(() {
        _result = null;
        _error = e.message;
        _visibleSequence = 0;
      });
    } catch (_) {
      setState(() {
        _result = null;
        _error =
            'Could not evaluate this resource state. Check the matrices and try again.';
        _visibleSequence = 0;
      });
    }
  }

  void _playSequence() {
    _sequenceTimer?.cancel();
    final result = _result;
    if (result == null || !result.isSafe) return;
    setState(() => _visibleSequence = 0);
    _sequenceTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(
        () => _visibleSequence = (_visibleSequence + 1)
            .clamp(0, result.safeSequence.length)
            .toInt(),
      );
      if (_visibleSequence >= result.safeSequence.length) timer.cancel();
    });
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    _allocation.dispose();
    _maximum.dispose();
    _available.dispose();
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
                _statusSummary(_result!),
                const SizedBox(height: 16),
                _needMatrix(_result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputPanel(double screenWidth) {
    final matrixWidth = screenWidth < 700
        ? screenWidth - 72
        : screenWidth < 1050
        ? 390.0
        : 470.0;
    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            'Resource state',
            'Use non-negative whole numbers. Separate process rows with ; and resources with spaces.',
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: matrixWidth,
                child: TextField(
                  controller: _allocation,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'Allocation matrix',
                    hintText: '0 1 0; 2 0 0; ...',
                  ),
                ),
              ),
              SizedBox(
                width: matrixWidth,
                child: TextField(
                  controller: _maximum,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'Maximum matrix',
                    hintText: '7 5 3; 3 2 2; ...',
                  ),
                ),
              ),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _available,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Available resources',
                    hintText: '3 3 2',
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: _run,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Check safety'),
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

  Widget _statusSummary(BankersResult result) {
    final safe = result.isSafe;
    final accent = safe ? AppTheme.cyan : const Color(0xFFFF7FA6);
    final completed = result.safeSequence.length;
    final blocked = List<int>.generate(
      result.need.length,
      (i) => i,
    ).where((i) => !result.safeSequence.contains(i)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _metric(
              'SYSTEM STATE',
              safe ? 'SAFE' : 'UNSAFE',
              accent,
              safe ? Icons.verified_rounded : Icons.warning_amber_rounded,
            ),
            _metric(
              'PROCESSES',
              '${result.need.length}',
              AppTheme.blue,
              Icons.memory_rounded,
            ),
            _metric(
              'SAFE ORDER',
              safe ? '$completed steps' : '$completed of ${result.need.length}',
              AppTheme.violet,
              Icons.account_tree_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      safe ? Icons.check_rounded : Icons.priority_high_rounded,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          safe
                              ? 'Safe state found'
                              : 'No complete safe sequence',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          safe
                              ? 'The sequence below releases resources as each process finishes.'
                              : 'These processes remain blocked with the current available resources.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: .5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (safe)
                    IconButton(
                      onPressed: _playSequence,
                      tooltip: 'Replay safe sequence',
                      icon: const Icon(
                        Icons.replay_rounded,
                        color: AppTheme.cyan,
                      ),
                    ),
                ],
              ),
              if (safe) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _visibleSequence >= result.safeSequence.length
                            ? 'Safe execution sequence'
                            : 'Execution steps · $_visibleSequence of ${result.safeSequence.length}',
                        style: const TextStyle(
                          color: AppTheme.cyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.cyan,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (
                        var index = 0;
                        index < _visibleSequence;
                        index++
                      ) ...[
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: .75, end: 1),
                          duration: const Duration(milliseconds: 360),
                          curve: Curves.easeOutBack,
                          builder: (context, scale, child) =>
                              Transform.scale(scale: scale, child: child),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.cyan.withValues(alpha: .11),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: AppTheme.cyan.withValues(alpha: .3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: AppTheme.cyan.withValues(alpha: .7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'P${result.safeSequence[index]}',
                                  style: const TextStyle(
                                    color: AppTheme.cyan,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (index < _visibleSequence - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFF526078),
                              size: 18,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 15),
                _errorBanner(
                  'Blocked: ${blocked.map((i) => 'P$i').join(', ')} cannot finish with the resources currently available.',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _needMatrix(BankersResult result) => _panel(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PanelTitle(
          'Need matrix',
          'Remaining resources each process needs to finish · Maximum − Allocation.',
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: const WidgetStatePropertyAll(Color(0xFF18243A)),
            dataRowColor: const WidgetStatePropertyAll(Color(0xFF0C1423)),
            dividerThickness: .5,
            columns: [
              const DataColumn(label: Text('PROCESS')),
              for (var r = 0; r < result.need.first.length; r++)
                DataColumn(label: Text('R$r')),
            ],
            rows: [
              for (var p = 0; p < result.need.length; p++)
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        'P$p',
                        style: const TextStyle(
                          color: AppTheme.blue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    for (final value in result.need[p])
                      DataCell(Text('$value')),
                  ],
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _metric(String title, String value, Color accent, IconData icon) =>
      Container(
        width: 205,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111A2B),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: accent.withValues(alpha: .23)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1,
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              'DEADLOCK AVOIDANCE',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.6,
                color: AppTheme.violet,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Banker's algorithm",
              style: TextStyle(
                fontSize: 28,
                letterSpacing: -.6,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Check whether the system can safely satisfy every process.',
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
    child: const Icon(Icons.account_tree_rounded, color: AppTheme.violet),
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
