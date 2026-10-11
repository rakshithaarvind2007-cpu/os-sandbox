void lruPageReplacement(List<int> pages, int frameCount) {
  List<int> frames = [];
  int pageFaults = 0;
  int pageHits = 0;

  print("Page\tFrames\t\tStatus");

  for (int page in pages) {

    // Page Hit
    if (frames.contains(page)) {
      pageHits++;

      // Move the recently used page to the end
      frames.remove(page);
      frames.add(page);

      print("$page\t$frames\t\tHit");
    }

    // Page Fault
    else {
      pageFaults++;

      // Empty frame available
      if (frames.length < frameCount) {
        frames.add(page);
      }

      // All frames are full
      else {
        // Remove the least recently used page
        frames.removeAt(0);

        // Add the new page
        frames.add(page);
      }

      print("$page\t$frames\t\tFault");
    }
  }

  print("\nTotal Page Faults: $pageFaults");
  print("Total Page Hits: $pageHits");
}