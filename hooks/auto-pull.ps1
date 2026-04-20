$claudeDir = "$env:USERPROFILE\.claude"
Set-Location $claudeDir
git pull --ff-only origin master 2>$null
