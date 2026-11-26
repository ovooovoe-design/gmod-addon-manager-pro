# GMod Addon Manager Pro

A modern dark-themed, multi-level folder explorer & addon manager for **Garry's Mod** (`lua/menu/`), with real-time **Chinese / English (`简体中文` / `English`)** language switching, presets, custom notes, and menu-safe UI rendering.

> Built upon the original Simple Addon Manager concept by LibertyForce, redesigned into a folder-based explorer (`v3.1.0`).

---

## ✨ Features / 功能亮点

- **Folder Tree & Explorer View (`文件夹视图` / `纯列表`)**
  - Multi-level nested folders (`Parent/Subfolder`) with collapsible sidebar tree, color themes, breadcrumb navigation, and folder cards grid with progress bars.
  - One-click **Smart Auto-Sort (`智能归类未整理模组` / `Auto-Sort Uncategorized`)** by Workshop category (`Map`, `Weapon`, `Tool`, `Model`, `Effects`, etc.).
- **Live Bilingual UI (`简体中文` / `English`)**
  - Top-bar `语言: 中文` / `Lang: EN` instant toggle.
  - Auto-synced bilingual names for smart auto-sorted category folders (including subfolders and current scope), while preserving user-created custom folder names.
- **Presets (`预设方案`)**
  - Save, apply, overwrite, or delete mod loadouts (e.g., Sandbox, Realism, RP) in one click.
- **Notes (`备注`) & Batch Actions**
  - Add searchable personal notes per addon (highlighted amber badge), shift-click multi-select, batch enable/disable, move across folders, copy ID/URL, vote, or uninstall.
- **High-DPI Vector UI & Menu-Safe Input**
  - DPI-scaled `Microsoft YaHei UI` typography and crisp `surface.DrawPoly` vector toggle switches & folder icons (no `□□` broken emoji boxes).
  - Non-blocking main menu floating pill button (`模组管理器` / `Addon Manager`) + `lf_addon_manager` console command.
  - Menu-safe close & popup focus handling that won't lock GMod's main menu buttons or `~` developer console.

---

## 📦 Installation / 安装方法

### Option 1: One-Click Installer (Windows) / 一键安装（推荐）

1. Download and extract the release `.zip` package (or clone this repository).
2. Double-click **`install.bat`**.
3. The script automatically locates your Steam / Garry's Mod library (or lets you paste the `GarrysMod` folder path), backs up `menu.lua`, installs `lf_simple_addon_manager.lua`, and adds the `include` line.
4. Restart **Garry's Mod**.

To uninstall cleanly at any time, run **`uninstall.bat`**.

### Option 2: Manual Installation / 手动安装

1. Copy `garrysmod/lua/menu/lf_simple_addon_manager.lua` to:
   ```text
   <Your SteamLibrary>/steamapps/common/GarrysMod/garrysmod/lua/menu/lf_simple_addon_manager.lua
   ```
2. Open:
   ```text
   <Your SteamLibrary>/steamapps/common/GarrysMod/garrysmod/lua/menu/menu.lua
   ```
   and append this line at the bottom:
   ```lua
   include( "lf_simple_addon_manager.lua" )
   ```
3. Launch or restart **Garry's Mod**.

---

## 🚀 Usage / 使用说明

- On the GMod main menu, click the floating pill button at the bottom-right (**`模组管理器`** / **`Addon Manager`**), or open the developer console (`~`) and run:
  ```text
  lf_addon_manager
  ```
- **Folder shortcuts**:
  - Click a folder in the left tree or right-hand card grid to enter it.
  - Right-click any folder to enable/disable all addons inside, create a subfolder, rename, change folder color, or delete.
- **Multi-select addons**:
  - Click cards to select; hold **Left Shift** and click to range-select.
- **Switch language**:
  - Click **`语言: 中文`** / **`Lang: EN`** in the top-right header bar.

---

## 💾 Data Storage / 配置存储

Your folder layout, notes, presets, and language preference are stored automatically in GMod's menu storage (`cookie` SQLite in `mn.db` under key `lf_addon_manager_addons`, and `garrysmod/data/lf_addon_manager/addons.txt` when file write is available). Backward-compatible with legacy `v1/v2` saves.

---

## 📄 License

Released under the [MIT License](LICENSE).
