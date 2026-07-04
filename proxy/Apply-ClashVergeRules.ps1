param(
    [string]$VergeRoot = (Join-Path $env:APPDATA "io.github.clash-verge-rev.clash-verge-rev"),
    [string]$RulesPath = (Join-Path $PSScriptRoot "rules.yml"),
    [string]$TargetMapPath = "",
    [switch]$NoReload
)

$ErrorActionPreference = "Stop"

function Read-Utf8Lines {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "File not found: $Path"
    }

    return [System.IO.File]::ReadAllLines($Path, [System.Text.Encoding]::UTF8)
}

function Write-Utf8Lines {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string[]]$Lines
    )

    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllLines($Path, $Lines, $encoding)
}

function Unquote-Scalar {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Value)

    $trimmed = $Value.Trim()
    if (($trimmed.StartsWith('"') -and $trimmed.EndsWith('"')) -or
        ($trimmed.StartsWith("'") -and $trimmed.EndsWith("'"))) {
        return $trimmed.Substring(1, $trimmed.Length - 2)
    }

    return $trimmed
}

function Quote-YamlString {
    param([Parameter(Mandatory = $true)][string]$Value)

    return '"' + $Value.Replace("\", "\\").Replace('"', '\"') + '"'
}

function Resolve-TargetMapPath {
    param(
        [Parameter(Mandatory = $true)][string]$VergeRoot,
        [string]$RequestedPath
    )

    if ($RequestedPath) {
        if (-not (Test-Path -LiteralPath $RequestedPath)) {
            throw "Target map file not found: $RequestedPath"
        }

        return $RequestedPath
    }

    $preferred = Join-Path $VergeRoot "codex-proxy-targets.yml"
    if (Test-Path -LiteralPath $preferred) {
        return $preferred
    }

    $legacy = Join-Path $HOME ".config\clash\codex-proxy-targets.yml"
    if (Test-Path -LiteralPath $legacy) {
        return $legacy
    }

    throw "Target map file not found. Create one at $preferred or pass -TargetMapPath."
}

function Read-TargetMap {
    param([Parameter(Mandatory = $true)][string]$Path)

    $targets = @{}
    $inTargets = $false

    foreach ($line in Read-Utf8Lines -Path $Path) {
        if ($line -match '^\s*(#.*)?$') {
            continue
        }

        if ($line -match '^\s*targets:\s*$') {
            $inTargets = $true
            continue
        }

        if ($inTargets -and $line -match '^\s{2,}([^:#]+):\s*(.+?)\s*$') {
            $targets[$matches[1].Trim()] = Unquote-Scalar -Value $matches[2]
            continue
        }

        if ($inTargets -and $line -match '^\S') {
            $inTargets = $false
        }
    }

    if ($targets.Count -eq 0) {
        throw "No targets were found in target map: $Path"
    }

    return $targets
}

function Read-OverlayRules {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][hashtable]$Targets
    )

    $rules = @()
    $inPrependRules = $false

    foreach ($line in Read-Utf8Lines -Path $Path) {
        if ($line -match '^\s*prepend-rules:\s*$') {
            $inPrependRules = $true
            continue
        }

        if (-not $inPrependRules) {
            continue
        }

        if ($line -match '^\s*-\s*(.+?)\s*$') {
            $rawRule = Unquote-Scalar -Value $matches[1]
            $parts = $rawRule.Split(',', 3)
            if ($parts.Count -ne 3) {
                throw "Invalid prepend rule. Expected RULE-TYPE,value,logical-target: $rawRule"
            }

            $logicalTarget = $parts[2].Trim()
            if (-not $Targets.ContainsKey($logicalTarget)) {
                throw "No local target mapping for logical target '$logicalTarget'."
            }

            $rules += [pscustomobject]@{
                Type          = $parts[0].Trim()
                Value         = $parts[1].Trim()
                LogicalTarget = $logicalTarget
                Target        = [string]$Targets[$logicalTarget]
            }
            continue
        }

        if ($line -match '^\S' -and $line -notmatch '^\s*#') {
            $inPrependRules = $false
        }
    }

    return $rules
}

function Read-ProfilesConfig {
    param([Parameter(Mandatory = $true)][string]$Path)

    $current = $null
    $items = @()
    $item = $null
    $inOption = $false

    foreach ($line in Read-Utf8Lines -Path $Path) {
        if ($line -match '^current:\s*(.+?)\s*$') {
            $current = $matches[1].Trim()
            continue
        }

        if ($line -match '^- uid:\s*(.+?)\s*$') {
            if ($null -ne $item) {
                $items += [pscustomobject]$item
            }

            $item = [ordered]@{
                uid    = $matches[1].Trim()
                option = @{}
            }
            $inOption = $false
            continue
        }

        if ($null -eq $item) {
            continue
        }

        if ($line -match '^\s{2}option:\s*$') {
            $inOption = $true
            continue
        }

        if ($inOption -and $line -match '^\s{4}([^:]+):\s*(.*?)\s*$') {
            $item.option[$matches[1].Trim()] = Unquote-Scalar -Value $matches[2]
            continue
        }

        if ($inOption -and $line -match '^\s{2}\S') {
            $inOption = $false
        }

        if ($line -match '^\s{2}([^:]+):\s*(.*?)\s*$') {
            $key = $matches[1].Trim()
            if ($key -ne "option") {
                $item[$key] = Unquote-Scalar -Value $matches[2]
            }
        }
    }

    if ($null -ne $item) {
        $items += [pscustomobject]$item
    }

    if (-not $current) {
        throw "No current profile was found in: $Path"
    }

    return [pscustomobject]@{
        Current = $current
        Items   = $items
    }
}

function Get-ActiveRulesProfilePath {
    param([Parameter(Mandatory = $true)][string]$VergeRoot)

    $profilesYamlPath = Join-Path $VergeRoot "profiles.yaml"
    $profiles = Read-ProfilesConfig -Path $profilesYamlPath
    $currentItem = $profiles.Items | Where-Object { $_.uid -eq $profiles.Current } | Select-Object -First 1
    if (-not $currentItem) {
        throw "Current profile '$($profiles.Current)' was not found in: $profilesYamlPath"
    }

    $rulesUid = $currentItem.option["rules"]
    if (-not $rulesUid) {
        throw "Current profile '$($profiles.Current)' does not have an option.rules profile."
    }

    $rulesItem = $profiles.Items | Where-Object { $_.uid -eq $rulesUid } | Select-Object -First 1
    if (-not $rulesItem) {
        throw "Rules profile '$rulesUid' was not found in: $profilesYamlPath"
    }

    if (-not $rulesItem.file) {
        throw "Rules profile '$rulesUid' does not have a file field."
    }

    return Join-Path (Join-Path $VergeRoot "profiles") $rulesItem.file
}

function Get-ClashScalar {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    $pattern = '^\s*' + [regex]::Escape($Name) + ':\s*(.+?)\s*$'
    foreach ($line in Read-Utf8Lines -Path $Path) {
        if ($line -match $pattern) {
            return Unquote-Scalar -Value $matches[1]
        }
    }

    return $null
}

function Reload-MihomoRuntime {
    param([Parameter(Mandatory = $true)][string]$VergeRoot)

    $runtimePath = Join-Path $VergeRoot "clash-verge.yaml"
    if (-not (Test-Path -LiteralPath $runtimePath)) {
        Write-Warning "Runtime config not found, skipped controller reload: $runtimePath"
        return
    }

    $configPath = Join-Path $VergeRoot "config.yaml"
    $controller = Get-ClashScalar -Path $configPath -Name "external-controller"
    if (-not $controller) {
        $controller = "127.0.0.1:9097"
    }

    if ($controller -notmatch '^https?://') {
        $controller = "http://$controller"
    }

    $secret = Get-ClashScalar -Path $configPath -Name "secret"
    $headers = @{}
    if ($secret) {
        $headers["Authorization"] = "Bearer $secret"
    }

    $body = @{ path = $runtimePath } | ConvertTo-Json -Compress
    Invoke-RestMethod -Method Put -Uri ($controller.TrimEnd('/') + "/configs?force=true") -Headers $headers -Body $body -ContentType "application/json" -TimeoutSec 5 | Out-Null
}

$resolvedVergeRoot = [System.IO.Path]::GetFullPath($VergeRoot)
$resolvedRulesPath = [System.IO.Path]::GetFullPath($RulesPath)
$resolvedTargetMapPath = Resolve-TargetMapPath -VergeRoot $resolvedVergeRoot -RequestedPath $TargetMapPath

$targets = Read-TargetMap -Path $resolvedTargetMapPath
$rules = Read-OverlayRules -Path $resolvedRulesPath -Targets $targets
$activeRulesProfilePath = Get-ActiveRulesProfilePath -VergeRoot $resolvedVergeRoot

$rendered = @(
    "# Profile Enhancement Rules Template for Clash Verge",
    "# Generated by personal-config/proxy/Apply-ClashVergeRules.ps1",
    "# Source: $resolvedRulesPath",
    "# Target map: $resolvedTargetMapPath"
)

if ($rules.Count -eq 0) {
    $rendered += "prepend: []"
}
else {
    $rendered += "prepend:"
    foreach ($rule in $rules) {
        $rendered += "  - " + (Quote-YamlString -Value "$($rule.Type),$($rule.Value),$($rule.Target)")
    }
}

$rendered += @(
    "",
    "append: []",
    "",
    "delete: []"
)

Write-Utf8Lines -Path $activeRulesProfilePath -Lines $rendered

Write-Host "Wrote Clash Verge Profile Enhancement rules:"
Write-Host "  $activeRulesProfilePath"
Write-Host "Rules generated: $($rules.Count)"

if (-not $NoReload) {
    try {
        Reload-MihomoRuntime -VergeRoot $resolvedVergeRoot
        Write-Host "Requested Mihomo runtime reload."
    }
    catch {
        Write-Warning "Generated the profile rules, but controller reload failed: $($_.Exception.Message)"
    }
}
