#Requires -Version 5.1
# Smart Git Commit Script for git-pushing skill (Windows/PowerShell)
# Handles staging, commit message generation, and pushing

$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host "-> $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "!! $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "X $msg" -ForegroundColor Red }

# Get current branch
$CurrentBranch = git rev-parse --abbrev-ref HEAD
Write-Info "Current branch: $CurrentBranch"

# Check if there are changes
git diff --quiet 2>$null
$unstaged = $LASTEXITCODE
git diff --cached --quiet 2>$null
$staged = $LASTEXITCODE

if ($unstaged -eq 0 -and $staged -eq 0) {
    Write-Warn "No changes to commit"
    exit 0
}

# Stage all changes
Write-Info "Staging all changes..."
git add .

# Get staged files for commit message analysis
$StagedFiles = git diff --cached --name-only
$DiffStat = git diff --cached --stat

function Get-CommitType($files) {
    $joined = $files -join "`n"
    if ($joined -match "test") { return "test" }
    if ($joined -match "\.(md|txt|rst)$") { return "docs" }
    if ($joined -match "package\.json|requirements\.txt|Cargo\.toml") { return "chore" }

    $diff = git diff --cached
    $diffJoined = $diff -join "`n"
    if ($diffJoined -match "(?m)^\+.*fix|^\+.*bug") { return "fix" }
    if ($diffJoined -match "(?m)^\+.*refactor") { return "refactor" }

    return "feat"
}

function Get-Scope($files) {
    $joined = $files -join "`n"
    if ($joined -match "plugin") { return "plugin" }
    if ($joined -match "skill") { return "skill" }
    if ($joined -match "agent") { return "agent" }

    $first = ($files | Select-Object -First 1)
    if ($first -and $first.Contains("/")) {
        $scope = $first.Split("/")[0]
        if ($scope -and $scope -ne ".") { return $scope }
    }
    return ""
}

# Generate commit message if not provided
if ($args.Count -eq 0 -or [string]::IsNullOrWhiteSpace($args[0])) {
    $CommitType = Get-CommitType $StagedFiles
    $Scope = Get-Scope $StagedFiles
    $NumFiles = ($StagedFiles | Measure-Object).Count

    switch ($CommitType) {
        "docs"  { $Description = "update documentation" }
        "test"  { $Description = "update tests" }
        "chore" { $Description = "update dependencies" }
        default { $Description = "update $NumFiles file(s)" }
    }

    if ($Scope) {
        $CommitMsg = "${CommitType}(${Scope}): ${Description}"
    } else {
        $CommitMsg = "${CommitType}: ${Description}"
    }

    Write-Info "Generated commit message: $CommitMsg"
} else {
    $CommitMsg = $args[0]
    Write-Info "Using provided message: $CommitMsg"
}

# Create commit
git commit -m $CommitMsg
if ($LASTEXITCODE -ne 0) {
    Write-Err "Commit failed"
    exit 1
}

$CommitHash = git rev-parse --short HEAD
Write-Info "Created commit: $CommitHash"

# Push to remote
Write-Info "Pushing to origin/$CurrentBranch..."

$branchExists = git ls-remote --exit-code --heads origin $CurrentBranch 2>$null
if ($LASTEXITCODE -eq 0) {
    git push
    if ($LASTEXITCODE -eq 0) {
        Write-Info "Successfully pushed to origin/$CurrentBranch"
        Write-Host $DiffStat
    } else {
        Write-Err "Push failed"
        exit 1
    }
} else {
    git push -u origin $CurrentBranch
    if ($LASTEXITCODE -eq 0) {
        Write-Info "Successfully pushed new branch to origin/$CurrentBranch"
        Write-Host $DiffStat

        $RemoteUrl = git remote get-url origin
        if ($RemoteUrl -match "github\.com") {
            $Repo = $RemoteUrl -replace '.*github\.com[:/](.*?)(?:\.git)?$', '$1'
            Write-Warn "Create PR: https://github.com/$Repo/pull/new/$CurrentBranch"
        }
    } else {
        Write-Err "Push failed"
        exit 1
    }
}

exit 0
