# 🚀 دليل تشغيل ونشر Flash Cards App

---

## 📋 المتطلبات الأساسية

- Flutter SDK 3.0+
- Node.js 18+
- حساب Firebase (مجاني)
- Android Studio أو VS Code

---

## 🔥 الخطوة 1: إعداد Firebase

### 1.1 إنشاء مشروع Firebase
1. اذهب إلى https://console.firebase.google.com
2. اضغط "Add project"
3. اكتب اسم المشروع: `flash-cards-bac`
4. فعّل Google Analytics (اختياري)

### 1.2 تفعيل Authentication
1. من القائمة الجانبية: Authentication → Get started
2. اضغط "Email/Password" → Enable → Save

### 1.3 إنشاء Firestore Database
1. من القائمة: Firestore Database → Create database
2. اختر "Start in production mode"
3. اختر أقرب region (europe-west1 للجزائر)

### 1.4 قواعد Firestore Security Rules
اذهب إلى Firestore → Rules والصق هذا:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // المستخدمون: يقرأ/يكتب صاحب الحساب فقط
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // المواد والدروس: للقراءة فقط للمستخدمين المسجلين
    match /subjects/{subjectId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin فقط عبر Firebase Console أو Admin SDK

      match /lessons/{lessonId} {
        allow read: if request.auth != null;
        allow write: if false;

        match /cards/{cardId} {
          allow read: if request.auth != null;
          allow write: if false;
        }
      }
    }

    // السنوات والدورات
    match /years/{yearId} {
      allow read: if request.auth != null;
      allow write: if false;

      match /sessions/{sessionId} {
        allow read: if request.auth != null;
        allow write: if false;

        match /cards/{cardId} {
          allow read: if request.auth != null;
          allow write: if false;
        }
      }
    }
  }
}
```

> ⚠️ ملاحظة: لوحة التحكم تستخدم بريد Admin مع صلاحيات خاصة.
> عدّل القواعد لتسمح للـ Admin بالكتابة:
> `allow write: if request.auth.token.email == "admin@flashcards.dz";`

---

## 📱 الخطوة 2: إعداد Flutter

### 2.1 تثبيت FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 2.2 ربط المشروع بـ Firebase
```bash
cd flutter_project
flutter pub get
flutterfire configure
```
- اختر مشروعك من القائمة
- اختر Android و iOS
- سيتم توليد `firebase_options.dart` تلقائياً ✅

### 2.3 إعداد Android
في `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // مهم
        targetSdkVersion 34
    }
}
```

### 2.4 إعداد iOS
```bash
cd ios
pod install
```
في `ios/Runner/Info.plist` أضف:
```xml
<key>NSCameraUsageDescription</key>
<string>Flash Cards App</string>
```

### 2.5 تشغيل التطبيق
```bash
flutter run
```

### 2.6 بناء APK للأندرويد
```bash
flutter build apk --release
# الملف في: build/app/outputs/flutter-apk/app-release.apk
```

### 2.7 بناء للـ iOS
```bash
flutter build ios --release
# ثم افتح Xcode وarchive
```

---

## 🖥️ الخطوة 3: إعداد لوحة التحكم Admin

### 3.1 إنشاء حساب Admin
1. في Firebase Console → Authentication
2. اضغط "Add user"
3. أدخل: `admin@flashcards.dz` وكلمة مرور قوية

### 3.2 تثبيت لوحة التحكم
```bash
cd admin_dashboard
npm install
```

### 3.3 إعداد Firebase في لوحة التحكم
افتح `src/firebase.js` وضع بياناتك:
- اذهب إلى Firebase Console → Project Settings
- انسخ firebaseConfig وضعه في الملف

### 3.4 تشغيل لوحة التحكم محلياً
```bash
npm start
# يفتح على http://localhost:3000
```

### 3.5 نشر لوحة التحكم على الإنترنت (Firebase Hosting)
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
npm run build
firebase deploy
# رابطك: https://flash-cards-bac.web.app
```

---

## 📊 الخطوة 4: إضافة البيانات الأولية

### عبر لوحة التحكم:
1. افتح لوحة التحكم وسجّل دخول بـ Admin
2. اذهب لـ "المواد والدروس"
3. اضغط "+ إضافة مادة" وأدخل: فيزياء، ⚛️، colorIndex: 1
4. اضغط على المادة ثم "+ درس" وأدخل: النواس الثقلي
5. اضغط على الدرس ثم "+ بطاقة"

### أو عبر الكود (مرة واحدة):
في التطبيق أضف مؤقتاً في `main()`:
```dart
await FirestoreService().seedSampleData();
```
ثم احذفها بعد التشغيل الأول.

---

## 🔐 الخطوة 5: نظام منع تعدد الأجهزة

هذا النظام مُطبَّق بالكامل في `auth_service.dart`:

**كيف يعمل:**
1. أول تسجيل دخول → يُحفظ `deviceId` في Firestore
2. عند كل دخول → يُقارن `deviceId` الحالي مع المحفوظ
3. إذا اختلفا → يُرفض الدخول ويظهر رسالة خطأ
4. Admin يستطيع إعادة تعيين الجهاز من لوحة التحكم

**لإعادة تعيين جهاز مستخدم:**
1. اذهب للوحة التحكم → المستخدمون
2. ابحث عن المستخدم
3. اضغط "إعادة الجهاز" ✅

---

## 📁 هيكل الملفات الكامل

```
flashcards_app/
├── flutter_project/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── firebase_options.dart
│   │   ├── core/
│   │   │   ├── constants/app_colors.dart
│   │   │   ├── constants/app_strings.dart
│   │   │   └── theme/app_theme.dart
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   └── subject_model.dart  (يحتوي كل النماذج)
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   ├── firestore_service.dart
│   │   │   └── device_service.dart
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   ├── screens/
│   │   │   ├── auth/login_screen.dart
│   │   │   ├── auth/register_screen.dart
│   │   │   ├── auth/forgot_password_screen.dart
│   │   │   ├── home/home_screen.dart
│   │   │   ├── subjects/subjects_screen.dart
│   │   │   ├── subjects/lessons_screen.dart
│   │   │   ├── subjects/flashcard_screen.dart
│   │   │   ├── years/years_screen.dart
│   │   │   ├── years/sessions_screen.dart
│   │   │   ├── saved/saved_cards_screen.dart
│   │   │   └── subscription/expired_screen.dart
│   │   └── widgets/
│   │       ├── custom_text_field.dart
│   │       └── gradient_button.dart
│   └── pubspec.yaml
│
└── admin_dashboard/
    ├── src/
    │   ├── App.js        (كل لوحة التحكم)
    │   └── firebase.js
    └── package.json
```

---

## 🐛 مشاكل شائعة وحلولها

### ❌ `firebase_options.dart` not found
```bash
flutterfire configure
```

### ❌ minSdkVersion error
في `android/app/build.gradle` غيّر `minSdkVersion` إلى `21`

### ❌ لوحة التحكم تعطي "غير مصرح"
تأكد أن بريدك في قائمة `ADMIN_EMAILS` في `App.js`

### ❌ البطاقات لا تظهر في التطبيق
تأكد من Firestore Rules وأن المستخدم مسجل دخول

---

## 📞 هيكل قاعدة البيانات المرجعي

```
users/{uid}
  email, fullName, phone
  subscriptionStart, subscriptionEnd
  isActive, deviceId, deviceName
  savedCards: [{cardId, question, answer, sourceName...}]

subjects/{subjectId}
  name, icon, colorIndex, order, isActive
  → lessons/{lessonId}
      name, order, cardCount
      → cards/{cardId}
          question, answer, order

years/{yearId}
  year, isActive
  → sessions/{sessionId}
      name, subjectName, order, cardCount
      → cards/{cardId}
          question, answer, order
```

---

## ✅ قائمة التحقق قبل النشر

- [ ] Firebase مُعدّ بشكل صحيح
- [ ] `firebase_options.dart` مُولَّد
- [ ] Firestore Rules مُفعَّلة
- [ ] حساب Admin مُنشأ
- [ ] بيانات أولية مُضافة
- [ ] اختبار تسجيل الدخول
- [ ] اختبار نظام الجهاز الواحد
- [ ] اختبار انتهاء الاشتراك
- [ ] APK مبني ومختبر

---

**حظاً موفقاً! 🚀**
