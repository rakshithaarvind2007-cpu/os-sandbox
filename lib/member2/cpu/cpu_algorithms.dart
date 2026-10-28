class Process {
  String id;
  int arrivalTime;
  int burstTime;
  int priority;

  Process({
    required this.id,
    required this.arrivalTime,
    required this.burstTime,
    this.priority = 0,
  });
}

class SchedulingResult {
  List<String> executionOrder;
  Map<String, int> waitingTime;
  Map<String, int> turnaroundTime;
  double averageWaitingTime;
  double averageTurnaroundTime;

  SchedulingResult({
    required this.executionOrder,
    required this.waitingTime,
    required this.turnaroundTime,
    required this.averageWaitingTime,
    required this.averageTurnaroundTime,
  });
}

// FCFS
SchedulingResult fcfs(List<Process> input) {
  List<Process> processes = List.from(input);

  processes.sort((a, b) {
    int result = a.arrivalTime.compareTo(b.arrivalTime);
    if (result != 0) return result;
    return a.id.compareTo(b.id);
  });

  int currentTime = 0;
  List<String> executionOrder = [];
  Map<String, int> waitingTime = {};
  Map<String, int> turnaroundTime = {};

  for (Process process in processes) {
    if (currentTime < process.arrivalTime) {
      currentTime = process.arrivalTime;
    }

    waitingTime[process.id] =
        currentTime - process.arrivalTime;

    currentTime += process.burstTime;

    turnaroundTime[process.id] =
        currentTime - process.arrivalTime;

    executionOrder.add(process.id);
  }

  double averageWaitingTime =
      waitingTime.values.reduce((a, b) => a + b) /
          processes.length;

  double averageTurnaroundTime =
      turnaroundTime.values.reduce((a, b) => a + b) /
          processes.length;

  return SchedulingResult(
    executionOrder: executionOrder,
    waitingTime: waitingTime,
    turnaroundTime: turnaroundTime,
    averageWaitingTime: averageWaitingTime,
    averageTurnaroundTime: averageTurnaroundTime,
  );
}

// SJF
SchedulingResult sjf(List<Process> input) {
  List<Process> processes = List.from(input);

  int currentTime = 0;
  int completed = 0;

  List<String> executionOrder = [];
  Map<String, int> waitingTime = {};
  Map<String, int> turnaroundTime = {};
  Set<String> completedIds = {};

  while (completed < processes.length) {
    List<Process> available = processes.where((process) {
      return process.arrivalTime <= currentTime &&
          !completedIds.contains(process.id);
    }).toList();

    if (available.isEmpty) {
      int nextArrival = processes
          .where((process) => !completedIds.contains(process.id))
          .map((process) => process.arrivalTime)
          .reduce((a, b) => a < b ? a : b);

      currentTime = nextArrival;
      continue;
    }

    available.sort((a, b) {
      int result = a.burstTime.compareTo(b.burstTime);

      if (result != 0) return result;

      result = a.arrivalTime.compareTo(b.arrivalTime);

      if (result != 0) return result;

      return a.id.compareTo(b.id);
    });

    Process selected = available.first;

    waitingTime[selected.id] =
        currentTime - selected.arrivalTime;

    currentTime += selected.burstTime;

    turnaroundTime[selected.id] =
        currentTime - selected.arrivalTime;

    executionOrder.add(selected.id);
    completedIds.add(selected.id);
    completed++;
  }

  double averageWaitingTime =
      waitingTime.values.reduce((a, b) => a + b) /
          processes.length;

  double averageTurnaroundTime =
      turnaroundTime.values.reduce((a, b) => a + b) /
          processes.length;

  return SchedulingResult(
    executionOrder: executionOrder,
    waitingTime: waitingTime,
    turnaroundTime: turnaroundTime,
    averageWaitingTime: averageWaitingTime,
    averageTurnaroundTime: averageTurnaroundTime,
  );
}

// Priority Scheduling
SchedulingResult priorityScheduling(List<Process> input) {
  List<Process> processes = List.from(input);

  int currentTime = 0;
  int completed = 0;

  List<String> executionOrder = [];
  Map<String, int> waitingTime = {};
  Map<String, int> turnaroundTime = {};
  Set<String> completedIds = {};

  while (completed < processes.length) {
    List<Process> available = processes.where((process) {
      return process.arrivalTime <= currentTime &&
          !completedIds.contains(process.id);
    }).toList();

    if (available.isEmpty) {
      int nextArrival = processes
          .where((process) => !completedIds.contains(process.id))
          .map((process) => process.arrivalTime)
          .reduce((a, b) => a < b ? a : b);

      currentTime = nextArrival;
      continue;
    }

    available.sort((a, b) {
      int result = a.priority.compareTo(b.priority);

      if (result != 0) return result;

      result = a.arrivalTime.compareTo(b.arrivalTime);

      if (result != 0) return result;

      return a.id.compareTo(b.id);
    });

    Process selected = available.first;

    waitingTime[selected.id] =
        currentTime - selected.arrivalTime;

    currentTime += selected.burstTime;

    turnaroundTime[selected.id] =
        currentTime - selected.arrivalTime;

    executionOrder.add(selected.id);
    completedIds.add(selected.id);
    completed++;
  }

  double averageWaitingTime =
      waitingTime.values.reduce((a, b) => a + b) /
          processes.length;

  double averageTurnaroundTime =
      turnaroundTime.values.reduce((a, b) => a + b) /
          processes.length;

  return SchedulingResult(
    executionOrder: executionOrder,
    waitingTime: waitingTime,
    turnaroundTime: turnaroundTime,
    averageWaitingTime: averageWaitingTime,
    averageTurnaroundTime: averageTurnaroundTime,
  );
}

// Round Robin
SchedulingResult roundRobin(
  List<Process> input,
  int timeQuantum,
) {
  if (timeQuantum <= 0) {
    throw ArgumentError('Time quantum must be greater than 0');
  }

  List<Process> processes = List.from(input);

  processes.sort((a, b) {
    int result = a.arrivalTime.compareTo(b.arrivalTime);

    if (result != 0) return result;

    return a.id.compareTo(b.id);
  });

  int currentTime = 0;
  int nextProcess = 0;

  List<String> executionOrder = [];
  Map<String, int> waitingTime = {};
  Map<String, int> turnaroundTime = {};
  Map<String, int> remainingTime = {};

  for (Process process in processes) {
    remainingTime[process.id] = process.burstTime;
  }

  List<Process> queue = [];

  while (nextProcess < processes.length || queue.isNotEmpty) {
    while (nextProcess < processes.length &&
        processes[nextProcess].arrivalTime <= currentTime) {
      queue.add(processes[nextProcess]);
      nextProcess++;
    }

    if (queue.isEmpty) {
      currentTime = processes[nextProcess].arrivalTime;
      continue;
    }

    Process selected = queue.removeAt(0);

    int remaining = remainingTime[selected.id]!;

    int runTime =
        remaining < timeQuantum ? remaining : timeQuantum;

    executionOrder.add(selected.id);

    currentTime += runTime;
    remaining -= runTime;

    remainingTime[selected.id] = remaining;

    while (nextProcess < processes.length &&
        processes[nextProcess].arrivalTime <= currentTime) {
      queue.add(processes[nextProcess]);
      nextProcess++;
    }

    if (remaining > 0) {
      queue.add(selected);
    } else {
      turnaroundTime[selected.id] =
          currentTime - selected.arrivalTime;

      waitingTime[selected.id] =
          turnaroundTime[selected.id]! - selected.burstTime;
    }
  }

  double averageWaitingTime =
      waitingTime.values.reduce((a, b) => a + b) /
          processes.length;

  double averageTurnaroundTime =
      turnaroundTime.values.reduce((a, b) => a + b) /
          processes.length;

  return SchedulingResult(
    executionOrder: executionOrder,
    waitingTime: waitingTime,
    turnaroundTime: turnaroundTime,
    averageWaitingTime: averageWaitingTime,
    averageTurnaroundTime: averageTurnaroundTime,
  );
}

// SRTF
SchedulingResult srtf(List<Process> input) {
  List<Process> processes = List.from(input);

  Map<String, int> remainingTime = {};
  Map<String, int> completionTime = {};

  for (Process process in processes) {
    remainingTime[process.id] = process.burstTime;
  }

  int currentTime = 0;
  int completed = 0;

  List<String> executionOrder = [];

  while (completed < processes.length) {
    List<Process> available = processes.where((process) {
      return process.arrivalTime <= currentTime &&
          remainingTime[process.id]! > 0;
    }).toList();

    if (available.isEmpty) {
      int nextArrival = processes
          .where((process) => remainingTime[process.id]! > 0)
          .map((process) => process.arrivalTime)
          .reduce((a, b) => a < b ? a : b);

      currentTime = nextArrival;
      continue;
    }

    available.sort((a, b) {
      int result =
          remainingTime[a.id]!.compareTo(remainingTime[b.id]!);

      if (result != 0) return result;

      result = a.arrivalTime.compareTo(b.arrivalTime);

      if (result != 0) return result;

      return a.id.compareTo(b.id);
    });

    Process selected = available.first;

    executionOrder.add(selected.id);

    remainingTime[selected.id] =
        remainingTime[selected.id]! - 1;

    currentTime++;

    if (remainingTime[selected.id] == 0) {
      completionTime[selected.id] = currentTime;
      completed++;
    }
  }

  Map<String, int> waitingTime = {};
  Map<String, int> turnaroundTime = {};

  for (Process process in processes) {
    int turnaround =
        completionTime[process.id]! - process.arrivalTime;

    int waiting =
        turnaround - process.burstTime;

    turnaroundTime[process.id] = turnaround;
    waitingTime[process.id] = waiting;
  }

  double averageWaitingTime =
      waitingTime.values.reduce((a, b) => a + b) /
          processes.length;

  double averageTurnaroundTime =
      turnaroundTime.values.reduce((a, b) => a + b) /
          processes.length;

  return SchedulingResult(
    executionOrder: executionOrder,
    waitingTime: waitingTime,
    turnaroundTime: turnaroundTime,
    averageWaitingTime: averageWaitingTime,
    averageTurnaroundTime: averageTurnaroundTime,
  );
}