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

Push-Location $repoRoot
try {
  & $HugoPath --gc --minify --cleanDestinationDir --baseURL $BaseUrl --destination $outputDir | Out-Null
  if ($LASTEXITCODE -ne 0) {
    throw "Hugo build failed with exit code $LASTEXITCODE."
  }
}
finally {
  Pop-Location
}

$homeHtml = Get-Content -Path (Join-Path $outputDir 'index.html') -Raw
$postsHtml = Get-Content -Path (Join-Path $outputDir 'posts\index.html') -Raw
$notesHtml = Get-Content -Path (Join-Path $outputDir 'notes\index.html') -Raw
$tagsHtml = Get-Content -Path (Join-Path $outputDir 'tags\index.html') -Raw
$aboutHtml = Get-Content -Path (Join-Path $outputDir 'about\index.html') -Raw
$todoHtml = if (Test-Path (Join-Path $outputDir 'todo\index.html')) {
  Get-Content -Path (Join-Path $outputDir 'todo\index.html') -Raw
} else {
  ''
}
$postDetailFiles = Get-ChildItem -Path (Join-Path $outputDir 'posts') -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -notin @('page') }
$noteDetailFiles = Get-ChildItem -Path (Join-Path $outputDir 'notes') -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -notin @('page') }
$postDetailFile = $postDetailFiles | Select-Object -First 1
$postHtml = if ($postDetailFile -and (Test-Path (Join-Path $postDetailFile.FullName 'index.html'))) {
  Get-Content -Path (Join-Path $postDetailFile.FullName 'index.html') -Raw
} else {
  ''
}
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
$noteDetailFile = $noteDetailFiles | Select-Object -First 1
$noteHtml = if ($noteDetailFile -and (Test-Path (Join-Path $noteDetailFile.FullName 'index.html'))) {
  Get-Content -Path (Join-Path $noteDetailFile.FullName 'index.html') -Raw
} else {
  ''
}
$cssFile = Get-ChildItem -Path (Join-Path $outputDir 'css') -Filter 'site*.css' | Select-Object -First 1
$cssText = if ($cssFile) { Get-Content -Path $cssFile.FullName -Raw } else { '' }
$singleTemplate = Get-Content -Path (Join-Path $repoRoot 'layouts\_default\single.html') -Raw
$headTemplate = Get-Content -Path (Join-Path $repoRoot 'layouts\partials\head.html') -Raw
$commentsPartial = Get-Content -Path (Join-Path $repoRoot 'layouts\partials\comments-giscus.html') -Raw
$hugoToml = Get-Content -Path (Join-Path $repoRoot 'hugo.toml') -Raw
$tagDetailFile = Get-ChildItem -Path (Join-Path $outputDir 'tags') -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -notin @('page') } |
  Select-Object -First 1
$tagDetailHtml = if ($tagDetailFile) {
  Get-Content -Path (Join-Path $tagDetailFile.FullName 'index.html') -Raw
} else {
  ''
}
$pagesConfigPath = Join-Path $repoRoot '.pages.yml'
$cmsDateCheckScript = @"
import pathlib, sys, yaml
data = yaml.safe_load(pathlib.Path(r'$pagesConfigPath').read_text(encoding='utf-8'))
entries = {item['name']: item for item in data['content']}
posts_date = next(field for field in entries['posts']['fields'] if field['name'] == 'date')
notes_date = next(field for field in entries['notes']['fields'] if field['name'] == 'date')
expected = 'yyyy-MM-dd' + chr(39) + 'T' + chr(39) + 'HH:mm:ss'
ok = (
    (posts_date.get('options') or {}).get('time') is True
    and (notes_date.get('options') or {}).get('time') is True
    and (posts_date.get('options') or {}).get('format') == expected
    and (notes_date.get('options') or {}).get('format') == expected
)
sys.stdout.write('True' if ok else 'False')
"@
$cmsDateConfigCheck = python -c $cmsDateCheckScript
$hugoConfig = Get-Content -Path (Join-Path $repoRoot 'hugo.toml') -Raw

$themePages = @($homeHtml, $postsHtml, $notesHtml, $tagsHtml, $aboutHtml, $todoHtml)
if ($postHtml) {
  $themePages += $postHtml
}
if ($tagDetailHtml) {
  $themePages += $tagDetailHtml
}
if ($noteHtml) {
  $themePages += $noteHtml
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
$heatmapSectionIndex = $homeHtml.IndexOf('writing-heatmap-section')
$postsSectionIndex = $homeHtml.IndexOf('最近文章')
$heatmapMonthCardCount = ([regex]::Matches($homeHtml, 'heatmap-month-card')).Count
$heatmapMonthTitleCount = ([regex]::Matches($homeHtml, 'heatmap-month-title')).Count
$heatmapDayCellCount = ([regex]::Matches($homeHtml, 'heatmap-day-cell')).Count
$heatmapPlaceholderCount = ([regex]::Matches($homeHtml, 'heatmap-day-placeholder')).Count
$homePostCount = $homeCardCount - $homeNoteCount
$expectedHomePostCount = [Math]::Min(2, $postDetailFiles.Count)
$expectedHomeNoteCount = [Math]::Min(2, $noteDetailFiles.Count)
$agentSeriesOrderOk = $agentSeriesHtml -match 'Agent 学习 01[\s\S]*Agent 学习 02[\s\S]*Agent 学习 03'
$sidebarOrderOk = $homeHtml -match 'sidebar-brand-card[\s\S]*sidebar-profile-card[\s\S]*sidebar-nav-panel'
$navOrderOk = $homeHtml -match '<span>首页</span>[\s\S]*<span>文章</span>[\s\S]*<span>日记</span>[\s\S]*<span>系列</span>[\s\S]*<span>待办</span>[\s\S]*<span>标签</span>[\s\S]*<span>About</span>[\s\S]*<span>RSS</span>'

$checks = @(
  @{ Name = 'home uses card-based article layout'; Ok = $homeHtml -match 'class=reading-card' },
  @{ Name = 'home shows available recent entries per section'; Ok = $homePostCount -eq $expectedHomePostCount -and $homeNoteCount -eq $expectedHomeNoteCount },
  @{ Name = 'notes display labels are renamed to diary'; Ok = $homeHtml -match '最近日记' -and $homeHtml -match '查看全部日记' -and $notesHtml -match '<h1>日记</h1>' -and $notesHtml -notmatch $oldNotesLabel },
  @{ Name = 'home exposes explicit read-more action'; Ok = $homeHtml -match 'class=reading-action' },
  @{ Name = 'sidebar uses separated editorial panels'; Ok = $homeHtml -match 'sidebar-brand-card' -and $homeHtml -match 'sidebar-nav-panel' },
  @{ Name = 'profile card is placed between brand and nav'; Ok = $sidebarOrderOk },
  @{ Name = 'sidebar nav orders series before tags'; Ok = $navOrderOk },
  @{ Name = 'sidebar cards use sidebar shadow matching content cards'; Ok = $cssText -match '--shadow-card:6px 6px 0' -and $cssText -match '--sidebar-shadow:6px 6px 0' -and $cssText -match '\.sidebar-brand-card,\.sidebar-nav-panel,\.sidebar-profile-card\{[^}]*box-shadow:var\(--sidebar-shadow\)' },
  @{ Name = 'sidebar renders personal profile card'; Ok = ($themePages | Where-Object { $_ -match 'sidebar-profile-card' -and $_ -match 'profile-main' -and $_ -match 'profile-links' -and $_ -match '>koi<' -and $_ -match 'https://linux.do/u/koi_alkaid/summary' -and $_ -match 'profile/avatar.jpg' }).Count -eq $themePages.Count },
  @{ Name = 'profile card exposes direct CMS entry button'; Ok = ($themePages | Where-Object { $_ -match 'profile-admin-link' -and $_ -match 'href=https://app\.pagescms\.org/koialkaid/blog/main' -and $_ -match 'aria-label=进入写作后台' }).Count -eq $themePages.Count },
  @{ Name = 'home no longer renders intro card'; Ok = $homeHtml -notmatch 'Writing Index' -and $homeHtml -notmatch 'class=home-intro' },
  @{ Name = 'home no longer renders writing note panel'; Ok = $homeHtml -notmatch 'Writing Note' -and $homeHtml -notmatch 'sidebar-context-panel' },
  @{ Name = 'brand block keeps only the new site title'; Ok = $homeHtml -match "Koi&#39;s Blog|Koi's Blog" -and $homeHtml -notmatch $oldHomeIntro },
  @{ Name = 'posts list no longer renders visible section description'; Ok = $postsHtml -notmatch '<section class=page-header>.*?<p class=lede>' },
  @{ Name = 'notes list no longer renders visible section description'; Ok = $notesHtml -notmatch '<section class=page-header>.*?<p class=lede>' },
  @{ Name = 'tags page no longer renders visible description'; Ok = $tagsHtml -notmatch '<section class=page-header>.*?<p class=lede>' },
  @{ Name = 'listing cards only keep date in meta'; Ok = $homeHtml -match '<div class=writing-meta><span>[^<]+</span></div>' -and ($postDetailFiles.Count -eq 0 -or $postsHtml -match '<div class=writing-meta><span>[^<]+</span></div>') -and ($noteDetailFiles.Count -eq 0 -or $notesHtml -match '<div class=writing-meta><span>[^<]+</span></div>') },
  @{ Name = 'listing cards no longer show feature or note badges'; Ok = $homeHtml -notmatch 'class=reading-label' -and $postsHtml -notmatch 'class=reading-label' -and $notesHtml -notmatch 'class=reading-label' },
  @{ Name = 'visible reading time removed from cards and pages'; Ok = ($themePages | Where-Object { $_ -notmatch '分钟阅读' }).Count -eq $themePages.Count },
  @{ Name = 'single pages now use full character count'; Ok = $aboutCount -gt 100 -and ($postHtml -eq '' -or $postCount -gt 100) },
  @{ Name = 'theme toggle renders across audited pages'; Ok = ($themePages | Where-Object { $_ -match 'data-theme-toggle' }).Count -eq $themePages.Count },
  @{ Name = 'theme init script renders across audited pages'; Ok = ($themePages | Where-Object { $_ -match 'localStorage.getItem\("theme"\)' -and $_ -match 'data-theme=light' }).Count -eq $themePages.Count },
  @{ Name = 'home renders monthly writing heatmap body without heading copy'; Ok = $homeHtml -match 'writing-heatmap-section' -and $homeHtml -match 'writing-heatmap' -and $homeHtml -notmatch 'writing-heatmap-title' -and $homeHtml -notmatch '>写作记录<' -and $homeHtml -notmatch '>最近一年<' -and $homeHtml -notmatch '>Activity<' },
  @{ Name = 'writing heatmap appears before recent posts'; Ok = $heatmapSectionIndex -ge 0 -and $postsSectionIndex -ge 0 -and $heatmapSectionIndex -lt $postsSectionIndex },
  @{ Name = 'writing heatmap renders 12 month cards'; Ok = $heatmapMonthCardCount -eq 12 },
  @{ Name = 'writing heatmap renders month titles'; Ok = $heatmapMonthTitleCount -eq 12 },
  @{ Name = 'writing heatmap renders daily cells'; Ok = $heatmapDayCellCount -ge 365 },
  @{ Name = 'writing heatmap renders padding placeholders for calendar structure'; Ok = $heatmapPlaceholderCount -ge 20 },
  @{ Name = 'cms post and note dates use datetime format supported by Pages CMS'; Ok = $cmsDateConfigCheck -eq 'True' },
  @{ Name = 'hugo builds future-dated CMS entries immediately'; Ok = $hugoConfig -match '(?m)^buildFuture\s*=\s*true\s*$' },
  @{ Name = 'article page keeps global page frame untouched'; Ok = $cssText -notmatch '\.kind-page\.section-posts \.site-frame' -and $cssText -notmatch '\.kind-page\.section-notes \.site-frame' -and $cssText -notmatch '\.kind-page\.section-posts \.site-content' -and $cssText -notmatch '\.kind-page\.section-notes \.site-content' },
  @{ Name = 'article page no longer overrides global content shell by section'; Ok = $cssText -notmatch '\.kind-page\.section-posts \.content-shell' -and $cssText -notmatch '\.kind-page\.section-notes \.content-shell' },
  @{ Name = 'global html keeps a stable scrollbar gutter'; Ok = $cssText -match 'html\{[^}]*scrollbar-gutter:\s*stable' },
  @{ Name = 'light theme uses a unified solid site background'; Ok = $cssText -match '--bg:\s*#fcfcfc' -and $cssText -match 'body\{[^}]*background:\s*var\(--bg\)' },
  @{ Name = 'global shell uses expanded site and content widths'; Ok = $cssText -match '--site-width:\s*1440px' -and $cssText -match '--content-width:\s*1120px' },
  @{ Name = 'dark theme softens bright text to gray'; Ok = $cssText -match 'html\[data-theme=dark\]\{[^}]*--ink:\s*#d2d2d2[^}]*--accent:\s*#d2d2d2[^}]*--accent-deep:\s*#d2d2d2' },
  @{ Name = 'giscus config is defined in hugo params'; Ok = $hugoToml -match '\[params\.giscus\]' -and $hugoToml -match "repo = 'koialkaid/blog'" -and $hugoToml -match "repoId = 'R_kgDOR-EI_A'" -and $hugoToml -match "categoryId = 'DIC_kwDOR-EI_M4C7CtO'" },
  @{ Name = 'article page uses balanced reading-first two-column shell'; Ok = $cssText -match '\.article-page-shell\{[^}]*grid-template-columns:\s*minmax\(0,\s*52rem\)\s*minmax\(10\.5rem,\s*12rem\)[^}]*gap:\s*2rem' },
  @{ Name = 'article page no longer ships a separate no-aside desktop shell'; Ok = $cssText -notmatch '\.article-page-shell\.no-aside\{' -and $singleTemplate -notmatch 'article-page-shell\{\{ if not \(or \$hasToc \$hasSeries\) \}\} no-aside' },
  @{ Name = 'article body and summary keep a restrained readable measure'; Ok = $cssText -match '\.article-page \.article-summary,\s*\.article-page \.article-body\{[^}]*max-width:\s*52rem' },
  @{ Name = 'article pages render giscus directly without extra intro block'; Ok = ($postHtml -eq '' -or ($postHtml -match 'giscus\.app/client\.js' -and $postHtml -match 'data-repo=koialkaid/blog' -and $postHtml -match 'data-repo-id=R_kgDOR-EI_A' -and $postHtml -match 'data-category=Announcements' -and $postHtml -match 'data-category-id=DIC_kwDOR-EI_M4C7CtO')) -and ($noteHtml -eq '' -or ($noteHtml -match 'giscus\.app/client\.js')) -and $commentsPartial -notmatch 'section-kicker">Comments<' -and $commentsPartial -notmatch '登录 GitHub 后即可评论' },
  @{ Name = 'comment section keeps article width and full widget width'; Ok = $cssText -match '\.article-comments\{[^}]*max-width:\s*52rem' -and $cssText -match '\.article-comments-frame \.giscus,\s*\.article-comments-frame \.giscus-frame\{[^}]*width:\s*100%' },
  @{ Name = 'head theme script syncs giscus theme with site theme'; Ok = $headTemplate -match 'window\.__syncGiscusTheme' },
  @{ Name = 'article aside stays compact and close to content'; Ok = $cssText -match '\.article-aside\{[^}]*padding-left:\s*0(?:;|\s|\})' -and $cssText -match '\.article-toc-card,\s*\.series-reading-card\{[^}]*max-width:\s*12rem' },
  @{ Name = 'toc card keeps a fixed height with internal scrolling'; Ok = $cssText -match '\.article-toc-card\{[^}]*max-height:\s*22rem[^}]*overflow:\s*auto[^}]*scrollbar-width:\s*thin' },
  @{ Name = 'article main keeps existing card visual style'; Ok = $cssText -match '\.article-main\{[^}]*border-top:\s*2px solid var\(--accent-deep\)' -and $cssText -match '\.sidebar-brand-card,\.sidebar-nav-panel,\.sidebar-profile-card,\.sidebar-context-panel,\.home-intro,\.page-header,\.reading-card,\.article-main,\.taxonomy-card\{[^}]*background:\s*var\(--panel-bg\)[^}]*box-shadow:\s*var\(--shadow-card\)' },
  @{ Name = 'single template keeps a stable article aside slot'; Ok = $singleTemplate -match '\$hasAsideContent' -and $singleTemplate -like '*<aside class="article-aside{{ if not $hasAsideContent }} is-empty{{ end }}"*' },
  @{ Name = 'article page remains a dedicated shell'; Ok = ($postHtml -eq '' -or ($postHtml -match 'article-page-shell' -and $postHtml -match 'article-main' -and $postHtml -match 'article-aside')) -and ($agentArticleHtml -eq '' -or ($agentArticleHtml -match 'article-page-shell' -and $agentArticleHtml -match 'article-main' -and $agentArticleHtml -match 'article-aside')) },
  @{ Name = 'post page renders on-this-page block in right-side aside'; Ok = $postHtml -eq '' -or ($postHtml -match 'On This Page' -and $postHtml -match 'article-aside' -and $postHtml -match 'article-toc-card') },
  @{ Name = 'post page toc is not rendered in sidebar'; Ok = $postHtml -notmatch 'sidebar-context-panel' },
  @{ Name = 'post page toc is not rendered before body inside main flow'; Ok = $postHtml -notmatch 'article-toc-block' },
  @{ Name = 'post page keeps independent article shell'; Ok = $postHtml -eq '' -or $postHtml -match 'article-page-shell' },
  @{ Name = 'toc aside uses sticky positioning'; Ok = $cssText -match '\.article-aside\{[^}]*position:sticky[^}]*top:[^;}]+[^}]*' },
  @{ Name = 'toc card supports internal scrolling when long'; Ok = $cssText -match '\.article-aside\{[^}]*max-height:calc\(100vh - 4rem\)[^}]*overflow:auto' },
  @{ Name = 'toc and series cards keep visible card shadow'; Ok = $cssText -match '\.article-toc-card,\s*\.series-reading-card\{[^}]*box-shadow:var\(--shadow-card\)' },
  @{ Name = 'series index page renders when series content exists'; Ok = $seriesHtml -eq '' -or $seriesHtml -match '<h1>系列</h1>' },
  @{ Name = 'tags page uses compact grid layout'; Ok = $tagsHtml -match 'taxonomy-tag-grid' -and $tagsHtml -match 'taxonomy-tag-card' },
  @{ Name = 'tags page uses single-layer tag cards'; Ok = $cssText -match '\.taxonomy-tag-card\{[^}]*border:0[^}]*background:(?:transparent|0 0)[^}]*box-shadow:none' -and $cssText -match '\.taxonomy-tag-card \.tag-pill\{[^}]*box-shadow:var\(--shadow-card\)|\.taxonomy-tag-card\.tag-pill\{[^}]*box-shadow:var\(--shadow-card\)' },
  @{ Name = 'series index shows description for agent learning when present'; Ok = $seriesHtml -notmatch 'Agent 学习' -or ($seriesHtml -match 'taxonomy-series-card' -and $seriesHtml -match '基本概念、工具调用与边界设定') },
  @{ Name = 'series detail shows description for agent learning when present'; Ok = $agentSeriesHtml -notmatch 'Agent 学习' -or $agentSeriesHtml -match '基本概念、工具调用与边界设定' },
  @{ Name = 'todo page exists and renders in navigation'; Ok = $todoHtml -match '<h1>待办</h1>' -and $homeHtml -match '<span>待办</span>' -and $homeHtml -match 'href=/blog/todo/' },
  @{ Name = 'agent learning series page sorts entries by series order when present'; Ok = $agentSeriesHtml -notmatch 'Agent 学习' -or $agentSeriesOrderOk },
  @{ Name = 'series article shows series metadata when present'; Ok = $agentArticleHtml -eq '' -or ($agentArticleHtml -match '系列：Agent 学习' -and $agentArticleHtml -match '第 1 篇') },
  @{ Name = 'series article shows full series list card in aside when present'; Ok = $agentArticleHtml -eq '' -or ($agentArticleHtml -match 'series-reading-card' -and $agentArticleHtml -match 'Agent 学习 01' -and $agentArticleHtml -match 'Agent 学习 02' -and $agentArticleHtml -match 'Agent 学习 03' -and $agentArticleHtml -match '查看系列') },
  @{ Name = 'series reading is removed from article main'; Ok = $agentArticleHtml -notmatch '<div class=article-main>[\s\S]*<section class=series-reading' },
  @{ Name = 'series reading marks current article when present'; Ok = $agentArticleHtml -eq '' -or $agentArticleHtml -match '<em>当前</em>' },
  @{ Name = 'non-series article does not render series block'; Ok = $postHtml -eq '' -or ($postHtml -notmatch 'series-reading-card' -and $postHtml -notmatch '系列：') }
)

$failed = $checks | Where-Object { -not $_.Ok }

if ($failed) {
  Write-Output 'Editorial layout checks failed:'
  $failed | ForEach-Object { "- $($_.Name)" }
  exit 1
}

Write-Output 'Editorial layout checks passed.'
