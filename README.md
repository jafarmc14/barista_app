# Pavilijon Coffee - Barista App

A modern, highly-responsive Flutter application designed for baristas and staff to manage incoming "To-Go" orders efficiently. This application integrates directly with the Pavilijon Coffee API to fetch live orders, track completion progress, and synchronize data securely.

## 🚀 Key Features

### 🔐 Secure PIN Authentication
- Staff members can log in using a secure PIN verified via the centralized REST API (`/api/auth/login`).
- Stores JWT `auth_token`, `user_name`, and session data persistently utilizing `shared_preferences`.

### 📋 Interactive Task Management (To-Do / Done)
- **Live Order Fetching**: Polls `PAID` "To-Go" orders from the server using synchronized `GET` requests with embedded payload bodies.
- **Detailed Order Cards**: Parses and displays deeply nested order data including the `orderHash` (e.g., *Order #B2EA74*), Customer Name, and granular details for every product (e.g., `1x Latte (Small)`).
- **Interactive UI**: Staff can tap checkmark icons to mark tasks as "Done," dynamically shifting them to completed lists.

### 🔄 Batch Cloud Synchronization
- **One-Tap Completion (DONE logic)**: Loops over all locally completed tasks and fires asynchronous `PATCH` updates (`COMPLETED`) directly to the backend endpoint.
- Provides immediate visual feedback through `CircularProgressIndicator` and `SnackBars`.

### 🎨 Beautiful & Responsive Design
- Engineered with a customized design system mapping exactly to the defined Tailwind styling configuration.
- **Color Palette**: `Primary Blue (#005E9F)`, `Surface (#F5F6F7)`, and Deep Grays (`#2C2F30`, `#595C5D`).
- **Typography**: Employs the **Manrope** font family to emphasize readable and highly visible metrics (`Extrabold` headers).

## 🛠 Architecture & Tech Stack

- **Framework**: Flutter / Dart
- **Network**: `http` package for robust API communication handling JSON payloads directly in `http.Request`.
- **Local Storage**: `shared_preferences` for reliable on-device token persistence.
- **State Handling**: Core local state managed natively through `StatefulWidget` lifecycles.

## ⚙️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- Dart SDK

### Installation
1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   ```
2. **Install Dependencies:**
   Navigate into the project directory and fetch the required packages:
   ```bash
   cd barista_app
   flutter pub get
   ```
3. **Run the Application:**
   Run the project on your preferred emulator or connected device:
   ```bash
   flutter run
   ```

---
*Created as part of the operational tooling for Pavilijon Coffee.*
