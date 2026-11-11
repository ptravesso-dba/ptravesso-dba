# Gera assets/avatar.png (1000x1000) a partir de assets/avatar.svg com o Edge sem janela.
# Uso: perl build.pl; powershell -File render-avatar.ps1
$ErrorActionPreference = 'Continue'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$tmp = Join-Path $env:TEMP 'ptravesso-avatar-render'
New-Item -ItemType Directory -Force $tmp | Out-Null
$svg = (Join-Path $root 'assets\avatar.svg').Replace('\', '/')
$html = Join-Path $tmp 'avatar.html'
Set-Content -Encoding utf8 $html "<!doctype html><html><head><meta charset=utf-8><style>html,body{margin:0;width:1000px;height:1000px;overflow:hidden;background:#0c0a09}img{display:block;width:1000px;height:1000px}</style></head><body><img src='file:///$svg'></body></html>"
$dest = Join-Path $root 'assets\avatar.png'
& $edge --headless=new --disable-gpu --hide-scrollbars --allow-file-access-from-files `
  "--user-data-dir=$tmp\profile" '--window-size=1000,1000' --virtual-time-budget=5000 `
  "--screenshot=$dest" ('file:///' + $html.Replace('\', '/')) 2>$null | Out-Null
Start-Sleep -Milliseconds 500
if (-not (Test-Path $dest)) { throw 'nao gerou avatar.png' }
Write-Output ('assets\avatar.png: {0} bytes' -f (Get-Item $dest).Length)
