# CurrencyX

A multi-currency converter and exchange rate viewer built with Flutter. Convert and sum multiple currencies simultaneously, browse live exchange rates, and configure your preferred base currency — all backed by real-time data from the Exchange Rates Data API.

**Live Demo:** https://currencyx-b53c5.web.app/

---

## Table of Contents

- [Live Demo](#live-demo)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Build & Run Instructions](#build--run-instructions)
- [Project Structure](#project-structure)
- [Architecture & Design Decisions](#architecture--design-decisions)
- [App Flow](#app-flow)
- [Assumptions](#assumptions)

---

## Live Demo

A demo version of the app is deployed on Firebase Hosting. You can test it directly in your browser:

https://currencyx-b53c5.web.app/

---

## Features

- **Multi-currency converter** — add multiple currency rows, enter amounts, and calculate the combined total in your base currency.
- **Live exchange rates** — browse all available currencies with search/filter and a floating action button to refresh.
- **Configurable base currency** — change the base currency from Settings; rates are re-fetched from the API before applying.
- **Offline-first with Hive caching** — cached data is loaded instantly on app start; network calls only happen when no cache exists or explicitly triggered.
- **Auto-retry on splash** — up to 5 automatic retries with a manual retry option on persistent failure.
- **Persisted preferences** — the selected base currency is stored locally and survives app restarts.

---

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | `>=3.11.1` |
| Dart SDK | `>=3.11.1` |
| Xcode | 15+ (for iOS) |
| Android Studio / Android SDK | API 21+ (for Android) |
| Chrome | Any modern version (for web) |

Verify your setup:

```bash
flutter doctor
```

---

## Build & Run Instructions

### 1. Clone & install dependencies

```bash
git clone <repo-url>
cd currencyx
flutter pub get
```

### 2. Generate code (dart_mappable)

The project uses `dart_mappable` for JSON serialization. Generated `.mapper.dart` files are already committed, but if you need to regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run on Android

```bash
# Start an emulator or connect a device
flutter run -d android
```

Or build an APK:

```bash
flutter build apk --release
```

### 4. Run on iOS

```bash
cd ios && pod install && cd ..
flutter run -d ios
```

Or build for release:

```bash
flutter build ios --release
```

> **Note:** iOS builds require a Mac with Xcode installed and a valid signing configuration.

### 5. Run on Web

```bash
flutter run -d chrome
```

Or build for deployment:

```bash
flutter build web
```

### 6. Run tests

```bash
flutter test
```

All 45 unit tests cover the repository layer, view model logic, and notifier behavior.

---

## Project Structure

```
lib/
├── main.dart                          # App entry point — Hive init, ProviderScope setup
├── common/
│   ├── assets/
│   │   └── app_icons.dart             # Custom icon data (logo, shield, etc.)
│   ├── constants/
│   │   ├── api.dart                   # Base URL and API key
│   │   └── colors.dart                # App-wide color palette
│   ├── mapper/
│   │   └── mapper.dart                # dart_mappable container init
│   └── widgets/
│       └── searchable_dropdown.dart   # Reusable overlay-based searchable dropdown
├── models/
│   ├── currency_data/
│   │   └── currency_data.dart         # CurrencyData class with symbol map & formatting
│   ├── entity/
│   │   ├── base_error.dart            # Abstract error base class
│   │   └── network_error.dart         # HTTP-specific error with status code
│   ├── rates/
│   │   ├── rates.dart                 # API response model (dart_mappable)
│   │   └── rates.mapper.dart          # Generated serialization code
│   └── symbols/
│       ├── symbols.dart               # API response model (dart_mappable)
│       └── symbols.mapper.dart        # Generated serialization code
├── repositories/
│   └── currency_repository.dart       # Data layer: API + cache coordination
├── services/
│   ├── api_services.dart              # Dio HTTP client with error mapping
│   └── currency_cache.dart            # Hive-based local storage
└── views/
    ├── splash_screen/
    │   ├── splash_screen.dart         # Initial loading screen with retry logic
    │   └── widgets/
    │       ├── label_icon.dart         # SECURE / GLOBAL / INSTANT badges
    │       └── loading_progress_bar.dart  # Animated indeterminate progress bar
    ├── home_screen/
    │   ├── home_screen.dart           # Scaffold with bottom navigation (3 tabs)
    │   ├── viewmodel/
    │   │   └── home_viewmodel.dart    # All Riverpod providers and notifiers
    │   └── widgets/
    │       ├── converter_view.dart    # Converter tab UI
    │       ├── currency_row.dart      # Single currency input row
    │       ├── add_currency_button.dart
    │       ├── calculate_button.dart
    │       ├── total_value_card.dart   # Hero card showing total in base currency
    │       └── status_indicator.dart   # "Updated Xm ago" / "Live Market Rates"
    ├── rates_screen/
    │   └── rates_screen.dart          # Rates list with search + FAB refresh
    └── settings_screen/
        └── settings_screen.dart       # Base currency selector with save button
```

---

## Architecture & Design Decisions

### State Management — Riverpod v3

The app uses **flutter_riverpod ^3.3.1** with the `Notifier` / `AsyncNotifier` pattern. Key providers:

| Provider | Type | Purpose |
|----------|------|---------|
| `homeViewModelProvider` | `AsyncNotifierProvider` | Fetches and holds the full currency list |
| `baseCurrencyProvider` | `NotifierProvider` | Manages the selected base currency |
| `calculationProvider` | `NotifierProvider` | Manages calculation state and total |
| `entriesProvider` | `NotifierProvider` | Manages the list of currency entry rows |
| `navIndexProvider` | `NotifierProvider` | Bottom navigation tab index |
| `settingsSavingProvider` | `NotifierProvider` | Blocks navigation during settings save |
| `tickProvider` | `NotifierProvider` | 30-second timer for "updated ago" label refresh |

### Networking — Dio + Twofold

- **Dio** handles HTTP with 30-second connect/receive timeouts.
- **Twofold** (a Result type library) wraps API responses as `Twofold<T, NetworkError>` — success or typed error, no exceptions leak to the UI.
- `safeApiCall<T>()` catches `DioException`, `SocketException`, `TimeoutException`, `IOException`, and `FormatException` with user-friendly messages.

### Caching — Hive

- **Why Hive over Floor:** Floor (an SQLite abstraction) was initially considered, but it had dependency conflicts with `dart_mappable_builder` due to incompatible `source_gen` versions. Hive was chosen for its simplicity, fast read/write, and zero native dependency conflicts.
- Two Hive boxes:
  - `currencies` — stores the full currency list as `Map<dynamic, dynamic>` entries (keyed by currency code).
  - `settings` — stores user preferences (currently just the base currency string).
- On app start, cached data is loaded synchronously. If cache is empty, an API call is made.
- Cache is cleared and re-populated whenever the base currency changes, preventing stale rate data.

### Serialization — dart_mappable

Models (`Rates`, `Symbols`) use `dart_mappable` annotations with code generation via `build_runner`. This provides `fromJson`, `toMap`, `copyWith`, and equality out of the box.

### API-First Base Currency Change

When the user changes the base currency in Settings:
1. The new base is sent to the API **first**.
2. Only if the API call succeeds does the app update the local state, cache, and UI.
3. On failure, the previous base currency is preserved — no inconsistent state.

### Calculation Logic

The converter does **not** call the API when calculating. It uses the already-fetched rate data:
- For each entry, `amount / rate` converts the entered amount to the base currency.
- All converted amounts are summed to produce the total.

---

## App Flow

### 1. Splash Screen

```
App Launch
  └─► main.dart
       ├─ Hive.initFlutter()
       ├─ CurrencyCache.init() (opens Hive boxes)
       └─ ProviderScope (overrides currencyCacheProvider)
            └─► SplashScreen
                 └─ Listens to homeViewModelProvider
```

`HomeViewModel.build()` runs automatically:
- **Cache hit** → returns cached `List<CurrencyData>` instantly.
- **Cache miss** → calls `repo.fetchCurrencies(base:)` which fires both `/symbols` and `/latest?base=` API calls in parallel via `Future.wait`.

On success, the splash screen navigates to `HomeScreen`. On error, it retries up to 5 times (1-second delay between retries). After 5 failures, a snackbar with a **Retry** button is shown.

### 2. Home Screen (Converter Tab)

The default tab. The user can:

- **Add currency rows** — each row has an amount text field and a searchable currency dropdown.
- **Enter amounts** — numeric input with decimal support (up to 2 decimal places).
- **Calculate** — taps the "Calculate Total" button. The app sums all entered amounts converted to the base currency using cached rates. No API call is made.
- **View total** — displayed in the hero card at the top, showing the base currency symbol and formatted total.
- **Status indicators** — "Updated Xm ago" (auto-refreshes every 30 seconds via `tickProvider`) and "Live Market Rates".

The Calculate button is disabled when:
- No amount is entered in any row.
- A calculation is already in progress.
- Rates are currently loading (e.g., during a refresh).

### 3. Rates Screen

Displays all exchange rates relative to the base currency in a scrollable list. Each row shows the currency code, full name, symbol, and rate.

- **Search** — filter currencies by code or name via the search bar.
- **Refresh** — the floating action button triggers `updateRates()`, which calls both `/symbols` and `/latest` APIs, updates the cache, and refreshes the UI. A snackbar confirms success or failure.

If the refresh fails, the previous data is restored so the user never sees an empty screen.

### 4. Settings Screen

Allows the user to change the base currency.

- **Dropdown** — a searchable dropdown listing all available currencies. Selecting a currency only updates local pending state (no API call yet).
- **Save button** — appears only when the selection differs from the current base. On tap:
  1. Sets `settingsSavingProvider` to `true` (disables bottom navigation bar).
  2. Calls `baseCurrencyProvider.notifier.set(code)` which:
     - Fires `repo.fetchCurrencies(base: newCode)` to get fresh rates for the new base.
     - On success: updates state, persists to Hive, resets calculation, and updates the currency list.
     - On failure: returns `false`, keeping the old base currency.
  3. Shows a success or failure snackbar.
  4. Re-enables navigation.

The dropdown is wrapped in `IgnorePointer` during save to prevent interaction.

---

## Assumptions

1. **Hive instead of Floor** — Floor was the originally intended caching solution, but it was replaced with Hive due to dependency version conflicts between `floor_generator` and `dart_mappable_builder` (both require different versions of `source_gen`). Hive provides equivalent functionality with simpler setup.

2. **Single API source** — The app relies on `api.apilayer.com/exchangerates_data` for both currency symbols and latest rates. If this API is unavailable, the app falls back to cached data.

3. **Base currency = conversion target** — All conversions compute the total in the selected base currency. The formula is `amount / rate` for each entry, where `rate` is relative to the base.

4. **No authentication** — The API key is embedded in the app constants. In a production app, this would be stored securely (e.g., via environment variables or a backend proxy).

5. **No persistent entry state** — Currency entry rows in the converter are ephemeral. They reset when the app is restarted. Only the base currency preference and rate data are persisted.

6. **Cache invalidation on base change** — When the base currency changes, the entire cache is cleared and re-populated with rates for the new base. This prevents stale cross-base rate data.

7. **30-second timeout** — API calls have a 30-second timeout for both connection and response. This is generous enough for slow networks but prevents indefinite hangs.

8. **Web compatibility** — The app uses `hive_flutter` which works on web without additional setup (no native SQLite dependencies needed).

9. **UI designs generated with Stitch AI** — The application's UI designs were created using Stitch AI, then implemented in Flutter.
