import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'device_profile.dart';
import '../member2/cpu/cpu_algorithms.dart';
import '../member3/memory/memory_algorithms.dart';
import '../member3/disk/disk_algorithms.dart' as disk;
import '../member3/deadlock/banker_algorithm.dart';

class _CpuSnapshot {
  final int time;
  final String? running;
  final List<String> ready;
  final List<String> upcoming;
  final Map<String, int> remaining;

  const _CpuSnapshot({
    required this.time,
    required this.running,
    required this.ready,
    required this.upcoming,
    required this.remaining,
  });
}

class SandboxPage extends StatefulWidget {
  const SandboxPage({super.key});
  @override
  State<SandboxPage> createState() => _SandboxPageState();
}

class _SandboxPageState extends State<SandboxPage> {
  final _processes = TextEditingController(
    text: 'P1:0:7:2, P2:2:4:1, P3:4:3:3',
  );
  final _pages = TextEditingController(text: '2, 3, 2, 1, 5, 2, 4, 5, 3, 2');
  final _disk = TextEditingController(
    text: '98, 183, 37, 122, 14, 124, 65, 67',
  );
  final _memoryRequests = TextEditingController(text: '120, 180, 90');
  final _claims = TextEditingController(text: '1 2; 2 1; 1 2');
  Timer? _timer;
  String _os = 'Reading device…',
      _preset = 'Balanced',
      _error = '',
      _safety = 'Awaiting workload';
  int _cores = 1, _ram = 0, _free = 0, _app = 0, _time = 0;
  Map<String, SchedulingResult> _cpu = {};
  List<_CpuSnapshot> _cpuTimeline = [];
  Map<String, int> _faults = {};
  Map<String, List<List<int>>> _pageFrames = {};
  Map<String, List<bool>> _pageHits = {};
  Map<String, int> _seek = {};
  Map<String, MemoryAllocationResult> _memory = {};
  @override
  void initState() {
    super.initState();
    _readDevice();
    _run();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _processes.dispose();
    _pages.dispose();
    _disk.dispose();
    _memoryRequests.dispose();
    _claims.dispose();
    super.dispose();
  }

  Future<void> _readDevice() async {
    try {
      final data = await loadDeviceProfile();
      if (!mounted) return;
      setState(() {
        _os = data.operatingSystem;
        _cores = data.logicalCores;
        _ram = data.totalMemoryBytes;
        _free = data.availableMemoryBytes;
        _app = data.appVirtualMemoryBytes;
      });
      if (_cpu.isNotEmpty) _run();
    } catch (_) {
      if (mounted) setState(() => _os = 'Device details unavailable');
    }
  }

  void _presetTo(String name) {
    final pair = switch (name) {
      'CPU burst' => (
        'A1:0:12:1, A2:1:2:4, A3:2:3:3',
        '1, 2, 3, 1, 4, 1, 2, 5, 1',
      ),
      'Memory pressure' => (
        'M1:0:8:2, M2:1:6:1, M3:3:5:3',
        '1, 2, 3, 4, 1, 2, 5, 1, 2, 3',
      ),
      'I/O surge' => (
        'I1:0:3:1, I2:1:5:2, I3:2:2:4',
        '4, 1, 4, 2, 5, 4, 2, 6, 4',
      ),
      _ => ('P1:0:7:2, P2:2:4:1, P3:4:3:3', '2, 3, 2, 1, 5, 2, 4, 5, 3'),
    };
    setState(
      () => {
        _preset = name,
        _processes.text = pair.$1,
        _pages.text = pair.$2,
        _time = 0,
      },
    );
    _run();
  }

  List<int> _numbers(String s, String label) {
    final parts = s.split(',').map((x) => x.trim()).toList();
    if (parts.isEmpty || parts.length > 24 || parts.any((x) => x.isEmpty))
      throw FormatException(label + ' needs 1–24 comma-separated numbers.');
    return parts.map((x) {
      final v = int.tryParse(x);
      if (v == null || v < 0)
        throw FormatException(
          label + ' must contain non-negative whole numbers.',
        );
      return v;
    }).toList();
  }

  void _run() {
    _timer?.cancel();
    try {
      final ps = <Process>[];
      for (final row in _processes.text.split(',')) {
        final v = row.trim().split(':').map((x) => x.trim()).toList();
        if (v.length != 4)
          throw const FormatException(
            'Use PID:arrival:burst:priority, e.g. P1:0:6:2.',
          );
        final a = int.tryParse(v[1]),
            b = int.tryParse(v[2]),
            q = int.tryParse(v[3]);
        if (a == null || b == null || q == null || a < 0 || a > 1000 || b < 1 || b > 1000 || q < 0)
          throw FormatException(
            v[0] + ' needs arrival 0–1000, burst 1–1000, and non-negative priority.',
          );
        ps.add(Process(id: v[0], arrivalTime: a, burstTime: b, priority: q));
      }
      if (ps.map((p) => p.id.toLowerCase()).toSet().length != ps.length)
        throw const FormatException('Process IDs must be unique.');
      final pages = _numbers(_pages.text, 'Page trace'),
          requests = _numbers(_disk.text, 'Disk queue');
      if (requests.any((x) => x > 199))
        throw const FormatException('Disk cylinders must be 0–199.');
      final memoryRequests = _numbers(_memoryRequests.text, 'Memory requests');
      if (memoryRequests.length != ps.length ||
          memoryRequests.any((size) => size == 0 || size > 100000)) {
        throw const FormatException(
          'Enter one positive memory request (MB) for each process.',
        );
      }
      final claimRows = _claims.text.split(';').map((r) => r.trim()).toList();
      if (claimRows.length != ps.length || claimRows.any((r) => r.isEmpty)) {
        throw const FormatException(
          'Enter one maximum CPU/IO claim row per process, separated by semicolons.',
        );
      }
      final allocation = List.generate(ps.length, (i) => [i % 2, (i + 1) % 2]);
      final maximum = <List<int>>[];
      for (var i = 0; i < claimRows.length; i++) {
        final parts = claimRows[i].split(RegExp(r'\s+'));
        if (parts.length != 2)
          throw FormatException(
            'Resource claim row ' +
                (i + 1).toString() +
                ' needs two values: CPU IO.',
          );
        final cpuClaim = int.tryParse(parts[0]),
            ioClaim = int.tryParse(parts[1]);
        if (cpuClaim == null || ioClaim == null || cpuClaim < 0 || ioClaim < 0)
          throw FormatException(
            'Resource claim row ' +
                (i + 1).toString() +
                ' must use non-negative whole numbers.',
          );
        if (cpuClaim < allocation[i][0] || ioClaim < allocation[i][1])
          throw FormatException(
            'Maximum claim for P' +
                (i + 1).toString() +
                ' cannot be lower than its current allocation.',
          );
        maximum.add([cpuClaim, ioClaim]);
      }
      final cpu = <String, SchedulingResult>{
        'FCFS': fcfs(ps),
        'SJF': sjf(ps),
        'SRTF': srtf(ps),
        'Priority': priorityScheduling(ps),
        'Round Robin': roundRobin(ps, 2),
      };
      final cpuTimeline = _buildCpuTimeline(ps);
      final fault = <String, int>{};
      final frameSnapshots = <String, List<List<int>>>{};
      final frameHits = <String, List<bool>>{};
      for (final policy in ['FIFO', 'LRU', 'Optimal']) {
        final frames = <int>[], last = <int, int>{};
        final snapshots = <List<int>>[];
        final hits = <bool>[];
        var count = 0;
        for (var i = 0; i < pages.length; i++) {
          final page = pages[i];
          final hit = frames.contains(page);
          hits.add(hit);
          if (hit) {
            last[page] = i;
            snapshots.add(List<int>.from(frames));
            continue;
          }
          count++;
          if (frames.length < 3) {
            frames.add(page);
          } else {
            var victim = 0;
            if (policy == 'LRU') {
              for (var j = 1; j < frames.length; j++) {
                if ((last[frames[j]] ?? -1) < (last[frames[victim]] ?? -1))
                  victim = j;
              }
            }
            if (policy == 'Optimal') {
              var far = -1;
              for (var j = 0; j < frames.length; j++) {
                final next = pages.indexOf(frames[j], i + 1),
                    distance = next < 0 ? pages.length + 1 : next;
                if (distance > far) {
                  far = distance;
                  victim = j;
                }
              }
            }
            frames[victim] = page;
          }
          last[page] = i;
          snapshots.add(List<int>.from(frames));
        }
        fault[policy] = count;
        frameSnapshots[policy] = snapshots;
        frameHits[policy] = hits;
      }
      final diskResults = <String, int>{
        'FCFS': disk.fcfs(requests: requests, head: 53).totalHeadMovement,
        'SSTF': disk.sstf(requests: requests, head: 53).totalHeadMovement,
        'SCAN': disk
            .scan(
              requests: requests,
              head: 53,
              diskSize: 200,
              direction: 'Right',
            )
            .totalHeadMovement,
        'LOOK': disk
            .look(requests: requests, head: 53, direction: 'Right')
            .totalHeadMovement,
      };
      final m = (_free == 0 ? 4096 : (_free / 1048576).round()).clamp(
        512,
        100000,
      );
      final blocks = [m ~/ 4, m ~/ 3, m ~/ 5, m ~/ 4], sizes = memoryRequests;
      final memory = <String, MemoryAllocationResult>{
        'First Fit': firstFit(blocks, sizes),
        'Best Fit': bestFit(blocks, sizes),
        'Worst Fit': worstFit(blocks, sizes),
      };
      final safe = bankersAlgorithm(
        allocation: allocation,
        maximum: maximum,
        available: [(_cores < 1 ? 4 : _cores), 4],
      );
      setState(
        () => {
          _cpu = cpu,
          _cpuTimeline = cpuTimeline,
          _faults = fault,
          _pageFrames = frameSnapshots,
          _pageHits = frameHits,
          _seek = diskResults,
          _memory = memory,
          _time = 0,
          _error = '',
          _safety = safe.isSafe
              ? 'SAFE · ' +
                    safe.safeSequence
                        .map((i) => 'P' + (i + 1).toString())
                        .join(' → ')
              : 'UNSAFE',
        },
      );
    } on FormatException catch (e) {
      setState(() => {_error = e.message, _cpu = {}});
    }
  }

  List<_CpuSnapshot> _buildCpuTimeline(List<Process> processes) {
    final remaining = {for (final p in processes) p.id: p.burstTime};
    final steps = <_CpuSnapshot>[];
    var time = 0;
    var completed = 0;
    while (completed < processes.length) {
      final available = processes
          .where((p) => p.arrivalTime <= time && remaining[p.id]! > 0)
          .toList()
        ..sort((a, b) {
          final byRemaining = remaining[a.id]!.compareTo(remaining[b.id]!);
          if (byRemaining != 0) return byRemaining;
          final byArrival = a.arrivalTime.compareTo(b.arrivalTime);
          return byArrival != 0 ? byArrival : a.id.compareTo(b.id);
        });
      final upcoming = processes
          .where((p) => p.arrivalTime > time && remaining[p.id]! > 0)
          .map((p) => p.id)
          .toList()
        ..sort((a, b) {
          final pa = processes.firstWhere((p) => p.id == a);
          final pb = processes.firstWhere((p) => p.id == b);
          final byArrival = pa.arrivalTime.compareTo(pb.arrivalTime);
          return byArrival != 0 ? byArrival : pa.id.compareTo(pb.id);
        });
      if (available.isEmpty) {
        steps.add(_CpuSnapshot(
          time: time,
          running: null,
          ready: const [],
          upcoming: upcoming,
          remaining: Map.of(remaining),
        ));
        time++;
        continue;
      }
      final running = available.first;
      steps.add(_CpuSnapshot(
        time: time,
        running: running.id,
        ready: available.skip(1).map((p) => p.id).toList(),
        upcoming: upcoming,
        remaining: Map.of(remaining),
      ));
      remaining[running.id] = remaining[running.id]! - 1;
      if (remaining[running.id] == 0) completed++;
      time++;
    }
    steps.add(_CpuSnapshot(time: time, running: null, ready: const [], upcoming: const [], remaining: Map.of(remaining)));
    return steps;
  }

  void _play() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 660), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _time++);
    });
  }

  void _step() => setState(() => _time++);
  void _reset() {
    _timer?.cancel();
    setState(() => {_time = 0});
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cpuStep = _cpuTimeline.isEmpty
        ? null
        : _cpuTimeline[_time % _cpuTimeline.length];
    return SingleChildScrollView(
      padding: EdgeInsets.all(w < 700 ? 18 : 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Heading(),
              const SizedBox(height: 16),
              _panel(
                Row(
                  children: [
                    const Icon(Icons.devices_rounded, color: AppTheme.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _os +
                            ' · ' +
                            _cores.toString() +
                            ' logical cores · ' +
                            (_ram == 0
                                ? 'RAM details unavailable'
                                : (_ram / 1073741824).toStringAsFixed(1) +
                                      ' GB RAM · ' +
                                      (_free / 1073741824).toStringAsFixed(1) +
                                      ' GB free · app ' +
                                      (_app / 1048576).toStringAsFixed(0) +
                                      ' MB'),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    IconButton(
                      onPressed: _readDevice,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _panel(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create a workload',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          [
                                'Balanced',
                                'CPU burst',
                                'Memory pressure',
                                'I/O surge',
                              ]
                              .map(
                                (s) => ChoiceChip(
                                  label: Text(s),
                                  selected: _preset == s,
                                  onSelected: (_) => _presetTo(s),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: w < 700 ? w - 75 : 450,
                          child: TextField(
                            controller: _processes,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText:
                                  'Processes · PID:arrival:burst:priority',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: w < 700 ? w - 75 : 340,
                          child: TextField(
                            controller: _pages,
                            decoration: const InputDecoration(
                              labelText: 'Page reference string',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: w < 700 ? w - 75 : 340,
                          child: TextField(
                            controller: _disk,
                            decoration: const InputDecoration(
                              labelText: 'Disk request queue · 0–199',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: w < 700 ? w - 75 : 300,
                          child: TextField(
                            controller: _memoryRequests,
                            decoration: const InputDecoration(
                              labelText: 'Process memory requests · MB',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: w < 700 ? w - 75 : 380,
                          child: TextField(
                            controller: _claims,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText:
                                  'Maximum CPU/IO claims · one row per process',
                              hintText: '1 2; 2 1; 1 2',
                            ),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: _run,
                          icon: const Icon(Icons.bolt_rounded),
                          label: const Text('Build scenario'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 10),
                _panel(
                  Text(
                    _error,
                    style: const TextStyle(color: Color(0xFFFF8292)),
                  ),
                ),
              ],
              if (_cpu.isNotEmpty) ...[
                const SizedBox(height: 12),
                _panel(
                  Column(
                    children: [
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: _timer == null
                                ? _play
                                : () {
                                    _timer?.cancel();
                                    setState(() => _timer = null);
                                  },
                            icon: Icon(
                              _timer == null
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                            ),
                            label: Text(_timer == null ? 'Run' : 'Pause'),
                          ),
                          IconButton(
                            onPressed: _step,
                            icon: const Icon(Icons.skip_next_rounded),
                          ),
                          IconButton(
                            onPressed: _reset,
                            icon: const Icon(Icons.restart_alt_rounded),
                          ),
                          const Spacer(),
                          Text(
                            'CPU t=${cpuStep?.time ?? 0}',
                            style: const TextStyle(
                              color: AppTheme.cyan,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _readyQueue(cpuStep),
                const SizedBox(height: 12),
                _comparison(
                  'CPU scheduling · lower wait / turnaround',
                  _cpu.entries
                      .map(
                        (e) => _item(
                          e.key,
                          'W ' +
                              e.value.averageWaitingTime.toStringAsFixed(1) +
                              ' · T ' +
                              e.value.averageTurnaroundTime.toStringAsFixed(1),
                          e.key == 'SRTF' ? AppTheme.cyan : AppTheme.blue,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                _comparison(
                  'Page replacement · three frames',
                  _faults.entries
                      .map(
                        (e) => _item(
                          e.key,
                          e.value.toString() + ' page faults',
                          e.key == 'LRU' ? AppTheme.violet : AppTheme.blue,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                _frameView(),
                const SizedBox(height: 12),
                _comparison(
                  'Memory placement · host-scaled pool',
                  _memory.entries.map((e) {
                    final n = e.value.blocks
                        .expand((b) => b.segments)
                        .where((s) => s.isFragmented)
                        .fold<int>(0, (sum, s) => sum + s.size);
                    return _item(
                      e.key,
                      n.toString() + ' MB fragmented',
                      AppTheme.violet,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                _comparison(
                  'Banker resource safety · generated from process count',
                  [_item('System state', _safety, AppTheme.cyan)],
                ),
                const SizedBox(height: 12),
                _comparison(
                  'Disk scheduling · head movement',
                  _seek.entries
                      .map(
                        (e) => _item(
                          e.key,
                          e.value.toString() + ' cylinders',
                          const Color(0xFFFF7FA6),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                _panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Animated SRTF execution trace · CPU t=${cpuStep?.time ?? 0}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        children: [
                          for (
                            var i = 0;
                            i < _cpu['SRTF']!.executionOrder.length;
                            i++
                          )
                            AnimatedContainer(
                              duration: Duration(
                                milliseconds: 180 + (i % 4) * 70,
                              ),
                              width: 22,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _color(_cpu['SRTF']!.executionOrder[i])
                                    .withValues(
                                      alpha:
                                          i ==
                                              _time %
                                                  _cpu['SRTF']!
                                                      .executionOrder
                                                      .length
                                          ? .6
                                          : .16,
                                    ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _cpu['SRTF']!.executionOrder[i],
                                style: const TextStyle(fontSize: 9),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Text(
                'Measured device profile is read only. Workload processes are simulated from your inputs: mobile apps and browsers cannot inspect or reschedule other apps’ processes or kernel page frames.',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: .48),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _readyQueue(_CpuSnapshot? step) {
    if (step == null) return const SizedBox.shrink();
    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SRTF ready queue · CPU time ${step.time}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('The shortest remaining burst runs first; arrivals join the queue as time advances.',
              style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: .5))),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _queueChip('RUNNING', step.running, AppTheme.cyan, step.remaining),
            for (var i = 0; i < step.ready.length; i++)
              _queueChip('READY ${i + 1}', step.ready[i], AppTheme.blue, step.remaining),
            for (final id in step.upcoming)
              _queueChip('ARRIVES LATER', id, AppTheme.violet, step.remaining),
            if (step.running == null && step.ready.isEmpty && step.upcoming.isEmpty)
              const Text('All processes complete', style: TextStyle(color: AppTheme.cyan)),
          ]),
        ],
      ),
    );
  }

  Widget _queueChip(String label, String? id, Color color, Map<String, int> remaining) {
    if (id == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .035), borderRadius: BorderRadius.circular(10)),
        child: const Text('CPU IDLE', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w800)),
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: color.withValues(alpha: .1), border: Border.all(color: color.withValues(alpha: .38)), borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 8, letterSpacing: .8, color: color, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text('$id · ${remaining[id]} left', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
  Widget _frameView() {
    if (_pageFrames['LRU'] == null || _pageFrames['LRU']!.isEmpty)
      return const SizedBox.shrink();
    final sequence = _pageFrames['LRU']!;
    final hits = _pageHits['LRU']!;
    final step = _time % sequence.length;
    final frame = sequence[step];
    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Page walk · request ${step + 1} · ${hits[step] ? 'HIT' : 'FAULT'}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.violet,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              for (var i = 0; i < 3; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 48,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: i < frame.length
                          ? AppTheme.violet.withValues(alpha: .15)
                          : const Color(0xFF0C1423),
                      border: Border.all(
                        color: i < frame.length
                            ? AppTheme.violet
                            : Colors.white12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        i < frame.length
                            ? 'FRAME ${i + 1} · ${frame[i]}'
                            : 'EMPTY',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppTheme.violet,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _comparison(String title, List<Widget> items) => _panel(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 9),
        Wrap(spacing: 8, runSpacing: 8, children: items),
      ],
    ),
  );
  Widget _item(String name, String value, Color c) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: c.withValues(alpha: .08),
      border: Border.all(color: c.withValues(alpha: .22)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w800),
        ),
        Text(value, style: const TextStyle(fontSize: 10)),
      ],
    ),
  );
  Widget _panel(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF111A2B),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF263149)),
    ),
    child: child,
  );
  Color _color(String id) {
    const colors = [
      AppTheme.cyan,
      AppTheme.blue,
      AppTheme.violet,
      Color(0xFFFFB86B),
      Color(0xFFFF7FA6),
    ];
    return colors[id.hashCode.abs() % colors.length];
  }
}

class _Heading extends StatelessWidget {
  const _Heading();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Icon(Icons.science_rounded, color: AppTheme.cyan, size: 34),
      SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LIVE SYSTEM LAB',
              style: TextStyle(
                color: AppTheme.cyan,
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'System Sandbox',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
            ),
            Text(
              'Change the workload. Watch OS policies compete.',
              style: TextStyle(fontSize: 12, color: Color(0xFF9DAAC4)),
            ),
          ],
        ),
      ),
    ],
  );
}
