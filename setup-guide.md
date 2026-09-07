---
layout: default
title: Installation & Setup
nav_order: 2
description: "Step-by-step installation, environment variables, unit testing, and Flutter build guide."
---

# Installation & Setup Guide

Follow this guide to clone, configure, build, and run the AI Travel Booking Assistant application on your workstation or emulator.

---

## 📋 Prerequisites

| Component | Minimum Version | Notes |
|:---|:---|:---|
| **Flutter SDK** | `v3.19.0` (stable) | Required for core engine & UI components |
| **Dart SDK** | `v3.3.0` | Included with Flutter SDK |
| **Android Studio / Xcode** | Latest stable | Required for device emulators & simulators |
| **Google Gemini API Key** | Optional | Required for online LLM; offline local engine runs automatically if omitted |

---

## 🛠️ Step-by-Step Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/aavvvacado/Ai-travel-booking-assistance.git
cd Ai-travel-booking-assistance
flutter pub get
```

---

### Step 2: Configure Gemini API Key

The app uses **Google Gemini 1.5 Flash**. You can provide your key in two ways:

#### Option A: Via App UI Key Dialog
Launch the app and click the key icon (🔑) in the app bar. Enter your API key (starting with `AIzaSy...` or `AQ...`) and click **Save Key**.

#### Option B: Via `--dart-define` at Compile Time
```bash
flutter run --dart-define=GEMINI_API_KEY="AIzaSyYourSecretGeminiApiKeyHere"
```

---

### Step 3: Run Automated Tests

Run all 14 automated unit tests verifying date resolution, NLP intent parsing, layover & duration sorting, and date corrections:

```bash
flutter test
```

---

### Step 4: Run Application

```bash
# Run on connected Android / iOS device or emulator
flutter run

# Run on Web (Chrome)
flutter run -d chrome
```
