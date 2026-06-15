# Using Stitch MCP to Find & Implement Designs

## Overview

Stitch is a Google design tool that publishes UI designs via an MCP (Model Context Protocol) server. An AI coding agent can query Stitch to:

- List and inspect design projects
- View individual screens and their visual structure
- Extract design systems (colors, typography, spacing, components)
- Generate new screens or variants from text prompts
- Apply a design system directly into code

This doc describes the workflow an AI agent should follow when asked to implement a Flutter UI based on a Stitch design.

---

## 1. Connected MCP Server

The Stitch server is configured in `cline_mcp_settings.json` as a `streamableHttp` server at `https://stitch.googleapis.com/mcp` with an API key.

**Available tools** (as exposed by the MCP protocol):

### Project Tools

| Tool | Input | Output |
|------|-------|--------|
| `list_projects` | — | Array of `{id, title, updatedAt}` |
| `get_project` | `{projectId}` | Project with screens and design-system refs |
| `create_project` | `{title, description?}` | New project |

### Screen Tools

| Tool | Input | Output |
|------|-------|--------|
| `list_screens` | `{projectId}` | Array of `{id, name, thumbnailUrl?}` |
| `get_screen` | `{screenId}` | Screen with layout tree, styles, text, images |
| `get_screen_html` | `{screenId}` | HTML+CSS representation |
| `get_screen_data` | `{screenId}` | Structured data (JSON) |
| `generate_screen_from_text` | `{projectId, prompt}` | Generated screen |
| `edit_screens` | `{projectId, prompt}` | Bulk edit across screens |
| `generate_variants` | `{projectId, screenId, prompt?}` | Variants of a screen |

### Design System Tools

| Tool | Input | Output |
|------|-------|--------|
| `list_design_systems` | `{projectId?}` | Array of design systems |
| `get_design_system` | `{designSystemId}` | Full design system spec |
| `create_design_system` | `{projectId, name, ...}` | New design system |
| `create_design_system_from_design_md` | `{projectId, designMd}` | Design system from markdown |
| `update_design_system` | `{designSystemId, ...}` | Update existing |
| `apply_design_system` | `{projectId, designSystemId}` | Apply to project |
| `upload_design_md` | `{projectId, designMd}` | Upload raw design spec |

---

## 2. Recommended Workflow

When told "implement this design from Stitch", follow these steps in order.

### Step A: Discover the Project

```mermaid
flowchart LR
    A[list_projects] --> B[find matching project]
    B --> C[get_project]
```

1. Call `list_projects` to see all available projects.
2. Match the user's description against project titles.
3. Call `get_project(projectId)` to get the project's screen list and metadata.

### Step B: Inspect Screens

```
list_screens(projectId)          → all screens in project
get_screen(screenId)             → full layout with styling
get_screen_html(screenId)        → HTML+CSS preview (useful for visual context)
get_screen_data(screenId)        → structured JSON (useful for data extraction)
```

**Which one to call?**
- `get_screen` gives the richest output — layout tree, text styles, fill colors, spacing.
- `get_screen_html` is useful when you need a visual anchor to understand layout structure.
- `get_screen_data` returns clean structured data suitable for programmatic extraction.

Call at least `get_screen` on the primary screen(s) you need to implement.

### Step C: Extract the Design System

```
list_design_systems(projectId)   → see if a design system exists
get_design_system(systemId)      → get full token set
```

If a design system exists for the project, use it directly. It will contain:

- **Colors** – fill, text, surface, border tokens with hex values
- **Typography** – font family, size, weight, line height per text style
- **Spacing** – padding, gap, margin tokens
- **Corner radius / elevation** – shape tokens
- **Component definitions** – reusable patterns

If no design system exists, you can create one from a screen:

```
create_design_system_from_design_md(projectId, designMd)
```

or manually after analyzing screens:

```
create_design_system(projectId, name, colors?, typography?, spacing?, ...)
```

### Step D: Generate Code

Translate the design tokens and screen layout into Flutter code.

**Typical mapping:**

| Stitch Token | Flutter |
|---|---|
| colors → fills, text | `app_theme.dart` – `Color` constants |
| typography | `GoogleFonts.xyz()` or `TextStyle` |
| spacing / padding | `EdgeInsets`, `SizedBox`, `gap` |
| corner radius | `BorderRadius.circular()` |
| elevation | `BoxShadow` |
| layout tree | `Row`, `Column`, `Stack`, `ListView` |

---

## 3. Example: Extracting a "Zen Assistant" Chat Screen

Below is a real-world example showing how Stitch → Flutter translation works.

### 3.1 Discover

```
list_projects → find "jarvis_flutter" or "Zen Assistant" project
get_project("project_xyz")
```

Result: project contains a single screen "Chat Screen".

### 3.2 Inspect Screen

```
get_screen("screen_abc")
```

From the output, extract:

```
colors:
  #F8F6F0   → paperBg (background)
  #FFFFFF   → paperSheet (cards, input)
  #2D2A24   → ink (text, icons)
  #E8E4DA   → surfaceVariant (borders)
  #EAE6DD   → surfaceContainer (input bg)
  #D4CFC4   → outline (date marker, hints)
  #A8A294   → onSurfaceVariant (secondary text)
  #E6DFCC   → secondaryContainer (chip bg)
  #3E3A33   → onSecondaryContainer (chip text)
  #C4BBA8   → surfaceContainerHighest (border)

typography:
  Headline "Zen Assistant":
    font: Source Serif 4, 24px, w600, -1% letter-spacing
  Body text:
    font: Inter, 14px, w400, 20px line height
  Small labels (date, chip, AI header):
    font: Inter, 11px, w500, 14px line height, 2% letter-spacing

spacing:
  horizontal padding: 24px
  message gap: 32px below date marker
  chip gap: 8px
  input vertical: 32px bottom safe area
  chip padding: 16px horizontal, 8px vertical
```

### 3.3 Create Design System (optional)

```
create_design_system(
  projectId: "project_xyz",
  name: "Zen Design System",
  colors: { paperBg: "#F8F6F0", ink: "#2D2A24", ... },
  typography: {
    headline: { font: "Source Serif 4", size: 24, weight: 600 },
    body: { font: "Inter", size: 14, weight: 400, lineHeight: 20 },
    label: { font: "Inter", size: 11, weight: 500, lineHeight: 14, letterSpacing: 0.02 }
  }
)
```

### 3.4 Implement in Flutter

Create files in this order:

1. **`lib/app_theme.dart`** – color constants, text style helpers
2. **`lib/models/chat_message.dart`** – data model
3. **`lib/widgets/message_bubble.dart`** – message bubble with text + timestamp
4. **`lib/widgets/typing_indicator.dart`** – animated dots
5. **`lib/screens/chat_screen.dart`** – full screen layout
6. **`lib/main.dart`** – entry point

**Layout structure (from Stitch screen):**

```
Scaffold
 ├─ AppBar (toolbarHeight: 64)
 │    ├─ menu button (left, 40×40)
 │    ├─ "Zen Assistant" title (center)
 │    └─ history button (right, 40×40)
 ├─ Center (maxWidth: 720)
 │    └─ Column
 │         ├─ Expanded ListView
 │         │    ├─ DateMarker "TODAY"
 │         │    ├─ MessageBubble (AI greeting)
 │         │    ├─ MessageBubble (user messages)
 │         │    └─ TypingIndicator (when AI is replying)
 │         └─ Bottom Input
 │              ├─ QuickChips row (horizontal scroll)
 │              └─ Input container (24px rounded)
 │                   ├─ Add (+) button
 │                   ├─ TextField (multi-line)
 │                   └─ Send (↑) button
```

---

## 4. Common Pitfalls & Tips

### 4.1 Don't guess colors
Always extract exact hex values from `get_screen` or `get_design_system`. Stitch uses a specific palette — eyeballing leads to drift.

### 4.2 Typography matters
Stitch specifies line-height (`height` in Flutter is `lineHeight / fontSize`). Pass the ratio, not a pixel value. Example: lineHeight 20 ÷ fontSize 14 = `height: 1.428`.

### 4.3 Use Google Fonts
If the Stitch design uses Source Serif 4 or Inter (common), add `google_fonts` to `pubspec.yaml` and use `GoogleFonts.sourceSerif4()` / `GoogleFonts.inter()`.

### 4.4 Layout boundaries
If a screen has `max-width` or centering constraints, capture them. Stitch often designs at a fixed width (e.g. 390px mobile). The Flutter implementation should center the content with `ConstrainedBox(maxWidth: 720)` on larger screens.

### 4.5 Quick chip colors
Secondary container and on-secondary-container colors are frequently used for pill/chip components. Extract the exact token.

### 4.6 Shadows & borders
Stitch often uses subtle borders (`0.5px`, `1px`) and very light box shadows (`0, 2px, 4px, 2% opacity`). Match these precisely for a polished look.

### 4.7 Safe areas
Always wrap the bottom input area in `SafeArea` to handle device notches and home indicators.

---

## 5. Quick Reference Card

```
1. list_projects                          → find project
2. get_project(projectId)                 → get screen list
3. list_screens(projectId)                → find target screen
4. get_screen(screenId)                   → extract layout + styles
5. list_design_systems(projectId)         → find existing design system
   (optional) get_design_system(sysId)    → get full token set
6. Implement Flutter code in order:
   a. app_theme.dart (colors + typography)
   b. models (data classes)
   c. widgets (reusable components)
   d. screens (page layout)
   e. main.dart (entry point)
```

---

*Last updated: June 2026 – Stitch MCP v1 (Google Stitch)*