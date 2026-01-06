// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
            'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ✅ Android Config (from your google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAZJ7V5CgjREvJJjMPKEImcZZQAe_vkn9k',
    appId: '1:241612108908:android:584e3e9b1855d7e4275449',
    messagingSenderId: '241612108908',
    projectId: 'aashni-and-co',
    storageBucket: 'aashni-and-co.firebasestorage.app',
  );

  // ✅ iOS Config (from your GoogleService-Info.plist)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBjUvhZZbHgIl40-ZRdfGY6GrcEtNHk5NU',
    appId: '1:241612108908:ios:3f4e1885234dc61c275449',
    messagingSenderId: '241612108908',
    projectId: 'aashni-and-co',
    storageBucket: 'aashni-and-co.firebasestorage.app',
    iosBundleId: 'com.aashniandco.app.aashniandco',
  );
}