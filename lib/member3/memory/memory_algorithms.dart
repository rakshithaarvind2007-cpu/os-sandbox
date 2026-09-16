class MemoryAllocationResult {
  final List<int> allocation;
  final List<int> remainingBlocks;

  MemoryAllocationResult({
    required this.allocation,
    required this.remainingBlocks,
  });
}

MemoryAllocationResult firstFit(
  List<int> blocks,
  List<int> processes,
) {
  List<int> remaining = List.from(blocks);
  List<int> allocation = List.filled(processes.length, -1);

  for (int i = 0; i < processes.length; i++) {
    for (int j = 0; j < remaining.length; j++) {
      if (remaining[j] >= processes[i]) {
        allocation[i] = j;
        remaining[j] -= processes[i];
        break;
      }
    }
  }

  return MemoryAllocationResult(
    allocation: allocation,
    remainingBlocks: remaining,
  );
}

MemoryAllocationResult bestFit(
  List<int> blocks,
  List<int> processes,
) {
  List<int> remaining = List.from(blocks);
  List<int> allocation = List.filled(processes.length, -1);

  for (int i = 0; i < processes.length; i++) {
    int bestIndex = -1;

    for (int j = 0; j < remaining.length; j++) {
      if (remaining[j] >= processes[i]) {
        if (bestIndex == -1 ||
            remaining[j] < remaining[bestIndex]) {
          bestIndex = j;
        }
      }
    }

    if (bestIndex != -1) {
      allocation[i] = bestIndex;
      remaining[bestIndex] -= processes[i];
    }
  }

  return MemoryAllocationResult(
    allocation: allocation,
    remainingBlocks: remaining,
  );
}

MemoryAllocationResult worstFit(
  List<int> blocks,
  List<int> processes,
) {
  List<int> remaining = List.from(blocks);
  List<int> allocation = List.filled(processes.length, -1);

  for (int i = 0; i < processes.length; i++) {
    int worstIndex = -1;

    for (int j = 0; j < remaining.length; j++) {
      if (remaining[j] >= processes[i]) {
        if (worstIndex == -1 ||
            remaining[j] > remaining[worstIndex]) {
          worstIndex = j;
        }
      }
    }

    if (worstIndex != -1) {
      allocation[i] = worstIndex;
      remaining[worstIndex] -= processes[i];
    }
  }

  return MemoryAllocationResult(
    allocation: allocation,
    remainingBlocks: remaining,
  );
}