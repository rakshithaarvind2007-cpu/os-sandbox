class DeviceProfile {
  final String operatingSystem;
  final int logicalCores;
  final int totalMemoryBytes;
  final int availableMemoryBytes;
  final int appVirtualMemoryBytes;

  const DeviceProfile({
    required this.operatingSystem,
    required this.logicalCores,
    this.totalMemoryBytes = 0,
    this.availableMemoryBytes = 0,
    this.appVirtualMemoryBytes = 0,
  });
}

Future<DeviceProfile> loadDeviceProfile() async => const DeviceProfile(
  operatingSystem: 'Web browser (sandboxed)',
  logicalCores: 1,
);
