--[[

SIMPLE ADDON MANAGER (Pro Folder Explorer & Modern Dark UI Edition)
Original concept by LibertyForce
Upgraded: Folder Tree, Notes, Presets, Bilingual (ZH/EN), Vector Icons & Menu-Safe Input

--]]

local Version = "3.1.0"

local WorkshopReady = false
local Addons = nil
local Folders = { } -- [folderPath] = { color = idx, expanded = bool }
local Presets = { } -- [presetName] = { enabled = { idStr, ... } }
local TagList = { }
local Menu = { }
local Lang = "zh" -- "zh" or "en"

local dir = "lf_addon_manager"
local savefile = dir .. "/addons.txt"
local cookie_key = "lf_addon_manager_addons"

local ValidTypes = { "Gamemode", "Map", "Weapon", "Vehicle", "NPC", "Tool", "Effects", "Model", "Entity", "ServerContent" }

local CatLabels = {
	zh = {
		Gamemode = "游戏模式",
		Map = "地图",
		Weapon = "武器",
		Vehicle = "载具",
		NPC = "NPC",
		Tool = "工具",
		Effects = "特效",
		Model = "模型",
		Entity = "实体",
		ServerContent = "服务器资源",
		INVALID = "未分类",
	},
	en = {
		Gamemode = "Gamemode",
		Map = "Map",
		Weapon = "Weapon",
		Vehicle = "Vehicle",
		NPC = "NPC",
		Tool = "Tool",
		Effects = "Effects",
		Model = "Model",
		Entity = "Entity",
		ServerContent = "Server Content",
		INVALID = "Uncategorized",
	},
}

local I18N = {
	zh = {
		app_title = "模组文件夹管理器",
		shortcut = "模组管理器",
		loading = "正在加载...",
		stats_fmt = "已启用 %d / %d  ·  加载 %s / %s  ·  %d 个文件夹",
		err_not_ready = "错误：模组列表尚未初始化，请等待所有工坊下载完成。\n",
		local_gma = "*** 手动安装的本地 GMA 文件 ***",
		local_id = "本地",
		ok = "确定",
		cancel = "取消",
		refresh = "刷新列表",
		presets_btn = "☰ 预设方案 ▾",
		lang_btn = "语言: 中文",
		search_ph = "全局搜索：名称、备注、文件夹或 ID...",
		view_folder = "文件夹视图",
		view_list = "☰ 纯列表",
		state_all = "全部状态",
		state_on = "仅看已启用",
		state_off = "仅看未启用",
		type_all = "全部类型",
		type_uncat = "未分类",
		sort_name = "按名称排序",
		sort_active = "按启用状态排序",
		sort_size = "按体积从大到小",
		sort_folder = "按文件夹排序",
		sort_id = "按 ID 排序",
		sel_all = "全选",
		sel_clear = "取消选择",
		sel_count = "已选 %s 项",
		en_sel = "启用选中项",
		dis_sel = "禁用选中项",
		move_sel = "移至文件夹 ▾",
		more_btn = "更多操作 ▾",
		auto_cat_menu = "✨ 智能按类型归类未整理模组",
		en_all = "全部启用",
		dis_all = "全部禁用",
		vote_sel = "为选中项点赞",
		uninst_sel = "卸载选中模组",
		clear_notes_menu = "清除全部备注",
		side_title = "文件夹分类",
		new_btn = "+ 新建",
		auto_cat_btn = "✨ 智能归类未整理模组",
		tree_all = "全部模组",
		tree_enabled = "已启用模组",
		tree_uncat = "未归类模组",
		tree_hint_hdr = "自定义文件夹 (右键管理)",
		tree_empty_hint = "暂无自定义文件夹。\n点右上角【+ 新建】或下方【✨ 智能归类】立刻生成！",
		back_up = "← 上一级",
		crumb_search = "✦ 全局搜索结果",
		crumb_all = "◈ 全部模组",
		crumb_enabled = "⚡ 已启用模组",
		crumb_uncat = "▫ 未归类模组",
		crumb_root = "全部模组",
		sub_btn = "+ 新建子文件夹",
		folder_on = "整夹启用",
		folder_off = "整夹禁用",
		subfolders_hdr = "子文件夹 (%d)",
		folder_stats = "%d / %d 已启用  ·  %s",
		addons_hdr = "模组列表 (%d)",
		root_addons_hdr = "根目录 / 未归类模组 (%d)",
		empty_all = "当前所有模组均已整理进上方文件夹！",
		empty_folder = "此文件夹下暂无符合条件的模组",
		btn_archive = "归档",
		btn_note = "备注",
		status_on = "已启用",
		status_off = "未启用",
		note_prefix = "备注: ",
		ctx_disable = "禁用此模组",
		ctx_enable = "启用此模组",
		ctx_move = "移动到文件夹",
		ctx_uncat = "▫ 移出文件夹 (设为未归类)",
		ctx_new_move = "+ 新建文件夹并移入...",
		ctx_ws = "在创意工坊中打开",
		ctx_url = "复制工坊链接",
		ctx_id = "复制工坊 ID",
		ctx_note_add = "添加备注",
		ctx_note_edit = "编辑备注",
		ctx_note_clear = "清除备注",
		fctx_on = "✓ 启用整个文件夹",
		fctx_off = "✕ 禁用整个文件夹",
		fctx_sub = "+ 新建子文件夹",
		fctx_rename = "重命名文件夹",
		fctx_color = "设置文件夹颜色",
		fctx_del = "删除文件夹 (模组移回上级/未归类)",
		dlg_new_folder = "新建文件夹",
		dlg_new_folder_ph = "输入名称或路径，如：三角洲/武器",
		dlg_new_move_t = "新建文件夹并移入选中模组",
		dlg_new_move_ph = "输入文件夹名称，如：三角洲/地图",
		dlg_rename_t = "重命名文件夹",
		dlg_rename_ph = "输入新的文件夹名称...",
		dlg_note_t = "设置模组备注",
		dlg_note_ph = "输入备注说明，留空则清除...",
		dlg_preset_t = "保存模组方案",
		dlg_preset_ph = "输入方案名称，如：航天基地跑图",
		preset_save = "+ 将当前已启用模组保存为方案...",
		preset_item = "☰ %s (%d 个)",
		preset_apply = "▸ 立即应用此方案",
		preset_overwrite = "覆盖更新为当前状态",
		preset_delete = "删除方案",
		vote_title = "工坊点赞",
		vote_t1 = "确定要为选中的 %d 个模组点赞吗？",
		vote_t2 = "此操作不可撤销，感谢支持模组作者。",
		vote_ok = "确认点赞",
		uninst_title = "警告：即将卸载 %d 个模组",
		uninst_t1 = "确定取消订阅并卸载选中的 %d 个模组吗？",
		uninst_t2 = "此操作会取消创意工坊订阅且不可撤销。\n卸载完成后建议重启 Garry's Mod。",
		uninst_ok = "确认卸载",
		uninst_ing = "正在卸载...",
		uninst_wait = "请稍候，正在取消工坊订阅。",
		clr_note_title = "清除备注",
		clr_note_t1 = "确定清除所有模组的备注吗？",
		clr_note_t2 = "所有模组备注将被清空，此操作不可撤销。",
		clr_note_ok = "全部清除",
	},
	en = {
		app_title = "Addon Folder Manager",
		shortcut = "Addon Manager",
		loading = "Loading...",
		stats_fmt = "Enabled %d / %d  ·  %s / %s  ·  %d Folders",
		err_not_ready = "Error: Addons not initialized yet. Please wait for workshop downloads.\n",
		local_gma = "*** Local GMA Addons ***",
		local_id = "Local",
		ok = "OK",
		cancel = "Cancel",
		refresh = "Refresh",
		presets_btn = "☰ Presets ▾",
		lang_btn = "Lang: EN",
		search_ph = "Global search: title, note, folder or ID...",
		view_folder = "Folder View",
		view_list = "☰ List",
		state_all = "All Status",
		state_on = "Enabled Only",
		state_off = "Disabled Only",
		type_all = "All Types",
		type_uncat = "Uncategorized",
		sort_name = "Sort: Name",
		sort_active = "Sort: Enabled",
		sort_size = "Sort: Size",
		sort_folder = "Sort: Folder",
		sort_id = "Sort: ID",
		sel_all = "Select All",
		sel_clear = "Clear",
		sel_count = "%s selected",
		en_sel = "Enable Sel",
		dis_sel = "Disable Sel",
		move_sel = "Move to Folder ▾",
		more_btn = "More ▾",
		auto_cat_menu = "✨ Auto-Sort Uncategorized by Type",
		en_all = "Enable All",
		dis_all = "Disable All",
		vote_sel = "Like Selected",
		uninst_sel = "Uninstall Selected",
		clear_notes_menu = "Clear All Notes",
		side_title = "Folders",
		new_btn = "+ New",
		auto_cat_btn = "✨ Auto-Sort Uncategorized",
		tree_all = "All Addons",
		tree_enabled = "Enabled Addons",
		tree_uncat = "Uncategorized",
		tree_hint_hdr = "Custom Folders (Right-click)",
		tree_empty_hint = "No custom folders yet.\nClick [+ New] above or [✨ Auto-Sort] below!",
		back_up = "← Up",
		crumb_search = "✦ Global Search Results",
		crumb_all = "◈ All Addons",
		crumb_enabled = "⚡ Enabled Addons",
		crumb_uncat = "▫ Uncategorized",
		crumb_root = "All Addons",
		sub_btn = "+ Subfolder",
		folder_on = "Enable All",
		folder_off = "Disable All",
		subfolders_hdr = "Subfolders (%d)",
		folder_stats = "%d / %d Enabled  ·  %s",
		addons_hdr = "Addons (%d)",
		root_addons_hdr = "Root / Uncategorized (%d)",
		empty_all = "All addons are organized into folders above!",
		empty_folder = "No matching addons in this folder",
		btn_archive = "Move",
		btn_note = "Note",
		status_on = "Enabled",
		status_off = "Disabled",
		note_prefix = "Note: ",
		ctx_disable = "Disable Addon",
		ctx_enable = "Enable Addon",
		ctx_move = "Move to Folder",
		ctx_uncat = "▫ Remove from Folder (Uncategorized)",
		ctx_new_move = "+ New Folder & Move...",
		ctx_ws = "Open in Workshop",
		ctx_url = "Copy Workshop URL",
		ctx_id = "Copy Workshop ID",
		ctx_note_add = "Add Note",
		ctx_note_edit = "Edit Note",
		ctx_note_clear = "Clear Note",
		fctx_on = "✓ Enable Whole Folder",
		fctx_off = "✕ Disable Whole Folder",
		fctx_sub = "+ New Subfolder",
		fctx_rename = "Rename Folder",
		fctx_color = "Folder Color",
		fctx_del = "Delete Folder (Keep Addons)",
		dlg_new_folder = "New Folder",
		dlg_new_folder_ph = "Name or path, e.g. DeltaForce/Weapons",
		dlg_new_move_t = "New Folder & Move Selected",
		dlg_new_move_ph = "Folder path, e.g. DeltaForce/Maps",
		dlg_rename_t = "Rename Folder",
		dlg_rename_ph = "Enter new folder name...",
		dlg_note_t = "Addon Note",
		dlg_note_ph = "Enter note (leave empty to clear)...",
		dlg_preset_t = "Save Preset",
		dlg_preset_ph = "Preset name, e.g. Spacecenter",
		preset_save = "+ Save Enabled Addons as Preset...",
		preset_item = "☰ %s (%d)",
		preset_apply = "▸ Apply Preset",
		preset_overwrite = "Overwrite with Current",
		preset_delete = "Delete Preset",
		vote_title = "Workshop Vote",
		vote_t1 = "Give a LIKE to %d selected addons?",
		vote_t2 = "This action cannot be undone.",
		vote_ok = "Give LIKE",
		uninst_title = "Warning: Uninstalling %d addons",
		uninst_t1 = "Unsubscribe and uninstall %d selected addons?",
		uninst_t2 = "This will unsubscribe on Workshop and cannot be undone.\nRestart Garry's Mod afterwards.",
		uninst_ok = "Confirm Uninstall",
		uninst_ing = "Uninstalling...",
		uninst_wait = "Please wait while unsubscribing.",
		clr_note_title = "Clear All Notes",
		clr_note_t1 = "Clear notes for ALL addons?",
		clr_note_t2 = "All saved notes will be removed and cannot be undone.",
		clr_note_ok = "Clear All",
	},
}

local function L( key, ... )
	local tbl = I18N[Lang] or I18N.zh
	local str = tbl[key] or I18N.zh[key] or key
	if select( "#", ... ) > 0 then
		return string.format( str, ... )
	end
	return str
end

local function GetCatLabel( cat )
	local tbl = CatLabels[Lang] or CatLabels.zh
	return tbl[cat] or tbl.INVALID or cat
end

local FOLDER_COLORS = {
	{ zh = "经典蓝", en = "Blue",    col = Color( 59, 130, 246, 255 ), dark = Color( 37, 99, 235, 255 ), bg = Color( 59, 130, 246, 28 ) },
	{ zh = "翡翠绿", en = "Emerald", col = Color( 16, 185, 129, 255 ), dark = Color( 5, 150, 105, 255 ), bg = Color( 16, 185, 129, 28 ) },
	{ zh = "琥珀橙", en = "Amber",   col = Color( 245, 158, 11, 255 ), dark = Color( 217, 119, 6, 255 ), bg = Color( 245, 158, 11, 28 ) },
	{ zh = "紫罗兰", en = "Violet",  col = Color( 139, 92, 246, 255 ), dark = Color( 109, 40, 217, 255 ), bg = Color( 139, 92, 246, 28 ) },
	{ zh = "青碧色", en = "Cyan",    col = Color( 6, 182, 212, 255 ),  dark = Color( 8, 145, 178, 255 ), bg = Color( 6, 182, 212, 28 ) },
	{ zh = "玫瑰红", en = "Rose",    col = Color( 244, 63, 94, 255 ),  dark = Color( 225, 29, 72, 255 ), bg = Color( 244, 63, 94, 28 ) },
}

local COL = {
	bg          = Color( 14, 18, 25, 253 ),
	header      = Color( 20, 26, 36, 255 ),
	panel       = Color( 19, 24, 33, 255 ),
	sidebar     = Color( 16, 21, 29, 255 ),
	listBg      = Color( 12, 16, 22, 255 ),
	card        = Color( 24, 31, 43, 255 ),
	cardHover   = Color( 32, 41, 57, 255 ),
	cardSel     = Color( 26, 49, 82, 255 ),
	border      = Color( 42, 53, 72, 255 ),
	borderLight = Color( 64, 80, 108, 255 ),
	accent      = Color( 59, 130, 246, 255 ),
	accentHover = Color( 96, 165, 250, 255 ),
	green       = Color( 16, 185, 129, 255 ),
	greenHover  = Color( 52, 211, 153, 255 ),
	greenBg     = Color( 16, 185, 129, 32 ),
	red         = Color( 239, 68, 68, 255 ),
	redBg       = Color( 185, 28, 28, 45 ),
	btn         = Color( 33, 42, 57, 255 ),
	btnHover    = Color( 46, 59, 80, 255 ),
	input       = Color( 11, 15, 21, 255 ),
	pill        = Color( 36, 46, 64, 255 ),
	tagPill     = Color( 30, 58, 95, 255 ),
	text        = Color( 241, 245, 249, 255 ),
	textSub     = Color( 148, 163, 184, 255 ),
	textMuted   = Color( 100, 116, 139, 255 ),
	scrollTrack = Color( 16, 21, 29, 255 ),
	scrollGrip  = Color( 56, 70, 94, 255 ),
	scrollGripH = Color( 84, 105, 140, 255 ),
}

local function UIScale()
	return math.Clamp( ScrH() / 1080, 1.0, 1.85 )
end

local function S( px )
	return math.Round( px * UIScale() )
end

local _lastFontScale = nil
local function EnsureFonts()
	local sc = UIScale()
	if _lastFontScale and math.abs( _lastFontScale - sc ) < 0.01 then return end
	_lastFontScale = sc

	surface.CreateFont( "SAM_Header", {
		font = "Microsoft YaHei UI",
		extended = true,
		size = S( 24 ),
		weight = 700,
		antialias = true,
	} )

	surface.CreateFont( "SAM_ItemTitle", {
		font = "Microsoft YaHei UI",
		extended = true,
		size = S( 20 ),
		weight = 700,
		antialias = true,
	} )

	surface.CreateFont( "SAM_Body", {
		font = "Microsoft YaHei UI",
		extended = true,
		size = S( 18 ),
		weight = 500,
		antialias = true,
	} )

	surface.CreateFont( "SAM_Small", {
		font = "Microsoft YaHei UI",
		extended = true,
		size = S( 16 ),
		weight = 500,
		antialias = true,
	} )

	surface.CreateFont( "Font_AddonTitle", {
		font = "Microsoft YaHei UI",
		extended = true,
		size = S( 20 ),
		weight = 700,
		antialias = true,
	} )
end

EnsureFonts()

-- -------------------- Vector Graphics Helpers --------------------
local function DrawCirclePoly( cx, cy, r, segs, col )
	local pts = { }
	for i = 0, segs - 1 do
		local a = ( i / segs ) * math.pi * 2
		pts[i + 1] = { x = cx + math.cos( a ) * r, y = cy + math.sin( a ) * r }
	end
	draw.NoTexture()
	surface.SetDrawColor( col )
	surface.DrawPoly( pts )
end

local function DrawPillPoly( x, y, w, h, col )
	local r = h * 0.5
	if w <= h then
		DrawCirclePoly( x + w * 0.5, y + r, r, 24, col )
		return
	end
	local pts = { }
	local segs = 16
	local cxL, cyM = x + r, y + r
	local cxR = x + w - r
	for i = 0, segs do
		local a = math.pi * 0.5 + ( i / segs ) * math.pi
		pts[#pts + 1] = { x = cxL + math.cos( a ) * r, y = cyM + math.sin( a ) * r }
	end
	for i = 0, segs do
		local a = -math.pi * 0.5 + ( i / segs ) * math.pi
		pts[#pts + 1] = { x = cxR + math.cos( a ) * r, y = cyM + math.sin( a ) * r }
	end
	draw.NoTexture()
	surface.SetDrawColor( col )
	surface.DrawPoly( pts )
end

local function DrawFolderIcon( x, y, w, h, colorIdx )
	local pal = FOLDER_COLORS[colorIdx] or FOLDER_COLORS[1]
	draw.RoundedBox( 3, x, y, math.Round( w * 0.45 ), math.Round( h * 0.36 ), pal.dark )
	draw.RoundedBox( 3, x, y + math.Round( h * 0.14 ), w, math.Round( h * 0.86 ), pal.dark )
	draw.RoundedBox( 3, x, y + math.Round( h * 0.24 ), w, math.Round( h * 0.76 ), pal.col )
	surface.SetDrawColor( 255, 255, 255, 45 )
	surface.DrawRect( x + 2, y + math.Round( h * 0.24 ), math.max( 0, w - 4 ), 1 )
end

local function TruncateText( str, font, maxW )
	surface.SetFont( font )
	if surface.GetTextSize( str ) <= maxW then return str end
	local len = utf8 and utf8.len( str )
	if not len then
		local d = str
		while #d > 1 and surface.GetTextSize( d .. ".." ) > maxW do
			d = string.sub( d, 1, #d - 1 )
		end
		return d .. ".."
	end
	local cur = len
	while cur > 1 do
		cur = cur - 1
		local byteEnd = utf8.offset( str, cur + 1 )
		local sub = byteEnd and string.sub( str, 1, byteEnd - 1 ) or str
		if surface.GetTextSize( sub .. ".." ) <= maxW then
			return sub .. ".."
		end
	end
	return ".."
end

local function DrawTextCentered( str, font, x, y, w, h, col, alignLeft )
	surface.SetFont( font )
	local tw, th = surface.GetTextSize( str )
	surface.SetTextColor( col.r, col.g, col.b, col.a )
	local tx = alignLeft and x or math.Round( x + ( w - tw ) * 0.5 )
	local ty = math.Round( y + ( h - th ) * 0.5 )
	surface.SetTextPos( tx, ty )
	surface.DrawText( str )
	return tw, th
end

local function FormatBytes( bytes )
	local b = tonumber( bytes ) or 0
	if b <= 0 then return "0 B" end
	if b < 1024 then return string.format( "%d B", b ) end
	if b < 1048576 then return string.format( "%.1f KB", b / 1024 ) end
	if b < 1073741824 then return string.format( "%.1f MB", b / 1048576 ) end
	return string.format( "%.2f GB", b / 1073741824 )
end

-- -------------------- Folder Path Helpers --------------------
local function NormalizeFolderPath( path )
	if not path or path == "" then return "" end
	local s = string.Replace( tostring( path ), "\\", "/" )
	local parts = { }
	for _, seg in ipairs( string.Split( s, "/" ) ) do
		seg = string.Trim( seg )
		if seg ~= "" and seg ~= "." and seg ~= ".." then
			table.insert( parts, seg )
		end
	end
	return table.concat( parts, "/" )
end

local function GetParentFolder( path )
	path = NormalizeFolderPath( path )
	if path == "" then return "" end
	local parts = string.Split( path, "/" )
	if #parts <= 1 then return "" end
	table.remove( parts, #parts )
	return table.concat( parts, "/" )
end

local function GetFolderBaseName( path )
	path = NormalizeFolderPath( path )
	if path == "" then return L( "crumb_root" ) end
	local parts = string.Split( path, "/" )
	return parts[#parts]
end

local function GetFolderDepth( path )
	path = NormalizeFolderPath( path )
	if path == "" then return 0 end
	return #string.Split( path, "/" )
end

local function IsFolderOrChild( candidate, rootFolder )
	if rootFolder == "" then return true end
	if candidate == rootFolder then return true end
	return string.StartsWith( candidate, rootFolder .. "/" )
end

local function EnsureFolderChain( path, colorIdx )
	path = NormalizeFolderPath( path )
	if path == "" then return "" end
	local parts = string.Split( path, "/" )
	local cur = ""
	for i, seg in ipairs( parts ) do
		cur = ( cur == "" ) and seg or ( cur .. "/" .. seg )
		if not Folders[cur] then
			local cidx = ( i == #parts and colorIdx ) or ( ( ( #table.GetKeys( Folders ) ) % #FOLDER_COLORS ) + 1 )
			Folders[cur] = { color = cidx, expanded = true }
		end
	end
	return path
end

local function TranslateAutoCatPath( path, targetLang )
	path = NormalizeFolderPath( path )
	if path == "" then return "" end
	local targetTbl = CatLabels[targetLang] or CatLabels.zh
	local parts = string.Split( path, "/" )
	local first = parts[1]
	for cat, zhLabel in pairs( CatLabels.zh ) do
		local enLabel = CatLabels.en[cat]
		if first == zhLabel or ( enLabel and first == enLabel ) then
			parts[1] = targetTbl[cat] or first
			return table.concat( parts, "/" )
		end
	end
	return path
end

local function SyncAutoCatFoldersToLang( targetLang, scope )
	local changed = false
	local newFolders = { }
	for fp, fd in pairs( Folders ) do
		local np = TranslateAutoCatPath( fp, targetLang )
		if np ~= fp then changed = true end
		if not newFolders[np] or np == fp then
			newFolders[np] = fd
		end
	end
	if changed then
		Folders = newFolders
		for fp in pairs( table.Copy( Folders ) ) do
			EnsureFolderChain( fp )
		end
	end
	if istable( Addons ) then
		for _, info in pairs( Addons ) do
			local oldF = info.folder or ""
			if oldF ~= "" then
				local newF = TranslateAutoCatPath( oldF, targetLang )
				if newF ~= oldF then
					info.folder = newF
					changed = true
				end
			end
		end
	end
	if scope and scope ~= "" and not string.StartsWith( scope, "__" ) then
		scope = TranslateAutoCatPath( scope, targetLang )
	end
	return scope, changed
end

-- -------------------- Persistence --------------------
local function WriteSave( jsonStr )
	local meta = FindMetaTable and FindMetaTable( "File" )
	if meta and isfunction( meta.Write ) then
		local ok, res = pcall( file.Write, savefile, jsonStr )
		if ok and res ~= false then return true end
	end
	if cookie and cookie.Set then
		cookie.Set( cookie_key, jsonStr )
		return true
	end
	return false
end

local function ReadSave()
	if file.Exists( savefile, "DATA" ) and ( file.Size( savefile, "DATA" ) or 0 ) > 0 then
		local ok, raw = pcall( file.Read, savefile, "DATA" )
		if ok and raw and raw ~= "" then return raw end
	end
	if cookie and cookie.GetString then
		local raw = cookie.GetString( cookie_key, "" )
		if raw and raw ~= "" then return raw end
	end
	return nil
end

if not file.Exists( dir, "DATA" ) then file.CreateDir( dir ) end

local function Save()
	if not istable( Addons ) then return end
	local out = {
		v = 3,
		lang = Lang,
		addons = { },
		folders = { },
		presets = Presets or { },
	}
	for k, v in pairs( Addons ) do
		local tagsClean = ( v.tags and #v.tags > 0 ) and v.tags or nil
		local folderClean = ( v.folder and v.folder ~= "" ) and v.folder or nil
		local noteClean = ( v.note and v.note ~= "" ) and v.note or nil
		if tagsClean or noteClean or folderClean then
			out.addons[tostring( k )] = {
				tags = tagsClean,
				note = noteClean,
				folder = folderClean,
			}
		end
	end
	for fpath, fdata in pairs( Folders ) do
		out.folders[fpath] = {
			color = fdata.color or 1,
			expanded = fdata.expanded ~= false,
		}
	end
	WriteSave( util.TableToJSON( out, true ) )
end

local function InitAddons()
	Addons = { }
	TagList = { }
	Folders = { }
	Presets = { }

	local savedAddons = { }
	local isLegacyFormat = false
	local hasSavedLang = false
	local rawSave = ReadSave()
	if rawSave then
		local parsed = util.JSONToTable( rawSave )
		if istable( parsed ) then
			if parsed.lang == "zh" or parsed.lang == "en" then
				Lang = parsed.lang
				hasSavedLang = true
			end
			if parsed.v == 3 and istable( parsed.addons ) then
				for ID, v in pairs( parsed.addons ) do
					local key = tonumber( ID ) or ID
					savedAddons[key] = v
				end
				if istable( parsed.folders ) then
					for fpath, fdata in pairs( parsed.folders ) do
						local np = NormalizeFolderPath( fpath )
						if np ~= "" then
							Folders[np] = {
								color = tonumber( fdata.color ) or 1,
								expanded = fdata.expanded ~= false,
							}
							EnsureFolderChain( np )
						end
					end
				end
				if istable( parsed.presets ) then
					Presets = parsed.presets
				end
			else
				isLegacyFormat = true
				for ID, v in pairs( parsed ) do
					local key = tonumber( ID ) or ID
					savedAddons[key] = v
				end
			end
		end
	end

	if not hasSavedLang and not rawSave then
		local glang = GetConVarString and GetConVarString( "gmod_language" ) or ""
		if glang ~= "" and not string.StartsWith( glang:lower(), "zh" ) then
			Lang = "en"
		else
			Lang = "zh"
		end
	end

	local InstallData = engine.GetAddons() or { }
	for _, v in pairs( InstallData ) do
		local id
		local title
		if tonumber( v.wsid ) and tonumber( v.wsid ) > 0 then
			id = tonumber( v.wsid )
			title = v.title
		else
			id = 0
			title = L( "local_gma" )
		end

		Addons[id] = { }
		Addons[id].title = title
		Addons[id].active = v.mounted == true
		Addons[id].size = tonumber( v.size ) or 0
		Addons[id].updated = tonumber( v.updated ) or 0

		local tbl = string.Split( v.tags or "", "," )
		local found = false
		if istable( tbl ) then
			for _, tagStr in pairs( tbl ) do
				for _, cat in pairs( ValidTypes ) do
					if string.Trim( tagStr ):lower() == cat:lower() then
						Addons[id].cat = cat
						found = true
						break
					end
				end
				if found then break end
			end
		end
		if not found then Addons[id].cat = "INVALID" end

		Addons[id].tags = { }
		Addons[id].folder = ""

		local sv = savedAddons[id]
		if istable( sv ) then
			for _, t in pairs( sv.tags or {} ) do
				local ts = tostring( t )
				table.insert( Addons[id].tags, ts )
				if not table.HasValue( TagList, ts ) then
					table.insert( TagList, ts )
				end
			end
			table.sort( Addons[id].tags, function( a, b )
				return string.lower( a ) < string.lower( b )
			end )
			Addons[id].note = sv.note or sv.customname
			local fpath = NormalizeFolderPath( sv.folder or "" )
			if fpath == "" and isLegacyFormat and #Addons[id].tags > 0 then
				fpath = NormalizeFolderPath( Addons[id].tags[1] )
			end
			if fpath ~= "" then
				EnsureFolderChain( fpath )
				Addons[id].folder = fpath
			end
		end
	end

	table.sort( TagList, function( a, b )
		return string.lower( a ) < string.lower( b )
	end )

	SyncAutoCatFoldersToLang( Lang )
end

local function GetAddons( noSave )
	if not istable( Addons ) then
		InitAddons()
	end
	timer.Simple( 0.03, function()
		if not istable( Addons ) then return end
		if not noSave then Save() end
		if Menu.UpdateStats then Menu.UpdateStats() end
		if Menu.PopulateFolders then Menu.PopulateFolders() end
		if Menu.Populate then Menu.Populate() end
	end )
end

-- Load saved language early so main menu shortcut matches immediately
InitAddons()

-- -------------------- Modern UI Style Helpers --------------------
local function StyleScrollbar( scrollPanel )
	local vbar = scrollPanel:GetVBar()
	if not IsValid( vbar ) then return end
	vbar:SetWide( S( 8 ) )
	vbar:SetHideButtons( true )
	vbar.Paint = function( self, w, h )
		draw.RoundedBox( 4, 1, 0, w - 2, h, COL.scrollTrack )
	end
	vbar.btnUp.Paint = function() end
	vbar.btnDown.Paint = function() end
	vbar.btnGrip.Paint = function( self, w, h )
		local c = self:IsHovered() and COL.scrollGripH or COL.scrollGrip
		draw.RoundedBox( 4, 1, 0, w - 2, h, c )
	end
end

local function StyleButton( btn, text, styleType, fontName )
	btn:SetFont( fontName or "SAM_Body" )
	btn:SetText( text or "" )

	local bgCol, hovCol, borderCol, txtCol = COL.btn, COL.btnHover, COL.border, COL.text
	if styleType == "primary" then
		bgCol, hovCol, borderCol = COL.accent, COL.accentHover, COL.accent
	elseif styleType == "success" then
		bgCol, hovCol, borderCol = Color( 16, 125, 89, 255 ), COL.green, Color( 16, 185, 129, 180 )
	elseif styleType == "danger" then
		bgCol, hovCol, borderCol, txtCol = Color( 72, 30, 36, 255 ), Color( 185, 42, 48, 255 ), Color( 239, 68, 68, 120 ), Color( 254, 202, 202, 255 )
	elseif styleType == "danger_solid" then
		bgCol, hovCol, borderCol = Color( 190, 38, 42, 255 ), COL.red, COL.red
	elseif styleType == "ghost" then
		bgCol, hovCol, borderCol, txtCol = Color( 24, 31, 43, 255 ), COL.btnHover, COL.border, COL.textSub
	end

	btn:SetTextColor( txtCol )
	btn.Paint = function( self, w, h )
		local col = bgCol
		if not self:IsEnabled() then
			col = Color( 26, 32, 42, 180 )
		elseif self:IsDown() then
			col = Color( math.max( 0, hovCol.r - 20 ), math.max( 0, hovCol.g - 20 ), math.max( 0, hovCol.b - 20 ), hovCol.a )
		elseif self:IsHovered() then
			col = hovCol
		end
		draw.RoundedBox( 6, 0, 0, w, h, borderCol )
		draw.RoundedBox( 5, 1, 1, w - 2, h - 2, col )
	end
	return btn
end

local function StyleTextEntry( te, placeholder )
	te:SetFont( "SAM_Body" )
	te:SetTextColor( COL.text )
	te:SetCursorColor( COL.accent )
	te:SetHighlightColor( Color( 59, 130, 246, 110 ) )
	te:SetDrawLanguageID( false )
	te.Paint = function( self, w, h )
		local bcol = self:HasFocus() and COL.accent or COL.border
		draw.RoundedBox( 6, 0, 0, w, h, bcol )
		draw.RoundedBox( 5, 1, 1, w - 2, h - 2, COL.input )
		self:DrawTextEntryText( COL.text, Color( 59, 130, 246, 110 ), COL.text )
		if placeholder and self:GetValue() == "" and not self:HasFocus() then
			DrawTextCentered( placeholder, "SAM_Body", S( 10 ), 0, w, h, COL.textMuted, true )
		end
	end
	return te
end

local function StyleComboBox( cb )
	cb:SetFont( "SAM_Body" )
	cb:SetTextColor( COL.text )
	cb.Paint = function( self, w, h )
		local bcol = ( self:IsHovered() or self:IsMenuOpen() ) and COL.borderLight or COL.border
		local bg = self:IsHovered() and COL.btnHover or COL.btn
		draw.RoundedBox( 6, 0, 0, w, h, bcol )
		draw.RoundedBox( 5, 1, 1, w - 2, h - 2, bg )
	end
	local oldOpen = cb.OpenMenu
	cb.OpenMenu = function( self, pControlOpener )
		oldOpen( self, pControlOpener )
		if IsValid( self.Menu ) then
			self.Menu.Paint = function( m, w, h )
				draw.RoundedBox( 6, 0, 0, w, h, COL.borderLight )
				draw.RoundedBox( 5, 1, 1, w - 2, h - 2, COL.panel )
			end
			for _, child in pairs( self.Menu:GetCanvas():GetChildren() ) do
				child:SetFont( "SAM_Body" )
				child:SetTextColor( COL.text )
				child.Paint = function( item, w, h )
					if item:IsHovered() then
						draw.RoundedBox( 4, 2, 1, w - 4, h - 2, COL.accent )
					end
				end
			end
		end
	end
	return cb
end

local function StyleDarkMenu( m )
	m.Paint = function( self, w, h )
		draw.RoundedBox( 6, 0, 0, w, h, COL.borderLight )
		draw.RoundedBox( 5, 1, 1, w - 2, h - 2, COL.panel )
	end
	local oldAdd = m.AddOption
	m.AddOption = function( self, text, func )
		local opt = oldAdd( self, text, func )
		opt:SetFont( "SAM_Body" )
		opt:SetTextColor( COL.text )
		opt.Paint = function( item, w, h )
			if item:IsHovered() then
				draw.RoundedBox( 4, 3, 1, w - 6, h - 2, COL.accent )
			end
		end
		return opt
	end
	local oldSub = m.AddSubMenu
	m.AddSubMenu = function( self, text, func )
		local sub, opt = oldSub( self, text, func )
		opt:SetFont( "SAM_Body" )
		opt:SetTextColor( COL.text )
		opt.Paint = function( item, w, h )
			if item:IsHovered() then
				draw.RoundedBox( 4, 3, 1, w - 6, h - 2, COL.accent )
			end
		end
		StyleDarkMenu( sub )
		return sub, opt
	end
	return m
end

local function CreateDarkMenu( parent )
	return StyleDarkMenu( parent:Add( "DMenu" ) )
end

local function PopupWindow( pw, ph, titleText )
	if IsValid( Menu.ActivePopup ) then
		Menu.ActivePopup:Remove()
	end
	local f = vgui.Create( "DFrame" )
	Menu.ActivePopup = f
	f:SetSize( pw, ph )
	f:SetTitle( "" )
	f:SetDraggable( true )
	f:SetScreenLock( true )
	f:ShowCloseButton( false )
	f:Center()
	f:MakePopup()
	f:DockPadding( 1, 1, 1, 1 )
	f.Paint = function( self, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, COL.borderLight )
		draw.RoundedBox( 7, 1, 1, w - 2, h - 2, COL.panel )
		return true
	end
	f.OnClose = function()
		if Menu.ActivePopup == f then Menu.ActivePopup = nil end
		if IsValid( Menu.Frame ) then
			Menu.Frame:MakePopup()
		end
	end

	local p = f:Add( "DPanel" )
	p:DockPadding( S( 20 ), S( 18 ), S( 20 ), S( 18 ) )
	p:Dock( FILL )
	p.Paint = function() end

	if titleText then
		local hdr = p:Add( "DLabel" )
		hdr:Dock( TOP )
		hdr:DockMargin( 0, 0, 0, S( 12 ) )
		hdr:SetFont( "SAM_Header" )
		hdr:SetText( titleText )
		hdr:SetTextColor( COL.text )
		hdr:SizeToContents()
	end
	return f, p
end

local function PopupConfirm( pw, ph, b1_label, b2_label, text1, text2, header, b1_width, b2_width, danger )
	local f, p = PopupWindow( pw, ph, header )

	local t1
	if text1 then
		t1 = p:Add( "DLabel" )
		t1:Dock( TOP )
		t1:SetFont( "SAM_ItemTitle" )
		t1:SetText( text1 )
		t1:SetTextColor( COL.text )
		t1:SetWrap( true )
		t1:SetAutoStretchVertical( true )
	end

	local t2
	if text2 then
		t2 = p:Add( "DLabel" )
		t2:Dock( TOP )
		t2:DockMargin( 0, S( 8 ), 0, 0 )
		t2:SetFont( "SAM_Body" )
		t2:SetText( text2 )
		t2:SetTextColor( COL.textSub )
		t2:SetWrap( true )
		t2:SetAutoStretchVertical( true )
	end

	local btnRow = p:Add( "DPanel" )
	btnRow:Dock( BOTTOM )
	btnRow:SetTall( S( 36 ) )
	btnRow.Paint = function() end

	local b1 = btnRow:Add( "DButton" )
	b1:SetSize( b1_width or S( 130 ), S( 34 ) )
	b1:Dock( LEFT )
	StyleButton( b1, b1_label, danger and "danger_solid" or "primary" )

	local b2 = btnRow:Add( "DButton" )
	b2:SetSize( b2_width or S( 116 ), S( 34 ) )
	b2:Dock( RIGHT )
	StyleButton( b2, b2_label, "default" )

	return f, b1, b2, t1, t2
end

local function PopupPrompt( titleText, placeholder, initialVal, onConfirm )
	local f, p = PopupWindow( S( 420 ), S( 175 ), titleText )
	local te = p:Add( "DTextEntry" )
	te:Dock( TOP )
	te:SetTall( S( 36 ) )
	te:SetValue( initialVal or "" )
	StyleTextEntry( te, placeholder )
	te:RequestFocus()

	local function Submit()
		local val = string.Trim( te:GetValue() )
		f:Close()
		if onConfirm then onConfirm( val ) end
	end
	te.OnEnter = Submit

	local btnRow = p:Add( "DPanel" )
	btnRow:Dock( BOTTOM )
	btnRow:SetTall( S( 36 ) )
	btnRow.Paint = function() end

	local b1 = btnRow:Add( "DButton" )
	b1:Dock( LEFT )
	b1:SetSize( S( 170 ), S( 34 ) )
	StyleButton( b1, L( "ok" ), "primary" )
	b1.DoClick = Submit

	local b2 = btnRow:Add( "DButton" )
	b2:Dock( RIGHT )
	b2:SetSize( S( 170 ), S( 34 ) )
	StyleButton( b2, L( "cancel" ), "default" )
	b2.DoClick = function() f:Close() end
end

-- -------------------- Main Window --------------------
function Menu.Setup()
	if not WorkshopReady and #( engine.GetAddons() or {} ) > 0 then
		WorkshopReady = true
	end

	if not WorkshopReady then
		MsgC( Color( 255, 90, 90 ), L( "err_not_ready" ) )
		return
	end

	if IsValid( Menu.Frame ) then
		Menu.Frame:Close()
		return
	end

	EnsureFonts()

	Menu.Frame = vgui.Create( "DFrame" )
	local fw = math.min( math.Round( ScrW() * 0.92 ), S( 1380 ) )
	local fh = math.min( math.Round( ScrH() * 0.89 ), S( 920 ) )
	Menu.Frame:SetSize( fw, fh )
	Menu.Frame:SetTitle( "" )
	Menu.Frame:SetVisible( true )
	Menu.Frame:SetDraggable( true )
	Menu.Frame:SetScreenLock( true )
	Menu.Frame:ShowCloseButton( false )
	Menu.Frame:DockPadding( 0, 0, 0, 0 )
	Menu.Frame:Center()
	Menu.Frame:MakePopup()
	Menu.Frame:SetKeyboardInputEnabled( true )
	Menu.Frame.Paint = function( self, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, COL.border )
		draw.RoundedBox( 7, 1, 1, w - 2, h - 2, COL.bg )
	end

	Menu.Frame._wasEscDown = input.IsKeyDown( KEY_ESCAPE )
	Menu.Frame._wasTildeDown = input.IsKeyDown( KEY_BACKQUOTE )
	local baseFrameThink = Menu.Frame.Think
	Menu.Frame.Think = function( self )
		if baseFrameThink then baseFrameThink( self ) end

		local escDown = input.IsKeyDown( KEY_ESCAPE )
		if escDown and not self._wasEscDown and not IsValid( Menu.ActivePopup ) then
			self._wasEscDown = true
			self:Close()
			return
		end
		self._wasEscDown = escDown

		local tildeDown = input.IsKeyDown( KEY_BACKQUOTE )
		if tildeDown and not self._wasTildeDown then
			local kf = vgui.GetKeyboardFocus()
			local typing = IsValid( kf ) and kf:GetClassName() == "TextEntry"
			if not typing and not gui.IsConsoleVisible() then
				RunConsoleCommand( "showconsole" )
			end
		end
		self._wasTildeDown = tildeDown
	end

	-- State (restore across instant language switch)
	local AddonsReadable = { }
	local Selected_Addons = { }
	local CurrentScope = Menu.SavedScope or "__ALL__"
	local ViewMode = Menu.SavedViewMode or "folder"
	local Selected_Cat = nil
	local EnabledFilter = 0
	local SortType = 1
	local last_selected = 1
	Menu.SavedScope = nil
	Menu.SavedViewMode = nil

	Menu.Frame.OnClose = function( self )
		CloseDermaMenus()
		if IsValid( Menu.ActivePopup ) then
			Menu.ActivePopup:Remove()
			Menu.ActivePopup = nil
		end
		local kf = vgui.GetKeyboardFocus()
		if IsValid( kf ) and ( kf == self or kf:HasParent( self ) ) then
			kf:KillFocus()
		end
		self:SetKeyboardInputEnabled( false )
		self:SetMouseInputEnabled( false )
		self:MouseCapture( false )
		if IsValid( pnlMainMenu ) then
			pnlMainMenu:SetPopupStayAtBack( true )
		end
	end

	-- -------------------- Core Logic Helpers --------------------
	local function GetSortedFolderPaths()
		local list = { }
		for fpath in pairs( Folders ) do
			table.insert( list, fpath )
		end
		table.sort( list, function( a, b )
			return string.lower( a ) < string.lower( b )
		end )
		return list
	end

	local function ComputeFolderStats( rootPath )
		local total, active, sizeBytes = 0, 0, 0
		for _, info in pairs( Addons or {} ) do
			local match = false
			if rootPath == "__ALL__" then
				match = true
			elseif rootPath == "__ENABLED__" then
				match = info.active == true
			elseif rootPath == "__UNCAT__" then
				match = ( info.folder or "" ) == ""
			else
				match = IsFolderOrChild( info.folder or "", rootPath )
			end
			if match then
				total = total + 1
				sizeBytes = sizeBytes + ( info.size or 0 )
				if info.active then active = active + 1 end
			end
		end
		return total, active, sizeBytes
	end

	local function GetImmediateChildFolders( parentPath )
		local baseDepth = ( parentPath == "__ALL__" or parentPath == "" ) and 0 or GetFolderDepth( parentPath )
		local children = { }
		for _, fpath in ipairs( GetSortedFolderPaths() ) do
			local d = GetFolderDepth( fpath )
			if d == baseDepth + 1 then
				if baseDepth == 0 or GetParentFolder( fpath ) == parentPath then
					table.insert( children, fpath )
				end
			end
		end
		return children
	end

	function Menu.UpdateStats()
		if not IsValid( Menu.StatsLabel ) or not istable( Addons ) then return end
		local total, active, totalBytes, activeBytes = 0, 0, 0, 0
		for _, v in pairs( Addons ) do
			total = total + 1
			totalBytes = totalBytes + ( v.size or 0 )
			if v.active then
				active = active + 1
				activeBytes = activeBytes + ( v.size or 0 )
			end
		end
		Menu.StatsLabel:SetText( L( "stats_fmt", active, total, FormatBytes( activeBytes ), FormatBytes( totalBytes ), #table.GetKeys( Folders ) ) )
		Menu.StatsLabel:SizeToContents()
	end

	local function AddonSetActive( id, value, skipRefresh )
		if id > 0 then
			steamworks.SetShouldMountAddon( id, value )
		end
		Addons[id].active = value
		if not skipRefresh then
			steamworks.ApplyAddons()
			Menu.UpdateStats()
			Menu.PopulateFolders()
			Menu.Populate()
		end
	end

	local function ToggleFolderAddons( folderPath, value )
		local changed = false
		for id, info in pairs( Addons ) do
			local match = false
			if folderPath == "__ALL__" then match = true
			elseif folderPath == "__UNCAT__" then match = ( info.folder or "" ) == ""
			else match = IsFolderOrChild( info.folder or "", folderPath ) end
			if match and info.active ~= value then
				AddonSetActive( id, value, true )
				changed = true
			end
		end
		if changed then
			steamworks.ApplyAddons()
			Menu.UpdateStats()
			Menu.PopulateFolders()
			Menu.Populate()
		end
	end

	local function AddonToggleSelected( value )
		if #table.GetKeys( Selected_Addons ) < 1 then return end
		for id in pairs( Selected_Addons ) do
			if Addons[id] then AddonSetActive( id, value, true ) end
		end
		steamworks.ApplyAddons()
		Menu.UpdateStats()
		Menu.PopulateFolders()
		Menu.Populate()
	end

	local function AddonToggleAll( value )
		for id in pairs( Addons ) do
			AddonSetActive( id, value, true )
		end
		steamworks.ApplyAddons()
		GetAddons( true )
	end

	local function MoveAddonsToFolder( idList, targetFolder )
		targetFolder = NormalizeFolderPath( targetFolder or "" )
		if targetFolder ~= "" then EnsureFolderChain( targetFolder ) end
		for _, id in ipairs( idList ) do
			if Addons[id] then
				Addons[id].folder = targetFolder
			end
		end
		GetAddons()
	end

	local function CreateNewFolderDialog( defaultPrefix )
		local pre = ( defaultPrefix and defaultPrefix ~= "" ) and ( defaultPrefix .. "/" ) or ""
		PopupPrompt( L( "dlg_new_folder" ), L( "dlg_new_folder_ph" ), pre, function( val )
			local np = NormalizeFolderPath( val )
			if np == "" then return end
			EnsureFolderChain( np )
			CurrentScope = np
			GetAddons()
		end )
	end

	local function RenameFolderDialog( oldPath )
		oldPath = NormalizeFolderPath( oldPath )
		if oldPath == "" then return end
		local parent = GetParentFolder( oldPath )
		local oldName = GetFolderBaseName( oldPath )
		PopupPrompt( L( "dlg_rename_t" ), L( "dlg_rename_ph" ), oldName, function( newName )
			newName = string.Trim( string.Replace( newName, "/", "" ) )
			if newName == "" or newName == oldName then return end
			local newPath = ( parent == "" ) and newName or ( parent .. "/" .. newName )
			if Folders[newPath] then return end

			local newFolders = { }
			for fp, fd in pairs( Folders ) do
				if fp == oldPath then
					newFolders[newPath] = fd
				elseif string.StartsWith( fp, oldPath .. "/" ) then
					local suffix = string.sub( fp, #oldPath + 2 )
					newFolders[newPath .. "/" .. suffix] = fd
				else
					newFolders[fp] = fd
				end
			end
			Folders = newFolders

			for _, info in pairs( Addons ) do
				if info.folder == oldPath then
					info.folder = newPath
				elseif string.StartsWith( info.folder or "", oldPath .. "/" ) then
					info.folder = newPath .. "/" .. string.sub( info.folder, #oldPath + 2 )
				end
			end

			if CurrentScope == oldPath then
				CurrentScope = newPath
			elseif string.StartsWith( CurrentScope, oldPath .. "/" ) then
				CurrentScope = newPath .. "/" .. string.sub( CurrentScope, #oldPath + 2 )
			end
			GetAddons()
		end )
	end

	local function DeleteFolderAction( folderPath )
		folderPath = NormalizeFolderPath( folderPath )
		if folderPath == "" then return end
		local fallback = GetParentFolder( folderPath )
		for fp in pairs( table.Copy( Folders ) ) do
			if IsFolderOrChild( fp, folderPath ) then
				Folders[fp] = nil
			end
		end
		for _, info in pairs( Addons ) do
			if IsFolderOrChild( info.folder or "", folderPath ) then
				info.folder = fallback
			end
		end
		if IsFolderOrChild( CurrentScope, folderPath ) then
			CurrentScope = ( fallback ~= "" ) and fallback or "__ALL__"
		end
		GetAddons()
	end

	local function AutoCategorizeUncategorized()
		local moved = 0
		for _, info in pairs( Addons ) do
			if ( info.folder or "" ) == "" and info.cat ~= "INVALID" then
				local label = GetCatLabel( info.cat )
				EnsureFolderChain( label )
				info.folder = label
				moved = moved + 1
			end
		end
		if moved > 0 then
			GetAddons()
		else
			Menu.PopulateFolders()
			Menu.Populate()
		end
	end

	local function OpenMoveMenu( parentPanel, idList )
		local m = CreateDarkMenu( parentPanel )
		m:AddOption( L( "ctx_uncat" ), function()
			MoveAddonsToFolder( idList, "" )
		end )
		m:AddSpacer()
		local sorted = GetSortedFolderPaths()
		if #sorted > 0 then
			for _, fpath in ipairs( sorted ) do
				local indent = string.rep( "　", math.max( 0, GetFolderDepth( fpath ) - 1 ) )
				m:AddOption( indent .. "▸ " .. GetFolderBaseName( fpath ) .. ( GetFolderDepth( fpath ) > 1 and ( "  (" .. fpath .. ")" ) or "" ), function()
					MoveAddonsToFolder( idList, fpath )
				end )
			end
			m:AddSpacer()
		end
		m:AddOption( L( "ctx_new_move" ), function()
			PopupPrompt( L( "dlg_new_move_t" ), L( "dlg_new_move_ph" ), "", function( val )
				local np = NormalizeFolderPath( val )
				if np == "" then return end
				MoveAddonsToFolder( idList, np )
			end )
		end )
		return m
	end

	local function OpenFolderContextMenu( parentPanel, fpath )
		local m = CreateDarkMenu( parentPanel )
		m:AddOption( L( "fctx_on" ), function() ToggleFolderAddons( fpath, true ) end ):SetIcon( "icon16/tick.png" )
		m:AddOption( L( "fctx_off" ), function() ToggleFolderAddons( fpath, false ) end ):SetIcon( "icon16/cross.png" )
		m:AddSpacer()
		m:AddOption( L( "fctx_sub" ), function() CreateNewFolderDialog( fpath ) end ):SetIcon( "icon16/folder_add.png" )
		m:AddOption( L( "fctx_rename" ), function() RenameFolderDialog( fpath ) end ):SetIcon( "icon16/textfield_rename.png" )

		local colorSub = m:AddSubMenu( L( "fctx_color" ) )
		for idx, cinfo in ipairs( FOLDER_COLORS ) do
			local cname = ( Lang == "en" ) and cinfo.en or cinfo.zh
			colorSub:AddOption( "● " .. cname, function()
				if Folders[fpath] then
					Folders[fpath].color = idx
					GetAddons()
				end
			end )
		end

		m:AddSpacer()
		m:AddOption( L( "fctx_del" ), function() DeleteFolderAction( fpath ) end ):SetIcon( "icon16/folder_delete.png" )
		m:Open()
	end

	-- -------------------- Presets Management --------------------
	local function ApplyPreset( name )
		local pr = Presets[name]
		if not istable( pr ) then return end
		local enableSet = { }
		for _, idStr in ipairs( pr.enabled or {} ) do
			enableSet[tostring( idStr )] = true
		end
		for id in pairs( Addons ) do
			AddonSetActive( id, enableSet[tostring( id )] == true, true )
		end
		steamworks.ApplyAddons()
		Menu.UpdateStats()
		Menu.PopulateFolders()
		Menu.Populate()
	end

	local function OpenPresetMenu( anchorBtn )
		local m = CreateDarkMenu( Menu.MainPanel )
		m:AddOption( L( "preset_save" ), function()
			PopupPrompt( L( "dlg_preset_t" ), L( "dlg_preset_ph" ), "", function( name )
				if name == "" then return end
				local en = { }
				for id, info in pairs( Addons ) do
					if info.active then table.insert( en, tostring( id ) ) end
				end
				Presets[name] = { enabled = en }
				Save()
			end )
		end ):SetIcon( "icon16/disk.png" )

		local names = table.GetKeys( Presets )
		table.sort( names, function( a, b ) return string.lower( a ) < string.lower( b ) end )
		if #names > 0 then
			m:AddSpacer()
			for _, pname in ipairs( names ) do
				local cnt = #( Presets[pname].enabled or {} )
				local sub = m:AddSubMenu( L( "preset_item", pname, cnt ), function()
					ApplyPreset( pname )
				end )
				sub:AddOption( L( "preset_apply" ), function() ApplyPreset( pname ) end ):SetIcon( "icon16/tick.png" )
				sub:AddOption( L( "preset_overwrite" ), function()
					local en = { }
					for id, info in pairs( Addons ) do
						if info.active then table.insert( en, tostring( id ) ) end
					end
					Presets[pname] = { enabled = en }
					Save()
				end ):SetIcon( "icon16/disk.png" )
				sub:AddOption( L( "preset_delete" ), function()
					Presets[pname] = nil
					Save()
				end ):SetIcon( "icon16/bin.png" )
			end
		end

		local sx, sy = anchorBtn:LocalToScreen( 0, anchorBtn:GetTall() + 2 )
		m:Open( sx, sy )
	end

	local function AddonSetNote( id )
		PopupPrompt( L( "dlg_note_t" ), L( "dlg_note_ph" ), Addons[id].note or "", function( txt )
			if txt ~= "" then
				Addons[id].note = txt
				GetAddons()
			elseif Addons[id].note then
				Addons[id].note = nil
				GetAddons()
			end
		end )
	end

	local function AddonLikeSelected()
		local count = #table.GetKeys( Selected_Addons )
		if count < 1 then return end
		local f, b1, b2 = PopupConfirm( S( 410 ), S( 195 ), L( "vote_ok" ), L( "cancel" ),
			L( "vote_t1", count ), L( "vote_t2" ), L( "vote_title" ) )
		b1.DoClick = function()
			for id in pairs( Selected_Addons ) do
				if id > 0 then steamworks.Vote( id, true ) end
			end
			f:Close()
		end
		b2.DoClick = function() f:Close() end
	end

	local function AddonDeleteSelected()
		local count = #table.GetKeys( Selected_Addons )
		if count < 1 then return end
		local f, b1, b2, t1, t2 = PopupConfirm( S( 470 ), S( 225 ), L( "uninst_ok" ), L( "cancel" ),
			L( "uninst_t1", count ), L( "uninst_t2" ), L( "uninst_title", count ), S( 155 ), S( 116 ), true )

		b1:SetEnabled( false )
		b1:SetText( L( "uninst_ok" ) .. " (3)" )
		timer.Simple( 1, function() if IsValid( b1 ) then b1:SetText( L( "uninst_ok" ) .. " (2)" ) end end )
		timer.Simple( 2, function() if IsValid( b1 ) then b1:SetText( L( "uninst_ok" ) .. " (1)" ) end end )
		timer.Simple( 3, function() if IsValid( b1 ) then b1:SetText( L( "uninst_ok" ) ) b1:SetEnabled( true ) end end )

		b1.DoClick = function()
			t1:SetText( L( "uninst_ing" ) )
			t2:SetText( L( "uninst_wait" ) )
			b1:SetEnabled( false )
			b2:SetEnabled( false )
			for id in pairs( Selected_Addons ) do
				Selected_Addons[id] = nil
				Addons[id] = nil
				if id > 0 then steamworks.Unsubscribe( id ) end
			end
			timer.Simple( 0.5, function()
				steamworks.ApplyAddons()
				Selected_Addons = { }
				if IsValid( Menu.NoSelectedAddons ) then Menu.NoSelectedAddons.Count() end
				Addons = nil
			end )
			timer.Simple( 2.5, function()
				GetAddons()
				if IsValid( f ) then f:Close() end
			end )
		end
		b2.DoClick = function() f:Close() end
	end

	local function AddonRemoveNotes()
		local f, b1, b2 = PopupConfirm( S( 410 ), S( 190 ), L( "clr_note_ok" ), L( "cancel" ),
			L( "clr_note_t1" ), L( "clr_note_t2" ), L( "clr_note_title" ), S( 126 ), S( 116 ), true )
		b1.DoClick = function()
			for _, v in pairs( Addons ) do v.note = nil end
			GetAddons()
			f:Close()
		end
		b2.DoClick = function() f:Close() end
	end

	-- -------------------- Top Header Bar --------------------
	Menu.Header = Menu.Frame:Add( "DPanel" )
	Menu.Header:Dock( TOP )
	Menu.Header:SetTall( S( 58 ) )
	Menu.Header.Paint = function( self, w, h )
		draw.RoundedBoxEx( 6, 1, 1, w - 2, h - 1, COL.header, true, true, false, false )
		surface.SetDrawColor( COL.border )
		surface.DrawLine( 1, h - 1, w - 1, h - 1 )
		DrawCirclePoly( S( 22 ), math.Round( h * 0.5 ), S( 5 ), 18, COL.accent )
	end
	Menu.Header.OnMousePressed = function( self, mcode )
		if mcode == MOUSE_LEFT and IsValid( Menu.Frame ) then
			local fx, fy = Menu.Frame:GetPos()
			self._dragOffX = gui.MouseX() - fx
			self._dragOffY = gui.MouseY() - fy
			self._dragging = true
		end
	end
	Menu.Header.OnMouseReleased = function( self ) self._dragging = false end
	Menu.Header.Think = function( self )
		if self._dragging then
			if not input.IsMouseDown( MOUSE_LEFT ) or not IsValid( Menu.Frame ) then
				self._dragging = false
				return
			end
			local nx = math.Clamp( gui.MouseX() - self._dragOffX, 0, math.max( 0, ScrW() - Menu.Frame:GetWide() ) )
			local ny = math.Clamp( gui.MouseY() - self._dragOffY, 0, math.max( 0, ScrH() - Menu.Frame:GetTall() ) )
			Menu.Frame:SetPos( nx, ny )
		end
	end

	local hdrTitle = Menu.Header:Add( "DLabel" )
	hdrTitle:SetPos( S( 38 ), S( 16 ) )
	hdrTitle:SetFont( "SAM_Header" )
	hdrTitle:SetText( L( "app_title" ) )
	hdrTitle:SetTextColor( COL.text )
	hdrTitle:SizeToContents()

	Menu.StatsLabel = Menu.Header:Add( "DLabel" )
	local tx = hdrTitle:GetPos()
	Menu.StatsLabel:SetPos( tx + hdrTitle:GetWide() + S( 18 ), S( 21 ) )
	Menu.StatsLabel:SetFont( "SAM_Small" )
	Menu.StatsLabel:SetText( L( "loading" ) )
	Menu.StatsLabel:SetTextColor( COL.textSub )
	Menu.StatsLabel:SizeToContents()

	local closeBtn = Menu.Header:Add( "DButton" )
	closeBtn:Dock( RIGHT )
	closeBtn:DockMargin( S( 8 ), S( 11 ), S( 14 ), S( 11 ) )
	closeBtn:SetWide( S( 38 ) )
	closeBtn:SetText( "✕" )
	closeBtn:SetFont( "SAM_Body" )
	closeBtn:SetTextColor( COL.textSub )
	closeBtn.Paint = function( self, w, h )
		if self:IsHovered() then
			draw.RoundedBox( 6, 0, 0, w, h, COL.red )
			self:SetTextColor( COL.text )
		else
			draw.RoundedBox( 6, 0, 0, w, h, COL.btn )
			self:SetTextColor( COL.textSub )
		end
	end
	closeBtn.DoClick = function() Menu.Frame:Close() end

	local refreshBtn = Menu.Header:Add( "DButton" )
	refreshBtn:Dock( RIGHT )
	refreshBtn:DockMargin( S( 8 ), S( 11 ), 0, S( 11 ) )
	refreshBtn:SetWide( S( 104 ) )
	StyleButton( refreshBtn, L( "refresh" ), "default" )
	refreshBtn.DoClick = function()
		Addons = nil
		GetAddons( true )
	end

	local langBtn = Menu.Header:Add( "DButton" )
	langBtn:Dock( RIGHT )
	langBtn:DockMargin( S( 8 ), S( 11 ), 0, S( 11 ) )
	langBtn:SetWide( S( 110 ) )
	StyleButton( langBtn, L( "lang_btn" ), "default", "SAM_Small" )
	langBtn.DoClick = function()
		Lang = ( Lang == "zh" ) and "en" or "zh"
		CurrentScope = SyncAutoCatFoldersToLang( Lang, CurrentScope )
		Save()
		Menu.SavedScope = CurrentScope
		Menu.SavedViewMode = ViewMode
		Menu.Frame:Close()
		timer.Simple( 0, Menu.Setup )
	end

	local presetBtn = Menu.Header:Add( "DButton" )
	presetBtn:Dock( RIGHT )
	presetBtn:DockMargin( S( 8 ), S( 11 ), 0, S( 11 ) )
	presetBtn:SetWide( S( 132 ) )
	StyleButton( presetBtn, L( "presets_btn" ), "primary" )
	presetBtn:SetIsMenu( true )
	presetBtn.DoClick = function() OpenPresetMenu( presetBtn ) end

	-- -------------------- Body Layout --------------------
	Menu.MainPanel = Menu.Frame:Add( "DPanel" )
	Menu.MainPanel:Dock( FILL )
	Menu.MainPanel:DockPadding( S( 14 ), S( 12 ), S( 14 ), S( 14 ) )
	Menu.MainPanel.Paint = function() end

	-- Top Toolbar Card
	Menu.Top = Menu.MainPanel:Add( "DPanel" )
	Menu.Top:Dock( TOP )
	Menu.Top:SetTall( S( 100 ) )
	Menu.Top:DockMargin( 0, 0, 0, S( 12 ) )
	Menu.Top.Paint = function( self, w, h )
		draw.RoundedBox( 6, 0, 0, w, h, COL.border )
		draw.RoundedBox( 5, 1, 1, w - 2, h - 2, COL.panel )
	end

	local row1 = Menu.Top:Add( "DPanel" )
	row1:Dock( TOP )
	row1:SetTall( S( 42 ) )
	row1:DockMargin( S( 12 ), S( 10 ), S( 12 ), S( 4 ) )
	row1.Paint = function() end

	local bViewList = row1:Add( "DButton" )
	bViewList:Dock( RIGHT )
	bViewList:SetWide( S( 106 ) )
	bViewList:DockMargin( S( 4 ), S( 2 ), 0, S( 2 ) )
	bViewList:SetFont( "SAM_Small" )
	bViewList:SetText( L( "view_list" ) )
	bViewList.Paint = function( self, w, h )
		local active = ViewMode == "list"
		local bg = active and COL.accent or ( self:IsHovered() and COL.btnHover or COL.btn )
		draw.RoundedBox( 6, 0, 0, w, h, active and COL.accentHover or COL.border )
		draw.RoundedBox( 5, 1, 1, w - 2, h - 2, bg )
		self:SetTextColor( active and COL.text or COL.textSub )
	end
	bViewList.DoClick = function()
		ViewMode = "list"
		Menu.Populate()
	end

	local bViewFolder = row1:Add( "DButton" )
	bViewFolder:Dock( RIGHT )
	bViewFolder:SetWide( S( 128 ) )
	bViewFolder:DockMargin( S( 8 ), S( 2 ), 0, S( 2 ) )
	bViewFolder:SetText( "" )
	bViewFolder.Paint = function( self, w, h )
		local active = ViewMode == "folder"
		local bg = active and COL.accent or ( self:IsHovered() and COL.btnHover or COL.btn )
		draw.RoundedBox( 6, 0, 0, w, h, active and COL.accentHover or COL.border )
		draw.RoundedBox( 5, 1, 1, w - 2, h - 2, bg )
		DrawFolderIcon( S( 10 ), math.Round( ( h - S( 14 ) ) * 0.5 ), S( 16 ), S( 14 ), active and 3 or 1 )
		DrawTextCentered( L( "view_folder" ), "SAM_Small", S( 30 ), 0, w - S( 34 ), h, active and COL.text or COL.textSub )
	end
	bViewFolder.DoClick = function()
		ViewMode = "folder"
		Menu.Populate()
	end

	local sortCombo = row1:Add( "DComboBox" )
	sortCombo:Dock( RIGHT )
	sortCombo:SetWide( S( 176 ) )
	sortCombo:DockMargin( S( 8 ), S( 2 ), 0, S( 2 ) )
	sortCombo:SetSortItems( false )
	sortCombo:SetValue( L( "sort_name" ) )
	sortCombo:AddChoice( L( "sort_name" ) )
	sortCombo:AddChoice( L( "sort_active" ) )
	sortCombo:AddChoice( L( "sort_size" ) )
	sortCombo:AddChoice( L( "sort_folder" ) )
	sortCombo:AddChoice( L( "sort_id" ) )
	StyleComboBox( sortCombo )
	sortCombo.OnSelect = function( _, index )
		SortType = index
		Menu.Populate()
	end

	local catCombo = row1:Add( "DComboBox" )
	catCombo:Dock( RIGHT )
	catCombo:SetWide( S( 186 ) )
	catCombo:DockMargin( S( 8 ), S( 2 ), 0, S( 2 ) )
	catCombo:SetSortItems( false )
	catCombo:SetValue( L( "type_all" ) )
	catCombo:AddChoice( L( "type_all" ) )
	for _, cat in pairs( ValidTypes ) do
		local lbl = GetCatLabel( cat )
		catCombo:AddChoice( ( lbl ~= cat ) and ( lbl .. " (" .. cat .. ")" ) or cat )
	end
	catCombo:AddChoice( L( "type_uncat" ) )
	StyleComboBox( catCombo )
	catCombo.OnSelect = function( _, index )
		if index == 1 then Selected_Cat = nil
		elseif index > 1 and index <= ( #ValidTypes + 1 ) then Selected_Cat = ValidTypes[index - 1]
		else Selected_Cat = "INVALID" end
		Menu.Populate()
	end

	local stateCombo = row1:Add( "DComboBox" )
	stateCombo:Dock( RIGHT )
	stateCombo:SetWide( S( 134 ) )
	stateCombo:DockMargin( S( 8 ), S( 2 ), 0, S( 2 ) )
	stateCombo:SetSortItems( false )
	stateCombo:SetValue( L( "state_all" ) )
	stateCombo:AddChoice( L( "state_all" ) )
	stateCombo:AddChoice( L( "state_on" ) )
	stateCombo:AddChoice( L( "state_off" ) )
	StyleComboBox( stateCombo )
	stateCombo.OnSelect = function( _, index )
		EnabledFilter = index - 1
		Menu.Populate()
	end

	Menu.AddonFilter = row1:Add( "DTextEntry" )
	Menu.AddonFilter:Dock( FILL )
	Menu.AddonFilter:DockMargin( 0, S( 2 ), 0, S( 2 ) )
	Menu.AddonFilter:SetUpdateOnType( true )
	StyleTextEntry( Menu.AddonFilter, L( "search_ph" ) )
	Menu.AddonFilter.OnEnter = function() end
	Menu.AddonFilter.OnValueChange = function()
		if timer.Exists( "lf_addon_manager_filter_refresh" ) then
			timer.Start( "lf_addon_manager_filter_refresh" )
		else
			timer.Create( "lf_addon_manager_filter_refresh", 0.12, 1, Menu.Populate )
		end
	end

	-- Row 2
	local row2 = Menu.Top:Add( "DPanel" )
	row2:Dock( TOP )
	row2:SetTall( S( 38 ) )
	row2:DockMargin( S( 12 ), 0, S( 12 ), S( 6 ) )
	row2.Paint = function() end

	local bSelAll = row2:Add( "DButton" )
	bSelAll:Dock( LEFT )
	bSelAll:SetWide( S( 90 ) )
	bSelAll:DockMargin( 0, S( 2 ), S( 6 ), S( 2 ) )
	StyleButton( bSelAll, L( "sel_all" ), "default" )
	bSelAll.DoClick = function()
		local DoSelect = false
		for _, v in pairs( AddonsReadable ) do
			if not Selected_Addons[v[1]] then DoSelect = true break end
		end
		for _, v in pairs( AddonsReadable ) do
			Selected_Addons[v[1]] = DoSelect and true or nil
		end
		last_selected = 1
		Menu.NoSelectedAddons.Count()
		Menu.Populate()
	end

	local bClearSel = row2:Add( "DButton" )
	bClearSel:Dock( LEFT )
	bClearSel:SetWide( S( 92 ) )
	bClearSel:DockMargin( 0, S( 2 ), S( 10 ), S( 2 ) )
	StyleButton( bClearSel, L( "sel_clear" ), "default" )
	bClearSel.DoClick = function()
		Selected_Addons = { }
		last_selected = 1
		Menu.NoSelectedAddons.Count()
		Menu.Populate()
	end

	Menu.NoSelectedAddons = row2:Add( "DLabel" )
	Menu.NoSelectedAddons:Dock( LEFT )
	Menu.NoSelectedAddons:SetWide( S( 110 ) )
	Menu.NoSelectedAddons:DockMargin( S( 2 ), S( 2 ), S( 8 ), S( 2 ) )
	Menu.NoSelectedAddons:SetFont( "SAM_Small" )
	Menu.NoSelectedAddons:SetTextColor( COL.accentHover )
	function Menu.NoSelectedAddons.Count()
		local No = tostring( #table.GetKeys( Selected_Addons ) )
		Menu.NoSelectedAddons:SetText( L( "sel_count", No ) )
	end
	Menu.NoSelectedAddons.Count()

	local bMore = row2:Add( "DButton" )
	bMore:Dock( RIGHT )
	bMore:SetWide( S( 116 ) )
	bMore:DockMargin( S( 6 ), S( 2 ), 0, S( 2 ) )
	StyleButton( bMore, L( "more_btn" ), "default" )
	bMore:SetIsMenu( true )
	local MoreMenu
	bMore.DoClick = function()
		if IsValid( MoreMenu ) then CloseDermaMenus() return end
		MoreMenu = CreateDarkMenu( Menu.MainPanel )
		MoreMenu:AddOption( L( "auto_cat_menu" ), AutoCategorizeUncategorized ):SetIcon( "icon16/wand.png" )
		MoreMenu:AddSpacer()
		MoreMenu:AddOption( L( "en_all" ), function() AddonToggleAll( true ) end ):SetIcon( "icon16/tick.png" )
		MoreMenu:AddOption( L( "dis_all" ), function() AddonToggleAll( false ) end ):SetIcon( "icon16/cross.png" )
		MoreMenu:AddSpacer()
		MoreMenu:AddOption( L( "vote_sel" ), AddonLikeSelected ):SetIcon( "icon16/thumb_up.png" )
		MoreMenu:AddOption( L( "uninst_sel" ), AddonDeleteSelected ):SetIcon( "icon16/bin.png" )
		MoreMenu:AddOption( L( "clear_notes_menu" ), AddonRemoveNotes ):SetIcon( "icon16/textfield_delete.png" )
		local sx, sy = bMore:LocalToScreen( 0, bMore:GetTall() + 2 )
		MoreMenu:Open( sx, sy )
	end

	local bMoveSel = row2:Add( "DButton" )
	bMoveSel:Dock( RIGHT )
	bMoveSel:SetWide( S( 156 ) )
	bMoveSel:DockMargin( S( 6 ), S( 2 ), 0, S( 2 ) )
	StyleButton( bMoveSel, L( "move_sel" ), "primary" )
	bMoveSel:SetIsMenu( true )
	bMoveSel.DoClick = function()
		local ids = table.GetKeys( Selected_Addons )
		if #ids < 1 then return end
		local m = OpenMoveMenu( Menu.MainPanel, ids )
		local sx, sy = bMoveSel:LocalToScreen( 0, bMoveSel:GetTall() + 2 )
		m:Open( sx, sy )
	end

	local bDisSel = row2:Add( "DButton" )
	bDisSel:Dock( RIGHT )
	bDisSel:SetWide( S( 116 ) )
	bDisSel:DockMargin( S( 6 ), S( 2 ), 0, S( 2 ) )
	StyleButton( bDisSel, L( "dis_sel" ), "danger" )
	bDisSel.DoClick = function() AddonToggleSelected( false ) end

	local bEnSel = row2:Add( "DButton" )
	bEnSel:Dock( RIGHT )
	bEnSel:SetWide( S( 116 ) )
	bEnSel:DockMargin( S( 6 ), S( 2 ), 0, S( 2 ) )
	StyleButton( bEnSel, L( "en_sel" ), "success" )
	bEnSel.DoClick = function() AddonToggleSelected( true ) end

	-- -------------------- Left Folder Tree Explorer Sidebar --------------------
	Menu.Left = Menu.MainPanel:Add( "DPanel" )
	Menu.Left:Dock( LEFT )
	Menu.Left:SetWide( S( 295 ) )
	Menu.Left:DockMargin( 0, 0, S( 12 ), 0 )
	Menu.Left:DockPadding( S( 12 ), S( 12 ), S( 12 ), S( 12 ) )
	Menu.Left.Paint = function( self, w, h )
		draw.RoundedBox( 6, 0, 0, w, h, COL.border )
		draw.RoundedBox( 5, 1, 1, w - 2, h - 2, COL.sidebar )
	end

	local sideHdr = Menu.Left:Add( "DPanel" )
	sideHdr:Dock( TOP )
	sideHdr:SetTall( S( 30 ) )
	sideHdr:DockMargin( 0, 0, 0, S( 8 ) )
	sideHdr.Paint = function() end

	local sideTitle = sideHdr:Add( "DLabel" )
	sideTitle:Dock( LEFT )
	sideTitle:SetFont( "SAM_ItemTitle" )
	sideTitle:SetText( L( "side_title" ) )
	sideTitle:SetTextColor( COL.text )
	sideTitle:SizeToContents()

	local bNewFolderSide = sideHdr:Add( "DButton" )
	bNewFolderSide:Dock( RIGHT )
	bNewFolderSide:SetWide( S( 104 ) )
	StyleButton( bNewFolderSide, L( "new_btn" ), "primary", "SAM_Small" )
	bNewFolderSide.DoClick = function()
		local base = ( CurrentScope ~= "__ALL__" and CurrentScope ~= "__ENABLED__" and CurrentScope ~= "__UNCAT__" ) and CurrentScope or ""
		CreateNewFolderDialog( base )
	end

	local bAutoCat = Menu.Left:Add( "DButton" )
	bAutoCat:Dock( BOTTOM )
	bAutoCat:SetTall( S( 34 ) )
	bAutoCat:DockMargin( 0, S( 8 ), 0, 0 )
	StyleButton( bAutoCat, L( "auto_cat_btn" ), "default", "SAM_Small" )
	bAutoCat.DoClick = AutoCategorizeUncategorized

	Menu.LeftScroll = Menu.Left:Add( "DScrollPanel" )
	Menu.LeftScroll:Dock( FILL )
	StyleScrollbar( Menu.LeftScroll )

	-- -------------------- Right Main Workspace --------------------
	local rightWrap = Menu.MainPanel:Add( "DPanel" )
	rightWrap:Dock( FILL )
	rightWrap.Paint = function( self, w, h )
		draw.RoundedBox( 6, 0, 0, w, h, COL.border )
		draw.RoundedBox( 5, 1, 1, w - 2, h - 2, COL.listBg )
	end

	Menu.BreadBar = rightWrap:Add( "DPanel" )
	Menu.BreadBar:Dock( TOP )
	Menu.BreadBar:SetTall( S( 46 ) )
	Menu.BreadBar:DockPadding( S( 12 ), S( 7 ), S( 12 ), S( 7 ) )
	Menu.BreadBar.Paint = function( self, w, h )
		draw.RoundedBoxEx( 5, 1, 1, w - 2, h - 1, COL.panel, true, true, false, false )
		surface.SetDrawColor( COL.border )
		surface.DrawLine( 1, h - 1, w - 1, h - 1 )
	end

	Menu.Scroll = rightWrap:Add( "DScrollPanel" )
	Menu.Scroll:Dock( FILL )
	Menu.Scroll:DockPadding( S( 10 ), S( 10 ), S( 8 ), S( 10 ) )
	StyleScrollbar( Menu.Scroll )

	-- -------------------- Populate Left Folder Tree --------------------
	function Menu.PopulateFolders()
		if not IsValid( Menu.LeftScroll ) then return end
		Menu.LeftScroll:Clear()

		local function AddTreeRow( scopeKey, label, depth, iconType, colorIdx, hasChildren, isExpanded )
			local total, active = ComputeFolderStats( scopeKey )
			local row = Menu.LeftScroll:Add( "DButton" )
			row:Dock( TOP )
			row:SetTall( S( 36 ) )
			row:DockMargin( 0, 0, S( 2 ), S( 4 ) )
			row:SetText( "" )

			local isCur = ( CurrentScope == scopeKey )
			row.Paint = function( self, w, h )
				local bg = isCur and COL.cardSel or ( self:IsHovered() and COL.cardHover or Color( 22, 28, 38, 255 ) )
				local bcol = isCur and COL.accent or COL.border
				draw.RoundedBox( 5, 0, 0, w, h, bcol )
				draw.RoundedBox( 4, 1, 1, w - 2, h - 2, bg )
				if isCur then
					surface.SetDrawColor( COL.accent )
					surface.DrawRect( 1, S( 5 ), S( 3 ), h - S( 10 ) )
				end

				local ix = S( 8 ) + depth * S( 16 )
				if hasChildren then
					local arrow = isExpanded and "▾" or "▸"
					DrawTextCentered( arrow, "SAM_Small", ix, 0, S( 14 ), h, COL.textSub )
				end
				ix = ix + ( depth > 0 and S( 16 ) or ( hasChildren and S( 16 ) or 0 ) )

				if iconType == "folder" then
					DrawFolderIcon( ix, math.Round( ( h - S( 16 ) ) * 0.5 ), S( 18 ), S( 16 ), colorIdx or 1 )
					ix = ix + S( 24 )
				elseif iconType == "all" then
					local sy = math.Round( ( h - S( 14 ) ) * 0.5 )
					draw.RoundedBox( 2, ix, sy, S( 6 ), S( 6 ), COL.accent )
					draw.RoundedBox( 2, ix + S( 8 ), sy, S( 6 ), S( 6 ), COL.accentHover )
					draw.RoundedBox( 2, ix, sy + S( 8 ), S( 6 ), S( 6 ), COL.accentHover )
					draw.RoundedBox( 2, ix + S( 8 ), sy + S( 8 ), S( 6 ), S( 6 ), COL.accent )
					ix = ix + S( 22 )
				elseif iconType == "uncat" then
					local sy = math.Round( ( h - S( 14 ) ) * 0.5 )
					draw.RoundedBox( 3, ix, sy, S( 15 ), S( 14 ), COL.borderLight )
					draw.RoundedBox( 2, ix + 2, sy + 2, S( 15 ) - 4, S( 14 ) - 6, COL.sidebar )
					ix = ix + S( 22 )
				else
					DrawTextCentered( iconType, "SAM_Small", ix, 0, S( 18 ), h, COL.green )
					ix = ix + S( 22 )
				end

				local cntTxt = string.format( "%d/%d", active, total )
				surface.SetFont( "SAM_Small" )
				local cw = surface.GetTextSize( cntTxt )
				local rightReserve = ( scopeKey ~= "__ENABLED__" ) and S( 34 ) or S( 8 )
				local badgeW = cw + S( 12 )
				local bx = w - rightReserve - badgeW
				draw.RoundedBox( 4, bx, math.Round( ( h - S( 22 ) ) * 0.5 ), badgeW, S( 22 ), COL.pill )
				DrawTextCentered( cntTxt, "SAM_Small", bx, 0, badgeW, h, active > 0 and COL.greenHover or COL.textMuted )

				local maxNameW = math.max( S( 40 ), bx - ix - S( 6 ) )
				local disp = TruncateText( label, "SAM_Body", maxNameW )
				DrawTextCentered( disp, "SAM_Body", ix, 0, maxNameW, h, isCur and COL.text or COL.textSub, true )
				return true
			end

			row.DoClick = function()
				CurrentScope = scopeKey
				Menu.PopulateFolders()
				Menu.Populate()
			end

			if scopeKey ~= "__ALL__" and scopeKey ~= "__ENABLED__" and scopeKey ~= "__UNCAT__" then
				row.DoRightClick = function()
					OpenFolderContextMenu( row, scopeKey )
				end
			end

			if hasChildren then
				local expBtn = row:Add( "DButton" )
				expBtn:SetPos( S( 6 ) + depth * S( 16 ), 0 )
				expBtn:SetSize( S( 18 ), S( 36 ) )
				expBtn:SetText( "" )
				expBtn.Paint = function() end
				expBtn.DoClick = function()
					if Folders[scopeKey] then
						Folders[scopeKey].expanded = not isExpanded
						Save()
						Menu.PopulateFolders()
					end
				end
			end

			if scopeKey ~= "__ENABLED__" and total > 0 then
				local allOn = ( active == total )
				local pwr = row:Add( "DButton" )
				pwr:SetPos( S( 242 ), math.Round( ( S( 36 ) - S( 20 ) ) * 0.5 ) )
				pwr:SetSize( S( 20 ), S( 20 ) )
				pwr:SetText( "" )
				pwr.Paint = function( self, w, h )
					local col = allOn and ( self:IsHovered() and COL.greenHover or COL.green ) or ( self:IsHovered() and COL.accent or Color( 55, 65, 81, 255 ) )
					DrawCirclePoly( math.Round( w * 0.5 ), math.Round( h * 0.5 ), S( 6 ), 16, col )
				end
				pwr.DoClick = function()
					ToggleFolderAddons( scopeKey, not allOn )
				end
				row.PerformLayout = function( self, rw )
					pwr:SetPos( rw - S( 26 ), math.Round( ( S( 36 ) - S( 20 ) ) * 0.5 ) )
				end
			end
		end

		AddTreeRow( "__ALL__", L( "tree_all" ), 0, "all", nil, false, false )
		AddTreeRow( "__ENABLED__", L( "tree_enabled" ), 0, "⚡", nil, false, false )
		AddTreeRow( "__UNCAT__", L( "tree_uncat" ), 0, "uncat", nil, false, false )

		local div = Menu.LeftScroll:Add( "DLabel" )
		div:Dock( TOP )
		div:SetTall( S( 24 ) )
		div:DockMargin( S( 4 ), S( 6 ), 0, S( 2 ) )
		div:SetFont( "SAM_Small" )
		div:SetText( L( "tree_hint_hdr" ) )
		div:SetTextColor( COL.textMuted )

		local sorted = GetSortedFolderPaths()
		if #sorted == 0 then
			local hint = Menu.LeftScroll:Add( "DLabel" )
			hint:Dock( TOP )
			hint:DockMargin( S( 6 ), S( 8 ), S( 6 ), 0 )
			hint:SetFont( "SAM_Small" )
			hint:SetText( L( "tree_empty_hint" ) )
			hint:SetTextColor( COL.textMuted )
			hint:SetWrap( true )
			hint:SetAutoStretchVertical( true )
			return
		end

		local childCount = { }
		for _, fp in ipairs( sorted ) do
			local par = GetParentFolder( fp )
			if par ~= "" then childCount[par] = ( childCount[par] or 0 ) + 1 end
		end

		for _, fp in ipairs( sorted ) do
			local visible = true
			local check = GetParentFolder( fp )
			while check ~= "" do
				if Folders[check] and Folders[check].expanded == false then
					visible = false
					break
				end
				check = GetParentFolder( check )
			end
			if visible then
				local fdata = Folders[fp] or { color = 1, expanded = true }
				AddTreeRow( fp, GetFolderBaseName( fp ), GetFolderDepth( fp ) - 1, "folder", fdata.color, ( childCount[fp] or 0 ) > 0, fdata.expanded ~= false )
			end
		end
	end

	-- -------------------- Populate Breadcrumb + Right Grid/Cards --------------------
	local function RebuildBreadcrumb( isSearching )
		Menu.BreadBar:Clear()

		local backBtn = Menu.BreadBar:Add( "DButton" )
		backBtn:Dock( LEFT )
		backBtn:SetWide( S( 92 ) )
		backBtn:DockMargin( 0, 0, S( 10 ), 0 )
		StyleButton( backBtn, L( "back_up" ), "ghost", "SAM_Small" )
		local canGoUp = ( CurrentScope ~= "__ALL__" and CurrentScope ~= "__ENABLED__" and CurrentScope ~= "__UNCAT__" )
		backBtn:SetEnabled( canGoUp )
		backBtn.DoClick = function()
			if not canGoUp then return end
			local p = GetParentFolder( CurrentScope )
			CurrentScope = ( p ~= "" ) and p or "__ALL__"
			Menu.PopulateFolders()
			Menu.Populate()
		end

		local crumbLbl = Menu.BreadBar:Add( "DLabel" )
		crumbLbl:Dock( FILL )
		crumbLbl:SetFont( "SAM_Body" )
		crumbLbl:SetTextColor( COL.text )
		if isSearching then
			crumbLbl:SetText( L( "crumb_search" ) )
		elseif CurrentScope == "__ALL__" then
			crumbLbl:SetText( L( "crumb_all" ) )
		elseif CurrentScope == "__ENABLED__" then
			crumbLbl:SetText( L( "crumb_enabled" ) )
		elseif CurrentScope == "__UNCAT__" then
			crumbLbl:SetText( L( "crumb_uncat" ) )
		else
			crumbLbl:SetText( L( "crumb_root" ) .. "  /  " .. string.Replace( CurrentScope, "/", "  /  " ) )
		end

		if not isSearching and CurrentScope ~= "__ENABLED__" then
			local bOffFolder = Menu.BreadBar:Add( "DButton" )
			bOffFolder:Dock( RIGHT )
			bOffFolder:SetWide( S( 104 ) )
			bOffFolder:DockMargin( S( 6 ), 0, 0, 0 )
			StyleButton( bOffFolder, L( "folder_off" ), "danger", "SAM_Small" )
			bOffFolder.DoClick = function() ToggleFolderAddons( CurrentScope, false ) end

			local bOnFolder = Menu.BreadBar:Add( "DButton" )
			bOnFolder:Dock( RIGHT )
			bOnFolder:SetWide( S( 104 ) )
			bOnFolder:DockMargin( S( 6 ), 0, 0, 0 )
			StyleButton( bOnFolder, L( "folder_on" ), "success", "SAM_Small" )
			bOnFolder.DoClick = function() ToggleFolderAddons( CurrentScope, true ) end

			if CurrentScope ~= "__ALL__" and CurrentScope ~= "__UNCAT__" then
				local bSub = Menu.BreadBar:Add( "DButton" )
				bSub:Dock( RIGHT )
				bSub:SetWide( S( 120 ) )
				bSub:DockMargin( S( 6 ), 0, 0, 0 )
				StyleButton( bSub, L( "sub_btn" ), "default", "SAM_Small" )
				bSub.DoClick = function() CreateNewFolderDialog( CurrentScope ) end
			end
		end
	end

	function Menu.Populate()
		if not IsValid( Menu.Scroll ) then return end
		Menu.Scroll:Clear()
		Menu.List = { }
		AddonsReadable = { }

		local AddonFilter = string.Trim( Menu.AddonFilter:GetValue() or "" )
		local isSearching = AddonFilter ~= ""
		RebuildBreadcrumb( isSearching )

		local showSubfolders = ( ViewMode == "folder" ) and ( not isSearching ) and ( CurrentScope == "__ALL__" or ( CurrentScope ~= "__ENABLED__" and CurrentScope ~= "__UNCAT__" ) )
		if showSubfolders then
			local children = GetImmediateChildFolders( CurrentScope )
			if #children > 0 then
				local secLbl = Menu.Scroll:Add( "DLabel" )
				secLbl:Dock( TOP )
				secLbl:SetTall( S( 26 ) )
				secLbl:DockMargin( S( 2 ), 0, 0, S( 8 ) )
				secLbl:SetFont( "SAM_Small" )
				secLbl:SetText( L( "subfolders_hdr", #children ) )
				secLbl:SetTextColor( COL.textSub )

				local gridContainer = Menu.Scroll:Add( "DPanel" )
				gridContainer:Dock( TOP )
				gridContainer:DockMargin( 0, 0, S( 4 ), S( 14 ) )
				gridContainer.Paint = function() end

				local folderCards = { }
				local cardH = S( 92 )
				local gap = S( 10 )

				for _, fpath in ipairs( children ) do
					local fdata = Folders[fpath] or { color = 1 }
					local pal = FOLDER_COLORS[fdata.color] or FOLDER_COLORS[1]
					local total, active, sizeBytes = ComputeFolderStats( fpath )
					local fname = GetFolderBaseName( fpath )

					local fcard = gridContainer:Add( "DButton" )
					fcard:SetText( "" )
					fcard.Paint = function( self, w, h )
						local bg = self:IsHovered() and COL.cardHover or COL.card
						local bcol = self:IsHovered() and pal.col or COL.border
						draw.RoundedBox( 6, 0, 0, w, h, bcol )
						draw.RoundedBox( 5, 1, 1, w - 2, h - 2, bg )
						surface.SetDrawColor( pal.col )
						surface.DrawRect( 1, 1, w - 2, S( 3 ) )

						DrawFolderIcon( S( 14 ), S( 16 ), S( 30 ), S( 26 ), fdata.color )

						local nameMaxW = math.max( S( 60 ), w - S( 120 ) )
						DrawTextCentered( TruncateText( fname, "SAM_ItemTitle", nameMaxW ), "SAM_ItemTitle", S( 54 ), S( 14 ), nameMaxW, S( 28 ), COL.text, true )

						local stLine = L( "folder_stats", active, total, FormatBytes( sizeBytes ) )
						DrawTextCentered( stLine, "SAM_Small", S( 14 ), S( 50 ), w - S( 28 ), S( 22 ), COL.textSub, true )

						local barY = h - S( 10 )
						local barW = w - S( 28 )
						draw.RoundedBox( 2, S( 14 ), barY, barW, S( 4 ), Color( 40, 50, 68, 255 ) )
						if total > 0 and active > 0 then
							local fillW = math.max( S( 4 ), math.Round( barW * ( active / total ) ) )
							draw.RoundedBox( 2, S( 14 ), barY, fillW, S( 4 ), COL.green )
						end
						return true
					end
					fcard.DoClick = function()
						CurrentScope = fpath
						Menu.PopulateFolders()
						Menu.Populate()
					end
					fcard.DoRightClick = function()
						OpenFolderContextMenu( fcard, fpath )
					end

					local fswW, fswH = S( 44 ), S( 22 )
					local fsw = fcard:Add( "DButton" )
					fsw:SetSize( fswW, fswH )
					fsw:SetText( "" )
					local allOn = ( total > 0 and active == total )
					fsw._anim = allOn and 1 or 0
					fsw.Paint = function( self, w, h )
						local target = allOn and 1 or 0
						self._anim = Lerp( math.min( 1, FrameTime() * 14 ), self._anim, target )
						local trackCol = allOn and ( self:IsHovered() and COL.greenHover or COL.green ) or ( active > 0 and Color( 217, 119, 6, 255 ) or ( self:IsHovered() and COL.borderLight or Color( 55, 65, 81, 255 ) ) )
						DrawPillPoly( 0, 0, w, h, trackCol )
						local pad = S( 3 )
						local r = ( h - pad * 2 ) * 0.5
						local knobCX = math.Round( pad + r + self._anim * ( w - ( pad + r ) * 2 ) )
						DrawCirclePoly( knobCX, math.Round( h * 0.5 ), math.Round( r ), 20, color_white )
					end
					fsw.DoClick = function()
						ToggleFolderAddons( fpath, not allOn )
					end

					table.insert( folderCards, { card = fcard, sw = fsw } )
				end

				gridContainer.PerformLayout = function( self, w )
					local cols = ( w >= S( 820 ) ) and 3 or ( ( w >= S( 480 ) ) and 2 or 1 )
					local cw = math.floor( ( w - gap * ( cols - 1 ) ) / cols )
					local rows = math.ceil( #folderCards / cols )
					for idx, item in ipairs( folderCards ) do
						local c = ( idx - 1 ) % cols
						local r = math.floor( ( idx - 1 ) / cols )
						item.card:SetPos( c * ( cw + gap ), r * ( cardH + gap ) )
						item.card:SetSize( cw, cardH )
						item.sw:SetPos( cw - S( 56 ), S( 16 ) )
					end
					self:SetTall( rows * cardH + math.max( 0, rows - 1 ) * gap )
				end
			end
		end

		local function MatchScope( v )
			if isSearching then return true end
			if CurrentScope == "__ALL__" then
				if ViewMode == "folder" and #table.GetKeys( Folders ) > 0 then
					return ( v.folder or "" ) == ""
				end
				return true
			elseif CurrentScope == "__ENABLED__" then
				return v.active == true
			elseif CurrentScope == "__UNCAT__" then
				return ( v.folder or "" ) == ""
			else
				if ViewMode == "folder" then
					return ( v.folder or "" ) == CurrentScope
				else
					return IsFolderOrChild( v.folder or "", CurrentScope )
				end
			end
		end

		local function MatchState( v )
			if EnabledFilter == 1 then return v.active == true end
			if EnabledFilter == 2 then return not v.active end
			return true
		end

		local function MatchCat( v )
			if Selected_Cat and Selected_Cat ~= v.cat then return false end
			return true
		end

		local function MatchSearch( k, v )
			if not isSearching then return true end
			local hay = v.title .. " " .. tostring( k ) .. " " .. ( v.folder or "" ) .. " " .. ( v.note or "" )
			for _, substr in pairs( string.Split( AddonFilter, " " ) ) do
				if substr ~= "" and not string.match( hay:lower(), string.PatternSafe( substr:lower() ) ) then
					return false
				end
			end
			return true
		end

		for k, v in pairs( Addons ) do
			if MatchScope( v ) and MatchState( v ) and MatchCat( v ) and MatchSearch( k, v ) then
				table.insert( AddonsReadable, {
					k,
					v.active and 1 or 0,
					v.title,
					v.folder or "",
					GetCatLabel( v.cat ),
					v.size or 0,
				} )
			end
		end

		table.sort( AddonsReadable, function( a, b )
			if SortType == 2 then
				if a[2] ~= b[2] then return a[2] > b[2] end
			elseif SortType == 3 then
				if a[6] ~= b[6] then return a[6] > b[6] end
			elseif SortType == 4 then
				local af, bf = string.lower( a[4] ), string.lower( b[4] )
				if af ~= bf then return af < bf end
			elseif SortType == 5 then
				return a[1] < b[1]
			end
			local a3, b3 = string.lower( a[3] ), string.lower( b[3] )
			if a3 ~= b3 then return a3 < b3 end
			return a[1] < b[1]
		end )

		local addonSecLbl = Menu.Scroll:Add( "DLabel" )
		addonSecLbl:Dock( TOP )
		addonSecLbl:SetTall( S( 26 ) )
		addonSecLbl:DockMargin( S( 2 ), 0, 0, S( 8 ) )
		addonSecLbl:SetFont( "SAM_Small" )
		local secTitle = L( "addons_hdr", #AddonsReadable )
		if ViewMode == "folder" and not isSearching and CurrentScope == "__ALL__" and #table.GetKeys( Folders ) > 0 then
			secTitle = L( "root_addons_hdr", #AddonsReadable )
		end
		addonSecLbl:SetText( secTitle )
		addonSecLbl:SetTextColor( COL.textSub )

		if #AddonsReadable == 0 then
			local emptyLbl = Menu.Scroll:Add( "DLabel" )
			emptyLbl:Dock( TOP )
			emptyLbl:SetTall( S( 72 ) )
			emptyLbl:SetFont( "SAM_Body" )
			emptyLbl:SetText( ( CurrentScope == "__ALL__" and not isSearching ) and L( "empty_all" ) or L( "empty_folder" ) )
			emptyLbl:SetTextColor( COL.textMuted )
			emptyLbl:SetContentAlignment( 5 )
			return
		end

		for k, v in ipairs( AddonsReadable ) do
			local id = v[1]
			local info = Addons[id]
			Menu.List[id] = { }

			local card = Menu.Scroll:Add( "DButton" )
			Menu.List[id].panel = card
			card:Dock( TOP )
			card:SetTall( S( 78 ) )
			card:DockMargin( S( 2 ), 0, S( 6 ), S( 8 ) )
			card:SetText( "" )
			card.index = k

			card.Paint = function( self, w, h )
				local isSel = Selected_Addons[id] == true
				local bg = isSel and COL.cardSel or ( self:IsHovered() and COL.cardHover or COL.card )
				local bcol = isSel and COL.accent or ( self:IsHovered() and COL.borderLight or COL.border )
				draw.RoundedBox( 6, 0, 0, w, h, bcol )
				draw.RoundedBox( 5, 1, 1, w - 2, h - 2, bg )

				local barCol = info.active and COL.green or COL.textMuted
				surface.SetDrawColor( barCol )
				surface.DrawRect( 1, S( 6 ), S( 4 ), h - S( 12 ) )
				return true
			end

			card.DoClick = function()
				if input.IsKeyDown( KEY_LSHIFT ) then
					local first = math.min( k, last_selected )
					local last = math.max( k, last_selected )
					local selectOn = not Selected_Addons[id]
					for idx = first, last do
						local line_id = AddonsReadable[idx][1]
						Selected_Addons[line_id] = selectOn and true or nil
					end
				else
					Selected_Addons[id] = ( not Selected_Addons[id] ) and true or nil
					last_selected = k
				end
				Menu.NoSelectedAddons.Count()
			end

			card.DoRightClick = function()
				local ContextMenu = CreateDarkMenu( card )
				ContextMenu:AddOption( info.active and L( "ctx_disable" ) or L( "ctx_enable" ), function()
					AddonSetActive( id, not info.active )
				end ):SetIcon( info.active and "icon16/cross.png" or "icon16/tick.png" )

				local moveSub = ContextMenu:AddSubMenu( L( "ctx_move" ) )
				moveSub:AddOption( L( "ctx_uncat" ), function() MoveAddonsToFolder( { id }, "" ) end )
				moveSub:AddSpacer()
				for _, fp in ipairs( GetSortedFolderPaths() ) do
					local indent = string.rep( "　", math.max( 0, GetFolderDepth( fp ) - 1 ) )
					moveSub:AddOption( indent .. "▸ " .. GetFolderBaseName( fp ), function()
						MoveAddonsToFolder( { id }, fp )
					end )
				end
				moveSub:AddSpacer()
				moveSub:AddOption( L( "ctx_new_move" ), function()
					PopupPrompt( L( "dlg_new_move_t" ), L( "dlg_new_move_ph" ), "", function( val )
						local np = NormalizeFolderPath( val )
						if np ~= "" then MoveAddonsToFolder( { id }, np ) end
					end )
				end )

				ContextMenu:AddSpacer()
				if id > 0 then
					ContextMenu:AddOption( L( "ctx_ws" ), function()
						gui.OpenURL( "https://steamcommunity.com/sharedfiles/filedetails/?id=" .. tostring( id ) )
					end ):SetIcon( "icon16/world_go.png" )
					ContextMenu:AddOption( L( "ctx_url" ), function()
						SetClipboardText( "https://steamcommunity.com/sharedfiles/filedetails/?id=" .. tostring( id ) )
					end ):SetIcon( "icon16/page_link.png" )
					ContextMenu:AddOption( L( "ctx_id" ), function()
						SetClipboardText( tostring( id ) )
					end ):SetIcon( "icon16/script_code.png" )
					ContextMenu:AddSpacer()
				end
				ContextMenu:AddOption( info.note and L( "ctx_note_edit" ) or L( "ctx_note_add" ), function()
					AddonSetNote( id )
				end ):SetIcon( "icon16/note_edit.png" )
				if info.note then
					ContextMenu:AddOption( L( "ctx_note_clear" ), function()
						info.note = nil
						GetAddons()
					end ):SetIcon( "icon16/note_delete.png" )
				end
				ContextMenu:Open()
			end

			local swW, swH = S( 50 ), S( 26 )
			local sw = card:Add( "DButton" )
			sw:SetPos( S( 16 ), math.Round( ( S( 78 ) - swH ) * 0.5 ) )
			sw:SetSize( swW, swH )
			sw:SetText( "" )
			sw._anim = info.active and 1 or 0
			sw.Paint = function( self, w, h )
				local target = info.active and 1 or 0
				self._anim = Lerp( math.min( 1, FrameTime() * 14 ), self._anim, target )
				local trackCol = info.active and ( self:IsHovered() and COL.greenHover or COL.green ) or ( self:IsHovered() and COL.borderLight or Color( 55, 65, 81, 255 ) )
				DrawPillPoly( 0, 0, w, h, trackCol )
				local pad = S( 3 )
				local r = ( h - pad * 2 ) * 0.5
				local knobCX = math.Round( pad + r + self._anim * ( w - ( pad + r ) * 2 ) )
				DrawCirclePoly( knobCX, math.Round( h * 0.5 ), math.Round( r ), 24, color_white )
			end
			sw.DoClick = function() AddonSetActive( id, not info.active ) end

			local moveBtn = card:Add( "DButton" )
			moveBtn:Dock( RIGHT )
			moveBtn:DockMargin( S( 4 ), S( 22 ), S( 12 ), S( 22 ) )
			moveBtn:SetWide( S( 78 ) )
			moveBtn:SetText( "" )
			moveBtn.Paint = function( self, w, h )
				local bg = self:IsHovered() and COL.btnHover or Color( 24, 31, 43, 255 )
				draw.RoundedBox( 6, 0, 0, w, h, COL.border )
				draw.RoundedBox( 5, 1, 1, w - 2, h - 2, bg )
				DrawFolderIcon( S( 10 ), math.Round( ( h - S( 13 ) ) * 0.5 ), S( 15 ), S( 13 ), 1 )
				DrawTextCentered( L( "btn_archive" ), "SAM_Small", S( 28 ), 0, w - S( 32 ), h, COL.textSub )
			end
			moveBtn.DoClick = function()
				local m = OpenMoveMenu( card, { id } )
				local sx, sy = moveBtn:LocalToScreen( 0, moveBtn:GetTall() + 2 )
				m:Open( sx, sy )
			end

			local noteBtn = card:Add( "DButton" )
			noteBtn:Dock( RIGHT )
			noteBtn:DockMargin( S( 4 ), S( 22 ), 0, S( 22 ) )
			noteBtn:SetWide( S( 68 ) )
			noteBtn:SetText( "" )
			noteBtn.Paint = function( self, w, h )
				local hasNote = ( info.note or "" ) ~= ""
				local bg = self:IsHovered() and COL.btnHover or ( hasNote and Color( 52, 38, 18, 255 ) or Color( 24, 31, 43, 255 ) )
				local bc = hasNote and Color( 245, 158, 11, 170 ) or COL.border
				draw.RoundedBox( 6, 0, 0, w, h, bc )
				draw.RoundedBox( 5, 1, 1, w - 2, h - 2, bg )
				DrawTextCentered( L( "btn_note" ), "SAM_Small", 0, 0, w, h, hasNote and Color( 251, 191, 36, 255 ) or COL.textSub )
			end
			noteBtn.DoClick = function()
				AddonSetNote( id )
			end

			local sizeText = FormatBytes( v[6] )
			local metaLbl = card:Add( "DLabel" )
			metaLbl:Dock( RIGHT )
			metaLbl:DockMargin( S( 8 ), S( 10 ), S( 10 ), S( 10 ) )
			metaLbl:SetWide( S( 205 ) )
			metaLbl:SetContentAlignment( 6 )
			metaLbl:SetFont( "SAM_Small" )
			metaLbl:SetText( string.format( "%s  ·  ID: %s", sizeText, id > 0 and tostring( id ) or L( "local_id" ) ) )
			metaLbl:SetTextColor( COL.textMuted )
			metaLbl:SetMouseInputEnabled( false )

			local titleLbl = card:Add( "DLabel" )
			titleLbl:SetPos( S( 80 ), S( 10 ) )
			titleLbl:SetSize( S( 440 ), S( 28 ) )
			titleLbl:SetFont( "SAM_ItemTitle" )
			titleLbl:SetText( v[3] )
			titleLbl:SetTextColor( info.active and COL.text or COL.textSub )
			titleLbl:SetWrap( false )
			titleLbl:SetMouseInputEnabled( false )

			local subRow = card:Add( "DPanel" )
			subRow:SetPos( S( 80 ), S( 42 ) )
			subRow:SetSize( S( 440 ), S( 26 ) )
			subRow:SetMouseInputEnabled( false )
			card.PerformLayout = function( self, w )
				local tw = math.max( S( 180 ), w - S( 472 ) )
				titleLbl:SetWide( tw )
				subRow:SetWide( tw )
			end
			subRow.Paint = function( self, w, h )
				local x = 0
				surface.SetFont( "SAM_Small" )

				local function DrawBadge( label, bgCol, fgCol )
					local tw = surface.GetTextSize( label )
					local bw = tw + S( 16 )
					if x + bw > w then return false end
					draw.RoundedBox( 4, x, 0, bw, h, bgCol )
					DrawTextCentered( label, "SAM_Small", x, 0, bw, h, fgCol )
					x = x + bw + S( 8 )
					return true
				end

				DrawBadge( v[5] or L( "type_uncat" ), COL.pill, COL.textSub )
				DrawBadge( info.active and L( "status_on" ) or L( "status_off" ), info.active and COL.greenBg or Color( 51, 65, 85, 90 ), info.active and COL.greenHover or COL.textMuted )

				if ( info.folder or "" ) ~= "" then
					local fdata = Folders[info.folder] or { color = 1 }
					local pal = FOLDER_COLORS[fdata.color] or FOLDER_COLORS[1]
					local tw = surface.GetTextSize( info.folder )
					local bw = tw + S( 34 )
					if x + bw <= w then
						draw.RoundedBox( 4, x, 0, bw, h, pal.bg )
						DrawFolderIcon( x + S( 7 ), math.Round( ( h - S( 12 ) ) * 0.5 ), S( 14 ), S( 12 ), fdata.color )
						DrawTextCentered( info.folder, "SAM_Small", x + S( 25 ), 0, tw + S( 4 ), h, pal.col, true )
						x = x + bw + S( 8 )
					end
				end

				if ( info.note or "" ) ~= "" then
					local noteStr = L( "note_prefix" ) .. info.note
					local maxAvail = w - x
					if maxAvail > S( 64 ) then
						local tw = surface.GetTextSize( noteStr )
						local bw = math.min( maxAvail, tw + S( 16 ) )
						local disp = TruncateText( noteStr, "SAM_Small", bw - S( 14 ) )
						draw.RoundedBox( 4, x, 0, bw, h, Color( 245, 158, 11, 34 ) )
						DrawTextCentered( disp, "SAM_Small", x, 0, bw, h, Color( 251, 191, 36, 255 ) )
					end
				end
			end
		end
	end

	Addons = nil
	GetAddons( true )
end

-- -------------------- Floating Non-Intrusive Main Menu Shortcut Pill --------------------
local function CreateMenuShortcut()
	if IsValid( Menu.Shortcut ) then return end
	local btn = vgui.Create( "DButton" )
	Menu.Shortcut = btn
	btn:SetSize( S( 164 ), S( 34 ) )
	btn:SetPos( math.max( 10, ScrW() - S( 182 ) ), S( 42 ) )
	btn:SetText( "" )
	btn:MakePopup()
	btn:SetKeyboardInputEnabled( false )
	btn.Paint = function( self, w, h )
		if IsInGame() or not gui.IsGameUIVisible() or IsValid( Menu.Frame ) then return end
		local bg = self:IsHovered() and COL.accent or Color( 20, 26, 36, 225 )
		local bc = self:IsHovered() and COL.accentHover or COL.borderLight
		draw.RoundedBox( 6, 0, 0, w, h, bc )
		draw.RoundedBox( 5, 1, 1, w - 2, h - 2, bg )
		DrawFolderIcon( S( 12 ), math.Round( ( h - S( 14 ) ) * 0.5 ), S( 16 ), S( 14 ), 1 )
		DrawTextCentered( L( "shortcut" ), "SAM_Small", S( 32 ), 0, w - S( 38 ), h, COL.text )
	end
	btn.Think = function( self )
		local show = ( not IsInGame() ) and gui.IsGameUIVisible() and ( not IsValid( Menu.Frame ) )
		self:SetMouseInputEnabled( show )
		self:SetPos( math.max( 10, ScrW() - S( 182 ) ), S( 42 ) )
		self:SetSize( S( 164 ), S( 34 ) )
	end
	btn.DoClick = function()
		Menu.Setup()
	end
end

hook.Add( "WorkshopEnd", "lf_addon_manager_wshook", function()
	WorkshopReady = true
	timer.Simple( 0.5, CreateMenuShortcut )
end )

timer.Simple( 2, function()
	if #( engine.GetAddons() or {} ) > 0 then
		WorkshopReady = true
		CreateMenuShortcut()
	end
end )

print( "Simple Addon Manager (Folder Pro UI + Bilingual) " .. Version .. " - Loaded." )

concommand.Add( "addon_manager", Menu.Setup )
concommand.Add( "addons", Menu.Setup )
