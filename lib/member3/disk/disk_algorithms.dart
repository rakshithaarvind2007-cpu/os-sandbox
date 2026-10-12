class DiskResult {
  final List<int> order;
  final int totalHeadMovement;

  DiskResult({
    required this.order,
    required this.totalHeadMovement,
  });
}

// FCFS - First Come First Serve
DiskResult fcfs({
  required List<int> requests,
  required int head,
}) {
  List<int> order = List.from(requests);
  int current = head;
  int totalMovement = 0;

  for (int request in order) {
    totalMovement += (request - current).abs();
    current = request;
  }

  return DiskResult(
    order: order,
    totalHeadMovement: totalMovement,
  );
}

// SSTF - Shortest Seek Time First
DiskResult sstf({
  required List<int> requests,
  required int head,
}) {
  List<int> remaining = List.from(requests);
  List<int> order = [];
  int current = head;
  int totalMovement = 0;

  while (remaining.isNotEmpty) {
    int closestIndex = 0;
    int closestDistance = (remaining[0] - current).abs();

    for (int i = 1; i < remaining.length; i++) {
      int distance = (remaining[i] - current).abs();

      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }

    int next = remaining[closestIndex];

    totalMovement += (next - current).abs();
    current = next;
    order.add(next);
    remaining.removeAt(closestIndex);
  }

  return DiskResult(
    order: order,
    totalHeadMovement: totalMovement,
  );
}

// SCAN - Elevator Algorithm
DiskResult scan({
  required List<int> requests,
  required int head,
  required int diskSize,
  required String direction,
}) {
  List<int> lower = [];
  List<int> higher = [];

  for (int request in requests) {
    if (request < head) {
      lower.add(request);
    } else {
      higher.add(request);
    }
  }

  lower.sort();
  higher.sort();

  List<int> order = [];
  int current = head;
  int totalMovement = 0;

  if (direction == 'Right') {
    for (int request in higher) {
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }

    if (current != diskSize - 1) {
      totalMovement += (diskSize - 1 - current).abs();
      current = diskSize - 1;
    }

    for (int i = lower.length - 1; i >= 0; i--) {
      int request = lower[i];
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }
  } else {
    for (int i = lower.length - 1; i >= 0; i--) {
      int request = lower[i];
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }

    if (current != 0) {
      totalMovement += current.abs();
      current = 0;
    }

    for (int request in higher) {
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }
  }

  return DiskResult(
    order: order,
    totalHeadMovement: totalMovement,
  );
}

// C-SCAN - Circular SCAN
DiskResult cscan({
  required List<int> requests,
  required int head,
  required int diskSize,
  required String direction,
}) {
  List<int> lower = [];
  List<int> higher = [];

  for (int request in requests) {
    if (request < head) {
      lower.add(request);
    } else {
      higher.add(request);
    }
  }

  lower.sort();
  higher.sort();

  List<int> order = [];
  int current = head;
  int totalMovement = 0;

  if (direction == 'Right') {
    for (int request in higher) {
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }

    if (current != diskSize - 1) {
      totalMovement += (diskSize - 1 - current).abs();
      current = diskSize - 1;
    }

    totalMovement += diskSize - 1;
    current = 0;

    for (int request in lower) {
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }
  } else {
    for (int i = lower.length - 1; i >= 0; i--) {
      int request = lower[i];
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }

    if (current != 0) {
      totalMovement += current.abs();
      current = 0;
    }

    totalMovement += diskSize - 1;
    current = diskSize - 1;

    for (int i = higher.length - 1; i >= 0; i--) {
      int request = higher[i];
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }
  }

  return DiskResult(
    order: order,
    totalHeadMovement: totalMovement,
  );
}

// LOOK
DiskResult look({
  required List<int> requests,
  required int head,
  required String direction,
}) {
  List<int> lower = [];
  List<int> higher = [];

  for (int request in requests) {
    if (request < head) {
      lower.add(request);
    } else {
      higher.add(request);
    }
  }

  lower.sort();
  higher.sort();

  List<int> order = [];
  int current = head;
  int totalMovement = 0;

  if (direction == 'Right') {
    for (int request in higher) {
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }

    for (int i = lower.length - 1; i >= 0; i--) {
      int request = lower[i];
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }
  } else {
    for (int i = lower.length - 1; i >= 0; i--) {
      int request = lower[i];
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }

    for (int request in higher) {
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }
  }

  return DiskResult(
    order: order,
    totalHeadMovement: totalMovement,
  );
}

// C-LOOK
DiskResult clook({
  required List<int> requests,
  required int head,
  required String direction,
}) {
  List<int> lower = [];
  List<int> higher = [];

  for (int request in requests) {
    if (request < head) {
      lower.add(request);
    } else {
      higher.add(request);
    }
  }

  lower.sort();
  higher.sort();

  List<int> order = [];
  int current = head;
  int totalMovement = 0;

  if (direction == 'Right') {
    for (int request in higher) {
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }

    if (lower.isNotEmpty) {
      totalMovement += (current - lower.first).abs();
      current = lower.first;
      order.add(current);

      for (int i = 1; i < lower.length; i++) {
        int request = lower[i];
        totalMovement += (request - current).abs();
        current = request;
        order.add(request);
      }
    }
  } else {
    for (int i = lower.length - 1; i >= 0; i--) {
      int request = lower[i];
      order.add(request);
      totalMovement += (request - current).abs();
      current = request;
    }

    if (higher.isNotEmpty) {
      totalMovement += (higher.last - current).abs();
      current = higher.last;
      order.add(current);

      for (int i = higher.length - 2; i >= 0; i--) {
        int request = higher[i];
        totalMovement += (request - current).abs();
        current = request;
        order.add(request);
      }
    }
  }

  return DiskResult(
    order: order,
    totalHeadMovement: totalMovement,
  );
}