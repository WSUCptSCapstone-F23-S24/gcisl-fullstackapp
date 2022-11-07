// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAw25bD-0yenO4O1C4Xb4tqb60YvAo47A8',
    appId: '1:361937343670:web:11b7fbbd448e8e9804c217',
    messagingSenderId: '361937343670',
    projectId: 'cobb-connect',
    authDomain: 'cobb-connect.firebaseapp.com',
    databaseURL: 'https://cobb-connect-default-rtdb.firebaseio.com',
    storageBucket: 'cobb-connect.appspot.com',
    measurementId: 'G-X3DJ6FYEE4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkwBURqSST55t6-RFFfmbV3pAOTpsoH50',
    appId: '1:361937343670:android:4fbabff3b17dc95704c217',
    messagingSenderId: '361937343670',
    projectId: 'cobb-connect',
    databaseURL: 'https://cobb-connect-default-rtdb.firebaseio.com',
    storageBucket: 'cobb-connect.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAgvdxU2rwK02exWn2lRLMhoUgzCVjOZg8',
    appId: '1:361937343670:ios:4c0869ddeba3b4a804c217',
    messagingSenderId: '361937343670',
    projectId: 'cobb-connect',
    databaseURL: 'https://cobb-connect-default-rtdb.firebaseio.com',
    storageBucket: 'cobb-connect.appspot.com',
    iosClientId: '361937343670-t4j2jp77n5ooorb9jcfv6grpoolmvba0.apps.googleusercontent.com',
    iosBundleId: 'com.example.gcislApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAgvdxU2rwK02exWn2lRLMhoUgzCVjOZg8',
    appId: '1:361937343670:ios:4c0869ddeba3b4a804c217',
    messagingSenderId: '361937343670',
    projectId: 'cobb-connect',
    databaseURL: 'https://cobb-connect-default-rtdb.firebaseio.com',
    storageBucket: 'cobb-connect.appspot.com',
    iosClientId: '361937343670-t4j2jp77n5ooorb9jcfv6grpoolmvba0.apps.googleusercontent.com',
    iosBundleId: 'com.example.gcislApp',
  );
}
