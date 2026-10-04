# Reflect & Gratitude

A daily reflection and gratitude companion based on the **"Let's Spend The Year Together"** calendar. Built with Flutter, so one codebase runs on Android and iOS.

---

## বাংলায়: কীভাবে চালাবেন

> **আগে এটা পড়ুন:** এই কোড যে কম্পিউটারে লেখা হয়েছে, সেখানে Flutter ইনস্টল করা যায়নি। তাই কোডটা এখনো কম্পাইল বা টেস্ট করে দেখা হয়নি। প্রথমবার চালানোর আগে `flutter analyze` আর `flutter test` চালান। কোনো error এলে সেটা কপি করে পাঠালেই ঠিক করে দেওয়া যাবে। নিচের GitHub পদ্ধতিতে এই দুটো চেক নিজে থেকেই চলে।

### পদ্ধতি ১: নিজের কম্পিউটারে

1. Flutter ইনস্টল করুন: https://docs.flutter.dev/get-started/install
   - Android-এর জন্য Android Studio লাগবে।
   - iPhone-এর জন্য Mac আর Xcode লাগবে।
2. এই ফোল্ডারে টার্মিনাল খুলে চালান:
   ```bash
   bash tool/setup_platforms.sh   # android/ আর ios/ ফোল্ডার তৈরি করে
   flutter pub get
   flutter analyze
   flutter test
   flutter run                    # ফোন বা emulator-এ অ্যাপ চালায়
   ```
   Windows-এ `bash` না থাকলে প্রথম লাইনের বদলে এটা চালান:
   ```bash
   flutter create --platforms=android,ios --org com.yeartogether --project-name reflect_gratitude .
   ```
3. **Android APK:** `flutter build apk --release`
   ফাইলটা পাবেন `build/app/outputs/flutter-apk/app-release.apk`-এ। এটা ফোনে পাঠিয়ে ইনস্টল করা যায়।
4. **iPhone / TestFlight:** Mac-এ `open ios/Runner.xcworkspace` চালান। Xcode-এ Signing & Capabilities থেকে আপনার Apple Developer টিম বেছে নিন। তারপর Product → Archive করে TestFlight-এ আপলোড করুন।
5. **Google Play:** `flutter build appbundle` দিয়ে `.aab` ফাইল বানান। আপলোড করার আগে নিজের signing key সেট করতে হবে: https://docs.flutter.dev/deployment/android

### পদ্ধতি ২: কিছু ইনস্টল না করে, GitHub দিয়ে APK

1. এই ফোল্ডারটা একটা GitHub repository-তে push করুন।
2. Repository-র **Actions** ট্যাব খুলুন। "Build app" নিজে থেকেই চলবে।
3. শেষ হলে run-এর নিচে **reflect-gratitude-android** থেকে APK ডাউনলোড করুন।
4. iOS-এর অংশটা শুধু দেখায় অ্যাপটা ঠিকমতো কম্পাইল হচ্ছে কি না। iPhone-এ ইনস্টল করতে Xcode-এ sign করতে হবে।

### নিজের কনটেন্ট বসাবেন কোথায়

| কী বদলাবেন | ফাইল |
|---|---|
| ১২ মাসের থিম, intention, essay-র শিরোনাম ও লিংক, ছবির রং | `assets/content/themes.json` |
| প্রতিদিনের quote | `assets/content/quotes.json` |
| অ্যাপের রং | `lib/theme/app_colors.dart` |
| চারটা প্রশ্নের লেখা | `lib/models/prompt.dart` |
| স্ট্রিকের নিয়ম (সপ্তাহে কত দিন, মাসে কত দিন) | `lib/logic/streaks.dart` |

এখনকার থিম, quote আর essay লিংক (`example.com`) সব নমুনা। আপনার ক্যালেন্ডারের আসল লেখা দিয়ে বদলে নিন।

---

## Developer notes

### What's in this version

| Area | Status |
|---|---|
| Welcome screen with the user's name | Done |
| **Today**: greeting, daily/weekly/monthly streaks, month theme card, daily quote, today's four prompts | Done |
| **Daily entry**: Reflection, Gratitude, Successes, Final thoughts, one step at a time, with autosave | Done |
| **Journal** tab: weekly review, gratitude round-up, entries, browse past weeks | Done |
| **Progress** tab: streak card, totals, consistency, this week's chart, month grid | Done |
| **Calendar** tab: month artwork, theme, intention, essay link, quote, calendar; open any past day | Done |
| On-device storage, works offline | Done |
| Accounts and sync across devices | Not yet. See "Adding accounts and sync" |
| Monthly photographs | Placeholder artwork drawn in code. See "Adding the real photographs" |
| App icon and splash screen | Flutter defaults |
| Reminders, AI prompts, team features, podcasts | Later phases |

### Project layout

```
lib/
  main.dart                 loads content and saved entries, starts the app
  app.dart                  MaterialApp, welcome gate
  data/
    content.dart            month themes and quotes from assets/content
    entry_store.dart        EntryStore interface + on-device implementation
  logic/
    dates.dart              date helpers (Monday-first weeks, DST-safe)
    streaks.dart            streak and progress rules (pure functions)
  models/
    entry.dart              one day's entry
    prompt.dart             the four prompts: text, colour, icon
  state/app_state.dart      AppState (ChangeNotifier) + AppScope
  theme/                    colours, type, status-bar styles
  widgets/                  cards, buttons, bottom tab bar, artwork painter
  screens/                  welcome, home shell, today, entry, weekly, progress, monthly
assets/
  content/                  themes.json, quotes.json
  fonts/                    Spectral and Nunito Sans (SIL Open Font License)
test/                       streak, entry and widget tests
tool/setup_platforms.sh     creates android/ and ios/ with flutter create
.github/workflows/build.yml analyze, test, APK, iOS compile check
```

State management is plain Flutter: one `ChangeNotifier` shared through an `InheritedNotifier`. The only packages are `shared_preferences` and `url_launcher`.

### Streak rules

- **Daily:** a day counts once at least one of the four sections has text. The streak runs back from today; if today isn't written yet it counts back from yesterday, so the streak doesn't drop to zero in the morning.
- **Weekly:** Monday-to-Sunday weeks with at least 4 written days, counted back from this week. The current week only adds once it reaches 4.
- **Monthly:** calendar months with at least 20 written days, same rule.
- **Consistency:** days written divided by days since the first entry.

Change the numbers in `StreakRules` (`lib/logic/streaks.dart`). The tests in `test/streaks_test.dart` cover these rules.

### Adding accounts and sync

All storage goes through `EntryStore` (`lib/data/entry_store.dart`). To add Supabase or Firebase:

1. Write a class that implements `EntryStore`, backed by your database. Keep `PrefsEntryStore` as a local cache so the app still works offline.
2. Add a sign-in screen in front of `HomeShell` in `lib/app.dart`.
3. Pass your new store to `AppState` in `lib/main.dart`.

No screen needs to change.

### Adding the real photographs

Put each image in `assets/images/` (for example `september.jpg`), register the folder in `pubspec.yaml`, add an `"image"` field to each month in `themes.json`, and draw it in place of `AbstractArt` in `MonthHeroCard` (`lib/screens/today_screen.dart`) and the hero in `lib/screens/monthly_screen.dart` with `Image.asset(..., fit: BoxFit.cover)`.

### Requirements

Flutter 3.27 or newer (Dart 3.6+). The code uses `Color.withValues` and `PopScope.onPopInvokedWithResult`, which older versions lack.
