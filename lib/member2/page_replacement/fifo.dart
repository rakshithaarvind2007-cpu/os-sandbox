class PageResult {
  int page;
  List<int> frames;
  bool pageFault;

  PageResult(this.page, this.frames, this.pageFault);
}

List<PageResult> fifo(
    List<int> referenceString, int frameCount) {
  List<int> frames = [];
  List<PageResult> results = [];

  int pointer = 0;

  for (int page in referenceString) {
    bool pageFault = false;

    // Page is already in memory
    if (!frames.contains(page)) {
      pageFault = true;

      // If frames are not full, add the page
      if (frames.length < frameCount) {
        frames.add(page);
      } else {
        // Replace the oldest page
        frames[pointer] = page;
        pointer = (pointer + 1) % frameCount;
      }
    }

    results.add(
      PageResult(
        page,
        List<int>.from(frames),
        pageFault,
      ),
    );
  }

  return results;
}