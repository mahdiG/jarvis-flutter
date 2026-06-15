# Jarvis Flutter - AI Agent Guide

## Project Overview

A Flutter chat application called **Zen Assistant** - an AI-powered mindfulness and reflection companion with a calm, warm design aesthetic.

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app_theme.dart                     # Design system tokens (colors, typography, theme)
├── models/
│   ├── chat_message.dart              # Message model (content, isUser, timestamp, etc.)
│   └── chat_conversation.dart         # Conversation model (title, preview, metadata)
├── screens/
│   ├── chat_screen.dart               # Main chat interface
│   └── conversations_list_screen.dart # History/conversations list
└── widgets/
    ├── message_bubble.dart            # AI and user message bubbles
    ├── typing_indicator.dart          # Animated typing dots
    └── conversation_card.dart         # Conversation list item card
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

## Navigation

- `ChatScreen` → (history button) → `ConversationsListScreen`
- `ConversationsListScreen` pops back with selected conversation via `Navigator.pop(conversation)`

## Stitch MCP Integration

This project uses Google Stitch MCP for UI design. To fetch or update designs:

```mermaid
flowchart LR
    A[list_projects] --> B[find "jarvis_flutter" project]
    B --> C[list_screens]
    C --> D[get_screen]
    D --> E[extract tokens & layout]
    E --> F[implement in Flutter]
```

### Available MCP Tools

- `list_projects` - List all design projects
- `get_project(projectId)` - Get project details and screen list
- `list_screens(projectId)` - List all screens in a project
- `get_screen(screenId)` - Get full layout tree and styles
- `get_screen_html(screenId)` - Get HTML+CSS preview
- `get_screen_data(screenId)` - Get structured JSON data
- `list_design_systems(projectId)` - List design systems
- `get_design_system(designSystemId)` - Get full token set

### Workflow for Implementing Stitch Designs

1. Call `list_projects` → find the "jarvis_flutter" project
2. Call `get_project(projectId)` → get screens list
3. Call `list_screens(projectId)` → identify target screen
4. Call `get_screen(screenId)` → extract layout + styles + colors
5. Call `list_design_systems(projectId)` → check for existing design system
6. Implement Flutter code matching the extracted tokens and layout

## Building & Running

```bash
flutter pub get
flutter run
flutter build apk  # Android
flutter build ios   # iOS
```

## Last Updated

June 2026