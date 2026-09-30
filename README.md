# Smart Facilities — ICT205 Assessment 3

Simple campus facility issue reporter. A student or staff member photographs a broken asset, attaches GPS, and saves it to Firebase so it can be tracked.

Firebase project: `anish-auth-bio` (same as Prac 8–10). Android package stays `com.example.personal_bio_app` so the existing `google-services.json` still works.

## Screens (6)

1. Login
2. Register
3. Facility Reports (live list)
4. New facility report (camera + GPS)
5. Report detail (mark Open / Resolved)
6. Profile / logout

## How native sensors are used

Camera and GPS are the evidence for each report, not decoration. The app will not submit without a photo and a location.

```
Flutter UI
  -> image_picker / geolocator plugin
  -> Platform Channel
  -> Android (Kotlin) / iOS (Swift)
  -> Camera / GPS
```

## One-time Console step

Firestore currently only allows `users/{uid}`. Publish these rules or **Submit report** will fail.

Firestore → Rules → paste `firestore.rules` → Publish  
Storage → Rules → paste `storage.rules` → Publish

## Run

```
cd "c:\FlutterProjects\assessment 3"
flutter pub get
flutter run
```

Log in with `anish@gg.com` (or register a new account). Tap **New report** → **Open Camera** → **Get Location** → **Submit report**. On the emulator, set a fake GPS first (`...` → Location).

## Team

- Anish Tamang (Cihe240555)
- Safal Poudel
- Abhishekh Khanal
