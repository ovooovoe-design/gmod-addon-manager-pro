$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$srcLua = Join-Path $repoRoot 'garrysmod\lua\menu\lf_simple_addon_manager.lua'
if (-not (Test-Path -LiteralPath $srcLua)) {
    Write-Host '[ERROR] Missing garrysmod\lua\menu\lf_simple_addon_manager.lua' -ForegroundColor Red
    exit 1
}

function Find-GModDirectory {
    $libs = New-Object System.Collections.Generic.List[string]
    $reg = (Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction SilentlyContinue).SteamPath
    if ($reg) { $libs.Add(($reg -replace '/', '\')) }
    $libs.Add('C:\Program Files (x86)\Steam')
    $libs.Add('C:\Program Files\Steam')
    $libs.Add('D:\Steam')
    $libs.Add('D:\steam')

    $expanded = New-Object System.Collections.Generic.List[string]
    foreach ($lib in $libs) {
        if ($lib -and (Test-Path -LiteralPath $lib)) {
            $expanded.Add($lib)
            $vdf = Join-Path $lib 'steamapps\libraryfolders.vdf'
            if (Test-Path -LiteralPath $vdf) {
                $vdfRaw = Get-Content -LiteralPath $vdf -Raw -Encoding UTF8
                foreach ($m in [regex]::Matches($vdfRaw, '"path"\s+"([^"]+)"')) {
                    $expanded.Add(($m.Groups[1].Value -replace '\\\\', '\'))
                }
            }
        }
    }

    foreach ($base in ($expanded | Select-Object -Unique)) {
        $gm = Join-Path $base 'steamapps\common\GarrysMod'
        if (Test-Path -LiteralPath (Join-Path $gm 'garrysmod\lua\menu\menu.lua')) {
            return $gm
        }
    }
    return $null
}

$gmod = Find-GModDirectory
if ($gmod) {
    Write-Host ("Detected Garry's Mod: " + $gmod) -ForegroundColor Cyan
} else {
    Write-Host "Could not auto-detect Garry's Mod folder." -ForegroundColor Yellow
}

$inputPath = Read-Host 'Press ENTER to confirm detected path, or paste your GarrysMod folder path'
if ($inputPath.Trim() -ne '') {
    $gmod = $inputPath.Trim().Trim('"')
}

$menuLua = Join-Path $gmod 'garrysmod\lua\menu\menu.lua'
if (-not $gmod -or -not (Test-Path -LiteralPath $menuLua)) {
    Write-Host '[ERROR] Invalid GarrysMod directory (garrysmod\lua\menu\menu.lua not found).' -ForegroundColor Red
    exit 1
}

$dstMenuDir = Join-Path $gmod 'garrysmod\lua\menu'
$dstLua = Join-Path $dstMenuDir 'lf_simple_addon_manager.lua'
Copy-Item -LiteralPath $srcLua -Destination $dstLua -Force

$menuRaw = [System.IO.File]::ReadAllText($menuLua, [System.Text.Encoding]::UTF8)
if ($menuRaw -notmatch 'lf_simple_addon_manager\.lua') {
    Copy-Item -LiteralPath $menuLua -Destination ($menuLua + '.bak') -Force
    $trimmed = $menuRaw.TrimEnd([char[]]@([char]13, [char]10))
    $updated = $trimmed + "`r`n`r`ninclude( `"lf_simple_addon_manager.lua`" )`r`n"
    [System.IO.File]::WriteAllText($menuLua, $updated, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host 'Updated menu.lua (backup saved as menu.lua.bak).' -ForegroundColor Green
} else {
    Write-Host 'menu.lua already includes lf_simple_addon_manager.lua.' -ForegroundColor Green
}

Write-Host "[DONE] Installed GMod Addon Manager Pro v3.1.0! Please restart Garry's Mod." -ForegroundColor Green
