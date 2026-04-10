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
  @{ Name = 'home no longer renders intro card'; Ok = $homeHtml -notmatch 'Writing Index' -and $homeHtml -notmatch 'class=home-intro' },
  @{ Name = 'home no longer renders writing note panel'; Ok = $homeHtml -notmatch 'Writing Note' -and $homeHtml -notmatch 'sidebar-context-panel' },
  @{ Name = 'brand block keeps only the new site title'; Ok = $homeHtml -match "Koi&#39;s Blog|Koi's Blog" -and $homeHtml -notmatch '公开写作、短记录与日常思考' },
  @{ Name = 'post page renders on-this-page panel in sidebar'; Ok = $postHtml -match 'On This Page' -and $postHtml -match 'sidebar-context-panel' },
  @{ Name = 'post page no longer renders old article toc column'; Ok = $postHtml -notmatch 'article-toc' -and $postHtml -notmatch 'article-layout' }
)

$failed = $checks | Where-Object { -not $_.Ok }

if ($failed) {
  Write-Output 'Editorial layout checks failed:'
  $failed | ForEach-Object { "- $($_.Name)" }
  exit 1
}

Write-Output 'Editorial layout checks passed.'
