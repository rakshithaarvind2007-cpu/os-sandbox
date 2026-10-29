import 'device_profile_stub.dart'
    if (dart.library.io) 'device_profile_native.dart'
    as platform;
import 'device_profile_stub.dart' show DeviceProfile;

export 'device_profile_stub.dart' show DeviceProfile;

Future<DeviceProfile> loadDeviceProfile() => platform.loadDeviceProfile();
