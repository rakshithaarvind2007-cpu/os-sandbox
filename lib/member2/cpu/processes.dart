class Process {
  int pid;
  int arrivalTime;
  int burstTime;

  int completionTime = 0;
  int turnaroundTime = 0;
  int waitingTime = 0;
  int responseTime = 0;

  Process(this.pid, this.arrivalTime, this.burstTime);
}