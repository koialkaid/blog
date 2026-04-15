param(
  [string]$BaseUrl = 'https://koialkaid.github.io/blog/',
  [string]$HugoPath = 'hugo'
)

$ErrorActionPreference = 'Stop'

$baseUri = [Uri]$BaseUrl
$pathPrefix = $baseUri.AbsolutePath.Trim('/')

if ([string]::IsNullOrWhiteSpace($pathPrefix)) {
  Write-Output "Base URL '$BaseUrl' has no path prefix; project-site link check skipped."
  exit 0
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$outputDir = Join-Path $env:TEMP 'ly-blog-project-site-link-check'

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

$prefixPattern = [Regex]::Escape("$pathPrefix/")
$brokenPattern = "(?:href|src)=(['""]?)/(?!$prefixPattern)"

$matches = Get-ChildItem -Path $outputDir -Recurse -Filter *.html |
  Select-String -Pattern $brokenPattern |
  ForEach-Object { "{0}:{1}:{2}" -f $_.Path, $_.LineNumber, $_.Line.Trim() }

if ($matches) {
  Write-Output 'Found root-relative internal links that ignore the project base path:'
  $matches
  exit 1
}

Write-Output "Project-site internal links are correctly prefixed with /$pathPrefix/."
