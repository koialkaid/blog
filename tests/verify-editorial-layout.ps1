param(
  [string]$BaseUrl = 'https://koialkaid.github.io/blog/',
  [string]$HugoPath = 'hugo'
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$outputDir = Join-Path $env:TEMP 'ly-blog-editorial-layout-check'

if (Test-Path $outputDir) {
  Remove-Item -LiteralPath $outputDir -Recurse -Force
}

& $HugoPath --gc --minify --cleanDestinationDir --baseURL $BaseUrl --destination $outputDir | Out-Null

if ($LASTEXITCODE -ne 0) {
  throw "Hugo build failed with exit code $LASTEXITCODE."
}

$homeHtml = Get-Content -Path (Join-Path $outputDir 'index.html') -Raw
$postHtml = Get-Content -Path (Join-Path $outputDir 'posts\welcome-to-my-blog\index.html') -Raw

$checks = @(
  @{ Name = 'home uses card-based article layout'; Ok = $homeHtml -match 'class=reading-card' },
  @{ Name = 'home exposes explicit read-more action'; Ok = $homeHtml -match 'class=reading-action' },
  @{ Name = 'sidebar uses separated editorial panels'; Ok = $homeHtml -match 'sidebar-brand-card' -and $homeHtml -match 'sidebar-nav-panel' },
  @{ Name = 'post page renders article toc block'; Ok = $postHtml -match 'article-toc' }
)

$failed = $checks | Where-Object { -not $_.Ok }

if ($failed) {
  Write-Output 'Editorial layout checks failed:'
  $failed | ForEach-Object { "- $($_.Name)" }
  exit 1
}

Write-Output 'Editorial layout checks passed.'
