class LRUPageResult {
  int page;
  List<int> frames;
  bool pageFault;

  LRUPageResult(this.page, this.frames, this.pageFault);
}

List<LRUPageResult> lru(
    List<int> referenceString, int frameCount) {
  List<int> frames = [];
  List<LRUPageResult> results = [];

  // Stores the last time each page was used
  Map<int, int> lastUsed = {};

  for (int time = 0; time < referenceString.length; time++) {
    int page = referenceString[time];
    bool pageFault = false;

    if (frames.contains(page)) {
      // Page hit
      pageFault = false;
    } else {
      // Page fault
      pageFault = true;

      if (frames.length < frameCount) {
        // Empty frame available
        frames.add(page);
      } else {
        // Find the least recently used page
        int lruPage = frames[0];

        for (int framePage in frames) {
          if (lastUsed[framePage]! < lastUsed[lruPage]!) {
            lruPage = framePage;
          }
        }

        // Replace LRU page
        int index = frames.indexOf(lruPage);
        frames[index] = page;

        // Remove old page's tracking information
        lastUsed.remove(lruPage);
      }
    }

    // Update last-used time
    lastUsed[page] = time;

    results.add(
      LRUPageResult(
        page,
        List<int>.from(frames),
        pageFault,
      ),
    );
  }

  return results;
}