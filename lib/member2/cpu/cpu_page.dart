import 'package:flutter/material.dart';
import '../../member1/app_theme.dart';
import 'cpu_algorithms.dart';

class CpuPage extends StatefulWidget {
  const CpuPage({super.key});
  @override State<CpuPage> createState() => _CpuPageState();
}

class _CpuPageState extends State<CpuPage> {
  final _input = TextEditingController(text: 'P1:0:7:2, P2:2:4:1, P3:4:1:3, P4:5:4:2');
  final _quantum = TextEditingController(text: '2');
  String _algorithm = 'SRTF';
  SchedulingResult? _result;
  List<_Block> _blocks = [];
  String? _error;
  static const _algorithms = ['FCFS', 'SJF', 'SRTF', 'Priority', 'Round Robin'];
  @override void dispose() { _input.dispose(); _quantum.dispose(); super.dispose(); }

  void _run() {
    try {
      final processes = _input.text.split(',').where((s) => s.trim().isNotEmpty).map((entry) {
        final values = entry.trim().split(':').map((e) => e.trim()).toList();
        if (values.length < 3 || values.length > 4) throw FormatException('Use PID:arrival:burst:priority for each process.');
        final arrival = int.parse(values[1]); final burst = int.parse(values[2]);
        final priority = values.length == 4 ? int.parse(values[3]) : 1;
        if (arrival < 0 || burst <= 0 || priority < 0) throw FormatException('Arrival and priority must be 0 or greater; burst must be above 0.');
        return Process(id: values[0], arrivalTime: arrival, burstTime: burst, priority: priority);
      }).toList();
      if (processes.isEmpty) throw FormatException('Add at least one process.');
      if (processes.map((p) => p.id).toSet().length != processes.length) throw FormatException('Process IDs must be unique.');
      final q = int.tryParse(_quantum.text) ?? 0;
      final result = switch (_algorithm) {
        'FCFS' => fcfs(processes),
        'SJF' => sjf(processes),
        'SRTF' => srtf(processes),
        'Priority' => priorityScheduling(processes),
        _ => roundRobin(processes, q),
      };
      final byId = {for (final p in processes) p.id: p};
      final remain = {for (final p in processes) p.id: p.burstTime};
      final blocks = <_Block>[]; var time = 0;
      for (final id in result.executionOrder) {
        final p = byId[id]!;
        if (_algorithm == 'SRTF') {
          final nextArrival = processes.where((x) => x.arrivalTime > time).map((x) => x.arrivalTime).fold<int?>(null, (a,b) => a == null || b < a ? b : a);
          if (remain[id] == p.burstTime && time < p.arrivalTime) time = p.arrivalTime;
          final duration = 1;
          _appendBlock(blocks, id, time, duration); remain[id] = remain[id]! - duration; time += duration;
          if (nextArrival != null && time < nextArrival && remain[id]! > 0) {}
        } else {
          if (time < p.arrivalTime) time = p.arrivalTime;
          final duration = _algorithm == 'Round Robin' ? (remain[id]! < q ? remain[id]! : q) : p.burstTime;
          _appendBlock(blocks, id, time, duration); time += duration; remain[id] = remain[id]! - duration;
        }
      }
      setState(() { _result = result; _blocks = blocks; _error = null; });
    } catch (e) { setState(() => _error = e.toString().replaceFirst('FormatException: ', '')); }
  }
  void _appendBlock(List<_Block> list, String id, int start, int duration) { if (list.isNotEmpty && list.last.id == id && list.last.end == start) { list.last.end += duration; } else { list.add(_Block(id, start, start + duration)); } }

  @override Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SingleChildScrollView(padding: EdgeInsets.all(width < 700 ? 18 : 30), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1150), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _PageHeading(icon: Icons.memory_rounded, accent: AppTheme.cyan, eyebrow: 'PROCESS MANAGEMENT', title: 'CPU scheduling', subtitle: 'Choose how the processor shares time. Then watch the queue come alive.'),
      const SizedBox(height: 22),
      _panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.end, children: [SizedBox(width: 210, child: DropdownButtonFormField<String>(value: _algorithm, decoration: const InputDecoration(labelText: 'Scheduling algorithm'), items: _algorithms.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(), onChanged: (v) => setState(() => _algorithm = v!))), if (_algorithm == 'Round Robin') SizedBox(width: 120, child: TextField(controller: _quantum, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Time quantum'))), SizedBox(width: width < 650 ? double.infinity : 500, child: TextField(controller: _input, decoration: const InputDecoration(labelText: 'Processes', hintText: 'P1:arrival:burst:priority, P2:...'), maxLines: 2)), FilledButton.icon(onPressed: _run, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Run simulation'))]),
        const SizedBox(height: 9), Text('Format: PID:arrival:burst:priority  ·  Lower priority number runs first', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .48))),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Color(0xFFFF8292)))),
      ])),
      if (_result != null) ...[
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 12, children: [_metric('AVG WAIT', '${_result!.averageWaitingTime.toStringAsFixed(2)} units', AppTheme.cyan), _metric('AVG TURNAROUND', '${_result!.averageTurnaroundTime.toStringAsFixed(2)} units', AppTheme.violet), _metric('CPU BURSTS', '${_blocks.length}', AppTheme.blue)]),
        const SizedBox(height: 16),
        _panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _PanelTitle('Execution timeline', 'Each colored segment is a CPU dispatch.'), const SizedBox(height: 20), SizedBox(height: 84, child: LayoutBuilder(builder: (context, c) { final total = _blocks.isEmpty ? 1 : _blocks.last.end; return Stack(children: [Positioned(left: 0, right: 0, top: 7, child: Container(height: 1, color: Colors.white12)), for (var i=0; i<_blocks.length; i++) _TimelineSegment(block: _blocks[i], total: total, width: c.maxWidth, index: i), Positioned(left: 0, bottom: 0, child: Text('0', style: _axis)), Positioned(right: 0, bottom: 0, child: Text('$total', style: _axis))]); })), const SizedBox(height: 16), Wrap(spacing: 14, runSpacing: 8, children: {for (final b in _blocks) b.id}.map((id) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: _processColor(id), borderRadius: BorderRadius.circular(3))), const SizedBox(width: 6), Text(id, style: const TextStyle(fontSize: 11))])).toList())])),
        const SizedBox(height: 16), _panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _PanelTitle('Process report', 'Waiting and turnaround time for each process.'), const SizedBox(height: 12), SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [DataColumn(label: Text('PROCESS')), DataColumn(label: Text('WAITING')), DataColumn(label: Text('TURNAROUND'))], rows: _result!.waitingTime.keys.map((id) => DataRow(cells: [DataCell(Text(id)), DataCell(Text('${_result!.waitingTime[id]} units')), DataCell(Text('${_result!.turnaroundTime[id]} units'))])).toList()))]))
      ] else const SizedBox(height: 20),
    ]))));
  }
  Widget _metric(String label, String value, Color accent) => Container(width: 210, padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: const Color(0xFF111A2B), borderRadius: BorderRadius.circular(17), border: Border.all(color: accent.withValues(alpha: .23))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 9, letterSpacing: 1.2, color: accent, fontWeight: FontWeight.w800)), const SizedBox(height: 7), Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))]));
  static TextStyle get _axis => const TextStyle(fontSize: 9, color: Colors.white54);
}
class _Block { final String id; final int start; int end; _Block(this.id, this.start, this.end); }
Color _processColor(String id) { final colors = [AppTheme.cyan, AppTheme.blue, AppTheme.violet, const Color(0xFFFFB86B), const Color(0xFFFF7FA6)]; return colors[id.hashCode.abs() % colors.length]; }
class _TimelineSegment extends StatelessWidget { final _Block block; final int total; final double width; final int index; const _TimelineSegment({required this.block, required this.total, required this.width, required this.index}); @override Widget build(BuildContext context) { final left = width * block.start / total; final w = (width * (block.end - block.start) / total).clamp(22.0, width); return AnimatedPositioned(duration: Duration(milliseconds: 360 + index * 45), curve: Curves.easeOutCubic, left: left, top: 18, width: w, height: 40, child: Container(margin: const EdgeInsets.only(right: 2), decoration: BoxDecoration(color: _processColor(block.id).withValues(alpha: .18), border: Border.all(color: _processColor(block.id).withValues(alpha: .72)), borderRadius: BorderRadius.circular(9)), child: Center(child: Text(block.id, overflow: TextOverflow.fade, style: TextStyle(color: _processColor(block.id), fontWeight: FontWeight.w800, fontSize: 10))))); } }

class _PageHeading extends StatelessWidget { final IconData icon; final Color accent; final String eyebrow,title,subtitle; const _PageHeading({required this.icon, required this.accent, required this.eyebrow, required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: accent.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: accent)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(eyebrow, style: TextStyle(fontSize: 10, letterSpacing: 1.6, color: accent, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(title, style: const TextStyle(fontSize: 28, letterSpacing: -.6, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: .56), fontSize: 13))]))]); }
Widget _panel({required Widget child}) => Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF111A2B), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF263149))), child: child);
class _PanelTitle extends StatelessWidget { final String title,subtitle; const _PanelTitle(this.title,this.subtitle); @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .48)))]); }
