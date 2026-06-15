# Stitch MCP Quick Reference

## Connected Server

The `github.com/stitch-tools/stitch-mcp` server is configured as a `streamableHttp` server at `https://stitch.googleapis.com/mcp` with an API key.

## Available Tools

### Project Tools
| Tool | Input | Output |
|------|-------|--------|
| `list_projects` | — | Array of `{id, title, updatedAt}` |
| `get_project` | `{projectId}` | Project w/ screen list & design system refs |
| `create_project` | `{title, description?}` | New project |

### Screen Tools
| Tool | Input | Output |
|------|-------|--------|
| `list_screens` | `{projectId}` | Array of `{id, name, thumbnailUrl?}` |
| `get_screen` | `{screenId}` | Full layout tree, styles, text, images |
| `get_screen_html` | `{screenId}` | HTML+CSS preview |
| `get_screen_data` | `{screenId}` | Structured JSON |
| `generate_screen_from_text` | `{projectId, prompt}` | AI-generated screen |
| `edit_screens` | `{projectId, prompt}` | Bulk edit across screens |
| `generate_variants` | `{projectId, screenId, prompt?}` | Screen variants |

### Design System Tools
| Tool | Input | Output |
|------|-------|--------|
| `list_design_systems` | `{projectId?}` | Array of design systems |
| `get_design_system` | `{designSystemId}` | Full token set (colors, typography, spacing) |
| `create_design_system` | `{projectId, name, ...}` | New design system |
| `create_design_system_from_design_md` | `{projectId, designMd}` | Design system from markdown |
| `update_design_system` | `{designSystemId, ...}` | Update existing |
| `apply_design_system` | `{projectId, designSystemId}` | Apply to project |
| `upload_design_md` | `{projectId, designMd}` | Upload raw design spec |

## Typical Workflow

1. **Discover project** → `list_projects` → match by title
2. **Get project details** → `get_project(projectId)` → screens list
3. **Inspect target screen** → `get_screen(screenId)` → layout, colors, typography
4. **Check design system** → `list_design_systems(projectId)` + `get_design_system(sysId)`
5. **Implement Flutter** → translate tokens into `app_theme.dart`, widgets, screens

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

*Last updated: June 2026*