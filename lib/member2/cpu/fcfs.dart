import 'processes.dart';

void fcfs(List<Process> processes) {
  // Sort processes according to Arrival Time
  processes.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

  int currentTime = 0;

  for (Process process in processes) {
    // CPU remains idle if the process hasn't arrived yet
    if (currentTime < process.arrivalTime) {
      currentTime = process.arrivalTime;
    }

    // Response Time = first CPU start time - Arrival Time
    process.responseTime = currentTime - process.arrivalTime;

    // Process executes
    currentTime += process.burstTime;

    // Completion Time
    process.completionTime = currentTime;

    // Turnaround Time = Completion Time - Arrival Time
    process.turnaroundTime =
        process.completionTime - process.arrivalTime;

    // Waiting Time = Turnaround Time - Burst Time
    process.waitingTime =
        process.turnaroundTime - process.burstTime;
  }
}