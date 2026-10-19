<#
Brain Clean runner - watches .runner/inbox and runs one Cursor agent task at a time.

Start (from the repo root, in Cursor's terminal):
    powershell -ExecutionPolicy Bypass -File .\tools\runner\brainclean_runner.ps1
Stop:   create an empty file .runner\STOP   (or press Ctrl+C)

Needs the Cursor CLI (`cursor-agent`, or `agent` in newer versions), logged in once with `cursor-agent login`.
Safety: dangerous commands are denied in .cursor/cli.json; the runner never builds and never pushes,
and after each task it checks the commit count and whether anything was pushed.
#>
param(
    [int]$PollSeconds = 20,
    [string]$Model = ""
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $Root
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$Inbox   = Join-Path $Root ".runner\inbox"
$Running = Join-Path $Root ".runner\running"
$Done    = Join-Path $Root ".runner\done"
$StopFile = Join-Path $Root ".runner\STOP"
foreach ($d in @($Inbox, $Running, $Done)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }

$agentCmd = Get-Command cursor-agent -ErrorAction SilentlyContinue
if (-not $agentCmd) { $agentCmd = Get-Command agent -ErrorAction SilentlyContinue }
if (-not $agentCmd) {
    Write-Host "Cursor CLI not found. Install it from https://cursor.com/cli, run 'cursor-agent login', then start this script again." -ForegroundColor Red
    exit 1
}
$AgentExe = $agentCmd.Source

function Git-Out([string[]]$GitArgs) {
    $out = & git @GitArgs 2>$null
    if ($LASTEXITCODE -ne 0) { return "" }
    return ($out -join "`n").Trim()
}

function Write-Result($Path, $Obj) {
    $Obj | ConvertTo-Json -Depth 5 | Set-Content -Path $Path -Encoding UTF8
}

Write-Host "Brain Clean runner started in $Root" -ForegroundColor Green
Write-Host "Agent: $AgentExe  |  Inbox: $Inbox  |  Stop: create .runner\STOP"

# Recover a task left in running/ by a crash: move it back to inbox.
Get-ChildItem $Running -Filter *.json -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Found unfinished task $($_.Name) in running/ - moving it to done/ as INTERRUPTED (Claude will decide)." -ForegroundColor Yellow
    Move-Item $_.FullName (Join-Path $Done ($_.BaseName + ".interrupted.json")) -Force
}

while ($true) {
    if (Test-Path $StopFile) { Remove-Item $StopFile -Force; Write-Host "STOP file found. Runner stopped."; break }

    $next = Get-ChildItem $Inbox -Filter *.json | Sort-Object Name | Select-Object -First 1
    if (-not $next) { Start-Sleep -Seconds $PollSeconds; continue }

    $runPath = Join-Path $Running $next.Name
    Move-Item $next.FullName $runPath -Force
    try {
        $task = Get-Content $runPath -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        Write-Host "Bad JSON in $($next.Name): $_" -ForegroundColor Red
        Move-Item $runPath (Join-Path $Done ($next.BaseName + ".badjson.json")) -Force
        continue
    }

    $id = [string]$task.id
    $timeout = 90
    if ($task.timeoutMinutes) { $timeout = [int]$task.timeoutMinutes }
    $log = Join-Path $Done "$id.log"
    $branch = Git-Out @("rev-parse", "--abbrev-ref", "HEAD")
    $headBefore = Git-Out @("rev-parse", "HEAD")
    $upstreamBefore = Git-Out @("rev-parse", "@{u}")
    $started = Get-Date

    Write-Host ""
    Write-Host "=== [$($started.ToString('HH:mm'))] Running $id - $($task.title) (timeout $timeout min) ===" -ForegroundColor Cyan

    $agentArgs = @("-p", [string]$task.prompt, "--force", "--output-format", "text")
    if ($Model) { $agentArgs += @("--model", $Model) }

    $job = Start-Job -ScriptBlock {
        param($exe, $argList, $cwd)
        Set-Location $cwd
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        & $exe @argList 2>&1
        "__EXIT_CODE__=$LASTEXITCODE"
    } -ArgumentList $AgentExe, $agentArgs, $Root

    $finishedInTime = Wait-Job $job -Timeout ($timeout * 60)
    if (-not $finishedInTime) { Stop-Job $job }
    $output = Receive-Job $job -ErrorAction SilentlyContinue
    Remove-Job $job -Force
    $output | Out-File -FilePath $log -Encoding UTF8
    $output | Select-Object -Last 25 | ForEach-Object { Write-Host $_ }

    $exitLine = ($output | Where-Object { "$_" -like "__EXIT_CODE__=*" } | Select-Object -Last 1)
    $exitCode = if ($exitLine) { [int]("$exitLine" -replace "__EXIT_CODE__=", "") } else { -1 }
    $resultLine = ($output | Where-Object { "$_" -match "^RESULT:" } | Select-Object -Last 1)

    $headAfter = Git-Out @("rev-parse", "HEAD")
    $commits = 0
    if ($headBefore -and $headAfter) { $commits = [int](Git-Out @("rev-list", "--count", "$headBefore..$headAfter")) }
    $upstreamAfter = Git-Out @("rev-parse", "@{u}")
    $pushed = ($upstreamBefore -ne $upstreamAfter)
    $dirty = Git-Out @("status", "--porcelain")

    $status = "DONE"
    if (-not $finishedInTime) { $status = "TIMEOUT" }
    elseif ($exitCode -ne 0) { $status = "FAILED" }
    elseif ($resultLine -match "BLOCKED") { $status = "BLOCKED" }
    elseif ($commits -ne 1) { $status = "CHECK_COMMITS" }
    if ($pushed) { $status = "ALERT_PUSHED" }
    if ((Git-Out @("rev-parse", "--abbrev-ref", "HEAD")) -ne $branch) { $status = "ALERT_BRANCH_CHANGED" }

    Write-Result (Join-Path $Done "$id.result.json") ([ordered]@{
        id = $id; status = $status; exitCode = $exitCode; result = "$resultLine"
        started = $started.ToString("s"); finished = (Get-Date).ToString("s")
        branch = $branch; headBefore = $headBefore; headAfter = $headAfter; commits = $commits
        pushed = $pushed; uncommittedFiles = ($dirty -split "`n" | Where-Object { $_ }).Count
    })
    Move-Item $runPath (Join-Path $Done "$id.json") -Force

    $color = if ($status -eq "DONE") { "Green" } else { "Yellow" }
    Write-Host "=== $id finished: $status (commits: $commits) - waiting for Claude's review ===" -ForegroundColor $color
}
