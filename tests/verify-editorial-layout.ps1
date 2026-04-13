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
$postsHtml = Get-Content -Path (Join-Path $outputDir 'posts\index.html') -Raw
$notesHtml = Get-Content -Path (Join-Path $outputDir 'notes\index.html') -Raw
$tagsHtml = Get-Content -Path (Join-Path $outputDir 'tags\index.html') -Raw
$aboutHtml = Get-Content -Path (Join-Path $outputDir 'about\index.html') -Raw
$postHtml = Get-Content -Path (Join-Path $outputDir 'posts\welcome-to-my-blog\index.html') -Raw
$cssFile = Get-ChildItem -Path (Join-Path $outputDir 'css') -Filter 'site*.css' | Select-Object -First 1
$cssText = if ($cssFile) { Get-Content -Path $cssFile.FullName -Raw } else { '' }
$tagDetailFile = Get-ChildItem -Path (Join-Path $outputDir 'tags') -Directory |
  Where-Object { $_.Name -notin @('page') } |
  Select-Object -First 1
$tagDetailHtml = if ($tagDetailFile) {
  Get-Content -Path (Join-Path $tagDetailFile.FullName 'index.html') -Raw
} else {
  ''
}

$themePages = @($homeHtml, $postsHtml, $notesHtml, $tagsHtml, $aboutHtml, $postHtml)
if ($tagDetailHtml) {
  $themePages += $tagDetailHtml
}

$oldNotesLabel = ([char]0x77ED).ToString() + ([char]0x8BB0).ToString()
$oldShortRecordLabel = ([char]0x77ED).ToString() + ([char]0x8BB0).ToString() + ([char]0x5F55).ToString()
$oldHomeIntro = "公开写作、$oldShortRecordLabel" + '与日常思考'

$aboutCountMatch = [regex]::Match($aboutHtml, 'article-meta><span>([0-9,]+) 字</span>')
$aboutCount = if ($aboutCountMatch.Success) {
  [int](($aboutCountMatch.Groups[1].Value) -replace ',', '')
} else {
  0
}

$postCountMatch = [regex]::Match($postHtml, 'article-meta><span>[^<]+</span>\s*<span>([0-9,]+) 字</span>')
$postCount = if ($postCountMatch.Success) {
  [int](($postCountMatch.Groups[1].Value) -replace ',', '')
} else {
  0
}

$homeCardCount = ([regex]::Matches($homeHtml, 'class="writing-item reading-card')).Count
$homeNoteCount = ([regex]::Matches($homeHtml, 'class="writing-item reading-card is-note')).Count

$checks = @(
  @{ Name = 'home uses card-based article layout'; Ok = $homeHtml -match 'class=reading-card' },
  @{ Name = 'home shows two recent entries per section'; Ok = $homeCardCount -eq 4 -and $homeNoteCount -eq 2 },
  @{ Name = 'notes display labels are renamed to diary'; Ok = $homeHtml -match '最近日记' -and $homeHtml -match '查看全部日记' -and $notesHtml -match '<h1>日记</h1>' -and $notesHtml -notmatch $oldNotesLabel },
  @{ Name = 'home exposes explicit read-more action'; Ok = $homeHtml -match 'class=reading-action' },
  @{ Name = 'sidebar uses separated editorial panels'; Ok = $homeHtml -match 'sidebar-brand-card' -and $homeHtml -match 'sidebar-nav-panel' },
  @{ Name = 'sidebar renders personal profile card'; Ok = ($themePages | Where-Object { $_ -match 'sidebar-profile-card' -and $_ -match 'profile-main' -and $_ -match 'profile-links' -and $_ -match '>koi<' -and $_ -match 'https://linux.do/u/koi_alkaid/summary' -and $_ -match 'profile/avatar.jpg' }).Count -eq $themePages.Count },
  @{ Name = 'home no longer renders intro card'; Ok = $homeHtml -notmatch 'Writing Index' -and $homeHtml -notmatch 'class=home-intro' },
  @{ Name = 'home no longer renders writing note panel'; Ok = $homeHtml -notmatch 'Writing Note' -and $homeHtml -notmatch 'sidebar-context-panel' },
  @{ Name = 'brand block keeps only the new site title'; Ok = $homeHtml -match "Koi&#39;s Blog|Koi's Blog" -and $homeHtml -notmatch $oldHomeIntro },
  @{ Name = 'posts list no longer renders visible section description'; Ok = $postsHtml -notmatch '<section class=page-header>.*?<p class=lede>' },
  @{ Name = 'notes list no longer renders visible section description'; Ok = $notesHtml -notmatch '<section class=page-header>.*?<p class=lede>' },
  @{ Name = 'tags page no longer renders visible description'; Ok = $tagsHtml -notmatch '<section class=page-header>.*?<p class=lede>' },
  @{ Name = 'listing cards only keep date in meta'; Ok = $homeHtml -match '<div class=writing-meta><span>[^<]+</span></div>' -and $postsHtml -match '<div class=writing-meta><span>[^<]+</span></div>' -and $notesHtml -match '<div class=writing-meta><span>[^<]+</span></div>' },
  @{ Name = 'listing cards no longer show feature or note badges'; Ok = $homeHtml -notmatch 'class=reading-label' -and $postsHtml -notmatch 'class=reading-label' -and $notesHtml -notmatch 'class=reading-label' },
  @{ Name = 'visible reading time removed from cards and pages'; Ok = ($themePages | Where-Object { $_ -notmatch '分钟阅读' }).Count -eq $themePages.Count },
  @{ Name = 'single pages now use full character count'; Ok = $aboutCount -gt 100 -and $postCount -gt 100 },
  @{ Name = 'theme toggle renders across audited pages'; Ok = ($themePages | Where-Object { $_ -match 'data-theme-toggle' }).Count -eq $themePages.Count },
  @{ Name = 'theme init script renders across audited pages'; Ok = ($themePages | Where-Object { $_ -match 'localStorage.getItem\("theme"\)' -and $_ -match 'data-theme=light' }).Count -eq $themePages.Count },
  @{ Name = 'post page renders on-this-page block in right-side aside'; Ok = $postHtml -match 'On This Page' -and $postHtml -match 'article-toc-aside' -and $postHtml -match 'article-toc-card' },
  @{ Name = 'post page toc is not rendered in sidebar'; Ok = $postHtml -notmatch 'sidebar-context-panel' },
  @{ Name = 'post page toc is not rendered before body inside main flow'; Ok = $postHtml -notmatch 'article-toc-block' },
  @{ Name = 'post page keeps independent article shell'; Ok = $postHtml -match 'article-page-shell' },
  @{ Name = 'toc aside uses sticky positioning'; Ok = $cssText -match '\.article-toc-aside\{[^}]*position:sticky[^}]*top:[^;}]+[^}]*' },
  @{ Name = 'toc card supports internal scrolling when long'; Ok = $cssText -match '\.article-toc-card\{[^}]*max-height:calc\(100vh - 4rem\)[^}]*overflow:auto' },
  @{ Name = 'toc card keeps visible card shadow'; Ok = $cssText -match '\.article-toc-card\{[^}]*box-shadow:var\(--shadow-card\)' }
)

$failed = $checks | Where-Object { -not $_.Ok }

if ($failed) {
  Write-Output 'Editorial layout checks failed:'
  $failed | ForEach-Object { "- $($_.Name)" }
  exit 1
}

Write-Output 'Editorial layout checks passed.'
