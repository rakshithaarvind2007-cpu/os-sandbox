import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('Disk Scheduling')),
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
              label: 'Disk Size',
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
                setState(() {
                  selectedAlgorithm = value!;
                  result = null;
                });
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
                  setState(() {
                    selectedDirection = value!;
                    result = null;
                  });
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            ],

            if (result != null) ...[
              const SizedBox(height: 24),

              const Text(
                'Result',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Order',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '${headController.text} → '
                        '${result!.order.join(' → ')}',
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Total Head Movement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '${result!.totalHeadMovement} cylinders',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
