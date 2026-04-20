# project

A new Flutter project.

## Development Guide

For instructions on **Isolated Development** (Playground) and how to build features efficiently, please refer to:
**[DEVELOPMENT.md](file:///c:/Users/Bam/Desktop/Computer_Science/01_Academics/CMSC23/project/DEVELOPMENT.md)**

---

## Firebase & Database Setup

This project uses Firebase for the database and authentication. Since configuration files contain sensitive keys, they are excluded from version control.

### Prerequisites
1. Install [FlutterFire CLI](https://firebase.flutter.dev/docs/cli):
   ```powershell
   dart pub global activate flutterfire_cli
   ```
2. Log in to Firebase:
   ```powershell
   firebase login
   ```

### Initializing Firebase
To generate the necessary `lib/firebase_options.dart` file for your local environment:

1. Run the configure command:
   ```powershell
   flutterfire configure
   ```
2. Select your Firebase project from the list.
3. Select the platforms you are developing for (Android, iOS, Web).
4. The CLI will automatically generate/update `lib/firebase_options.dart`.

---

## Getting Started

1. Ensure you have the Flutter SDK installed.
2. Clone the repository.
3. Run `flutter pub get`.
4. Follow the **Firebase Setup** above.
5. Run the app: `flutter run`.

