// import 'dart:io';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class AppUpdateService {
//   static Future<bool> checkForUpdate(BuildContext context) async {
//     final remoteConfig = FirebaseRemoteConfig.instance;
//
//     await remoteConfig.setConfigSettings(
//       RemoteConfigSettings(
//         fetchTimeout: const Duration(seconds: 10),
//         minimumFetchInterval: const Duration(hours: 1),
//       ),
//     );
//
//     await remoteConfig.fetchAndActivate();
//
//     final minVersion = remoteConfig.getString(
//       Platform.isAndroid ? 'android_min_version' : 'ios_min_version',
//     );
//
//     final forceUpdate = remoteConfig.getBool('force_update');
//     final message = remoteConfig.getString('update_message');
//
//     final packageInfo = await PackageInfo.fromPlatform();
//     final currentVersion = packageInfo.version;
//
//     if (_isUpdateRequired(currentVersion, minVersion)) {
//       _showUpdateDialog(
//         context,
//         forceUpdate,
//         message.isNotEmpty
//             ? message
//             : 'A new version is available. Please update the app.',
//       );
//       return forceUpdate;
//     }
//
//     return false;
//   }
//
//
//
//   static bool _isUpdateRequired(String current, String latest) {
//     List<int> curr = current.split('.').map(int.parse).toList();
//     List<int> lat = latest.split('.').map(int.parse).toList();
//
//     for (int i = 0; i < lat.length; i++) {
//       if (curr[i] < lat[i]) return true;
//       if (curr[i] > lat[i]) return false;
//     }
//     return false;
//   }
//
//   static void _showUpdateDialog(
//       BuildContext context,
//       bool forceUpdate,
//       String message,
//       ) {
//     showDialog(
//       context: context,
//       barrierDismissible: !forceUpdate,
//       builder: (_) => WillPopScope(
//         onWillPop: () async => !forceUpdate,
//         child: AlertDialog(
//           title: const Text('Update Available'),
//           content: Text(message),
//           actions: [
//             if (!forceUpdate)
//               TextButton(
//                 child: const Text('Later'),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ElevatedButton(
//               child: const Text('Update'),
//               onPressed: _launchStore,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   static Future<void> _launchStore() async {
//     final url = Platform.isAndroid
//         ? 'https://play.google.com/store/apps/details?id=com.aashniandco.aashniandco'
//         : 'https://apps.apple.com/in/app/aashni-co/id6514299813';
//
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//     }
//   }
// }


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService {
  /// Call this method once (Splash / first screen)
  static Future<bool> checkForUpdate(BuildContext context) async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await remoteConfig.fetchAndActivate();

      final latestVersion = remoteConfig.getString(
        Platform.isAndroid
            ? 'android_latest_version'
            : 'ios_latest_version',
      );

      final forceUpdate = remoteConfig.getBool('force_update');
      final message = remoteConfig.getString('update_message');

      if (latestVersion.isEmpty) return false;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isUpdateRequired(currentVersion, latestVersion)) {
        _showUpdateDialog(
          context,
          forceUpdate,
          message.isNotEmpty
              ? message
              : 'A new version is available. Please update the app.',
        );
        return forceUpdate;
      }

      return false;
    } catch (e) {
      debugPrint('⚠️ App update check failed: $e');
      return false;
    }
  }

  /// Safe semantic version comparison
  static bool _isUpdateRequired(String current, String latest) {
    final curr = current.split('.').map(int.parse).toList();
    final lat = latest.split('.').map(int.parse).toList();

    final maxLength =
    curr.length > lat.length ? curr.length : lat.length;

    for (int i = 0; i < maxLength; i++) {
      final c = i < curr.length ? curr[i] : 0;
      final l = i < lat.length ? lat[i] : 0;

      if (c < l) return true;
      if (c > l) return false;
    }
    return false;
  }

  static void _showUpdateDialog(
      BuildContext context,
      bool forceUpdate,
      String message,
      ) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (_) => WillPopScope(
        onWillPop: () async => !forceUpdate,
        child: AlertDialog(
          title: const Text('Update Available'),
          content: Text(message),
          actions: [
            if (!forceUpdate)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
            ElevatedButton(
              onPressed: _launchStore,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _launchStore() async {
    final url = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.aashniandco.aashniandco'
        : 'https://apps.apple.com/in/app/aashni-co/id6514299813';

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
