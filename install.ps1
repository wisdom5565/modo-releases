# MODO 설치·업데이트 (윈도). PowerShell로 받으면 SmartScreen '인터넷에서 받은 파일' 표시가 붙지 않는다 (#2)
#   irm https://raw.githubusercontent.com/wisdom5565/modo-releases/main/install.ps1 | iex
# - 받는 곳은 modo-releases의 최신 릴리스뿐이다. 받은 설치 파일은 릴리스의 SHA256SUMS.txt와 맞춰 보고, 다르면 실행하지 않는다
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'  # 진행 표시가 있으면 받기가 아주 느려진다

$repo = 'wisdom5565/modo-releases'
$dl = "https://github.com/$repo/releases/download/"
$rel = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest" -Headers @{ 'User-Agent' = 'modo-install' }
$exe = $rel.assets | Where-Object { $_.name -match '^MODO-Setup-\d+\.\d+\.\d+\.exe$' } | Select-Object -First 1
$sums = $rel.assets | Where-Object { $_.name -eq 'SHA256SUMS.txt' } | Select-Object -First 1
if (-not $exe -or -not $sums) { throw '최신 릴리스에서 설치 파일이나 SHA256SUMS.txt를 찾지 못했어요.' }
# 다른 주소에서는 받지 않는다
foreach ($a in @($exe, $sums)) { if (-not $a.browser_download_url.StartsWith($dl)) { throw "예상한 주소가 아니에요: $($a.browser_download_url)" } }

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("modo-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
  $file = Join-Path $tmp $exe.name
  $sumFile = Join-Path $tmp 'SHA256SUMS.txt'
  Write-Host "MODO $($rel.tag_name) 받는 중… ($($exe.name))"
  Invoke-WebRequest $exe.browser_download_url -OutFile $file -UseBasicParsing
  Invoke-WebRequest $sums.browser_download_url -OutFile $sumFile -UseBasicParsing

  $want = ''
  foreach ($line in Get-Content $sumFile) {
    $p = $line.Trim() -split '\s+', 2
    if ($p.Count -eq 2 -and $p[1].TrimStart('*') -eq $exe.name) { $want = $p[0].ToLower() }
  }
  $got = (Get-FileHash $file -Algorithm SHA256).Hash.ToLower()
  if (-not $want -or $want -ne $got) { throw '받은 파일이 릴리스와 달라서 설치하지 않았어요. 잠시 뒤 다시 해 보거나 릴리스 페이지에서 받아 주세요.' }

  Start-Process -FilePath $file -Wait
  Write-Host 'MODO 설치 창을 마쳤어요.'
} finally {
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
