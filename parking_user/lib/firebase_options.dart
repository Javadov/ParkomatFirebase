// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC3mJqyLRLmWS0Nf7esb5tDUVAV3IxS_vA',
    appId: '1:325314643898:web:ec06058873fa3ebe24ff83',
    messagingSenderId: '325314643898',
    projectId: 'park0mat',
    authDomain: 'park0mat.firebaseapp.com',
    storageBucket: 'park0mat.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCucBIHVpwoqUX-f5cJ3qwVCWCUUSFr2tM',
    appId: '1:325314643898:android:b1289a8ef470115924ff83',
    messagingSenderId: '325314643898',
    projectId: 'park0mat',
    storageBucket: 'park0mat.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQrIkXZ-TsjMiTCzPuWyARVPfKbzF1rPE',
    appId: '1:325314643898:ios:b2994a3bb21caa0024ff83',
    messagingSenderId: '325314643898',
    projectId: 'park0mat',
    storageBucket: 'park0mat.firebasestorage.app',
    iosBundleId: 'com.example.parkingUser',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBQrIkXZ-TsjMiTCzPuWyARVPfKbzF1rPE',
    appId: '1:325314643898:ios:b2994a3bb21caa0024ff83',
    messagingSenderId: '325314643898',
    projectId: 'park0mat',
    storageBucket: 'park0mat.firebasestorage.app',
    iosBundleId: 'com.example.parkingUser',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC3mJqyLRLmWS0Nf7esb5tDUVAV3IxS_vA',
    appId: '1:325314643898:web:13dcc6872db680d624ff83',
    messagingSenderId: '325314643898',
    projectId: 'park0mat',
    authDomain: 'park0mat.firebaseapp.com',
    storageBucket: 'park0mat.firebasestorage.app',
  );
}
