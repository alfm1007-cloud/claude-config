# auto-push.ps1 — Stop hook: claude-config + claude-projects-sync 동시 push

function Push-Repo($path) {
    if (-not (Test-Path "$path\.git")) { return }
    Push-Location $path
    try {
        $status = git status --porcelain 2>$null
        if ($status) {
            git add -A 2>$null
            $date = Get-Date -Format "yyyy-MM-dd"
            git commit -m "auto-sync: $date" 2>$null | Out-Null
            git push 2>$null | Out-Null
        }
    } finally {
        Pop-Location
    }
}

Push-Repo "$env:USERPROFILE\.claude"
Push-Repo "$env:USERPROFILE\.claude\projects"
