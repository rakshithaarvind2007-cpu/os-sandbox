class BlockSegment {
  final String label; // Process ID or 'Free' or 'Internal Frag'
  final int size;
  final bool isAllocated;
  final bool isFragmented;

  BlockSegment({
    required this.label,
    required this.size,
    required this.isAllocated,
    this.isFragmented = false,
  });
}

class MemoryBlockState {
  final int originalSize;
  final List<BlockSegment> segments;

  MemoryBlockState({
    required this.originalSize,
    required this.segments,
  });
}

class MemoryAllocationResult {
  final List<MemoryBlockState> blocks;
  final List<int> unallocatedProcesses;

  MemoryAllocationResult({
    required this.blocks,
    required this.unallocatedProcesses,
  });
}

// FIRST FIT
MemoryAllocationResult firstFit(List<int> blocks, List<int> processes) {
  List<int> remaining = List.from(blocks);
  List<List<BlockSegment>> blockSegments = List.generate(
    blocks.length,
    (i) => [],
  );
  List<int> unallocated = [];

  for (int i = 0; i < processes.length; i++) {
    int pSize = processes[i];
    bool allocated = false;

    for (int j = 0; j < remaining.length; j++) {
      if (remaining[j] >= pSize) {
        blockSegments[j].add(BlockSegment(
          label: 'P${i + 1} ($pSize)',
          size: pSize,
          isAllocated: true,
        ));
        remaining[j] -= pSize;
        allocated = true;
        break;
      }
    }

    if (!allocated) {
      unallocated.add(i + 1);
    }
  }

  // Construct final memory block states
  List<MemoryBlockState> finalBlocks = [];
  for (int i = 0; i < blocks.length; i++) {
    List<BlockSegment> segs = List.from(blockSegments[i]);
    if (remaining[i] > 0) {
      if (segs.isNotEmpty) {
        segs.add(BlockSegment(
          label: 'Frag (${remaining[i]})',
          size: remaining[i],
          isAllocated: false,
          isFragmented: true,
        ));
      } else {
        segs.add(BlockSegment(
          label: 'Free (${remaining[i]})',
          size: remaining[i],
          isAllocated: false,
        ));
      }
    }
    finalBlocks.add(MemoryBlockState(
      originalSize: blocks[i],
      segments: segs,
    ));
  }

  return MemoryAllocationResult(
    blocks: finalBlocks,
    unallocatedProcesses: unallocated,
  );
}

// BEST FIT
MemoryAllocationResult bestFit(List<int> blocks, List<int> processes) {
  List<int> remaining = List.from(blocks);
  List<List<BlockSegment>> blockSegments = List.generate(
    blocks.length,
    (i) => [],
  );
  List<int> unallocated = [];

  for (int i = 0; i < processes.length; i++) {
    int pSize = processes[i];
    int bestIndex = -1;

    for (int j = 0; j < remaining.length; j++) {
      if (remaining[j] >= pSize) {
        if (bestIndex == -1 || remaining[j] < remaining[bestIndex]) {
          bestIndex = j;
        }
      }
    }

    if (bestIndex != -1) {
      blockSegments[bestIndex].add(BlockSegment(
        label: 'P${i + 1} ($pSize)',
        size: pSize,
        isAllocated: true,
      ));
      remaining[bestIndex] -= pSize;
    } else {
      unallocated.add(i + 1);
    }
  }

  List<MemoryBlockState> finalBlocks = [];
  for (int i = 0; i < blocks.length; i++) {
    List<BlockSegment> segs = List.from(blockSegments[i]);
    if (remaining[i] > 0) {
      if (segs.isNotEmpty) {
        segs.add(BlockSegment(
          label: 'Frag (${remaining[i]})',
          size: remaining[i],
          isAllocated: false,
          isFragmented: true,
        ));
      } else {
        segs.add(BlockSegment(
          label: 'Free (${remaining[i]})',
          size: remaining[i],
          isAllocated: false,
        ));
      }
    }
    finalBlocks.add(MemoryBlockState(
      originalSize: blocks[i],
      segments: segs,
    ));
  }

  return MemoryAllocationResult(
    blocks: finalBlocks,
    unallocatedProcesses: unallocated,
  );
}

// WORST FIT
MemoryAllocationResult worstFit(List<int> blocks, List<int> processes) {
  List<int> remaining = List.from(blocks);
  List<List<BlockSegment>> blockSegments = List.generate(
    blocks.length,
    (i) => [],
  );
  List<int> unallocated = [];

  for (int i = 0; i < processes.length; i++) {
    int pSize = processes[i];
    int worstIndex = -1;

    for (int j = 0; j < remaining.length; j++) {
      if (remaining[j] >= pSize) {
        if (worstIndex == -1 || remaining[j] > remaining[worstIndex]) {
          worstIndex = j;
        }
      }
    }

    if (worstIndex != -1) {
      blockSegments[worstIndex].add(BlockSegment(
        label: 'P${i + 1} ($pSize)',
        size: pSize,
        isAllocated: true,
      ));
      remaining[worstIndex] -= pSize;
    } else {
      unallocated.add(i + 1);
    }
  }

  List<MemoryBlockState> finalBlocks = [];
  for (int i = 0; i < blocks.length; i++) {
    List<BlockSegment> segs = List.from(blockSegments[i]);
    if (remaining[i] > 0) {
      if (segs.isNotEmpty) {
        segs.add(BlockSegment(
          label: 'Frag (${remaining[i]})',
          size: remaining[i],
          isAllocated: false,
          isFragmented: true,
        ));
      } else {
        segs.add(BlockSegment(
          label: 'Free (${remaining[i]})',
          size: remaining[i],
          isAllocated: false,
        ));
      }
    }
    finalBlocks.add(MemoryBlockState(
      originalSize: blocks[i],
      segments: segs,
    ));
  }

  return MemoryAllocationResult(
    blocks: finalBlocks,
    unallocatedProcesses: unallocated,
  );
}