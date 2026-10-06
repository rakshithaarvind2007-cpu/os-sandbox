import 'processes.dart';

void mqs(
    List<Process> processes,
    int timeQuantum,
    List<int> queueNumbers,
    ) {
  int n = processes.length;
  int currentTime = 0;
  int completed = 0;

  List<int> remainingTime =
  processes.map((p) => p.burstTime).toList();

  List<bool> hasStarted = List.filled(n, false);
  List<bool> isCompleted = List.filled(n, false);

  // Queue 1 = High Priority (Round Robin)
  // Queue 2 = Low Priority (FCFS)

  while (completed < n) {
    // Find an arrived process from Queue 1
    int selectedIndex = -1;

    for (int i = 0; i < n; i++) {
      if (!isCompleted[i] &&
          queueNumbers[i] == 1 &&
          processes[i].arrivalTime <= currentTime) {
        selectedIndex = i;
        break;
      }
    }

    // If Queue 1 is empty, find a process from Queue 2
    if (selectedIndex == -1) {
      for (int i = 0; i < n; i++) {
        if (!isCompleted[i] &&
            queueNumbers[i] == 2 &&
            processes[i].arrivalTime <= currentTime) {
          selectedIndex = i;
          break;
        }
      }
    }

    // If no process has arrived, move time forward
    if (selectedIndex == -1) {
      currentTime++;
      continue;
    }

    // First CPU execution → Response Time
    if (!hasStarted[selectedIndex]) {
      processes[selectedIndex].responseTime =
          currentTime -
              processes[selectedIndex].arrivalTime;

      hasStarted[selectedIndex] = true;
    }

    int executionTime;

    if (queueNumbers[selectedIndex] == 1) {
      // Queue 1 → Round Robin
      executionTime =
      remainingTime[selectedIndex] < timeQuantum
          ? remainingTime[selectedIndex]
          : timeQuantum;
    } else {
      // Queue 2 → FCFS
      executionTime = remainingTime[selectedIndex];
    }

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
    }
  }
}