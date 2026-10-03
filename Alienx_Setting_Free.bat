<# :
@echo off
chcp 65001 >nul

:: ==============================================================================
::  [CONFIG] Right click -> Edit to change speed here:
::  Examples: 1MB, 2MB, 500KB, 100KB, 10KB, 1KB (or enter: 1, 2)
:: ==============================================================================
set SPEED=20KB

:: ==============================================================================
::  [LICENSE] Raw URL of the Pastebin that holds the key list (made by KeyGen)
::  Example: https://pastebin.com/raw/AbCd1234
:: ==============================================================================
set LICENSE_URL=https://pastebin.com/raw/bHQTm8HG

powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:ALIENX_BAT='%~f0'; $env:ALIENX_SPEED='%SPEED%'; $env:ALIENX_LICENSE_URL='%LICENSE_URL%'; Invoke-Expression ([System.IO.File]::ReadAllText('%~f0', [System.Text.Encoding]::UTF8))"
exit /b %errorlevel%
#>
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 1. Window Title
$Host.UI.RawUI.WindowTitle = "ALIENX"
[Console]::BackgroundColor = [ConsoleColor]::Black
[Console]::ForegroundColor = [ConsoleColor]::White

# 2. Window Size (63 columns x 23 rows)
try {
    $raw = $Host.UI.RawUI
    $size = New-Object System.Management.Automation.Host.Size(63, 23)
    $raw.CursorSize = 25
    if ($raw.WindowSize.Width -gt $size.Width) { $raw.WindowSize = New-Object System.Management.Automation.Host.Size($size.Width, $raw.WindowSize.Height) }
    if ($raw.WindowSize.Height -gt $size.Height) { $raw.WindowSize = New-Object System.Management.Automation.Host.Size($raw.WindowSize.Width, $size.Height) }
    $raw.BufferSize = $size
    $raw.WindowSize = $size
} catch {}

# 3. Win32 Lock Window
$win32 = @"
using System;
using System.Runtime.InteropServices;

public class Win32Window {
    [DllImport("kernel32.dll", ExactSpelling = true)]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern IntPtr GetSystemMenu(IntPtr hWnd, bool bRevert);

    [DllImport("user32.dll")]
    public static extern int DeleteMenu(IntPtr hMenu, uint nPosition, uint wFlags);

    [DllImport("user32.dll")]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

    [DllImport("user32.dll")]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

    [DllImport("user32.dll")]
    public static extern bool DrawMenuBar(IntPtr hWnd);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetStdHandle(int nStdHandle);

    [DllImport("kernel32.dll")]
    public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);

    [DllImport("kernel32.dll")]
    public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);

    [DllImport("user32.dll")]
    public static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);

    public const int STD_INPUT_HANDLE = -10;
    public const int GWL_STYLE = -16;
    public const int GWL_EXSTYLE = -20;
    public const int WS_EX_LAYERED = 0x00080000;
    public const uint LWA_ALPHA = 0x00000002;
    public const int WS_MAXIMIZEBOX = 0x00010000;
    public const int WS_SIZEBOX     = 0x00040000;
    public const int WS_THICKFRAME   = 0x00040000;
    public const uint SC_MAXIMIZE   = 0xF030;
    public const uint SC_SIZE       = 0xF000;
    public const uint MF_BYCOMMAND  = 0x00000000;

    public static void LockWindow() {
        IntPtr hwnd = GetConsoleWindow();
        if (hwnd == IntPtr.Zero) return;

        IntPtr sys = GetSystemMenu(hwnd, false);
        if (sys != IntPtr.Zero) {
            DeleteMenu(sys, SC_MAXIMIZE, MF_BYCOMMAND);
            DeleteMenu(sys, SC_SIZE, MF_BYCOMMAND);
            DrawMenuBar(hwnd);
        }

        int style = GetWindowLong(hwnd, GWL_STYLE);
        style &= ~(WS_MAXIMIZEBOX | WS_SIZEBOX | WS_THICKFRAME);
        SetWindowLong(hwnd, GWL_STYLE, style);
        SetWindowPos(hwnd, IntPtr.Zero, 0, 0, 0, 0, 0x0001 | 0x0002 | 0x0004 | 0x0020);

        int exStyle = GetWindowLong(hwnd, GWL_EXSTYLE);
        SetWindowLong(hwnd, GWL_EXSTYLE, exStyle | WS_EX_LAYERED);
        SetLayeredWindowAttributes(hwnd, 0, 215, LWA_ALPHA);

        IntPtr hIn = GetStdHandle(STD_INPUT_HANDLE);
        uint mode = 0;
        if (GetConsoleMode(hIn, out mode)) {
            mode &= ~((uint)0x0040 | (uint)0x0020 | (uint)0x0010);
            mode |= (uint)0x0080 | (uint)0x0001 | (uint)0x0002 | (uint)0x0004;
            SetConsoleMode(hIn, mode);
        }
    }
}
"@
try { Add-Type -TypeDefinition $win32 } catch {}
try { [Win32Window]::LockWindow() } catch {}

# ANSI Escape Codes Helper
$ESC = [char]27
function rgb($r, $g, $b) { return "$ESC[38;2;${r};${g};${b}m" }
function resetCol() { return "$ESC[0m$ESC[40m$ESC[37m" }

# ALIENX Logo
$S = [char]0x2588
$TL = [char]0x2554
$H = [char]0x2550
$TR = [char]0x2557
$V = [char]0x2551
$BL = [char]0x255A
$BR = [char]0x255D

$BANNER = @(
    "      $S$S$S$S$S$TR $S$S$TR     $S$S$TR$S$S$S$S$S$S$S$TR$S$S$S$TR   $S$S$TR$S$S$TR  $S$S$TR",
    "     $S$S$TL$H$H$S$S$TR$S$S$V     $S$S$V$S$S$TL$H$H$H$H$BR$S$S$S$S$TR  $S$S$V$BL$S$S$TR$S$S$TL$BR",
    "     $S$S$S$S$S$S$S$V$S$S$V     $S$S$V$S$S$S$S$S$TR  $S$S$TL$S$S$TR $S$S$V $BL$S$S$S$TL$BR ",
    "     $S$S$TL$H$H$S$S$V$S$S$V     $S$S$V$S$S$TL$H$H$BR  $S$S$V$BL$S$S$TR$S$S$V $S$S$TL$S$S$TR ",
    "     $S$S$V  $S$S$V$S$S$S$S$S$S$S$TR$S$S$V$S$S$S$S$S$S$S$TR$S$S$V $BL$S$S$S$S$V$S$S$TL$BR $S$S$TR",
    "     $BL$H$BR  $BL$H$BR$BL$H$H$H$H$H$H$BR$BL$H$BR$BL$H$H$H$H$H$H$BR$BL$H$BR  $BL$H$H$H$BR$BL$H$BR  $BL$H$BR"
)

function Get-BannerColor($t) {
    if ($t -le 0.0) { return @{r=20; g=70; b=220} }
    if ($t -ge 1.0) { return @{r=255; g=255; b=255} }

    $pts = @(
        @{t=0.00; r=20;  g=70;  b=220},
        @{t=0.25; r=40;  g=110; b=245},
        @{t=0.55; r=70;  g=150; b=255},
        @{t=0.80; r=170; g=205; b=255},
        @{t=1.00; r=255; g=255; b=255}
    )
    for ($i = 0; $i -lt $pts.Count - 1; $i++) {
        if ($t -ge $pts[$i].t -and $t -le $pts[$i+1].t) {
            $span = $pts[$i+1].t - $pts[$i].t
            $subT = ($t - $pts[$i].t) / $span
            $r = [Math]::Round($pts[$i].r + ($pts[$i+1].r - $pts[$i].r) * $subT)
            $g = [Math]::Round($pts[$i].g + ($pts[$i+1].g - $pts[$i].g) * $subT)
            $b = [Math]::Round($pts[$i].b + ($pts[$i+1].b - $pts[$i].b) * $subT)
            return @{r=$r; g=$g; b=$b}
        }
    }
    return @{r=255; g=255; b=255}
}

function Show-Banner() {
    [Console]::Write("$ESC[2J$ESC[H")
    [Console]::WriteLine()
    for ($i = 0; $i -lt $BANNER.Count; $i++) {
        $c = Get-BannerColor ($i / ($BANNER.Count - 1))
        [Console]::Write((rgb $c.r $c.g $c.b))
        [Console]::WriteLine($BANNER[$i])
    }
    [Console]::Write((resetCol))
    [Console]::WriteLine()
}

# ==============================================================================
#  GAME PROFILE CONTROLLER
# ==============================================================================

function Check-Admin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Init-QoS {
    try {
        $qosRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS"
        if (-not (Test-Path $qosRegPath)) {
            New-Item -Path $qosRegPath -Force | Out-Null
        }
        Set-ItemProperty -Path $qosRegPath -Name "Do not use NLA" -Value "1" -Type String -Force | Out-Null
        Set-ItemProperty -Path $qosRegPath -Name "Do not use NLA" -Value 1 -Type DWord -Force | Out-Null
    } catch {}
}

# Parse SPEED config from top of batch file
function Get-ConfiguredSpeed {
    $raw = $env:ALIENX_SPEED
    if ([string]::IsNullOrWhiteSpace($raw)) { $raw = "1MB" }
    $raw = $raw.Trim().ToUpper()

    $bps = 1000000
    if ($raw -match '^([0-9]+(\.[0-9]+)?)\s*MB?$') {
        $bps = [UInt64]([double]$matches[1] * 1000000)
    } elseif ($raw -match '^([0-9]+(\.[0-9]+)?)\s*KB?$') {
        $val = [double]$matches[1]
        if ($val -le 1) { $bps = 1024 } else { $bps = [UInt64]($val * 8000) }
    } elseif ($raw -match '^[0-9]+$') {
        $num = [UInt64]$raw
        if ($num -le 50) { $bps = [UInt64]($num * 1000000) } else { $bps = $num }
    }
    return @{ Label = $raw; Bps = $bps }
}

$cfg = Get-ConfiguredSpeed
$global:RateBps = $cfg.Bps
$global:SpeedLabel = $cfg.Label

$global:ProcessList = @(
    "FiveM.exe",
    "FiveM_GTAProcess.exe",
    "GTA5.exe",
    "FiveM_ChromeBrowser.exe",
    "FiveM_b2060_GTAProcess.exe",
    "FiveM_b2189_GTAProcess.exe",
    "FiveM_b2372_GTAProcess.exe",
    "FiveM_b2545_GTAProcess.exe",
    "FiveM_b2612_GTAProcess.exe",
    "FiveM_b2699_GTAProcess.exe",
    "FiveM_b2802_GTAProcess.exe",
    "FiveM_b2944_GTAProcess.exe",
    "FiveM_b3095_GTAProcess.exe",
    "FiveM_b3258_GTAProcess.exe",
    "FiveM_b3337_GTAProcess.exe",
    "FiveM_b3407_GTAProcess.exe"
)

function Get-ActiveTargets {
    $list = [System.Collections.Generic.List[string]]::new()
    foreach ($item in $global:ProcessList) {
        if (-not $list.Contains($item)) { [void]$list.Add($item) }
    }
    
    try {
        $running = Get-Process -ErrorAction SilentlyContinue | Where-Object { 
            $_.ProcessName -like "*FiveM*" -or 
            $_.ProcessName -like "*GTA*" 
        }
        foreach ($p in $running) {
            $name = $p.ProcessName + ".exe"
            if (-not $list.Contains($name)) {
                [void]$list.Add($name)
            }
            if (-not [string]::IsNullOrEmpty($p.Path)) {
                if (-not $list.Contains($p.Path)) {
                    [void]$list.Add($p.Path)
                }
            }
        }
    } catch {}
    return $list
}

function Get-ActiveState {
    try {
        $activePolicies = Get-NetQosPolicy -PolicyStore ActiveStore -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "GameOpt_*" }
        if ($activePolicies -and $activePolicies.Count -gt 0) {
            return $true
        }
    } catch {}
    try {
        $gpoPolicies = Get-NetQosPolicy -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "GameOpt_*" }
        if ($gpoPolicies -and $gpoPolicies.Count -gt 0) {
            return $true
        }
    } catch {}
    return $false
}

function Disable-Profile {
    try {
        $active = Get-NetQosPolicy -PolicyStore ActiveStore -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "GameOpt_*" }
        if ($active) {
            foreach ($p in $active) {
                Remove-NetQosPolicy -Name $p.Name -PolicyStore ActiveStore -Confirm:$false -ErrorAction SilentlyContinue
            }
        }
    } catch {}

    try {
        $local = Get-NetQosPolicy -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "GameOpt_*" }
        if ($local) {
            foreach ($p in $local) {
                Remove-NetQosPolicy -Name $p.Name -Confirm:$false -ErrorAction SilentlyContinue
            }
        }
    } catch {}
}

function Enable-Profile {
    param(
        [UInt64]$RateBps = $global:RateBps
    )

    Init-QoS
    Disable-Profile

    $targets = Get-ActiveTargets

    foreach ($target in $targets) {
        $cleanName = ($target -replace "[^a-zA-Z0-9_]", "_")
        if ($cleanName.Length -gt 50) { $cleanName = $cleanName.Substring($cleanName.Length - 50) }
        $pName = "GameOpt_" + $cleanName

        try {
            New-NetQosPolicy -Name $pName `
                             -NetworkProfile All `
                             -AppPathNameMatchCondition $target `
                             -IPProtocolMatchCondition Both `
                             -ThrottleRateActionBitsPerSecond $RateBps `
                             -PolicyStore ActiveStore `
                             -Confirm:$false `
                             -ErrorAction Stop | Out-Null
        } catch {}
    }

    try {
        New-NetQosPolicy -Name "GameOpt_Port_30120" `
                         -NetworkProfile All `
                         -IPPortMatchCondition 30120 `
                         -IPProtocolMatchCondition Both `
                         -ThrottleRateActionBitsPerSecond $RateBps `
                         -PolicyStore ActiveStore `
                         -Confirm:$false `
                         -ErrorAction Stop | Out-Null
    } catch {}
}

# Progress Bar
function Show-ProgressBar($title, $actionCompleteText, $doneMessage, [scriptblock]$action = $null) {
    $barWidth = 42
    $steps = 42
    $actionExecuted = $false
    for ($i = 0; $i -le $steps; $i++) {
        Show-Banner
        $pct = [Math]::Round(($i / $steps) * 100)

        [Console]::Write((rgb 90 160 255))
        [Console]::WriteLine("  $title")
        [Console]::WriteLine()

        [Console]::Write((rgb 70 140 255))
        [Console]::Write("  [")
        for ($j = 0; $j -lt $barWidth; $j++) {
            if ($j -lt $i) {
                $c = Get-BannerColor ($j / ($barWidth - 1))
                [Console]::Write((rgb $c.r $c.g $c.b) + "#")
            } else {
                [Console]::Write((rgb 25 40 75) + "-")
            }
        }
        [Console]::Write((rgb 70 140 255) + "]  ")
        [Console]::Write((rgb 255 255 255) + ("{0,3}%" -f $pct))
        [Console]::WriteLine()
        [Console]::WriteLine()

        if ($i -lt $steps) {
            $spins = @("|", "/", "-", "\")
            $spin = $spins[$i % 4]
            [Console]::Write((rgb 90 160 255) + "  $spin  " + (rgb 255 255 255) + "Loading...")
        } else {
            [Console]::Write((rgb 90 160 255) + "  |  " + (rgb 255 255 255) + "$actionCompleteText")
        }
        [Console]::Write((resetCol))

        if ($null -ne $action -and -not $actionExecuted -and $i -ge 20) {
            try { & $action } catch {}
            $actionExecuted = $true
        }

        Start-Sleep -Milliseconds 20
    }

    if ($null -ne $action -and -not $actionExecuted) {
        try { & $action } catch {}
    }

    Start-Sleep -Milliseconds 400

    Show-Banner
    [Console]::Write((rgb 255 255 255))
    [Console]::WriteLine("  $doneMessage")
    [Console]::WriteLine()
    [Console]::Write((rgb 90 160 255))
    [Console]::WriteLine("  Returning to menu...")
    [Console]::Write((resetCol))
    Start-Sleep -Milliseconds 1200
}

# ==============================================================================
#  NET CONTROL  (menu item 1 - START / RESET / CUSTOM value in real-time)
# ==============================================================================
$global:NetDefaultBps = 400000   # default value used by NET > START (0.4)
$global:NetRateBps = $global:NetDefaultBps

function Request-Admin {
    if (Check-Admin) { return $true }
    try {
        $batPath = $env:ALIENX_BAT
        if ([string]::IsNullOrEmpty($batPath)) { $batPath = "c:\Users\k\Downloads\NET\Alienx_Setting_Free.bat" }
        Start-Process cmd.exe -ArgumentList "/c `"`"$batPath`"`"" -Verb RunAs
        exit 0
    } catch {
        [Console]::WriteLine()
        [Console]::Write((rgb 255 65 75) + "  Please run as administrator!" + (resetCol))
        Start-Sleep -Milliseconds 1500
        return $false
    }
}

# Accepts: 0.5 | 1 | 1.5 | 500KB | 20KB | 2MB   (plain number <= 50 = MB, bigger = raw bps)
function ConvertTo-Bps($text) {
    if ([string]::IsNullOrWhiteSpace($text)) { return [UInt64]0 }
    $t = $text.Trim().ToUpper()
    if ($t -match '^([0-9]+(\.[0-9]+)?)\s*KB?$') {
        $v = [double]$matches[1]
        if ($v -le 0) { return [UInt64]0 }
        if ($v -le 1) { return [UInt64]1024 }
        return [UInt64]($v * 8000)
    }
    if ($t -match '^([0-9]+(\.[0-9]+)?)\s*(MB?)?$') {
        $v = [double]$matches[1]
        if ($v -le 0) { return [UInt64]0 }
        if ($matches[3] -or $v -le 50) { return [UInt64]($v * 1000000) }
        return [UInt64]$v
    }
    return [UInt64]0
}

function Format-Rate($bps) {
    return ("{0:0.###} MB" -f ([double]$bps / 1000000))
}

function Get-ActiveRate {
    try {
        $p = Get-NetQosPolicy -PolicyStore ActiveStore -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "GameOpt_*" } | Select-Object -First 1
        if ($p -and $p.ThrottleRateActionBitsPerSecond -gt 0) { return [UInt64]$p.ThrottleRateActionBitsPerSecond }
    } catch {}
    return [UInt64]0
}

function Show-Invalid($msg) {
    [Console]::WriteLine()
    [Console]::Write((rgb 255 65 75) + "  $msg" + (resetCol))
    Start-Sleep -Milliseconds 1000
}

function Apply-NetValue($bps) {
    $global:NetRateBps = $bps
    Show-ProgressBar "Applying value" "Complete" ("Value applied: " + (Format-Rate $bps)) {
        Enable-Profile -RateBps $global:NetRateBps
    }
}

function Show-NetMenu {
    while ($true) {
        try { [Win32Window]::LockWindow() } catch {}
        Show-Banner

        $isAdmin = Check-Admin
        $isActive = Get-ActiveState

        if (-not $isAdmin) {
            [Console]::WriteLine("  " + (rgb 70 140 255) + "STATUS: " + (rgb 255 180 50) + "RUN AS ADMIN REQUIRED")
        } elseif ($isActive) {
            $r = Get-ActiveRate
            $rt = ""
            if ($r -gt 0) { $rt = "  (" + (Format-Rate $r) + ")" }
            [Console]::WriteLine("  " + (rgb 120 120 120) + "STATUS: " + (rgb 80 230 100) + "ACTIVE" + (rgb 255 255 255) + $rt)
        } else {
            [Console]::WriteLine("  " + (rgb 120 120 120) + "STATUS: " + (rgb 140 165 210) + "DEFAULT")
        }
        [Console]::WriteLine()

        [Console]::WriteLine("  " + (rgb 70 140 255) + "[1]  " + (rgb 255 255 255) + "START   " + (rgb 120 120 120) + "CONFIG TO " + (Format-Rate $global:NetDefaultBps))
        [Console]::WriteLine("  " + (rgb 70 140 255) + "[2]  " + (rgb 255 255 255) + "RESET   " + (rgb 120 120 120) + "RESTORE ")
        [Console]::WriteLine("  " + (rgb 70 140 255) + "[3]  " + (rgb 255 255 255) + "CUSTOM  " + (rgb 120 120 120) + "SET YOUR OWN VALUE")
        [Console]::WriteLine()
        [Console]::WriteLine("  " + (rgb 70 140 255) + "[0]  " + (rgb 255 255 255) + "Back")
        [Console]::WriteLine()
        [Console]::Write((rgb 90 160 255) + "  Select mode: " + (rgb 255 255 255))
        [Console]::Write((resetCol))

        $choice = [Console]::ReadLine()
        if ($null -eq $choice) { return }
        $choice = $choice.Trim().ToUpper()
        Test-LicenseAlive

        switch ($choice) {
            { $_ -in "1", "START" } {
                if (-not (Request-Admin)) { continue }
                Apply-NetValue $global:NetDefaultBps
            }
            { $_ -in "2", "RESET" } {
                if (-not (Request-Admin)) { continue }
                Show-ProgressBar "Resetting profile" "Complete" "Reset completed successfully" {
                    Disable-Profile
                }
            }
            { $_ -in "3", "CUSTOM" } {
                if (-not (Request-Admin)) { continue }
                [Console]::WriteLine()
                [Console]::Write((rgb 90 160 255) + "  Value (e.g. 0.5, 1, 1.5, 500KB): " + (rgb 255 255 255))
                [Console]::Write((resetCol))
                $bps = ConvertTo-Bps ([Console]::ReadLine())
                if ($bps -gt 0) { Apply-NetValue $bps } else { Show-Invalid "Invalid value" }
            }
            { $_ -in "0", "BACK", "EXIT" } {
                return
            }
            default {
                # Typing a number directly (e.g. 0.5) applies it, like the original net profile
                $bps = ConvertTo-Bps $choice
                if ($bps -gt 0) {
                    if (-not (Request-Admin)) { continue }
                    Apply-NetValue $bps
                } else {
                    Show-Invalid "Invalid mode"
                }
            }
        }
    }
}

# Auto-elevate to Administrator on launch if not admin
$isAdmin = Check-Admin
if (-not $isAdmin) {
    try {
        $batPath = $env:ALIENX_BAT
        if ([string]::IsNullOrEmpty($batPath)) { $batPath = "c:\Users\k\Downloads\NET\Alienx_Setting_Free.bat" }
        $proc = Start-Process cmd.exe -ArgumentList "/c `"`"$batPath`"`"" -Verb RunAs -PassThru
        if ($null -ne $proc) {
            exit 0
        }
    } catch {}
}

# ==============================================================================
#  LICENSE  (key list hosted on Pastebin - URL comes from LICENSE_URL at the top)
#  List format, one per line:   sha256(KEY:HWID) | YYYY-MM-DD or LIFETIME
#  Nothing is uploaded: the tool only downloads the list and checks locally.
# ==============================================================================
function Get-Sha256Hex($s) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $bytes = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes([string]$s))
    return (($bytes | ForEach-Object { $_.ToString('x2') }) -join '')
}

function Get-Hwid {
    $parts = @()
    try { $parts += [string](Get-CimInstance Win32_ComputerSystemProduct -ErrorAction Stop).UUID } catch {}
    try { $parts += [string](Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1).ProcessorId } catch {}
    try { $parts += [string](Get-CimInstance Win32_BaseBoard -ErrorAction Stop | Select-Object -First 1).SerialNumber } catch {}
    if ($parts.Count -eq 0) { $parts = @($env:COMPUTERNAME) }
    $h = (Get-Sha256Hex (($parts -join '|') + '|ALIENX')).Substring(0, 16).ToUpper()
    return ($h -replace '(.{4})(?=.)', '$1-')
}

function Get-LicenseList($url) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 12 -Headers @{ 'User-Agent' = 'Mozilla/5.0'; 'Cache-Control' = 'no-cache' }
    if ($r.Content -is [byte[]]) { $text = [System.Text.Encoding]::UTF8.GetString($r.Content) } else { $text = [string]$r.Content }
    # Use the server's clock for expiry so changing the PC date does not help
    $now = [DateTime]::UtcNow
    try {
        $d = $r.Headers['Date']
        if ($d -is [array]) { $d = $d[0] }
        $now = [DateTime]::ParseExact([string]$d, 'r', [Globalization.CultureInfo]::InvariantCulture)
    } catch {}
    return @{ Text = $text; Now = $now }
}

function Test-LicenseKey($key, $hwid, $lic) {
    $hash = Get-Sha256Hex (($key.Trim().ToUpper()) + ':' + $hwid)
    foreach ($line in ($lic.Text -split "`r?`n")) {
        $l = $line.Trim().TrimStart([char]0xFEFF)
        if ($l -eq '' -or $l.StartsWith('#')) { continue }
        $p = $l.Split('|')
        if ($p[0].Trim().ToLower() -ne $hash) { continue }
        $exp = 'LIFETIME'
        if ($p.Count -gt 1) { $exp = $p[1].Trim().ToUpper() }
        if ($exp -eq 'LIFETIME') { return @{ Ok = $true; Msg = 'LIFETIME'; Expire = $null } }
        $e = ConvertTo-ExpiryUtc $exp
        if ($null -eq $e) { return @{ Ok = $false; Msg = 'Bad expiry date in key list' } }
        if ($lic.Now -le $e) { return @{ Ok = $true; Msg = 'OK'; Expire = $e } }
        return @{ Ok = $false; Msg = "Key expired ($exp UTC)" }
    }
    return @{ Ok = $false; Msg = 'Invalid key for this PC' }
}

# Expiry formats in the key list (UTC):  yyyy-MM-dd HH:mm   or   yyyy-MM-dd (valid until the end of that day)
function ConvertTo-ExpiryUtc($exp) {
    $inv = [Globalization.CultureInfo]::InvariantCulture
    try {
        if ($exp -match '^\d{4}-\d{2}-\d{2}$') { return ([DateTime]::ParseExact($exp, 'yyyy-MM-dd', $inv)).AddDays(1).AddSeconds(-1) }
        if ($exp -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$') { return [DateTime]::ParseExact($exp, 'yyyy-MM-dd HH:mm', $inv) }
    } catch {}
    return $null
}

function Format-Remaining($ts) {
    if ($ts.TotalDays -ge 1) { return ("{0}d {1}h left" -f [int][Math]::Floor($ts.TotalDays), $ts.Hours) }
    if ($ts.TotalHours -ge 1) { return ("{0}h {1}m left" -f [int][Math]::Floor($ts.TotalHours), $ts.Minutes) }
    return ("{0}m left" -f [Math]::Max(1, [int][Math]::Ceiling($ts.TotalMinutes)))
}

# "Now" according to the license server, kept ticking with a local stopwatch
function Get-LicenseNow { return $global:LicenseNowAtCheck.AddTicks($global:LicenseClock.Elapsed.Ticks) }

function Get-LicenseLabel {
    if ($null -eq $global:LicenseExpireUtc) { return "LIFETIME" }
    $left = $global:LicenseExpireUtc - (Get-LicenseNow)
    if ($left.TotalSeconds -lt 0) { return "EXPIRED" }
    $local = [DateTime]::SpecifyKind($global:LicenseExpireUtc, 'Utc').ToLocalTime().ToString('yyyy-MM-dd HH:mm', [Globalization.CultureInfo]::InvariantCulture)
    return ("until {0} ({1})" -f $local, (Format-Remaining $left))
}

# Called before every menu action: a key that runs out while the window is open stops working too
function Test-LicenseAlive {
    if ($null -eq $global:LicenseExpireUtc) { return }
    if ((Get-LicenseNow) -gt $global:LicenseExpireUtc) {
        try { Disable-Profile } catch {}
        Stop-License "License expired." "Your profile was reset. Ask the seller for a new key."
    }
}

function Stop-License($msg, $hint) {
    Show-Banner
    [Console]::WriteLine("  " + (rgb 255 65 75) + $msg + (resetCol))
    if ($hint) { [Console]::WriteLine("  " + (rgb 120 120 120) + $hint + (resetCol)) }
    [Console]::WriteLine()
    [Console]::Write((rgb 120 120 120) + "  Press Enter to exit..." + (resetCol))
    [void][Console]::ReadLine()
    exit 1
}

$global:LicenseExpireUtc = $null
$global:LicenseNowAtCheck = [DateTime]::UtcNow
$global:LicenseClock = [System.Diagnostics.Stopwatch]::StartNew()

function Invoke-LicenseCheck {
    $url = [string]$env:ALIENX_LICENSE_URL
    if ([string]::IsNullOrWhiteSpace($url) -or $url -match 'X{6,}') {
        Stop-License "License URL is not set." "Edit LICENSE_URL at the top of this file."
    }
    $url = $url.Trim()

    Show-Banner
    [Console]::WriteLine("  " + (rgb 90 160 255) + "Checking license..." + (resetCol))
    $hwid = Get-Hwid
    try { $lic = Get-LicenseList $url }
    catch { Stop-License "Cannot reach the license server." "Check your internet connection and try again." }

    # The key is asked on EVERY launch (nothing is remembered).
    # Also delete any key that an older version of this tool saved on this PC.
    Remove-Item (Join-Path $env:APPDATA "ALIENX\license.dat") -Force -ErrorAction SilentlyContinue
    $notice = ""

    for ($attempt = 1; $attempt -le 3; $attempt++) {
        Show-Banner
        [Console]::WriteLine("  " + (rgb 255 255 255) + "LICENSE REQUIRED")
        [Console]::WriteLine()
        [Console]::WriteLine("  " + (rgb 120 120 120) + "HWID  " + (rgb 90 160 255) + $hwid)
        [Console]::WriteLine("  " + (rgb 120 120 120) + "Send your HWID to the seller to get a key." + (resetCol))
        [Console]::WriteLine()
        if ($notice) { [Console]::WriteLine("  " + (rgb 255 65 75) + $notice + (resetCol)) } else { [Console]::WriteLine() }
        [Console]::Write((rgb 90 160 255) + "  Enter key: " + (rgb 255 255 255))
        [Console]::Write((resetCol))
        $key = [Console]::ReadLine()
        if ($null -eq $key) { exit 1 }
        if ([string]::IsNullOrWhiteSpace($key)) { $notice = "Please enter your key"; continue }

        $res = Test-LicenseKey $key $hwid $lic
        if ($res.Ok) {
            $global:LicenseExpireUtc = $res.Expire
            $global:LicenseNowAtCheck = $lic.Now
            $global:LicenseClock = [System.Diagnostics.Stopwatch]::StartNew()
            return
        }
        $notice = $res.Msg
    }
    Stop-License "Too many invalid attempts." ""
}

Invoke-LicenseCheck

# Main Menu Loop
while ($true) {
    try { [Win32Window]::LockWindow() } catch {}
    Show-Banner

    $isAdmin = Check-Admin
    $isActive = Get-ActiveState

    if (-not $isAdmin) {
        [Console]::WriteLine("  " + (rgb 70 140 255) + "STATUS: " + (rgb 255 180 50) + "RUN AS ADMIN REQUIRED")
    } elseif ($isActive) {
        [Console]::WriteLine("  " + (rgb 120 120 120) + "STATUS: " + (rgb 80 230 100) + "ACTIVE")
    } else {
        [Console]::WriteLine("  " + (rgb 120 120 120) + "STATUS: " + (rgb 140 165 210) + "DEFAULT")
    }
    [Console]::WriteLine("  " + (rgb 120 120 120) + "LICENSE: " + (rgb 255 255 255) + (Get-LicenseLabel))
    [Console]::WriteLine()

    [Console]::WriteLine("  " + (rgb 70 140 255) + "[1]  " + (rgb 255 255 255) + "NET CONTROL  " + (rgb 120 120 120) + "start / reset / custom")
    [Console]::WriteLine()
    [Console]::WriteLine("  " + (rgb 70 140 255) + "[0]  " + (rgb 255 255 255) + "Exit")
    [Console]::WriteLine()
    [Console]::Write((rgb 90 160 255) + "  Select mode: " + (rgb 255 255 255))
    [Console]::Write((resetCol))

    $choice = [Console]::ReadLine()
    if ($null -eq $choice) { break }
    $choice = $choice.Trim().ToUpper()
    Test-LicenseAlive

    switch ($choice) {
        { $_ -in "1", "NET" } {
            Show-NetMenu
        }
        { $_ -in "0", "EXIT" } {
            [Console]::Write((resetCol))
            exit 0
        }
        default {
            [Console]::WriteLine()
            [Console]::Write((rgb 255 65 75) + "  Invalid mode" + (resetCol))
            Start-Sleep -Milliseconds 800
        }
    }
}
