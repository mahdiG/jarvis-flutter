# Jarvis Flutter - AI Agent Guide

## Project Overview

A Flutter application called **Zen Assistant** — an AI-powered mindfulness and reflection companion with a calm, warm design aesthetic. The app also doubles as an **Android launcher** (Zen Launcher) that can replace the default home screen.

## Project Structure

```
lib/
├── main.dart                          # App entry point (routes to launcher or chat)
├── app_theme.dart                     # Design system tokens (colors, typography, theme)
├── config.dart                        # Feature flags (launcher enabled, etc.)
├── models/
│   ├── chat_message.dart              # Message model (content, isUser, timestamp, etc.)
│   ├── chat_conversation.dart         # Conversation model (title, preview, metadata)
│   └── launcher_app.dart              # App entry model (name, packageName, isFavorite)
├── screens/
│   ├── chat_screen.dart               # Main chat interface
│   ├── conversations_list_screen.dart # History/conversations list
│   ├── zen_launcher_screen.dart       # Zen Launcher home (greeting + favorites + bottom nav)
│   └── all_apps_screen.dart           # Full app list with search & favorite toggle
├── services/
│   └── app_list_service.dart          # Platform channel to query/launch Android apps
└── widgets/
    ├── message_bubble.dart            # AI and user message bubbles
    ├── typing_indicator.dart          # Animated typing dots
    ├── conversation_card.dart         # Conversation list item card
    └── launcher_bottom_nav.dart       # Bottom dock (Tasks, Journal, Timeline, Chat)

android/
└── app/src/main/
    ├── AndroidManifest.xml            # HOME + LAUNCHER intent filters, QUERY_ALL_PACKAGES
    └── kotlin/.../MainActivity.kt     # MethodChannel for getInstalledApps / launchApp
```

## Design System

### Colors (`ZenColors` class in `app_theme.dart`)

| Token | Hex | Usage |
|---|---|---|
| `background` / `paperBg` | `#FAF9F6` / `#FCFBF8` | Screen backgrounds |
| `ink` | `#1B1C1A` | Primary text, icons |
| `paperSheet` | `#FFFFFF` | Cards, input fields |
| `surfaceContainer` | `#EFEEEB` | Input background |
| `surfaceContainerHighest` | `#E3E2E0` | Subtle borders |
| `onSurfaceVariant` | `#454743` | Secondary text |
| `outline` | `#767872` | Date markers, hints |
| `secondaryContainer` | `#DEE5CE` | Chip backgrounds |
| `onSecondaryContainer` | `#606755` | Chip text |

### Typography

| Style | Font | Size | Weight | Line Height |
|---|---|---|---|---|
| Headline Large | Source Serif 4 | 30 | w600 | 1.267 |
| Headline Medium | Source Serif 4 | 24 | w600 | 1.333 |
| Headline Small | Source Serif 4 | 20 | w500 | 1.4 |
| Body Large | Inter | 16 | w400 | 1.5 |
| Body Medium | Inter | 14 | w400 | 1.429 |
| Label Large | Inter | 13 | w600 | 1.231 |
| Label Medium | Inter | 11 | w500 | 1.273 |

### Spacing

- Horizontal padding: 24px
- Message gap: 32px below date marker
- Chip gap: 8px
- Bottom safe area: 32px

## Key Architecture Decisions

- **Material 3** enabled with `useMaterial3: true`
- **Google Fonts** for Source Serif 4 and Inter
- **StatefulWidgets** with local state (no state management yet)
- **ConstrainedBox(maxWidth: 720)** for responsive centering
- **SafeArea** for bottom input to handle device notches
- **Feature flags** via `lib/config.dart` (e.g. `Config.launcherEnabled` toggles launcher vs chat as home)
- **Platform channels** — `MethodChannel('com.example.jarvis_flutter/launcher')` for querying/launching Android apps
- **Dual intent filters** — `HOME` (replace default launcher) + `LAUNCHER` (app drawer icon)

## Navigation

| Source | Action | Destination |
|---|---|---|
| (app start) | `Config.launcherEnabled` | `ZenLauncherScreen` or `ChatScreen` |
| `ZenLauncherScreen` | tap app name | launch via `AppListService.launchApp(packageName)` |
| `ZenLauncherScreen` | tap "More" | `AllAppsScreen` (push) |
| `ZenLauncherScreen` | tap Chat tab (bottom nav) | `ChatScreen` (push) |
| `ZenLauncherScreen` | Tasks/Journal/Timeline tabs | placeholder bottom sheet |
| `AllAppsScreen` | tap star icon | toggle favorite (populates launcher's favorites list) |
| `ChatScreen` → (history button) | → | `ConversationsListScreen` |
| `ConversationsListScreen` | pop with conversation | `ChatScreen` receives selection |

## Android Launcher Details

### How it Works

1. **`zen_launcher_screen.dart`** shows a greeting ("Good morning/afternoon/evening") + a text-only list of favorite apps + a "More" link + bottom navigation dock.
2. **`all_apps_screen.dart`** shows all installed apps with search, star-toggle for favorites.
3. **`app_list_service.dart`** uses `MethodChannel` to communicate with Kotlin `MainActivity`.
4. **`MainActivity.kt`** queries `PackageManager` for launcher-intent activities and launches via `getLaunchIntentForPackage`.
5. **`AndroidManifest.xml`** declares both `HOME` (replace launcher) and `LAUNCHER` (app drawer) intent filters.

### Platform Channel API

| Method | Input | Output | Description |
|---|---|---|---|
| `getInstalledApps` | — | `List<{name, packageName}>` | All apps with launcher intent |
| `launchApp` | `{packageName}` | `bool` | Launch or open settings fallback |

### Mock Mode (non-Android)

When running on web, Linux, or desktop, `AppListService` returns a curated list of mock apps so the UI remains viewable during development.

### Feature Flag

```dart
// lib/config.dart
Config.launcherEnabled  // defaults to true
// Override at build time:
//   flutter run --dart-define=LAUNCHER_ENABLED=false
```

## Stitch MCP Integration

This project uses Google Stitch MCP for UI design. The MCP server is named `stitch` and is configured in `cline_mcp_settings.json`.

> ⚠️ **AI agents**: Always use server name `stitch`, NOT `github.com/stitch-tools/stitch-mcp`.

To fetch or update designs:

```mermaid
flowchart LR
    A[list_projects] --> B[find "jarvis_flutter" project]
    B --> C[get_project]
    C --> D[list_screens]
    D --> E[get_screen]
    E --> F[extract tokens & layout]
    F --> G[implement in Flutter]
```

### 🌟 CRITICAL: Correct Parameter Formats

Google Stitch uses **resource name-based addressing**. This is the #1 AI agent mistake.

| Tool | ❌ Wrong | ✅ Correct |
|------|----------|------------|
| `get_project` | `{projectId: "abc123"}` | `{name: "projects/abc123"}` |
| `list_screens` | `{projectId: "abc123"}` | `{parent: "projects/abc123"}` |
| `get_screen` | `{screenId: "xyz789"}` | `{name: "projects/abc123/screens/xyz789"}` |
| `create_design_system` | `{projectId, name: "DS"}` | `{projectId, designSystem: {displayName, theme}}` |

### Available MCP Tools

**✅ These tools exist and work:**

- `list_projects` — List all design projects (no params needed)
- `get_project({name: "projects/{project}"})` — Get project details and screen list
- `list_screens({parent: "projects/{project}"})` — List all screens in a project
- `get_screen({name: "projects/{project}/screens/{screen}"})` — Get full layout tree and styles
- `list_design_systems({projectId})` — List design systems (includes theme data)
- `create_design_system({projectId, designSystem: {displayName, theme}})` — Create new design system
- `create_design_system_from_design_md({projectId, selectedScreenInstance})` — Create DS from screen data
- `update_design_system({name, projectId, designSystem})` — Update existing design system
- `apply_design_system({projectId, selectedScreenInstances})` — Apply design system to screens
- `upload_design_md({projectId, designMdBase64})` — Upload base64-encoded design spec
- `generate_screen_from_text({projectId, prompt})` — AI-generate a screen (takes 30–60s)
- `edit_screens({projectId, selectedScreenIds, prompt})` — Bulk edit screens
- `generate_variants({projectId, selectedScreenIds, variantOptions})` — Generate screen variants

**❌ These tools do NOT exist (do NOT call):**

- `get_screen_html` — **does not exist**
- `get_screen_data` — **does not exist**
- `get_design_system` — **does not exist**

### Workflow for Implementing Stitch Designs

1. Call `list_projects` → find the "jarvis_flutter" project by `displayName`
2. Call `get_project({name: "projects/{project}"})` → get screen list
3. Call `list_screens({parent: "projects/{project}"})` → identify target screen
4. Call `get_screen({name: "projects/{project}/screens/{screen}"})` → extract layout + styles + colors
5. Call `list_design_systems({projectId})` → check for existing design system (theme data is in response)
6. Implement Flutter code matching the extracted tokens and layout

### Auto-Approval

Only `list_projects` is auto-approved. All other tools (including `get_screen`, `list_screens`, `create_design_system`) require **explicit user approval**. Wait for approval — do not try alternative approaches.

For the full reference, see `docs/stitch-mcp-reference.md`.

## Building & Running

```bash
flutter pub get
flutter run                                  # runs on connected device/emulator
flutter run --dart-define=LAUNCHER_ENABLED=false  # run without launcher (chat home)
flutter build apk  # Android
flutter build ios   # iOS
```

### Dev Notes

- **Google Fonts** requires internet on first run on Android/iOS. On web, fonts load from CDN.
- For the launcher to appear as a home screen option, the device must be running Android 5.0+ (API 21+). On first launch, the system prompt asks "Complete action using Zen Assistant / Always / Just once".
- To reset the default launcher on an emulator: Settings → Apps → Default apps → Home app.

## Last Updated

June 2026