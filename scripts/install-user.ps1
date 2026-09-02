#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Install (link) every flat skill of this repository into ~/.agents/skills.

.DESCRIPTION
    Windows: directory junction (no admin required).
    macOS/Linux: symbolic link.
    Idempotent: keeps correct links, repairs wrong ones, prunes stale links
    that point into this checkout. Re-run after `git pull`.

.NOTES
    Cross-platform PowerShell (pwsh 6+). Runs once per machine.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Split-Path -Parent $PSScriptRoot)).Path
$targetRoot = Join-Path $HOME '.agents'
$skillsDir = Join-Path $targetRoot 'skills'

function Test-WindowsLike {
    if ($null -ne $IsWindows) { return [bool]$IsWindows }
    return $env:OS -eq 'Windows_NT'
}

function Remove-SkillLink {
    param([Parameter(Mandatory)][string]$Path)
    if (Test-WindowsLike) {
        # Windows PowerShell 5.1 can throw NullReferenceException while removing
        # a directory junction through Remove-Item. rmdir removes the junction
        # itself and never traverses into its target.
        & cmd.exe /d /c rmdir "`"$Path`""
        if ($LASTEXITCODE -ne 0) { throw "Failed to remove junction: $Path" }
    } else {
        Remove-Item -LiteralPath $Path -Force
    }
}

# Collect flat skill directories: direct children of the repo root that contain SKILL.md.
$skills = @(
    Get-ChildItem -Path $repoRoot -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }
)
if ($skills.Count -eq 0) {
    Write-Host '[error] no flat skills found in repository root' -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null

foreach ($skill in $skills) {
    $linkPath = Join-Path $skillsDir $skill.Name
    $isLink = $false
    if (Test-Path $linkPath) {
        $item = Get-Item $linkPath -Force
        $isLink = $null -ne $item.LinkType
        if ($isLink) {
            $target = ($item.Target -join '')
            if ($target -eq $skill.FullName) {
                Write-Host "[keep ] $($skill.Name)"
                continue
            }
            Write-Host "[fix  ] $($skill.Name) (target changed)"
        } else {
            Write-Warning "[skip ] $($skill.Name): $linkPath exists and is not a link (review manually)"
            continue
        }
        Remove-SkillLink $linkPath
    }
    if (Test-WindowsLike) {
        New-Item -ItemType Junction -Path $linkPath -Target $skill.FullName | Out-Null
    } else {
        New-Item -ItemType SymbolicLink -Path $linkPath -Target $skill.FullName | Out-Null
    }
    Write-Host "[link ] $($skill.Name) -> $($skill.FullName)"
}

# Prune stale links in ~/.agents/skills that point into this checkout but no
# longer correspond to a skill here. Never touches unrelated user skills.
$known = @($skills | ForEach-Object { $_.Name })
Get-ChildItem -Path $skillsDir -Force | Where-Object { $null -ne $_.LinkType } | ForEach-Object {
    $target = ($_.Target -join '')
    if ($target.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase) -and $known -notcontains $_.Name) {
        Write-Host "[prune] $($_.Name) (stale)"
        Remove-SkillLink $_.FullName
    }
}

Write-Host ''
Write-Host "[done ] $($skills.Count) skill link(s) ensured in $skillsDir" -ForegroundColor Green
exit 0