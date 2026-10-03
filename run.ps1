$ErrorActionPreference="Stop"

$Url = "https://raw.githubusercontent.com/laksina31/AlienxCMD-/main/Alienx_Setting_Free.bat"
$Bat = Join-Path $env:TEMP "Alienx_Setting_Free.bat"

Invoke-WebRequest -Uri $Url -OutFile $Bat
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$Bat`"" -Wait
Remove-Item $Bat -Force -ErrorAction SilentlyContinue