class BankersResult {
  final bool isSafe;
  final List<int> safeSequence;
  final List<List<int>> need;

  BankersResult({
    required this.isSafe,
    required this.safeSequence,
    required this.need,
  });
}

BankersResult bankersAlgorithm({
  required List<List<int>> allocation,
  required List<List<int>> maximum,
  required List<int> available,
}) {
  final int processCount = allocation.length;
  final int resourceCount = available.length;

  List<List<int>> need = List.generate(
    processCount,
    (i) => List.generate(
      resourceCount,
      (j) => maximum[i][j] - allocation[i][j],
    ),
  );

  List<int> work = List.from(available);
  List<bool> finish = List.filled(processCount, false);
  List<int> safeSequence = [];

  while (safeSequence.length < processCount) {
    bool foundProcess = false;

    for (int i = 0; i < processCount; i++) {
      if (finish[i]) {
        continue;
      }

      bool canRun = true;

      for (int j = 0; j < resourceCount; j++) {
        if (need[i][j] > work[j]) {
          canRun = false;
          break;
        }
      }

      if (canRun) {
        for (int j = 0; j < resourceCount; j++) {
          work[j] += allocation[i][j];
        }

        finish[i] = true;
        safeSequence.add(i);
        foundProcess = true;
      }
    }

    if (!foundProcess) {
      break;
    }
  }

  return BankersResult(
    isSafe: safeSequence.length == processCount,
    safeSequence: safeSequence,
    need: need,
  );
}