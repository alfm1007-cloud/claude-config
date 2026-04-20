# sync-pull.ps1 ??Gist?먯꽌 理쒖떊 ref ?뚯씪 pull
$gistId = "257d831b5c69e565715bf6f5a49b7175"
$refDir = "$env:USERPROFILE\.claude\projects\C--Users-$env:USERNAME-Desktop-code\ref"
New-Item -ItemType Directory -Path $refDir -Force | Out-Null
try {
    $res = Invoke-RestMethod "https://api.github.com/gists/$gistId"
    @("stack","db","features","errors","rules") | ForEach-Object {
        $key = "ref_$_.md"
        if ($res.files.$key) {
            $content = Invoke-RestMethod $res.files.$key.raw_url
            Set-Content "$refDir\$_.md" -Value $content -Encoding UTF8
            Write-Host "   pull: $key"
        }
    }
} catch { }