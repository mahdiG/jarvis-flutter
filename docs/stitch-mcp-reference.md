# Stitch MCP Quick Reference

## Connected Server

- **MCP server name:** `stitch` (configured in `cline_mcp_settings.json`)
- **Server type:** `streamableHttp`
- **URL:** `https://stitch.googleapis.com/mcp`
- **Auth:** API key via `X-Goog-Api-Key` header
- **Config location:** `~/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json`

> ⚠️ **AI agents must use the server name `stitch`**, NOT `github.com/stitch-tools/stitch-mcp` or any other name.

## Available Tools

### Project Tools

| Tool | Required Parameters | Output |
|------|--------------------|--------|
| `list_projects` | `{}` (none) | Array of `{name, displayName, updatedAt}` — use `name` field for subsequent calls |
| `get_project` | `{name: "projects/{project}"}` | Project with screen list & design system references |
| `create_project` | `{title, description?}` | Newly created project |

**Common mistake:** `get_project` does NOT take `{projectId}` or `{id}`. It takes `{name: "projects/{project}"}` where `{project}` is the ID from the `name` field returned by `list_projects`.

### Screen Tools

| Tool | Required Parameters | Output |
|------|--------------------|--------|
| `list_screens` | `{parent: "projects/{project}"}` | Array of `{name, displayName, thumbnailUrl?}` — use `name` field for subsequent calls |
| `get_screen` | `{name: "projects/{project}/screens/{screen}"}` | Full screen layout tree, styles, text, images |
| `generate_screen_from_text` | `{projectId, prompt}` | AI-generated screen (can take 30+ seconds — do NOT retry) |
| `edit_screens` | `{projectId, selectedScreenIds: [...], prompt}` | Edit selected screens via AI |
| `generate_variants` | `{projectId, selectedScreenIds: [...], variantOptions: {variantCount, creativeRange, aspects}}` | Screen variants |

**Critical notes:**
- `get_screen` does NOT take `{screenId}` or `{id}`. It takes a **resource name** in form `"projects/{project}/screens/{screen}"`.
- `list_screens` does NOT take `{projectId}`. It takes `{parent: "projects/{project}"}`.
- `generate_screen_from_text` can take 30–60 seconds. If the tool call times out, **do NOT retry immediately** — wait for the result.
- The tools `get_screen_html` and `get_screen_data` do **NOT exist** on this MCP server. Do not attempt to call them.

### Design System Tools

| Tool | Required Parameters | Output |
|------|--------------------|--------|
| `list_design_systems` | `{projectId?}` | Array of design systems with `name`, `displayName`, `theme` |
| `create_design_system` | `{projectId, designSystem: {displayName, theme: {...}}}` | Newly created design system |
| `create_design_system_from_design_md` | `{projectId, selectedScreenInstance}` | Design system extracted from a screen |
| `update_design_system` | `{name: "projects/{project}/designSystems/{ds}", projectId, designSystem: {...}}` | Updated design system |
| `apply_design_system` | `{projectId, selectedScreenInstances: [...], assetId?}` | Apply a design system to selected screens |
| `upload_design_md` | `{projectId, designMdBase64: "<base64>"}` | Upload raw design markdown (must be base64-encoded) |

**Common mistakes:**
- `create_design_system` takes `{projectId, designSystem: {displayName, theme}}`, NOT `{projectId, name, ...}`.
- `create_design_system_from_design_md` takes `{projectId, selectedScreenInstance}`, NOT `{projectId, designMd}`.
- `update_design_system` takes a resource `name` (like `"projects/{project}/designSystems/{ds}"`), NOT `{designSystemId}`.
- `apply_design_system` works with `selectedScreenInstances` (array), NOT `{projectId, designSystemId}`.
- `upload_design_md` requires `designMdBase64` — the markdown must be base64-encoded first, NOT passed as raw text.
- The tool `get_design_system` does **NOT exist**. If you need design system details, check the response from `list_design_systems` or `create_design_system`.

## Typical Workflow

1. **Discover project** → `list_projects` → match by `displayName`
2. **Get project details** → `get_project({name: "projects/{project}"})` → screens list
3. **List screens** → `list_screens({parent: "projects/{project}"})` → target screen
4. **Inspect target screen** → `get_screen({name: "projects/{project}/screens/{screen}"})` → layout, colors, typography
5. **Check design system** → `list_design_systems({projectId})` → see if one exists
6. **Implement Flutter** → translate tokens into `app_theme.dart`, widgets, screens

## Resource Name Format

Google Stitch APIs use resource name-based addressing (like most Google APIs). Always use the full resource name:

| Entity | Resource Name Format |
|--------|---------------------|
| Project | `projects/{project}` |
| Screen | `projects/{project}/screens/{screen}` |
| Design System | `projects/{project}/designSystems/{ds}` |

The `name` field returned by list operations contains this full resource name. Extract the ID portion if you need just the short identifier.

## Auto-Approval Caveat

The MCP client has `autoApprove` for certain tools. This means the agent can call them without user prompting. The auto-approved tools are:

- `stitch_listProjects` / `list_projects`
- `stitch_getProject`
- `listTools` / `list_tools` (MCP introspection)
- `get_screen_html` (⚠️ does not exist — listed but will error)
- `get_screen_data` (⚠️ does not exist — listed but will error)

All other tools require explicit user approval before execution. If a tool is not auto-approved, wait for the user to approve it rather than trying alternative approaches.

## Stitch → Flutter Token Mapping

| Stitch Token | Flutter Equivalent |
|---|---|
| Fill color (hex) | `Color(0xFF...)` in `app_theme.dart` |
| Text style (font, size, weight, lineHeight) | `GoogleFonts.fontName(fontSize:, fontWeight:, height:)` |
| Spacing / padding (px) | `EdgeInsets.all(…)`, `SizedBox(height:)`, `gap` property |
| Corner radius (px) | `BorderRadius.circular(…)` |
| Box shadow (offset, blur, color, opacity) | `BoxShadow` |
| Layout (row, column, stack) | `Row`, `Column`, `Stack` |

## Notes

- Line-height in Flutter is `lineHeightPx / fontSizePx` as a ratio.
- Google Fonts requires internet on first run for Android/iOS; loads from CDN on web.
- The Stitch MCP server is external (Google) — confirm network access.
- If a tool call times out (especially `generate_screen_from_text`), wait and check results — do not retry blindly.

*Last updated: June 2026*