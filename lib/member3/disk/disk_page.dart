import 'dart:async';
import 'package:flutter/material.dart';
import 'disk_algorithms.dart';

class DiskPage extends StatefulWidget {
  const DiskPage({super.key});
  @override
  State<DiskPage> createState() => _DiskPageState();
}

class _DiskPageState extends State<DiskPage> {
  final _requests = TextEditingController(
    text: '98, 183, 37, 122, 14, 124, 65, 67',
  );
  final _head = TextEditingController(text: '53');
  final _size = TextEditingController(text: '200');
  static const _algorithms = [
    'FCFS',
    'SSTF',
    'SCAN',
    'C-SCAN',
    'LOOK',
    'C-LOOK',
  ];
  String _algorithm = 'FCFS';
  String _direction = 'Right';
  DiskResult? _result;
  String? _error;
  int _parsedHead = 53;
  int _diskSize = 200;
  int _visibleRequests = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _requests.dispose();
    _head.dispose();
    _size.dispose();
    super.dispose();
  }

  List<int> _parseRequests() {
    final raw = _requests.text.trim();
    if (raw.isEmpty) throw const FormatException('Request queue is required.');
    final tokens = raw.split(',').map((s) => s.trim()).toList();
    if (tokens.length > 24)
      throw const FormatException(
        'Enter at most 24 requests for a readable walkthrough.',
      );
    if (tokens.any((s) => s.isEmpty))
      throw const FormatException(
        'Separate requests with commas and remove empty items.',
      );
    return List<int>.generate(tokens.length, (i) {
      final value = int.tryParse(tokens[i]);
      if (value == null)
        throw FormatException(
          'Request ${i + 1} must be a whole cylinder number.',
        );
      return value;
    });
  }

  void _run() {
    _timer?.cancel();
    setState(() {
      _result = null;
      _error = null;
      _visibleRequests = 0;
    });
    try {
      final requests = _parseRequests();
      final head = int.tryParse(_head.text.trim());
      final size = int.tryParse(_size.text.trim());
      if (head == null)
        throw const FormatException(
          'Initial head position must be a whole number.',
        );
      if (size == null)
        throw const FormatException('Disk size must be a whole number.');
      if (size < 2 || size > 10000)
        throw const FormatException(
          'Disk size must be from 2 to 10,000 cylinders.',
        );
      if (head < 0 || head >= size)
        throw FormatException(
          'Head position must be between 0 and ${size - 1}.',
        );
      for (var i = 0; i < requests.length; i++) {
        if (requests[i] < 0 || requests[i] >= size)
          throw FormatException(
            'Request ${i + 1} must be between 0 and ${size - 1}.',
          );
      }
      final calculated = switch (_algorithm) {
        'FCFS' => fcfs(requests: requests, head: head),
        'SSTF' => sstf(requests: requests, head: head),
        'SCAN' => scan(
          requests: requests,
          head: head,
          diskSize: size,
          direction: _direction,
        ),
        'C-SCAN' => cscan(
          requests: requests,
          head: head,
          diskSize: size,
          direction: _direction,
        ),
        'LOOK' => look(requests: requests, head: head, direction: _direction),
        'C-LOOK' => clook(
          requests: requests,
          head: head,
          direction: _direction,
        ),
        _ => throw const FormatException('Select a disk scheduling algorithm.'),
      };
      setState(() {
        _parsedHead = head;
        _diskSize = size;
        _result = calculated;
      });
      _play();
    } on FormatException catch (e) {
      setState(() {
        _error = e.message;
        _result = null;
      });
    } catch (_) {
      setState(() {
        _error =
            'Could not schedule these requests. Check the values and try again.';
        _result = null;
      });
    }
  }

  void _play() {
    _timer?.cancel();
    final result = _result;
    if (result == null) return;
    setState(() => _visibleRequests = 0);
    _timer = Timer.periodic(const Duration(milliseconds: 480), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(
        () => _visibleRequests = (_visibleRequests + 1)
            .clamp(0, result.trajectory.length)
            .toInt(),
      );
      if (_visibleRequests >= result.trajectory.length) timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final needsDirection = const {
      'SCAN',
      'C-SCAN',
      'LOOK',
      'C-LOOK',
    }.contains(_algorithm);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DiskHeading(),
              const SizedBox(height: 22),
              _inputs(needsDirection),
              if (_error != null) ...[
                const SizedBox(height: 14),
                _errorCard(_error!),
              ],
              if (_result != null) ...[
                const SizedBox(height: 20),
                _visualization(_result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputs(bool needsDirection) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final queueWidth = screenWidth < 700 ? screenWidth - 72 : 430.0;
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
            'Disk request setup',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: queueWidth,
                child: TextField(
                  controller: _requests,
                  decoration: const InputDecoration(
                    labelText: 'Request queue',
                    hintText: '98, 183, 37, 122',
                    helperText: 'Whole numbers separated by commas',
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              SizedBox(
                width: 190,
                child: TextField(
                  controller: _head,
                  decoration: const InputDecoration(
                    labelText: 'Initial head',
                    hintText: '0 to size − 1',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                ),
              ),
              SizedBox(
                width: 190,
                child: TextField(
                  controller: _size,
                  decoration: const InputDecoration(
                    labelText: 'Disk size',
                    hintText: '2 to 10,000',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  value: _algorithm,
                  decoration: const InputDecoration(labelText: 'Algorithm'),
                  items: _algorithms
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _timer?.cancel();
                      setState(() {
                        _algorithm = value;
                        _result = null;
                        _visibleRequests = 0;
                      });
                    }
                  },
                ),
              ),
              if (needsDirection)
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<String>(
                    value: _direction,
                    decoration: const InputDecoration(
                      labelText: 'Scan direction',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Right', child: Text('Right')),
                      DropdownMenuItem(value: 'Left', child: Text('Left')),
                    ],
                    onChanged: (value) {
                      if (value != null)
                        setState(() {
                          _direction = value;
                          _result = null;
                          _visibleRequests = 0;
                        });
                    },
                  ),
                ),
              FilledButton.icon(
                onPressed: _run,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Run disk walk'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _visualization(DiskResult result) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Head trajectory · step by step',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: _play,
            tooltip: 'Replay head movement',
            icon: const Icon(Icons.replay_rounded, color: Color(0xFF62F4D4)),
          ),
        ],
      ),
      Text(
        '$_visibleRequests of ${result.trajectory.length} head path stops',
        style: const TextStyle(color: Color(0xFF9DAAC4), fontSize: 12),
      ),
      const SizedBox(height: 12),
      Container(
        height: 265,
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111A2B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF263149)),
        ),
        child: CustomPaint(
          painter: DiskTrajectoryPainter(
            head: _parsedHead,
            order: result.trajectory,
            diskSize: _diskSize,
            visibleRequests: _visibleRequests,
          ),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _metric('ALGORITHM', _algorithm, const Color(0xFF62F4D4)),
          _metric(
            'HEAD MOVEMENT',
            '${result.totalHeadMovement} cylinders',
            const Color(0xFF7D9BFF),
          ),
          _metric(
            'HEAD PATH SO FAR',
            '$_parsedHead → ${result.trajectory.take(_visibleRequests).join(' → ')}',
            const Color(0xFFB78CFF),
          ),
        ],
      ),
    ],
  );

  Widget _metric(String title, String value, Color color) => Container(
    width: 250,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFF111A2B),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: color.withValues(alpha: .24)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.2,
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Widget _errorCard(String message) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
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
}

class _DiskHeading extends StatelessWidget {
  const _DiskHeading();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Icon(Icons.album_rounded, color: Color(0xFF62F4D4), size: 32),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STORAGE MANAGEMENT',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: Color(0xFF62F4D4),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Disk scheduling',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    ],
  );
}

class DiskTrajectoryPainter extends CustomPainter {
  final int head;
  final List<int> order;
  final int diskSize;
  final int visibleRequests;
  DiskTrajectoryPainter({
    required this.head,
    required this.order,
    required this.diskSize,
    required this.visibleRequests,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final points = <int>[head, ...order.take(visibleRequests)];
    final axisPaint = Paint()
      ..color = const Color(0xFF526078)
      ..strokeWidth = 1.5;
    final linePaint = Paint()
      ..color = const Color(0xFF62F4D4)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final nodePaint = Paint()..color = const Color(0xFF7D9BFF);
    final startPaint = Paint()..color = const Color(0xFF62F4D4);
    canvas.drawLine(
      Offset(0, size.height - 8),
      Offset(size.width, size.height - 8),
      axisPaint,
    );
    double xPos(int cylinder) => (cylinder / (diskSize - 1)) * size.width;
    double yPos(int index) => (index / order.length) * (size.height - 30) + 12;
    if (points.length > 1) {
      final path = Path()..moveTo(xPos(points.first), yPos(0));
      for (var i = 1; i < points.length; i++) {
        path.lineTo(xPos(points[i]), yPos(i));
      }
      canvas.drawPath(path, linePaint);
    }
    for (var i = 0; i < points.length; i++) {
      final point = Offset(xPos(points[i]), yPos(i));
      canvas.drawCircle(
        point,
        i == 0 ? 6 : 4.5,
        i == 0 ? startPaint : nodePaint,
      );
      if (i > 0) {
        final label = TextPainter(
          text: TextSpan(
            text: '${points[i]}',
            style: const TextStyle(
              color: Color(0xFFDDE6F8),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        label.paint(canvas, point + const Offset(5, -15));
      }
    }
    final first = TextPainter(
      text: const TextSpan(
        text: '0',
        style: TextStyle(color: Color(0xFF9DAAC4), fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final last = TextPainter(
      text: TextSpan(
        text: '${diskSize - 1}',
        style: const TextStyle(color: Color(0xFF9DAAC4), fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    first.paint(canvas, Offset(0, size.height - 7));
    last.paint(canvas, Offset(size.width - last.width, size.height - 7));
  }

  @override
  bool shouldRepaint(covariant DiskTrajectoryPainter old) =>
      old.head != head ||
      old.order != order ||
      old.diskSize != diskSize ||
      old.visibleRequests != visibleRequests;
}
