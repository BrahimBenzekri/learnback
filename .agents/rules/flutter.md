---
trigger: always_on
---

# Flutter Best Practices – LearnBack App

## 🏗️ Project Structure (Feature-First)
Always use feature-first folder structure. Never organize by type (no global `widgets/` or `models/` dumps).

```
lib/
├── main.dart
├── app/
│   ├── app.dart              # Root widget, router setup
│   └── theme/                # AppTheme, colors, text styles
├── core/
│   ├── constants/            # API URLs, app-wide constants
│   ├── errors/               # Failure classes, exceptions
│   ├── network/              # Dio/http client setup
│   └── utils/                # Extensions, helpers
├── features/
│   ├── auth/
│   │   ├── data/             # API calls, DTOs, repository impl
│   │   ├── domain/           # Models, repository interfaces
│   │   └── presentation/     # Screens, widgets, providers
│   ├── skills/
│   ├── matching/
│   ├── roadmap/
│   ├── progress/
│   ├── quiz/
│   └── courses/
└── shared/
    ├── widgets/              # Truly reusable widgets only
    └── extensions/           # BuildContext extensions, etc.
```

---

## 🧱 Widget Rules

- **Always use `const` constructors** wherever possible — reduces rebuilds.
- **Never put business logic inside widgets.** Widgets only call providers and render UI.
- **Split large widgets** into smaller private widgets or separate files. If a build method exceeds ~80 lines, split it.
- **Prefer `StatelessWidget`** over `StatefulWidget`. Only use `StatefulWidget` for local UI state (e.g., form field focus, animation controllers).
- **Never use `setState` for app-level state.** That's Riverpod's job.
- Use `ListView.builder` / `GridView.builder` for any list — never `ListView(children: [...])` with dynamic data.
- Always handle **3 UI states**: loading, error, and data. No exceptions.

```dart
// ✅ Good
ref.watch(skillsProvider).when(
  loading: () => const SkeletonLoader(),
  error: (e, _) => ErrorView(message: e.toString()),
  data: (skills) => SkillList(skills: skills),
);

// ❌ Bad
final skills = ref.watch(skillsProvider).value ?? [];
return SkillList(skills: skills); // ignores loading/error
```

---

## 🧭 Navigation

- Use **GoRouter** for all navigation. No `Navigator.push` directly.
- Define all routes in a single `router.dart` file inside `app/`.
- Use **named routes** with path parameters for deep linking readiness.
- Protect authenticated routes using GoRouter's `redirect` callback — check auth state from a Riverpod provider.

```dart
// ✅ Good
context.go('/matches/${match.id}/roadmap');

// ❌ Bad
Navigator.push(context, MaterialPageRoute(builder: (_) => RoadmapScreen()));
```

---

## 🎨 Theming & Styling

- **Never hardcode colors or text styles** inline. Always use `Theme.of(context)`.
- Define a single `AppTheme` class with `lightTheme` and `darkTheme`.
- Use `ColorScheme` — do not define random hex colors scattered around.
- Use `TextTheme` for all typography (`headlineMedium`, `bodyLarge`, etc.).
- Define spacing constants (`AppSpacing.sm = 8.0`, `md = 16.0`, `lg = 24.0`).

```dart
// ✅ Good
Text('Hello', style: Theme.of(context).textTheme.titleLarge)
SizedBox(height: AppSpacing.md)

// ❌ Bad
Text('Hello', style: TextStyle(fontSize: 20, color: Color(0xFF333333)))
SizedBox(height: 16)
```

---

## 📡 API & Networking

- Use **Dio** as the HTTP client. Configure it once in `core/network/`.
- Use an interceptor for attaching JWT tokens to every request automatically.
- Never call `dio.get(...)` directly from a widget or provider — wrap it in a **repository class**.
- All API responses must be mapped to **typed model classes** (use `fromJson` factories).
- Handle API errors centrally — map HTTP status codes to custom `Failure` objects.

```dart
// ✅ Good — repository pattern
class SkillRepository {
  Future<List<Skill>> getSkills() async { ... }
}

// ❌ Bad — raw dio call in provider
final skills = await dio.get('/api/skills');
```

---

## 🖼️ Assets & Images

- Declare all assets in `pubspec.yaml` under `flutter: assets:`.
- Use `cached_network_image` for all remote images (user avatars, course thumbnails).
- Always provide a `placeholder` and `errorWidget` for network images.
- Use `flutter_svg` for vector icons/illustrations.

---

## ⚡ Performance & Best Practices

- Use `const` widgets aggressively — especially in lists.
- Avoid rebuilding entire screens — use fine-grained `ref.watch` on specific providers.
- Never do heavy work (parsing, filtering) inside `build()` — do it in providers.
- Use `RepaintBoundary` around complex animated widgets.
- Dispose controllers properly (`TextEditingController`, `AnimationController`) in `dispose()`.
- Always check `mounted` before using `BuildContext` after an `await`.

```dart
// ✅ Good
await someAsyncCall();
if (!mounted) return;
context.go('/home');

// ❌ Bad
await someAsyncCall();
context.go('/home'); // context might be dead
```

---

## 📦 Recommended Packages

| Purpose            | Package                        |
|--------------------|--------------------------------|
| State Management   | `flutter_riverpod`             |
| Navigation         | `go_router`                    |
| HTTP Client        | `dio`                          |
| Image Caching      | `cached_network_image`         |
| SVG Support        | `flutter_svg`                  |
| Secure Storage     | `flutter_secure_storage`       |
| File Picker        | `file_picker`                  |
| JSON Serialization | `freezed` + `json_serializable`|
| Env Variables      | `flutter_dotenv`               |
| Logging            | `logger`                       |

---

## 🚫 Hard Rules — Never Do These

- ❌ Never store JWT tokens in `SharedPreferences` — use `flutter_secure_storage`.
- ❌ Never use `BuildContext` across async gaps without checking `mounted`.
- ❌ Never use `print()` — use the `logger` package.
- ❌ Never commit `.env` files or API keys to git.
- ❌ Never put multiple screens in one file.
- ❌ Never name widgets `Widget1`, `MyWidget`, `TestScreen`.
- ❌ Never skip error and loading states — always handle all 3.