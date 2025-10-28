import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDRyNAjfKIsrzpLnE5raa0U7MGSmamrIyk',
    appId: '1:834677698431:web:c2195dd9b84f948b0a744a',
    messagingSenderId: '834677698431',
    projectId: 'hajjam-firebase-project',
    authDomain: 'hajjam-firebase-project.firebaseapp.com',
    storageBucket: 'hajjam-firebase-project.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDxxfpVaok6q_CQecSyg3ndoY1szte8R8k',
    appId: '1:834677698431:android:0438e947c3afaf950a744a',
    messagingSenderId: '834677698431',
    projectId: 'hajjam-firebase-project',
    storageBucket: 'hajjam-firebase-project.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDfYSCTpEfLkg3P_rye6EmFQsxXaBbC27o',
    appId: '1:834677698431:ios:9c5fecb7fedec5610a744a',
    messagingSenderId: '834677698431',
    projectId: 'hajjam-firebase-project',
    storageBucket: 'hajjam-firebase-project.firebasestorage.app',
    iosBundleId: 'com.example.hajjaamApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDfYSCTpEfLkg3P_rye6EmFQsxXaBbC27o',
    appId: '1:834677698431:ios:9c5fecb7fedec5610a744a',
    messagingSenderId: '834677698431',
    projectId: 'hajjam-firebase-project',
    storageBucket: 'hajjam-firebase-project.firebasestorage.app',
    iosBundleId: 'com.example.hajjaamApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDRyNAjfKIsrzpLnE5raa0U7MGSmamrIyk',
    appId: '1:834677698431:web:34351f67017f80fb0a744a',
    messagingSenderId: '834677698431',
    projectId: 'hajjam-firebase-project',
    authDomain: 'hajjam-firebase-project.firebaseapp.com',
    storageBucket: 'hajjam-firebase-project.firebasestorage.app',
  );

}