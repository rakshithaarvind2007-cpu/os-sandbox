import 'processes.dart';

void preemptivePBS(
    List<Process> processes, List<int> priorities) {
  int n = processes.length;
  int currentTime = 0;
  int completed = 0;

  List<int> remainingTime =
  processes.map((p) => p.burstTime).toList();

  List<bool> hasStarted = List.filled(n, false);

  while (completed < n) {
    int selectedIndex = -1;

    // Find the highest-priority process that has arrived.
    // Smaller priority number = higher priority.
    for (int i = 0; i < n; i++) {
      if (processes[i].arrivalTime <= currentTime &&
          remainingTime[i] > 0) {
        if (selectedIndex == -1 ||
            priorities[i] < priorities[selectedIndex]) {
          selectedIndex = i;
        }
      }
    }

    // If no process has arrived, move time forward
    if (selectedIndex == -1) {
      currentTime++;
      continue;
    }

    // Record response time when process gets CPU
    // for the first time
    if (!hasStarted[selectedIndex]) {
      processes[selectedIndex].responseTime =
          currentTime -
              processes[selectedIndex].arrivalTime;

      hasStarted[selectedIndex] = true;
    }

    // Execute for one unit of time
    remainingTime[selectedIndex]--;
    currentTime++;

    // Check if process has completed
    if (remainingTime[selectedIndex] == 0) {
      processes[selectedIndex].completionTime =
          currentTime;

      processes[selectedIndex].turnaroundTime =
          processes[selectedIndex].completionTime -
              processes[selectedIndex].arrivalTime;

      processes[selectedIndex].waitingTime =
          processes[selectedIndex].turnaroundTime -
              processes[selectedIndex].burstTime;

      completed++;
    }
  }
}