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
$seriesHtml = if (Test-Path (Join-Path $outputDir 'series\index.html')) {
  Get-Content -Path (Join-Path $outputDir 'series\index.html') -Raw
} else {
  ''
}
$seriesDetailFile = Get-ChildItem -Path (Join-Path $outputDir 'series') -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -notin @('page') } |
  Select-Object -First 1
$agentSeriesHtml = if ($seriesDetailFile -and (Test-Path (Join-Path $seriesDetailFile.FullName 'index.html'))) {
  Get-Content -Path (Join-Path $seriesDetailFile.FullName 'index.html') -Raw
} else {
  ''
}
$agentArticleHtml = if (Test-Path (Join-Path $outputDir 'posts\agent-learning-01-what-is-agent\index.html')) {
  Get-Content -Path (Join-Path $outputDir 'posts\agent-learning-01-what-is-agent\index.html') -Raw
} else {
  ''
}
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
$agentSeriesOrderOk = $agentSeriesHtml -match 'Agent 学习 01[\s\S]*Agent 学习 02[\s\S]*Agent 学习 03'
$sidebarOrderOk = $homeHtml -match 'sidebar-brand-card[\s\S]*sidebar-profile-card[\s\S]*sidebar-nav-panel'
$navOrderOk = $homeHtml -match '<span>首页</span>[\s\S]*<span>文章</span>[\s\S]*<span>日记</span>[\s\S]*<span>系列</span>[\s\S]*<span>标签</span>[\s\S]*<span>About</span>[\s\S]*<span>RSS</span>'

$checks = @(
  @{ Name = 'home uses card-based article layout'; Ok = $homeHtml -match 'class=reading-card' },
  @{ Name = 'home shows two recent entries per section'; Ok = $homeCardCount -eq 4 -and $homeNoteCount -eq 2 },
  @{ Name = 'notes display labels are renamed to diary'; Ok = $homeHtml -match '最近日记' -and $homeHtml -match '查看全部日记' -and $notesHtml -match '<h1>日记</h1>' -and $notesHtml -notmatch $oldNotesLabel },
  @{ Name = 'home exposes explicit read-more action'; Ok = $homeHtml -match 'class=reading-action' },
  @{ Name = 'sidebar uses separated editorial panels'; Ok = $homeHtml -match 'sidebar-brand-card' -and $homeHtml -match 'sidebar-nav-panel' },
  @{ Name = 'profile card is placed between brand and nav'; Ok = $sidebarOrderOk },
  @{ Name = 'sidebar nav orders series before tags'; Ok = $navOrderOk },
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
  @{ Name = 'post page renders on-this-page block in right-side aside'; Ok = $postHtml -match 'On This Page' -and $postHtml -match 'article-aside' -and $postHtml -match 'article-toc-card' },
  @{ Name = 'post page toc is not rendered in sidebar'; Ok = $postHtml -notmatch 'sidebar-context-panel' },
  @{ Name = 'post page toc is not rendered before body inside main flow'; Ok = $postHtml -notmatch 'article-toc-block' },
  @{ Name = 'post page keeps independent article shell'; Ok = $postHtml -match 'article-page-shell' },
  @{ Name = 'toc aside uses sticky positioning'; Ok = $cssText -match '\.article-aside\{[^}]*position:sticky[^}]*top:[^;}]+[^}]*' },
  @{ Name = 'toc card supports internal scrolling when long'; Ok = $cssText -match '\.article-aside\{[^}]*max-height:calc\(100vh - 4rem\)[^}]*overflow:auto' },
  @{ Name = 'toc and series cards keep visible card shadow'; Ok = $cssText -match '\.article-toc-card,\s*\.series-reading-card\{[^}]*box-shadow:var\(--shadow-card\)' },
  @{ Name = 'series index page exists and lists agent learning'; Ok = $seriesHtml -match '<h1>系列</h1>' -and $seriesHtml -match 'Agent 学习' },
  @{ Name = 'agent learning series page sorts entries by series order'; Ok = $agentSeriesOrderOk },
  @{ Name = 'series article shows series metadata'; Ok = $agentArticleHtml -match '系列：Agent 学习' -and $agentArticleHtml -match '第 1 篇' },
  @{ Name = 'series article shows full series list card in aside'; Ok = $agentArticleHtml -match 'series-reading-card' -and $agentArticleHtml -match 'Agent 学习 01' -and $agentArticleHtml -match 'Agent 学习 02' -and $agentArticleHtml -match 'Agent 学习 03' -and $agentArticleHtml -match '查看系列' },
  @{ Name = 'series reading is removed from article main'; Ok = $agentArticleHtml -notmatch '<div class=article-main>[\s\S]*<section class=series-reading' },
  @{ Name = 'series reading marks current article'; Ok = $agentArticleHtml -match '<em>当前</em>' },
  @{ Name = 'non-series article does not render series block'; Ok = $postHtml -notmatch 'series-reading-card' -and $postHtml -notmatch '系列：' }
)

$failed = $checks | Where-Object { -not $_.Ok }

if ($failed) {
  Write-Output 'Editorial layout checks failed:'
  $failed | ForEach-Object { "- $($_.Name)" }
  exit 1
}

Write-Output 'Editorial layout checks passed.'
