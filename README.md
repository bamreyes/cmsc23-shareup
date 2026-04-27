# ShareUP

A Flutter application for sharing and exchanging items within a community.

## Developer Guide

For the full development guide covering **file structure, conventions, playground usage, git workflow, and PR templates**, please refer to:
**[DEVELOPMENT.md](DEVELOPMENT.md)**

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

## Cloudinary Setup

We use **[Cloudinary](https://cloudinary.com/)** for image uploads (profile photos, feed post images, etc.). The credentials are loaded from a `.env` file which is not committed to version control.

### Setup
1. Create a `.env` file in the project root (if it doesn't exist).
2. Add the following Cloudinary credentials (ask the team for the values):
   ```
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_UPLOAD_PRESET=your_upload_preset
   ```

> For usage details, see the [Developer Guide](DEVELOPMENT.md#image-uploads-with-cloudinary).

---

## Getting Started

1. Ensure you have the Flutter SDK installed.
2. Clone the repository.
3. Run `flutter pub get`.
4. Follow the **Firebase Setup** above.
5. Create the `.env` file with Cloudinary credentials (see **Cloudinary Setup** above).
6. Run the app: `flutter run`.
