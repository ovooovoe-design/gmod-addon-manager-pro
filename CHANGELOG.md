# Changelog

## v3.1.0
- Added real-time **Chinese / English (`简体中文` / `English`)** switcher in the top header bar (`Lang` saved persistently, auto-detects `gmod_language` on fresh install).
- Synchronized smart auto-sorted category folder names (`TranslateAutoCatPath` / `SyncAutoCatFoldersToLang`) when switching languages, including child paths and active view scope.
- Replaced all 4-byte surrogate-pair emojis with vector geometry icons and BMP symbols to prevent `□□` box rendering on Source Engine GDI fonts.
- Replaced custom alias with **Notes (`备注` / `Note`)** feature, card action button, amber note badge, and search filtering.

## v3.0.0
- Redesigned UI into a modern dark-themed **Pro Folder Explorer** with collapsible left folder tree, folder cards grid view, list view toggle, color palettes, breadcrumb bar, and presets manager.
- Added high-DPI font scaling (`Microsoft YaHei UI` + `UIScale`) and anti-aliased `surface.DrawPoly` vector toggle switches & folder icons.
- Added menu-safe save fallback (`cookie.Set` / `mn.db`) for GMod menu state where `File:Write()` is unavailable.
- Fixed main menu & console (`~`) focus lock on frame close, and added a floating main menu shortcut pill.
