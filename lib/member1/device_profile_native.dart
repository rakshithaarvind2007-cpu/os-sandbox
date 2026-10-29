import 'dart:io';
import 'dart:isolate';
import 'package:system_info2/system_info2.dart';
import 'device_profile_stub.dart';

Future<DeviceProfile> loadDeviceProfile() => Isolate.run(() {
  final fallback = DeviceProfile(
    operatingSystem: Platform.operatingSystem,
    logicalCores: Platform.numberOfProcessors,
  );
  try {
    return DeviceProfile(
      operatingSystem:
          SysInfo.operatingSystemName + ' ' + SysInfo.operatingSystemVersion,
      logicalCores: SysInfo.cores.length,
      totalMemoryBytes: SysInfo.getTotalPhysicalMemory(),
      availableMemoryBytes: SysInfo.getAvailablePhysicalMemory(),
      appVirtualMemoryBytes: SysInfo.getVirtualMemorySize(),
    );
  } catch (_) {
    return fallback;
  }
});
