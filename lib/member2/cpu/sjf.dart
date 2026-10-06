import 'processes.dart';

void sjf(List<Process> processes) {
  int currentTime = 0;
  int completed = 0;
  int n = processes.length;

  // Keep track of which processes have been completed
  List<bool> isCompleted = List.filled(n, false);

  while (completed < n) {
    Process? selectedProcess;
    int selectedIndex = -1;

    // Find the process with the shortest burst time
    // among the processes that have already arrived
    for (int i = 0; i < n; i++) {
      if (!isCompleted[i] &&
          processes[i].arrivalTime <= currentTime) {

        if (selectedProcess == null ||
            processes[i].burstTime < selectedProcess.burstTime) {
          selectedProcess = processes[i];
          selectedIndex = i;
        }
      }
    }

    // If no process has arrived, move time forward
    if (selectedProcess == null) {
      int nextArrival = -1;

      for (int i = 0; i < n; i++) {
        if (!isCompleted[i]) {
          if (nextArrival == -1 ||
              processes[i].arrivalTime < nextArrival) {
            nextArrival = processes[i].arrivalTime;
          }
        }
      }

      currentTime = nextArrival;
      continue;
    }

    // Response Time = first CPU start time - Arrival Time
    selectedProcess.responseTime =
        currentTime - selectedProcess.arrivalTime;

    // Execute the selected process
    currentTime += selectedProcess.burstTime;

    // Completion Time
    selectedProcess.completionTime = currentTime;

    // Turnaround Time = Completion Time - Arrival Time
    selectedProcess.turnaroundTime =
        selectedProcess.completionTime -
            selectedProcess.arrivalTime;

    // Waiting Time = Turnaround Time - Burst Time
    selectedProcess.waitingTime =
        selectedProcess.turnaroundTime -
            selectedProcess.burstTime;

    // Mark process as completed
    isCompleted[selectedIndex] = true;
    completed++;
  }
}