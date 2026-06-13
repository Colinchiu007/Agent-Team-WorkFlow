# Git proxy auto-detect wrapper
# Usage: just use git commands as normal (git push, git pull, etc.)
# Auto-detects proxy ports (7890 / 12334 / 7892)

function ProxyGit {
    $proxyPorts = @(7890, 12334, 7892)
    $proxyUrl = $null

    foreach ($port in $proxyPorts) {
        $result = Test-NetConnection -ComputerName 127.0.0.1 -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        if ($result) {
            $proxyUrl = "http://127.0.0.1:$port"
            Write-Host "[ProxyGit] Proxy detected on port $port" -ForegroundColor Green
            break
        }
    }

    $gitArgs = $args

    if ($proxyUrl) {
        Write-Host "[ProxyGit] Using proxy: $proxyUrl" -ForegroundColor Cyan
        & git.exe "-c" "http.proxy=$proxyUrl" "-c" "https.proxy=$proxyUrl" @gitArgs
    } else {
        Write-Host "[ProxyGit] No proxy detected, connecting directly" -ForegroundColor Yellow
        & git.exe @gitArgs
    }
}

Set-Alias -Name git -Value ProxyGit -Scope Global -Force
