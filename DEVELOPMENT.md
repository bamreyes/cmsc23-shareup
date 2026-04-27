# ShareUP Developer Guide

Please read through this guide before you start developing to ensure consistency across the codebase.

---

## Table of Contents

1. [Project File Structure](#project-file-structure)
2. [Core Directory](#core-directory)
3. [Feature-Based Directory](#feature-based-directory)
4. [Image Uploads with Cloudinary](#image-uploads-with-cloudinary)
5. [Playground (Isolated Development)](#playground-isolated-development)
6. [Git Workflow](#git-workflow)
7. [Pull Request Guidelines](#pull-request-guidelines)

---

## Project File Structure

```
lib/
├── core/                         # Shared, app-wide modules
│   ├── constants/                # App-wide constants (colors, sizing, etc.)
│   ├── models/                   # Data models used across the app
│   ├── router/                   # GoRouter configuration and route definitions
│   ├── services/                 # External service integrations
│   ├── theme/                    # Theme definitions (light/dark mode)
│   ├── utils/                    # General-purpose utility functions
│   └── widgets/                  # Reusable, shared widgets
│       ├── buttons/
│       ├── cards/
│       ├── feedback/
│       ├── headers/
│       ├── inputs/
│       └── navigation/
│
├── features/                     # Feature-based modules
│   ├── auth/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── feed/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── exchanges/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── profile/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── notifications/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   └── home/
│       └── screens/
│
├── main.dart                     # App entry point (production)
├── playground.dart               # Widget/screen testing sandbox
└── firebase_options.dart         # Firebase config (auto-generated, do NOT edit)
```

---

## Core Directory

The `core/` directory contains all shared, app-wide modules. Everything here is designed to be imported and reused across multiple features. **Do not put feature-specific logic in `core/`.**

### `constants/`

App-wide constants such as our color palette and other values that should never be hardcoded inline.

- **`colors.dart`** — Defines the `AppColors` class with our full color system (neutrals, primaries, semantic colors).

> Always use `AppColors.xxx` (e.g. `AppColors.primary500`) instead of raw `Color(0xFF...)` values.

---

### `models/`

All data models used across the app. Each model represents a data structure from our backend or internal state.

| File                             | Description                    |
| -------------------------------- | ------------------------------ |
| `user_model.dart`                | User profile data              |
| `post_model.dart`                | Feed post structure            |
| `request_model.dart`             | Exchange request structure     |
| `notification_model.dart`        | Notification data              |
| `notification_preferences.dart`  | User notification settings     |
| `leaderboard_model.dart`         | Leaderboard ranking entry      |

When creating a new model:
- Name the file `<name>_model.dart`
- Include `fromJson()` and `toJson()` methods for serialization
- Keep the model in `core/models/` if it is used across multiple features

---

### `router/`

We use **[GoRouter](https://pub.dev/packages/go_router)** for navigation instead of Flutter's built-in `Navigator`.

#### Why GoRouter instead of Navigator?

Flutter's default `Navigator` uses an **imperative** approach — you manually push and pop routes with `Navigator.push()` and `Navigator.pop()`. This works for simple apps, but becomes difficult to manage with deep linking, authentication redirects, and nested/tab-based navigation.

**GoRouter** uses a **declarative, URL-based** approach. Every screen is mapped to a URL path, and navigation is handled by changing the URL rather than manually managing a stack. This gives us:

- **Deep linking out of the box** — each screen has a URL, making it easy to link directly to any page
- **Built-in redirects** — auth guards and redirects are declared in one place, not scattered across screens
- **Nested navigation with state preservation** — using `StatefulShellRoute`, each bottom nav tab maintains its own navigation stack independently
- **Cleaner code** — routes are defined declaratively in a single file (`app_router.dart`)

#### Navigation cheat sheet

```dart
// Navigate to a route (replaces the current stack)
context.go('/feed');

// Push a route onto the stack (allows back navigation)
context.push('/feed/details/123');

// Go back
context.pop();
```

#### How our router is structured

Our app uses `StatefulShellRoute.indexedStack` for the bottom navigation tabs. Each tab is a `StatefulShellBranch`, so switching tabs preserves each tab's state. Auth routes (`/login`, `/signup`) are defined outside the shell so they don't show the bottom nav.

The router has a built-in `redirect` callback that:
- Redirects unauthenticated users to `/login`
- Redirects authenticated users away from `/login` and `/signup` to `/`

When adding new routes:
1. Add your `GoRoute` inside the appropriate `StatefulShellBranch` if it is a tabbed screen
2. Add standalone routes (e.g. modals, detail pages) at the top level of the `routes` list
3. Import your screen and wire it to the `builder`

---

### `services/`

All external service integrations live here. Each service wraps an external API or SDK into a clean, reusable interface. **Create new services as needed for your feature.**

| File                      | Description                                      |
| ------------------------- | ------------------------------------------------ |
| `auth_service.dart`       | Firebase Authentication (sign up, login, logout)  |
| `user_service.dart`       | Firestore user document operations               |
| `cloudinary_service.dart` | Cloudinary image/file upload                     |
| `database_service.dart`   | General Firestore database operations            |
| `location_service.dart`   | Device location services                         |

When creating a new service:
- Name the file `<name>_service.dart`
- Keep methods focused and stateless where possible
- Handle errors gracefully and return meaningful results using the `Result` type from `core/utils/result.dart`

---

### `theme/`

All theme definitions for light mode and dark mode.

- **`app_theme.dart`** — Defines `AppTheme.lightTheme` and `AppTheme.darkTheme` with complete `ThemeData` (colors, typography, component themes for AppBar, Cards, Inputs, etc.)
- **`theme_provider.dart`** — Theme state management
- **`extensions/`** — Custom theme extensions for widgets not covered by Material's default theming

The app follows the system theme automatically (`ThemeMode.system`). **Always use `Theme.of(context)` to access colors and text styles — never hardcode them in widgets.**

---

### `utils/`

General-purpose utility functions and helper classes that don't belong to any specific feature.

- **`result.dart`** — A `Result` type for handling success/error outcomes without throwing exceptions

Examples of utilities you might add:
- `date_utils.dart` — Date formatting, relative time strings ("2 hours ago"), date comparison helpers
- `string_utils.dart` — Capitalization, truncation, slug generation
- `validators.dart` — Shared form validation logic (email, phone, password strength)
- `image_utils.dart` — Image compression, thumbnail generation helpers

---

### `widgets/`

Commonly used widgets shared across the entire app. **It is important to use these shared widgets for consistency in our project.** Before creating a new widget inside a feature, always check if a shared widget already exists here.

| Directory      | Purpose                              | Examples                                                |
| -------------- | ------------------------------------ | ------------------------------------------------------- |
| `buttons/`     | All button variants                  | `PrimaryButton`, `SecondaryButton`                      |
| `cards/`       | Card components                      | Feed cards, profile cards                               |
| `feedback/`    | User feedback indicators             | Snackbars, loading spinners, dialogs                    |
| `headers/`     | App bar / header variants            | `AppHeader.greeting()`, `AppHeader.back()`, `AppHeader.title()` |
| `inputs/`      | Form input fields                    | `AppTextField`                                          |
| `navigation/`  | Navigation components               | `MainNavigationShell` (bottom nav bar)                  |

**Rules:**
- If you find yourself duplicating a widget across features, move it to `core/widgets/`
- Create new shared widgets as you develop — just make sure they are general-purpose and reusable
- Follow existing naming and file structure conventions

---

## Feature-Based Directory

Each feature in `features/` is a self-contained module with its own providers, screens, and widgets. This keeps feature-specific code isolated and organized.

```
features/<feature_name>/
├── providers/       # State management for this feature
├── screens/         # Full-page screens (each contains a Scaffold)
└── widgets/         # Widgets used only within this feature
```

### `providers/`

Contains `ChangeNotifier` classes that manage the state for the feature. These are registered with the `Provider` package and consumed by the screens and widgets within the feature.

### `screens/`

Each screen file represents a full-page view with a `Scaffold`. Screens are what get wired to routes in `app_router.dart`.

**Naming convention:** `<name>_screen.dart` → class `NameScreen`

### `widgets/`

Feature-specific widgets used only within this feature. Examples:
- `features/feed/widgets/feed_card.dart` — A card for displaying a single feed post
- `features/auth/widgets/step_account_details.dart` — A step form in the sign-up flow

If a widget starts being used across multiple features, promote it to `core/widgets/`.

---

## Image Uploads with Cloudinary

We use **[Cloudinary](https://cloudinary.com/)** as our image hosting and upload service. All image uploads (profile photos, feed post images, etc.) go through Cloudinary instead of Firebase Storage.

### How it works

The `CloudinaryService` (`core/services/cloudinary_service.dart`) handles uploading files to Cloudinary using an **unsigned upload preset**. It reads configuration from the `.env` file:

```
CLOUDINARY_CLOUD_NAME=<cloud_name>
CLOUDINARY_UPLOAD_PRESET=<upload_preset>
```

### Usage

```dart
import 'dart:io';
import 'package:project/core/services/cloudinary_service.dart';

final cloudinary = CloudinaryService();
final result = await cloudinary.uploadFile(File('/path/to/image.jpg'));

result.when(
  success: (url) {
    // url is the Cloudinary URL of the uploaded image
    // Save this URL to Firestore
  },
  error: (message) {
    // Handle upload error
  },
);
```

### Setup

The `.env` file is **not committed to version control**. To set up Cloudinary locally:
1. Create a `.env` file in the project root (if it doesn't exist)
2. Add the Cloudinary credentials (ask the team for the values):
   ```
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_UPLOAD_PRESET=your_upload_preset
   ```

---

## Playground (Isolated Development)

The **playground** (`lib/playground.dart`) is a sandbox for testing widgets and screens in isolation without navigating through the full app.

### How to use it

Run the playground:
```bash
flutter run lib/playground.dart
```

**To test a full screen:**
1. Import your screen at the top of `playground.dart`
2. Replace the `home:` value with your screen widget:
   ```dart
   home: const YourScreen(),
   ```

**To test individual widgets:**
1. Keep `PlaygroundHome()` as the `home:` target
2. Add your widgets to the `children` list inside `PlaygroundHome`

> **Important:** Before pushing your changes, make sure you've read this developer guide. The playground is for local development only — avoid committing playground changes specific to your testing.

---

## Git Workflow

### Branching

- **Always** create a new branch for your work
- Branch name format: **`feature/<feature-name>`**
  - Examples: `feature/auth`, `feature/feed`, `feature/profile-edit`
- **Do NOT push directly to `main`** — the main branch is currently locked

### Steps

```bash
# 1. Make sure you're on the latest main
git checkout main
git pull origin main

# 2. Create your feature branch
git checkout -b feature/<feature-name>

# 3. Work on your feature, commit regularly with clear messages
git add .
git commit -m "feat: description of what you did"

# 4. Push your branch
git push origin feature/<feature-name>

# 5. Open a Pull Request on GitHub (see PR template below)
```

### Commit Message Convention

Use these prefixes for your commit messages:

| Prefix      | When to use                            | Example                                      |
| ----------- | -------------------------------------- | -------------------------------------------- |
| `feat:`     | New feature or functionality           | `feat: add feed screen with post list`       |
| `fix:`      | Bug fix                                | `fix: resolve login redirect loop`           |
| `style:`    | UI/styling changes (no logic change)   | `style: update button border radius`         |
| `refactor:` | Code restructuring (no behavior change)| `refactor: extract form validation to utils` |
| `docs:`     | Documentation changes                  | `docs: update developer guide`               |
| `chore:`    | Maintenance, deps, config              | `chore: update firebase dependencies`        |

---

## Pull Request Guidelines

When you open a PR on GitHub, use the following format:

### PR Title
```
feat: <features implemented>
```

### PR Body Template

```markdown
## Summary
<Brief description of what this PR does and why>

## Changes
- <List of specific changes made>
- <Another change>
- <Another change>

## Demo
<Attach a screen recording demonstrating your feature>
```

### After Submitting a PR

1. **Notify the group chat** so the team knows there's a PR to review
2. **Wait for testing and review** before merging — do not merge your own PR
3. Address any review comments and push fixes to the same branch

---

## Quick Reference

| Task                          | Command / Location                                   |
| ----------------------------- | ---------------------------------------------------- |
| Run the app                   | `flutter run`                                        |
| Run the playground            | `flutter run lib/playground.dart`                    |
| Access colors                 | `AppColors.xxx` from `core/constants/colors.dart`    |
| Access theme                  | `Theme.of(context)`                                  |
| Navigate to a route           | `context.go('/path')` or `context.push('/path')`     |
| Upload an image               | `CloudinaryService().uploadFile(file)`               |
| Create a new feature          | Add folder under `features/<name>/` with `providers/`, `screens/`, `widgets/` |
| Create a new shared widget    | Add to `core/widgets/<category>/`                    |
| Create a new service          | Add to `core/services/<name>_service.dart`           |
| Create a new model            | Add to `core/models/<name>_model.dart`               |
| Create a new utility          | Add to `core/utils/<name>_utils.dart`                |

---

*Happy coding! If something is unclear or missing from this guide, raise it in the GC so we can update it.* 🚀
