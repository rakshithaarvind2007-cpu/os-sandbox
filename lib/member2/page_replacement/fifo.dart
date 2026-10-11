void fifoPageReplacement(List<int> pages, int frameCount) {
  List<int> frames = [];
  int pageFaults = 0;
  int pageHits = 0;

  print("Page\tFrames\t\tStatus");

  for (int page in pages) {
    // Page hit
    if (frames.contains(page)) {
      pageHits++;
      print("$page\t$frames\t\tHit");
    }

    // Page fault
    else {
      pageFaults++;

      // If there is an empty frame
      if (frames.length < frameCount) {
        frames.add(page);
      }

      // If all frames are full
      else {
        frames.removeAt(0); // Remove oldest page
        frames.add(page);   // Insert new page
      }

      print("$page\t$frames\t\tFault");
    }
  }

  print("\nTotal Page Faults: $pageFaults");
  print("Total Page Hits: $pageHits");
}