import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'disk_algorithms.dart';

class DiskPage extends StatefulWidget {
  const DiskPage({super.key});

  @override
  State<DiskPage> createState() => _DiskPageState();
}

class _DiskPageState extends State<DiskPage> {
  final TextEditingController requestsController = TextEditingController(
    text: '98, 183, 37, 122, 14, 124, 65, 67',
  );

  final TextEditingController headController = TextEditingController(
    text: '53',
  );

  final TextEditingController diskSizeController = TextEditingController(
    text: '200',
  );

  String selectedAlgorithm = 'FCFS';
  String selectedDirection = 'Right';

  DiskResult? result;
  String? errorMessage;
  int parsedHead = 53;
  int parsedDiskSize = 200;

  final List<String> algorithms = [
    'FCFS',
    'SSTF',
    'SCAN',
    'C-SCAN',
    'LOOK',
    'C-LOOK',
  ];

  List<int> parseRequests(String input) {
    return input.split(',').map((value) => int.parse(value.trim())).toList();
  }

  void runAlgorithm() {
    setState(() {
      errorMessage = null;
      result = null;
    });

    try {
      final requests = parseRequests(requestsController.text);
      final head = int.parse(headController.text.trim());
      final diskSize = int.parse(diskSizeController.text.trim());

      if (requests.isEmpty) {
        throw Exception('Enter at least one request.');
      }

      if (diskSize <= 0) {
        throw Exception('Disk size must be greater than 0.');
      }

      if (head < 0 || head >= diskSize) {
        throw Exception(
          'Initial head position must be between 0 and ${diskSize - 1}.',
        );
      }

      for (int request in requests) {
        if (request < 0 || request >= diskSize) {
          throw Exception(
            'Every request must be between 0 and ${diskSize - 1}.',
          );
        }
      }

      DiskResult calculatedResult;

      switch (selectedAlgorithm) {
        case 'FCFS':
          calculatedResult = fcfs(requests: requests, head: head);
          break;

        case 'SSTF':
          calculatedResult = sstf(requests: requests, head: head);
          break;

        case 'SCAN':
          calculatedResult = scan(
            requests: requests,
            head: head,
            diskSize: diskSize,
            direction: selectedDirection,
          );
          break;

        case 'C-SCAN':
          calculatedResult = cscan(
            requests: requests,
            head: head,
            diskSize: diskSize,
            direction: selectedDirection,
          );
          break;

        case 'LOOK':
          calculatedResult = look(
            requests: requests,
            head: head,
            direction: selectedDirection,
          );
          break;

        case 'C-LOOK':
          calculatedResult = clook(
            requests: requests,
            head: head,
            direction: selectedDirection,
          );
          break;

        default:
          throw Exception('Invalid algorithm selected.');
      }

      setState(() {
        parsedHead = head;
        parsedDiskSize = diskSize;
        result = calculatedResult;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool needsDirection =
        selectedAlgorithm == 'SCAN' ||
        selectedAlgorithm == 'C-SCAN' ||
        selectedAlgorithm == 'LOOK' ||
        selectedAlgorithm == 'C-LOOK';

    return Scaffold(
      appBar: AppBar(title: const Text('Disk Scheduling Visualizer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disk Scheduling Simulator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            buildInputField(
              label: 'Request Queue',
              controller: requestsController,
              hint: 'Example: 98, 183, 37, 122',
            ),
            const SizedBox(height: 16),
            buildInputField(
              label: 'Initial Head Position',
              controller: headController,
              hint: 'Example: 53',
            ),
            const SizedBox(height: 16),
            buildInputField(
              label: 'Disk Size (Cylinders)',
              controller: diskSizeController,
              hint: 'Example: 200',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedAlgorithm,
              decoration: const InputDecoration(
                labelText: 'Algorithm',
                border: OutlineInputBorder(),
              ),
              items: algorithms.map((algorithm) {
                return DropdownMenuItem(
                  value: algorithm,
                  child: Text(algorithm),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedAlgorithm = value;
                    result = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            if (needsDirection)
              DropdownButtonFormField<String>(
                initialValue: selectedDirection,
                decoration: const InputDecoration(
                  labelText: 'Direction',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Right', child: Text('Right')),
                  DropdownMenuItem(value: 'Left', child: Text('Left')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedDirection = value;
                      result = null;
                    });
                  }
                },
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: runAlgorithm,
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text('Run Algorithm', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 20),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red.shade900, fontSize: 16),
                  ),
                ),
              ),
            ],
            if (result != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Head Trajectory Visualization',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: CustomPaint(
                          painter: DiskTrajectoryPainter(
                            head: parsedHead,
                            order: result!.order,
                            diskSize: parsedDiskSize,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                          Text('Cylinders (0 to ${parsedDiskSize - 1})', style: TextStyle(color: Colors.grey.shade700)),
                          Text('${parsedDiskSize - 1}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Sequence',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$parsedHead → ${result!.order.join(' → ')}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Total Head Movement',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${result!.totalHeadMovement} cylinders',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    requestsController.dispose();
    headController.dispose();
    diskSizeController.dispose();
    super.dispose();
  }
}

class DiskTrajectoryPainter extends CustomPainter {
  final int head;
  final List<int> order;
  final int diskSize;

  DiskTrajectoryPainter({
    required this.head,
    required this.order,
    required this.diskSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final List<int> points = [head, ...order];
    if (points.length < 2) return;

    final Paint axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2;

    final Paint linePaint = Paint()
      ..color = Colors.blue.shade600
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final Paint nodePaint = Paint()
      ..color = Colors.blue.shade800
      ..style = PaintingStyle.fill;

    final Paint startNodePaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;

    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint);

    double xPos(int cylinder) => (cylinder / (diskSize - 1)) * size.width;
    double yPos(int index) => (index / (points.length - 1)) * (size.height - 20) + 10;

    final Path path = Path();
    path.moveTo(xPos(points[0]), yPos(0));

    for (int i = 1; i < points.length; i++) {
      path.lineTo(xPos(points[i]), yPos(i));
    }

    canvas.drawPath(path, linePaint);

    for (int i = 0; i < points.length; i++) {
      final double x = xPos(points[i]);
      final double y = yPos(i);

      canvas.drawCircle(
        Offset(x, y),
        i == 0 ? 6 : 4,
        i == 0 ? startNodePaint : nodePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DiskTrajectoryPainter oldDelegate) {
    return oldDelegate.head != head ||
        oldDelegate.order != order ||
        oldDelegate.diskSize != diskSize;
  }
}