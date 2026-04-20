# lite-setup.ps1 — 회사 PC 제약 환경용 WebFetch-only 복원
# 목적: git/npm/winget 전부 막혀도 ~/.claude 핵심 파일 복원
# 호출: irm https://raw.githubusercontent.com/alfm1007-cloud/claude-config/master/lite-setup.ps1 | iex

$ErrorActionPreference = 'Continue'
$base = "https://raw.githubusercontent.com/alfm1007-cloud/claude-config/master"
$target = "$HOME\.claude"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  무르 Claude lite-setup (WebFetch 전용)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 디렉터리 생성
$dirs = @("", "commands", "hooks", "memory", "ref")
foreach ($d in $dirs) {
    $path = if ($d) { "$target\$d" } else { $target }
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

# 파일 매니페스트
$files = @(
    "CLAUDE.md", "README.md", "MANUAL.md", "SETUP.md", ".gitignore",
    "commands/sync.md",
    "hooks/auto-pull.ps1", "hooks/auto-push.ps1",
    "memory/MEMORY.md", "memory/design_context.md", "memory/dev_context.md",
    "memory/feedback_custom_skills.md", "memory/feedback_token_efficiency.md",
    "memory/infrastructure.md", "memory/optimization_global_settings.md",
    "memory/planning_context.md", "memory/user_identity.md",
    "ref/errors.md", "ref/project_template.md", "ref/rules.md"
)

$ok = 0; $fail = 0
foreach ($f in $files) {
    $url = "$base/$f"
    $dest = "$target\$($f -replace '/', '\')"
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -ErrorAction Stop
        Write-Host "  ✅ $f" -ForegroundColor Green
        $ok++
    } catch {
        Write-Host "  ❌ $f ($($_.Exception.Message))" -ForegroundColor Red
        $fail++
    }
}

# settings.json 최소 템플릿 (기존 보호)
$settingsPath = "$target\settings.json"
if (-not (Test-Path $settingsPath)) {
    $template = @'
{
  "enabledPlugins": {},
  "enableAllProjectMcpServers": false,
  "spinnerTipsEnabled": false,
  "autoUpdatesChannel": "latest",
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "for d in ~/.claude ~/.claude/projects; do [ -d \"$d/.git\" ] && (cd \"$d\" && git pull --ff-only 2>/dev/null); done; true"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "for d in ~/.claude ~/.claude/projects; do [ -d \"$d/.git\" ] && (cd \"$d\" && (git diff --quiet && git diff --cached --quiet || (git add -A && git commit -m \"auto-sync: $(date +%Y-%m-%d)\" && git push))); done; true"
          }
        ]
      }
    ]
  }
}
'@
    Set-Content -Path $settingsPath -Value $template -Encoding UTF8
    Write-Host "  ✅ settings.json (신규 생성)" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  결과: $ok 성공 / $fail 실패" -ForegroundColor $(if ($fail -eq 0) { "Green" } else { "Yellow" })
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📌 다음 단계 (선택):" -ForegroundColor Yellow
Write-Host "  - git 사용 가능하면: cd ~/.claude && git init && git remote add origin https://github.com/alfm1007-cloud/claude-config.git && git fetch && git reset --hard origin/master"
Write-Host "  - 그래야 자동 동기화(훅) 작동. lite-setup만으론 수동 복원만 가능."
Write-Host ""
