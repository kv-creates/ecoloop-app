# EcoLoop - Sustainable Shopping & Recycling

A college Product Design project: a Flutter mobile app for sustainable shopping and recycling. Built with Cupertino (iOS-style) widgets, no backend, no login, no payments.

## Features

- **Home** – Greeting header, search, hero card, category chips, featured product carousel, recycle teaser
- **Shop** – Search, category filters, sort action sheet, product grid with wishlist heart
- **Product details** – Image, brand, price, feature tags, description, quantity stepper, add to cart, wishlist toggle
- **Wishlist** – Saved products grid
- **Cart** – List rows with swipe-to-delete, quantity stepper, order summary, free-shipping progress bar, checkout
- **Checkout** – Grouped shipping form with inline validation, cash on delivery, order confirmation with animated check
- **Recycle** – Verified recycling centres in Mumbai, Delhi, Bangalore with material/city filters and website links
- **Impact** – Personal impact tracker: orders placed, items bought, wishlist size, recycled kg, monthly bar chart, recycling log
- **About** – Student project disclosure

## Design

Modern iOS design language with Inter font, calm green colour palette, rounded cards, soft shadows, haptic feedback, and smooth page transitions.

## How to run

1. Install Flutter (stable channel): https://docs.flutter.dev/get-install
2. Clone this repo and run:
   ```
   flutter pub get
   flutter run
   ```

## Build release APK

### Via GitHub Actions (recommended)
1. Push to the `main` branch (or trigger `workflow_dispatch`).
2. The workflow builds a release APK and uploads it as an artifact named `ecoloop-apk`.
3. Download the artifact from the Actions page and install it on your phone.

### Locally
```
flutter build apk --release
```
The APK is output at:
`build/app/outputs/flutter-apk/app-release.apk`

Install on your Android device:
```
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Android setup

- `android/app/src/main/AndroidManifest.xml` includes `INTERNET` permission (required for Unsplash images) and `android:label="EcoLoop"`.
- `minSdk` is set to 21.
- Release builds use the default debug signing config so the APK installs for demos.

## Packages used

- `provider` – state management
- `shared_preferences` – local persistence for cart, wishlist, and recycling log
- `cached_network_image` – product image loading with shimmer placeholder
- `cupertino_icons` – iOS-style icons

No backend, no API keys, no paid services, no login.

## Important note

**EcoLoop is a student project. Orders are not processed or shipped.**

All data is sourced from real, verifiable brand and municipal pages (see `docs/SOURCES.md`). No payment details are collected. Nothing is charged or shipped.
