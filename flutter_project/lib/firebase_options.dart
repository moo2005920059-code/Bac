import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('هذا المنصة غير مدعومة');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAISZ9y6foC_BYVdbtCxB6tCbPjcH7SJ70',
    appId: '1:1092402747923:android:15f18372fb6441cef97de6',
    messagingSenderId: '1092402747923',
    projectId: 'bac-app-1c131',
    storageBucket: 'bac-app-1c131.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAISZ9y6foC_BYVdbtCxB6tCbPjcH7SJ70',
    appId: '1:1092402747923:android:15f18372fb6441cef97de6',
    messagingSenderId: '1092402747923',
    projectId: 'bac-app-1c131',
    storageBucket: 'bac-app-1c131.firebasestorage.app',
    iosBundleId: 'com.modbs.bac',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAISZ9y6foC_BYVdbtCxB6tCbPjcH7SJ70',
    appId: '1:1092402747923:android:15f18372fb6441cef97de6',
    messagingSenderId: '1092402747923',
    projectId: 'bac-app-1c131',
    storageBucket: 'bac-app-1c131.firebasestorage.app',
    authDomain: 'bac-app-1c131.firebaseapp.com',
  );
}
