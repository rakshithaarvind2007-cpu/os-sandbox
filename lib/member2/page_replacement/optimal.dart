class OptimalPageResult {
  int page;
  List<int> frames;
  bool pageFault;

  OptimalPageResult(this.page, this.frames, this.pageFault);
}

List<OptimalPageResult> optimal(
    List<int> referenceString, int frameCount) {
  List<int> frames = [];
  List<OptimalPageResult> results = [];

  for (int i = 0; i < referenceString.length; i++) {
    int page = referenceString[i];
    bool pageFault = false;

    // Page hit
    if (frames.contains(page)) {
      pageFault = false;
    } else {
      // Page fault
      pageFault = true;

      // Empty frame available
      if (frames.length < frameCount) {
        frames.add(page);
      } else {
        int pageToReplace = -1;
        int farthestUse = -1;

        // Find the page that will be used farthest in the future
        for (int framePage in frames) {
          int nextUse = -1;

          for (int j = i + 1; j < referenceString.length; j++) {
            if (referenceString[j] == framePage) {
              nextUse = j;
              break;
            }
          }

          // If this page is never used again,
          // replace it immediately.
          if (nextUse == -1) {
            pageToReplace = framePage;
            break;
          }

          // Otherwise, choose the page used farthest in the future.
          if (nextUse > farthestUse) {
            farthestUse = nextUse;
            pageToReplace = framePage;
          }
        }

        int index = frames.indexOf(pageToReplace);
        frames[index] = page;
      }
    }

    results.add(
      OptimalPageResult(
        page,
        List<int>.from(frames),
        pageFault,
      ),
    );
  }

  return results;
}