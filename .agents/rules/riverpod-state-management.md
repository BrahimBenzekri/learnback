---
trigger: always_on
---

# Riverpod Best Practices – LearnBack Project

## 🧠 Core Philosophy
- **Riverpod is the single source of truth** — no local state for anything that matters.
- **Providers are global, lazy, and disposable** — embrace it.
- **Use code generation** (`riverpod_generator`) — less boilerplate, more consistency.
- **Never use `ChangeNotifier`** — that's old school Flutter Provider energy, we don't do that here.

---

## 📦 Setup

```dart
// main.dart — always wrap with ProviderScope at the very root
void main() {
  runApp(const ProviderScope(child: LearnBackApp()));
}
```

---

## 🗂️ Provider File Organization

- One provider file per feature, inside `features/<feature>/presentation/providers/`.
- Name files clearly: `auth_provider.dart`, `skills_provider.dart`, `matches_provider.dart`.
- Keep provider logic thin — heavy logic goes in the repository, provider just calls repo.

```
features/
├── auth/
│   └── presentation/
│       └── providers/
│           └── auth_provider.dart
├── skills/
│   └── presentation/
│       └── providers/
│           ├── skills_provider.dart
│           └── user_skills_provider.dart
├── matches/
│   └── presentation/
│       └── providers/
│           └── matches_provider.dart
...
```

---

## ⚙️ Which Provider to Use When

| Situation | Use |
|---|---|
| Read-only async data (API fetch) | `@riverpod` (FutureProvider) |
| Stream of data (real-time future) | `@riverpod` (StreamProvider) |
| Mutable state + async actions | `@riverpod` class → `AsyncNotifier` |
| Simple sync mutable state | `@riverpod` class → `Notifier` |
| Auth state (token exists / user info) | `AsyncNotifier` |
| Form state (local, ephemeral) | `Notifier` or just `StatefulWidget` |

---

## ✅ Code Generation Pattern (Always Use This)

```dart
// ✅ Simple async fetch — auto-generates skillsProvider
@riverpod
Future<List<Skill>> skills(SkillsRef ref) async {
  final repo = ref.watch(skillRepositoryProvider);
  return repo.getAllSkills();
}

// ✅ Notifier for mutable state with actions
@riverpod
class UserSkills extends _$UserSkills {
  @override
  Future<List<UserSkill>> build() async {
    final repo = ref.watch(userSkillRepositoryProvider);
    return repo.getUserSkills();
  }

  Future<void> addSkill(String skillId, String level) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(userSkillRepositoryProvider);
      await repo.addSkill(skillId, level);
      return ref.refresh(userSkillsProvider.future);
    });
  }
}
```

---

## 🔐 Auth Provider Pattern

```dart
@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    final storage = ref.watch(storageServiceProvider);
    final token = await storage.getToken();
    if (token == null) return const AuthState.unauthenticated();
    return AuthState.authenticated(token: token);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final token = await repo.login(email, password);
      await ref.read(storageServiceProvider).saveToken(token);
      return AuthState.authenticated(token: token);
    });
  }

  Future<void> logout() async {
    await ref.read(storageServiceProvider).clearToken();
    ref.invalidateSelf();
    // Invalidate all user-specific providers
    ref.invalidate(userSkillsProvider);
    ref.invalidate(matchesProvider);
    ref.invalidate(userGoalsProvider);
  }
}
```

---

## 🔄 Dependency Between Providers

```dart
// ✅ Provider depending on auth token
@riverpod
Future<UserProfile> userProfile(UserProfileRef ref) async {
  // Will auto-recompute when authProvider changes
  final authState = await ref.watch(authProvider.future);
  if (authState is! Authenticated) throw Exception('Not authenticated');
  final repo = ref.watch(userRepositoryProvider);
  return repo.getProfile();
}
```

---

## 🎯 Watching vs Reading

| Scenario | Use |
|---|---|
| Widget needs to rebuild on change | `ref.watch()` |
| One-time action (button tap, init) | `ref.read()` |
| Listen to changes + run side effect | `ref.listen()` |
| Invalidate / force refresh | `ref.invalidate()` or `ref.refresh()` |

```dart
// ✅ Correct usage in widget
class MatchesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch = rebuilds when data changes
    final matchesAsync = ref.watch(matchesProvider);

    return matchesAsync.when(
      data: (matches) => MatchesList(matches: matches),
      loading: () => const MatchesShimmer(),
      error: (e, _) => ErrorRetryWidget(
        // read = one-time, no rebuild needed
        onRetry: () => ref.invalidate(matchesProvider),
      ),
    );
  }
}
```

---

## 📡 Side Effects Pattern (Mutations)

```dart
// ✅ Triggering a mutation from a button
class ApproveMatchButton extends ConsumerWidget {
  const ApproveMatchButton({super.key, required this.matchId});
  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        await ref.read(matchesProvider.notifier).approveMatch(matchId);
        // Show snackbar on success/failure via ref.listen elsewhere
      },
      child: const Text('Approve'),
    );
  }
}
```

---

## 🔔 Listening to State Changes (Snackbars / Navigation)

```dart
// ✅ Use ref.listen for side effects — NOT ref.watch
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<AuthState>>(authProvider, (prev, next) {
      next.whenOrNull(
        data: (state) {
          if (state is Authenticated) {
            context.go('/home');
          }
        },
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        },
      );
    });

    return const LoginForm();
  }
}
```

---

## ♻️ Provider Lifecycle & Auto-Dispose

- **Always use `@riverpod`** (auto-dispose by default with code gen) — providers dispose when no widget is watching.
- **Use `keepAlive: true`** only for global persistent state like auth or user profile.
- **Never hold providers alive unnecessarily** — memory leaks are real.

```dart
// ✅ Keep auth alive across the whole app
@Riverpod(keepAlive: true)
class Auth extends _$Auth { ... }

// ✅ Auto-dispose for screen-specific data (default)
@riverpod
Future<List<RoadmapStep>> roadmapSteps(RoadmapStepsRef ref, String matchId) async {
  return ref.watch(roadmapRepositoryProvider).getSteps(matchId);
}
```

---

## 📋 LearnBack-Specific Providers Checklist

```
✅ authProvider               — login, logout, token state
✅ userProfileProvider        — current user data
✅ skillsProvider             — all available skills list
✅ userSkillsProvider         — user's owned skills
✅ userGoalsProvider          — user's learning goals
✅ matchesProvider            — user's matches list
✅ matchDetailProvider(id)    — single match details
✅ roadmapStepsProvider(id)   — steps for a match
✅ stepProgressProvider(id)   — progress for a match
✅ finalQuizProvider(id)      — quiz for a match
✅ coursesProvider            — all professional courses
✅ userCourseUnlocksProvider  — user's unlocked courses
```

---

## 🚫 Hard Rules — Never Do This

- ❌ Never call `ref.watch()` inside a non-build method (use `ref.read()` instead).
- ❌ Never use `StateProvider` for complex state — use `Notifier` instead.
- ❌ Never mutate state directly — always go through the notifier method.
- ❌ Never create a provider inside a widget's build method.
- ❌ Never use `context.read()` from Provider package — we're on Riverpod only.
- ❌ Never skip `AsyncValue.guard()` for async notifier mutations — always wrap.
- ❌ Never forget to handle the `error` case in `.when()` — silent failures are a bug.