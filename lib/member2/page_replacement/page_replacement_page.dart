import 'package:flutter/material.dart';
import '../../member1/app_theme.dart';

class PageReplacementPage extends StatefulWidget {
  const PageReplacementPage({super.key});
  @override
  State<PageReplacementPage> createState() => _PageReplacementPageState();
}

class _PageReplacementPageState extends State<PageReplacementPage> {
  final _reference = TextEditingController(
    text: '7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2',
  );
  final _frames = TextEditingController(text: '3');
  String _algorithm = 'FIFO';
  _PageRun? _run;
  String? _error;

  @override
  void dispose() {
    _reference.dispose();
    _frames.dispose();
    super.dispose();
  }

  void _simulate() {
    try {
      final pages = _reference.text
          .split(',')
          .map((s) => int.parse(s.trim()))
          .toList();
      final count = int.parse(_frames.text.trim());
      if (pages.isEmpty || count < 1 || count > 8 || pages.any((p) => p < 0)) {
        throw const FormatException(
          'Use non-negative page numbers and between 1 and 8 frames.',
        );
      }
      final memory = <int>[];
      final lastUsed = <int, int>{};
      final snapshots = <List<int?>>[];
      final hitsByStep = <bool>[];
      var faults = 0;
      var hits = 0;
      for (var step = 0; step < pages.length; step++) {
        final page = pages[step];
        if (memory.contains(page)) {
          hits++;
          hitsByStep.add(true);
          lastUsed[page] = step;
        } else {
          faults++;
          hitsByStep.add(false);
          if (memory.length < count) {
            memory.add(page);
          } else {
            var victim = 0;
            if (_algorithm == 'LRU') {
              for (var i = 1; i < memory.length; i++) {
                if ((lastUsed[memory[i]] ?? -1) <
                    (lastUsed[memory[victim]] ?? -1))
                  victim = i;
              }
            } else if (_algorithm == 'Optimal') {
              var farthest = -1;
              for (var i = 0; i < memory.length; i++) {
                final next = pages.indexOf(memory[i], step + 1);
                final distance = next < 0 ? pages.length + 1 : next;
                if (distance > farthest) {
                  farthest = distance;
                  victim = i;
                }
              }
            }
            memory[victim] = page;
          }
          lastUsed[page] = step;
        }
        snapshots.add(
          List<int?>.generate(
            count,
            (i) => i < memory.length ? memory[i] : null,
          ),
        );
      }
      setState(() {
        _run = _PageRun(pages, snapshots, hitsByStep, faults, hits);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _run = null;
        _error = e.toString().replaceFirst('FormatException: ', '');
      });
    }
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
              const _Heading(),
              const SizedBox(height: 22),
              _inputPanel(width),
              if (_run != null) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _stat(
                      'PAGE FAULTS',
                      '${_run!.faults}',
                      const Color(0xFFFF7FA6),
                    ),
                    _stat('PAGE HITS', '${_run!.hits}', AppTheme.cyan),
                    _stat(
                      'HIT RATIO',
                      '${(_run!.hits * 100 / (_run!.hits + _run!.faults)).toStringAsFixed(1)}%',
                      AppTheme.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _frameTable(_run!),
              ] else
                const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputPanel(double width) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF111A2B),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF263149)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            SizedBox(
              width: 210,
              child: DropdownButtonFormField<String>(
                value: _algorithm,
                decoration: const InputDecoration(
                  labelText: 'Replacement policy',
                ),
                items: const ['FIFO', 'LRU', 'Optimal']
                    .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                    .toList(),
                onChanged: (x) => setState(() => _algorithm = x!),
              ),
            ),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _frames,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Frames'),
              ),
            ),
            SizedBox(
              width: width < 650 ? double.infinity : 560,
              child: TextField(
                controller: _reference,
                decoration: const InputDecoration(
                  labelText: 'Page reference string',
                  hintText: '7, 0, 1, 2, ...',
                ),
                maxLines: 2,
              ),
            ),
            FilledButton.icon(
              onPressed: _simulate,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Run simulation'),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          'Follow each request from left to right. A miss replaces a frame according to the selected policy.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: .48),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: const TextStyle(color: Color(0xFFFF8292)),
            ),
          ),
      ],
    ),
  );

  Widget _frameTable(_PageRun run) => Container(
    width: double.infinity,
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
          'Frame-by-frame memory',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Text(
          'Each column shows memory after that page request.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: .48),
          ),
        ),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 12,
            headingRowHeight: 42,
            dataRowMinHeight: 46,
            dataRowMaxHeight: 54,
            columns: [
              const DataColumn(label: Text('FRAME')),
              for (var i = 0; i < run.pages.length; i++)
                DataColumn(
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${run.pages[i]}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        run.hitsByStep[i] ? 'HIT' : 'FAULT',
                        style: TextStyle(
                          fontSize: 8,
                          color: run.hitsByStep[i]
                              ? AppTheme.cyan
                              : const Color(0xFFFF7FA6),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            rows: [
              for (var frame = 0; frame < run.snapshots.first.length; frame++)
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        'F${frame + 1}',
                        style: const TextStyle(
                          color: AppTheme.blue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    for (var step = 0; step < run.pages.length; step++)
                      DataCell(
                        _frameCell(
                          run.snapshots[step][frame],
                          run.hitsByStep[step],
                          step,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _frameCell(int? page, bool wasHit, int step) {
    final accent = wasHit ? AppTheme.cyan : const Color(0xFFFF7FA6);
    return AnimatedContainer(
      duration: Duration(milliseconds: 220 + step * 24),
      width: 34,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: page == null
            ? Colors.white.withValues(alpha: .025)
            : accent.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: page == null ? Colors.white10 : accent.withValues(alpha: .27),
        ),
      ),
      child: Text(
        page?.toString() ?? '—',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: page == null ? Colors.white24 : Colors.white,
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Container(
    width: 200,
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: const Color(0xFF111A2B),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: color.withValues(alpha: .25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.2,
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _PageRun {
  final List<int> pages;
  final List<List<int?>> snapshots;
  final List<bool> hitsByStep;
  final int faults;
  final int hits;
  _PageRun(this.pages, this.snapshots, this.hitsByStep, this.faults, this.hits);
}

class _Heading extends StatelessWidget {
  const _Heading();
  @override
  Widget build(BuildContext context) => const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Badge(),
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
                color: AppTheme.blue,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Page replacement',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -.6,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Follow each memory reference and see which page gets evicted.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9DAAC4)),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Badge extends StatelessWidget {
  const _Badge();
  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: AppTheme.blue.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Icon(Icons.layers_rounded, color: AppTheme.blue),
  );
}
