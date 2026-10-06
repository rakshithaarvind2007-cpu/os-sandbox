import 'processes.dart';

void feedbackQueue(List<Process> processes) {
  int n = processes.length;
  int currentTime = 0;
  int completed = 0;

  List<int> remainingTime =
  processes.map((p) => p.burstTime).toList();

  List<int> queueLevel = List.filled(n, 1);

  List<bool> hasStarted = List.filled(n, false);
  List<bool> isCompleted = List.filled(n, false);

  List<int> queue1 = [];
  List<int> queue2 = [];
  List<int> queue3 = [];

  while (completed < n) {
    // Add newly arrived processes to Queue 1
    for (int i = 0; i < n; i++) {
      if (!isCompleted[i] &&
          processes[i].arrivalTime <= currentTime &&
          queueLevel[i] == 1 &&
          !queue1.contains(i) &&
          !queue2.contains(i) &&
          !queue3.contains(i)) {
        queue1.add(i);
      }
    }

    // If Queue 1 is empty, check Queue 2
    if (queue1.isEmpty) {
      for (int i = 0; i < n; i++) {
        if (!isCompleted[i] &&
            processes[i].arrivalTime <= currentTime &&
            queueLevel[i] == 2 &&
            !queue2.contains(i) &&
            !queue3.contains(i)) {
          queue2.add(i);
        }
      }
    }

    // If Queue 1 and Queue 2 are empty, check Queue 3
    if (queue1.isEmpty && queue2.isEmpty) {
      for (int i = 0; i < n; i++) {
        if (!isCompleted[i] &&
            processes[i].arrivalTime <= currentTime &&
            queueLevel[i] == 3 &&
            !queue3.contains(i)) {
          queue3.add(i);
        }
      }
    }

    // Select process from highest-priority queue
    int selectedIndex = -1;
    int quantum = 0;

    if (queue1.isNotEmpty) {
      selectedIndex = queue1.removeAt(0);
      quantum = 2;
    } else if (queue2.isNotEmpty) {
      selectedIndex = queue2.removeAt(0);
      quantum = 4;
    } else if (queue3.isNotEmpty) {
      selectedIndex = queue3.removeAt(0);
      quantum = remainingTime[selectedIndex];
    }

    // No process available
    if (selectedIndex == -1) {
      currentTime++;
      continue;
    }

    // Record response time
    if (!hasStarted[selectedIndex]) {
      processes[selectedIndex].responseTime =
          currentTime -
              processes[selectedIndex].arrivalTime;

      hasStarted[selectedIndex] = true;
    }

    // Execute process
    int executionTime =
    remainingTime[selectedIndex] < quantum
        ? remainingTime[selectedIndex]
        : quantum;

    currentTime += executionTime;
    remainingTime[selectedIndex] -= executionTime;

    // Process completed
    if (remainingTime[selectedIndex] == 0) {
      processes[selectedIndex].completionTime =
          currentTime;

      processes[selectedIndex].turnaroundTime =
          processes[selectedIndex].completionTime -
              processes[selectedIndex].arrivalTime;

      processes[selectedIndex].waitingTime =
          processes[selectedIndex].turnaroundTime -
              processes[selectedIndex].burstTime;

      isCompleted[selectedIndex] = true;
      completed++;
    } else {
      // Move process to the next lower queue
      if (queueLevel[selectedIndex] == 1) {
        queueLevel[selectedIndex] = 2;
        queue2.add(selectedIndex);
      } else if (queueLevel[selectedIndex] == 2) {
        queueLevel[selectedIndex] = 3;
        queue3.add(selectedIndex);
      } else {
        // Remain in Queue 3
        queue3.add(selectedIndex);
      }
    }
  }
}