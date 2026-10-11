void lfuPageReplacement(List<int> pages, int frameCount) {
  List<int> frames = [];
  Map<int, int> frequency = {};

  int pageFaults = 0;
  int pageHits = 0;

  print("Page\tFrames\t\tStatus");

  for (int page in pages) {

    // Page Hit
    if (frames.contains(page)) {
      pageHits++;
      frequency[page] = frequency[page]! + 1;

      print("$page\t$frames\t\tHit");
    }

    // Page Fault
    else {
      pageFaults++;

      // Empty frame available
      if (frames.length < frameCount) {
        frames.add(page);
        frequency[page] = 1;
      }

      // Frames are full
      else {
        // Find page with lowest frequency
        int leastUsedPage = frames[0];

        for (int p in frames) {
          if (frequency[p]! < frequency[leastUsedPage]!) {
            leastUsedPage = p;
          }
        }

        // Remove LFU page
        frames.remove(leastUsedPage);
        frequency.remove(leastUsedPage);

        // Add new page
        frames.add(page);
        frequency[page] = 1;
      }

      print("$page\t$frames\t\tFault");
    }
  }

  print("\nTotal Page Faults: $pageFaults");
  print("Total Page Hits: $pageHits");
}