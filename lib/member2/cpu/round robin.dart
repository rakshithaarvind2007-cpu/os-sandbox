import 'processes.dart';

void roundRobin(List<Process> processes, int timeQuantum) {
  int n = processes.length;
  int currentTime = 0;
  int completed = 0;

  List<int> remainingTime =
  processes.map((p) => p.burstTime).toList();

  List<bool> hasStarted = List.filled(n, false);
  List<bool> inQueue = List.filled(n, false);

  List<int> queue = [];

  while (completed < n) {
    // Add all processes that have arrived
    for (int i = 0; i < n; i++) {
      if (!inQueue[i] &&
          remainingTime[i] > 0 &&
          processes[i].arrivalTime <= currentTime) {
        queue.add(i);
        inQueue[i] = true;
      }
    }

    // If queue is empty, move time to the next arriving process
    if (queue.isEmpty) {
      int nextArrival = -1;

      for (int i = 0; i < n; i++) {
        if (remainingTime[i] > 0) {
          if (nextArrival == -1 ||
              processes[i].arrivalTime < nextArrival) {
            nextArrival = processes[i].arrivalTime;
          }
        }
      }

      currentTime = nextArrival;
      continue;
    }

    // Take the first process from the queue
    int index = queue.removeAt(0);

    // Record response time when process gets CPU for the first time
    if (!hasStarted[index]) {
      processes[index].responseTime =
          currentTime - processes[index].arrivalTime;

      hasStarted[index] = true;
    }

    // Execute for one time quantum or until completion
    int executionTime =
    remainingTime[index] < timeQuantum
        ? remainingTime[index]
        : timeQuantum;

    currentTime += executionTime;
    remainingTime[index] -= executionTime;

    // Add newly arrived processes to the queue
    for (int i = 0; i < n; i++) {
      if (!inQueue[i] &&
          remainingTime[i] > 0 &&
          processes[i].arrivalTime <= currentTime) {
        queue.add(i);
        inQueue[i] = true;
      }
    }

    // If process is not finished, put it back into the queue
    if (remainingTime[index] > 0) {
      queue.add(index);
    } else {
      // Process completed
      processes[index].completionTime = currentTime;

      processes[index].turnaroundTime =
          processes[index].completionTime -
              processes[index].arrivalTime;

      processes[index].waitingTime =
          processes[index].turnaroundTime -
              processes[index].burstTime;

      completed++;
    }
  }
}