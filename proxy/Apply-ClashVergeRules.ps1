[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ProfileName,
    [string]$VergeRoot = (Join-Path $env:APPDATA "io.github.clash-verge-rev.clash-verge-rev"),
    [string]$RulesPath = (Join-Path $PSScriptRoot "rules.yml"),
    [string]$TargetMapPath = "",
    [string]$OutputPath = ""
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
            $key = $matches[1].Trim()
            $value = Unquote-Scalar -Value $matches[2]
            if ([string]::IsNullOrWhiteSpace($value) -or $value.Contains(',')) {
                throw "Invalid local target mapping for '$key'."
            }
            $targets[$key] = $value
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
            $parts = @($rawRule.Split(',') | ForEach-Object { $_.Trim() })
            if ($parts.Count -lt 3 -or $parts.Count -gt 4 -or
                @($parts | Where-Object { [string]::IsNullOrWhiteSpace($_) }).Count -gt 0) {
                throw "Invalid rule. Expected RULE-TYPE,value,logical-target[,no-resolve]: $rawRule"
            }
            if ($parts[0] -notin @('DOMAIN', 'DOMAIN-SUFFIX', 'GEOSITE', 'IP-CIDR', 'IP-CIDR6')) {
                throw "Unsupported rule type: $($parts[0])"
            }
            $options = ''
            if ($parts.Count -eq 4) {
                if ($parts[3] -ne 'no-resolve' -or $parts[0] -notin @('IP-CIDR', 'IP-CIDR6')) {
                    throw "Unsupported rule option: $rawRule"
                }
                $options = ',no-resolve'
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
                Options       = $options
            }
            continue
        }

        if ($line -match '^\S' -and $line -notmatch '^\s*#') {
            $inPrependRules = $false
        }
        elseif ($inPrependRules -and $line -notmatch '^\s*(#.*)?$') {
            throw "Invalid rule line: $line"
        }
    }

    if ($rules.Count -eq 0) {
        throw "No prepend rules found in $Path; refusing to clear the active rules."
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
            $current = Unquote-Scalar -Value $matches[1]
            continue
        }

        if ($line -match '^- uid:\s*(.+?)\s*$') {
            if ($null -ne $item) {
                $items += [pscustomobject]$item
            }

            $item = [ordered]@{
                uid    = Unquote-Scalar -Value $matches[1]
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
    param(
        [Parameter(Mandatory = $true)][string]$VergeRoot,
        [Parameter(Mandatory = $true)][string]$ExpectedName
    )

    $profilesYamlPath = Join-Path $VergeRoot "profiles.yaml"
    $profiles = Read-ProfilesConfig -Path $profilesYamlPath
    $currentItem = $profiles.Items | Where-Object { $_.uid -eq $profiles.Current } | Select-Object -First 1
    if (-not $currentItem) {
        throw "Current profile '$($profiles.Current)' was not found in: $profilesYamlPath"
    }
    if ($currentItem.name -ne $ExpectedName) {
        throw "Expected profile '$ExpectedName', but the selected profile is '$($currentItem.name)'. Nothing was written."
    }

    $rulesUid = $currentItem.option["rules"]
    if (-not $rulesUid) {
        throw "Current profile '$($profiles.Current)' does not have an option.rules profile."
    }
    $otherUsers = @($profiles.Items | Where-Object {
        $_.uid -ne $currentItem.uid -and $_.option['rules'] -eq $rulesUid
    })
    if ($otherUsers.Count -gt 0) {
        throw 'The rules enhancement is shared by another profile. Use a separate enhancement before applying personal rules.'
    }

    $rulesItem = $profiles.Items | Where-Object { $_.uid -eq $rulesUid } | Select-Object -First 1
    if (-not $rulesItem) {
        throw "Rules profile '$rulesUid' was not found in: $profilesYamlPath"
    }

    if (-not $rulesItem.file) {
        throw "Rules profile '$rulesUid' does not have a file field."
    }

    if ([IO.Path]::GetFileName($rulesItem.file) -ne $rulesItem.file) {
        throw 'The rules enhancement must be a file inside the Verge profiles directory.'
    }
    return Join-Path (Join-Path $VergeRoot "profiles") $rulesItem.file
}

$resolvedVergeRoot = [System.IO.Path]::GetFullPath($VergeRoot)
$resolvedRulesPath = [System.IO.Path]::GetFullPath($RulesPath)
$resolvedTargetMapPath = Resolve-TargetMapPath -VergeRoot $resolvedVergeRoot -RequestedPath $TargetMapPath

$targets = Read-TargetMap -Path $resolvedTargetMapPath
$rules = Read-OverlayRules -Path $resolvedRulesPath -Targets $targets
$activeRulesProfilePath = Get-ActiveRulesProfilePath -VergeRoot $resolvedVergeRoot -ExpectedName $ProfileName

# Do not discard append/delete edits or unsupported enhancement settings.
if (Test-Path -LiteralPath $activeRulesProfilePath) {
    foreach ($line in Read-Utf8Lines -Path $activeRulesProfilePath) {
        if ($line -match '^\s*(#.*)?$' -or $line -match '^prepend:\s*(\[\])?\s*$' -or
            $line -match '^\s*-\s*.+$' -or $line -match '^(append|delete):\s*\[\]\s*$') {
            continue
        }
        throw 'The enhancement contains additional settings or nonempty append/delete rules. Merge those manually before applying.'
    }
}

$rendered = @(
    "# Profile Enhancement Rules Template for Clash Verge",
    "# Generated by personal-config/proxy/Apply-ClashVergeRules.ps1",
    "# Source: $resolvedRulesPath",
    "# Target map: $resolvedTargetMapPath"
)

$rendered += "prepend:"
foreach ($rule in $rules) {
    $rendered += "  - " + (Quote-YamlString -Value "$($rule.Type),$($rule.Value),$($rule.Target)$($rule.Options)")
}

$rendered += @(
    "",
    "append: []",
    "",
    "delete: []"
)

$destination = $activeRulesProfilePath
if ($OutputPath) {
    $destination = [IO.Path]::GetFullPath($OutputPath)
}
if ($PSCmdlet.ShouldProcess($destination, "Write $($rules.Count) personal rules for '$ProfileName'")) {
    Write-Utf8Lines -Path $destination -Lines $rendered
    Write-Host "Wrote $($rules.Count) rules: $destination"
    if (-not $OutputPath) {
        Write-Host 'Reapply the profile in Clash Verge to compose and activate changed rules. This script does not reload the runtime.'
    }
}
