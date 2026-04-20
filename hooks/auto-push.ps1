$claudeDir = "$env:USERPROFILE\.claude"
Set-Location $claudeDir
$status = git status --porcelain 2>$null
if ($status) {
    git add -A
    $date = Get-Date -Format "yyyy-MM-dd"
    git commit -m "auto-sync: $date" 2>$null
    git push origin master 2>$null
}
