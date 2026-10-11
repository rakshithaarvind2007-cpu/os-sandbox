void optimalPageReplacement(List<int> pages, int frameCount) {
  List<int> frames = [];
  int pageFaults = 0;
  int pageHits = 0;

  print("Page\tFrames\t\tStatus");

  for (int i = 0; i < pages.length; i++) {
    int page = pages[i];

    // Page Hit
    if (frames.contains(page)) {
      pageHits++;

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
        int pageToReplace = -1;
        int farthest = -1;

        // Check each page currently in frames
        for (int j = 0; j < frames.length; j++) {
          int currentPage = frames[j];

          int nextUse = -1;

          // Find when this page will be used next
          for (int k = i + 1; k < pages.length; k++) {
            if (pages[k] == currentPage) {
              nextUse = k;
              break;
            }
          }

          // Page is never used again
          if (nextUse == -1) {
            pageToReplace = j;
            break;
          }

          // Page used farthest in the future
          if (nextUse > farthest) {
            farthest = nextUse;
            pageToReplace = j;
          }
        }

        // Replace the selected page
        frames[pageToReplace] = page;
      }

      print("$page\t$frames\t\tFault");
    }
  }

  print("\nTotal Page Faults: $pageFaults");
  print("Total Page Hits: $pageHits");
}