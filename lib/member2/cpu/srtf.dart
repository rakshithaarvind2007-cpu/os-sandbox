import 'processes.dart';

void srtf(List<Process> processes) {
  int n = processes.length;
  int completed = 0;
  int currentTime = 0;

  // Store remaining burst time for each process
  List<int> remainingTime =
  processes.map((p) => p.burstTime).toList();

  // Track whether a process has started execution
  List<bool> hasStarted = List.filled(n, false);

  while (completed < n) {
    int selectedIndex = -1;

    // Find the process with the shortest remaining time
    // among the processes that have arrived
    for (int i = 0; i < n; i++) {
      if (processes[i].arrivalTime <= currentTime &&
          remainingTime[i] > 0) {
        if (selectedIndex == -1 ||
            remainingTime[i] < remainingTime[selectedIndex]) {
          selectedIndex = i;
        }
      }
    }

    // If no process has arrived, move time forward
    if (selectedIndex == -1) {
      currentTime++;
      continue;
    }

    // Record response time when the process gets CPU for the first time
    if (!hasStarted[selectedIndex]) {
      processes[selectedIndex].responseTime =
          currentTime - processes[selectedIndex].arrivalTime;

      hasStarted[selectedIndex] = true;
    }

    // Execute the process for one unit of time
    remainingTime[selectedIndex]--;
    currentTime++;

    // Check if the process has completed
    if (remainingTime[selectedIndex] == 0) {
      processes[selectedIndex].completionTime = currentTime;

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