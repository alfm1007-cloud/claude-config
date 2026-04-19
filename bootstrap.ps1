# bootstrap.ps1 — 무르 Claude 새 PC 셋업 (Windows)
# Usage:
#   PowerShell 한 줄:
#   irm https://raw.githubusercontent.com/alfm1007-cloud/claude-config/master/bootstrap.ps1 | iex

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'  # winget 진행바 깔끔하게

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  무르 Claude 부트스트랩" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ──────────────────────────────────────────
# 헬퍼
# ──────────────────────────────────────────
function Test-Cmd($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Step($n, $total, $msg) {
    Write-Host "[$n/$total] $msg" -ForegroundColor Yellow
}

# ──────────────────────────────────────────
# [1/7] winget 점검
# ──────────────────────────────────────────
Step 1 7 "winget 점검"
if (-not (Test-Cmd winget)) {
    Write-Host "  ❌ winget이 없습니다." -ForegroundColor Red
    Write-Host "     Microsoft Store에서 'App Installer' 설치 후 재실행:" -ForegroundColor Red
    Write-Host "     https://apps.microsoft.com/detail/9NBLGGH4NNS1" -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ winget OK" -ForegroundColor Green

# ──────────────────────────────────────────
# [2/7] Node.js
# ──────────────────────────────────────────
Step 2 7 "Node.js"
if (-not (Test-Cmd node)) {
    Write-Host "  📦 설치 중..."
    winget install -e --id OpenJS.NodeJS.LTS --silent `
        --accept-source-agreements --accept-package-agreements | Out-Null
    Refresh-Path
    if (-not (Test-Cmd node)) {
        Write-Host "  ⚠️  PATH 갱신 실패. PowerShell 재시작 후 다시 실행하세요." -ForegroundColor Yellow
        exit 1
    }
}
Write-Host "  ✅ Node $(node --version)" -ForegroundColor Green

# ──────────────────────────────────────────
# [3/7] Git
# ──────────────────────────────────────────
Step 3 7 "Git"
if (-not (Test-Cmd git)) {
    Write-Host "  📦 설치 중..."
    winget install -e --id Git.Git --silent `
        --accept-source-agreements --accept-package-agreements | Out-Null
    Refresh-Path
    if (-not (Test-Cmd git)) {
        Write-Host "  ⚠️  PATH 갱신 실패. PowerShell 재시작 후 다시 실행하세요." -ForegroundColor Yellow
        exit 1
    }
}
Write-Host "  ✅ $(git --version)" -ForegroundColor Green

# ──────────────────────────────────────────
# [4/7] GitHub CLI (push 인증용)
# ──────────────────────────────────────────
Step 4 7 "GitHub CLI"
if (-not (Test-Cmd gh)) {
    Write-Host "  📦 설치 중..."
    winget install -e --id GitHub.cli --silent `
        --accept-source-agreements --accept-package-agreements | Out-Null
    Refresh-Path
}
if (Test-Cmd gh) {
    Write-Host "  ✅ gh 설치됨" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  gh 설치 실패 (선택 사항이라 계속 진행)" -ForegroundColor Yellow
}

# ──────────────────────────────────────────
# [5/7] Claude Code
# ──────────────────────────────────────────
Step 5 7 "Claude Code"
if (-not (Test-Cmd claude)) {
    Write-Host "  📦 npm install -g @anthropic-ai/claude-code"
    npm install -g @anthropic-ai/claude-code 2>&1 | Out-Null
    Refresh-Path
}
if (Test-Cmd claude) {
    Write-Host "  ✅ claude 설치됨" -ForegroundColor Green
} else {
    Write-Host "  ❌ claude 설치 실패. 수동: npm install -g @anthropic-ai/claude-code" -ForegroundColor Red
    exit 1
}

# ──────────────────────────────────────────
# [6/7] ~/.claude 클론 / 동기화
# ──────────────────────────────────────────
Step 6 7 "무르 설정 복원"
$claudeDir = "$HOME\.claude"
$repoUrl = "https://github.com/alfm1007-cloud/claude-config.git"

if (Test-Path "$claudeDir\.git") {
    Write-Host "  🔄 기존 저장소 → git pull"
    Push-Location $claudeDir
    try { git pull --ff-only } catch { Write-Host "  ⚠️  pull 실패 (네트워크/충돌 확인)" -ForegroundColor Yellow }
    Pop-Location
}
elseif (Test-Path $claudeDir) {
    $backup = "$claudeDir.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "  ⚠️  $claudeDir 존재 (git 아님) → 백업: $backup"
    Move-Item $claudeDir $backup
    git clone $repoUrl $claudeDir
}
else {
    Write-Host "  📥 git clone $repoUrl"
    git clone $repoUrl $claudeDir
}
Write-Host "  ✅ ~/.claude 준비 완료" -ForegroundColor Green

# ──────────────────────────────────────────
# [7/7] settings.json (hook 병합)
# ──────────────────────────────────────────
Step 7 7 "settings.json hook 설정"
$settingsPath = "$claudeDir\settings.json"
$hooksBlock = [ordered]@{
    SessionStart = @(
        [ordered]@{
            matcher = ""
            hooks = @(
                [ordered]@{
                    type = "command"
                    command = "cd ~/.claude && git pull --ff-only 2>/dev/null || true"
                }
            )
        }
    )
    Stop = @(
        [ordered]@{
            matcher = ""
            hooks = @(
                [ordered]@{
                    type = "command"
                    command = "cd ~/.claude && git diff --quiet && git diff --cached --quiet || (git add -A && git commit -m 'auto-sync: `$(date +%Y-%m-%d)' && git push)"
                }
            )
        }
    )
}

if (Test-Path $settingsPath) {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json -AsHashtable
    if (-not $settings.hooks) {
        $settings.hooks = $hooksBlock
        $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
        Write-Host "  ✅ 기존 settings.json에 hook 병합" -ForegroundColor Green
    } else {
        Write-Host "  ✅ hook 이미 설정됨 (건너뜀)" -ForegroundColor Green
    }
} else {
    $newSettings = [ordered]@{
        enabledPlugins = @{}
        enableAllProjectMcpServers = $false
        spinnerTipsEnabled = $false
        autoUpdatesChannel = "latest"
        hooks = $hooksBlock
    }
    $newSettings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
    Write-Host "  ✅ settings.json 신규 생성" -ForegroundColor Green
}

# Desktop\Claude 폴더 준비
$desktopClaude = "$HOME\Desktop\Claude"
if (-not (Test-Path $desktopClaude)) {
    New-Item -ItemType Directory -Path $desktopClaude -Force | Out-Null
    Write-Host "  📁 $desktopClaude 생성" -ForegroundColor Green
}

# ──────────────────────────────────────────
# 마무리 안내
# ──────────────────────────────────────────
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  ✅ 자동 셋업 완료" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 남은 수동 작업 (3가지):" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1) Claude 로그인" -ForegroundColor White
Write-Host "     > claude" -ForegroundColor Gray
Write-Host "     (브라우저가 열리면 Anthropic 계정 로그인)" -ForegroundColor Gray
Write-Host ""
Write-Host "  2) GitHub 인증 (push 권한용)" -ForegroundColor White
Write-Host "     > gh auth login" -ForegroundColor Gray
Write-Host "     (GitHub.com → HTTPS → 브라우저)" -ForegroundColor Gray
Write-Host ""
Write-Host "  3) 프로젝트 폴더 클론 (필요한 것만)" -ForegroundColor White
Write-Host "     > cd ~\Desktop\Claude" -ForegroundColor Gray
Write-Host "     > git clone https://github.com/alfm1007-cloud/swresort.git" -ForegroundColor Gray
Write-Host ""
Write-Host "🎯 검증: claude 실행 후 '내가 누구야?' 물어보세요" -ForegroundColor Cyan
Write-Host ""
