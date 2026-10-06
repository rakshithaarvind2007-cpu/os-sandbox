import 'processes.dart';

void priorityScheduling(
    List<Process> processes, List<int> priorities) {
  int currentTime = 0;
  int completed = 0;
  int n = processes.length;

  List<bool> isCompleted = List.filled(n, false);

  while (completed < n) {
    int selectedIndex = -1;

    // Find the highest-priority process that has arrived.
    // Smaller priority number = higher priority.
    for (int i = 0; i < n; i++) {
      if (!isCompleted[i] &&
          processes[i].arrivalTime <= currentTime) {
        if (selectedIndex == -1 ||
            priorities[i] < priorities[selectedIndex]) {
          selectedIndex = i;
        }
      }
    }

    // CPU is idle if no process has arrived
    if (selectedIndex == -1) {
      currentTime++;
      continue;
    }

    Process process = processes[selectedIndex];

    // Response Time
    process.responseTime =
        currentTime - process.arrivalTime;

    // Execute the process completely
    currentTime += process.burstTime;

    // Completion Time
    process.completionTime = currentTime;

    // Turnaround Time
    process.turnaroundTime =
        process.completionTime - process.arrivalTime;

    // Waiting Time
    process.waitingTime =
        process.turnaroundTime - process.burstTime;

    isCompleted[selectedIndex] = true;
    completed++;
  }
}