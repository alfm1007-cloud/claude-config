# auto-pull.ps1 — SessionStart hook: claude-config + claude-projects-sync 동시 pull

function Pull-Repo($path) {
    if (-not (Test-Path "$path\.git")) { return }
    Push-Location $path
    try {
        git pull --ff-only 2>$null | Out-Null
    } finally {
        Pop-Location
    }
}

Pull-Repo "$env:USERPROFILE\.claude"
Pull-Repo "$env:USERPROFILE\.claude\projects"
