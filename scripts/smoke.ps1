#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Verify the installed state of this skill pack after install-user.ps1.

.DESCRIPTION
    For every flat skill in the repository, asserts that
    ~/.agents/skills/<name> exists, is a link (junction/symlink), and resolves
    into this checkout. Exit code 0 = installed correctly, 1 = problems.

.NOTES
    Run from the alfred project or anywhere; checks the user-agents root that
    DSH / Codex / OpenCode / Claude all read.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Split-Path -Parent $PSScriptRoot)).Path
$skillsDir = Join-Path (Join-Path $HOME '.agents') 'skills'
$failures = 0

if (-not (Test-Path $skillsDir)) {
    Write-Host '[smoke] ~/.agents/skills does not exist; run scripts/install-user.ps1 first' -ForegroundColor Red
    exit 1
}

$skills = @(
    Get-ChildItem -Path $repoRoot -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }
)
Write-Host "[smoke] checking $($skills.Count) skills in $skillsDir"

foreach ($skill in $skills) {
    $linkPath = Join-Path $skillsDir $skill.Name
    if (-not (Test-Path $linkPath)) {
        Write-Host "[FAIL] missing link: $($skill.Name)" -ForegroundColor Red
        $failures++
        continue
    }
    $item = Get-Item $linkPath -Force
    if ($null -eq $item.LinkType) {
        Write-Host "[FAIL] not a link: $($skill.Name)" -ForegroundColor Red
        $failures++
        continue
    }
    $target = ($item.Target -join '')
    if (-not $target.Equals($skill.FullName, [System.StringComparison]::OrdinalIgnoreCase)) {
        Write-Host "[FAIL] target mismatch: $($skill.Name) -> $target (expected $($skill.FullName))" -ForegroundColor Red
        $failures++
        continue
    }
    $skillFile = Join-Path $linkPath 'SKILL.md'
    if (-not (Test-Path $skillFile)) {
        Write-Host "[FAIL] SKILL.md unreachable through link: $($skill.Name)" -ForegroundColor Red
        $failures++
        continue
    }
    Write-Host "[ ok ] $($skill.Name) -> $target"
}

if ($failures -eq 0) {
    Write-Host "[smoke] INSTALLED STATE OK ($($skills.Count) skills)" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[smoke] FAILED ($failures problem(s)); re-run scripts/install-user.ps1" -ForegroundColor Red
    exit 1
}