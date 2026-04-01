# Pavilijon Coffee - Barista & Kurir App

A modern, highly-responsive Flutter application designed for Pavilijon Coffee staff to manage both "To-Go" barista orders and "Delivery" courier tasks efficiently. The app features a swipeable dual-role interface and deep integration with the Pavilijon Coffee API.

## 🚀 Key Features

### 🔄 Dual-Workflow Interface
- **Barista Page**: Manage incoming "To-Go" orders. Marks tasks as `COMPLETED` on the server.
- **Kurir Page**: Manage "Delivery" orders. Displays critical delivery info:
  - 📞 Customer Phone
  - 📍 Delivery Address
  - 📱 Parcel/InPost Code
  - Marks tasks as `DELIVERED` on the server.
- **Swipe Navigation**: Seamlessly switch between Barista and Kurir workflows using a smooth `PageView` and tab indicators.

### 🔐 Multi-Layer Security
- **Secure Authentication**: Staff log in via a secure PIN API (`/auth/login`).
- **Hardware-Backed Storage**: Uses `flutter_secure_storage` to store JWT `auth_token` and sensitive data in the Android Keystore and iOS Keychain.
- **Environment Safety**: Configuration (like `API_BASE_URL`) is handled via `--dart-define` to prevent leaking secrets in the plaintext APK assets.
- **Android Hardening**: `allowBackup` is disabled to prevent unauthorized data extraction via ADB or Google Cloud backups.

### 📋 Interactive Task Management
- **Live Order Fetching**: Polls server for `PAID` orders using clean Bearer Token authentication (no PIN redundancy in GET requests).
- **Dynamic Task Cards**:
  - Displays `orderHash` or `queueNumber` prominently.
  - Granular item breakdown (e.g., `1x Latte (Small)`).
  - Highlighted **Customer notes** for special instructions.
- **Batch Sync**: Locally completed tasks are queued and synchronized to the cloud in one tap with real-time feedback.

### 🎨 Premium Design System
- Built with a sleek, interactive UI inspired by modern design standards.
- **Typography**: Uses **Manrope** for superior readability.
- **Visuals**: Vibrant primary blue (`#005E9F`), clean surfaces (`#F5F6F7`), and subtle micro-animations.

## 🛠 Tech Stack

- **Framework**: Flutter / Dart
- **Storage**: `flutter_secure_storage` (Keystore/Keychain integration)
- **Networking**: `http` package with standardized Bearer Token headers.
- **Configuration**: Dart Environment Variables (`--dart-define`).

## ⚙️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable)
- Android/iOS physical device or emulator

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd barista_app
   ```

2. **Fetch Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run with Environment Variables:**
   You **must** provide the `API_BASE_URL` at runtime for the app to connect to your backend:
   ```bash
   flutter run --dart-define=API_BASE_URL=https://pavilijoncoffee.com/api
   ```

### 📦 Building for Production (Release)
To build a production-ready, obfuscated APK:
```bash
flutter build apk --obfuscate --split-debug-info=./debug_info --dart-define=API_BASE_URL=https://pavilijoncoffee.com/api
```

---
*Operational tooling engineered for Pavilijon Coffee.*
