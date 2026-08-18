param(
  [switch]$SkipMoonCommands
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot

function Assert-Condition([bool]$condition, [string]$message) {
  if (-not $condition) {
    throw "ACCEPTANCE CHECK FAILED: $message"
  }
  Write-Output "PASS: $message"
}

function Invoke-Moon([string[]]$arguments) {
  Write-Output ("> moon " + ($arguments -join " "))
  & moon @arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Moon command failed with exit code $LASTEXITCODE."
  }
}

Push-Location $repoRoot
try {
  foreach ($path in @("README.md", "LICENSE", "moon.mod", ".github/workflows/ci.yml", ".github/workflows/publish.yml", "scripts/benchmark.ps1")) {
    Assert-Condition (Test-Path -LiteralPath $path) "required file exists: $path"
  }

  $files = @(Get-ChildItem -LiteralPath $repoRoot -Recurse -File -Force | Where-Object { $_.Extension -eq ".mbt" -and $_.FullName -notmatch "[\\/](?:_build|target|\.git|\.mooncakes|\.moonagent)[\\/]" })
  $production = @($files | Where-Object { $_.Name -notmatch "_test\.mbt$" -and $_.Name -notmatch "_wbtest\.mbt$" })
  $tests = @($files | Where-Object { $_.Name -match "_test\.mbt$|_wbtest\.mbt$" })
  $productionLines = (($production | Get-Content | Measure-Object -Line).Lines)
  $testLines = (($tests | Get-Content | Measure-Object -Line).Lines)
  $totalLines = (($files | Get-Content | Measure-Object -Line).Lines)
  $effectiveProductionLines = 0
  foreach ($file in $production) {
    foreach ($line in (Get-Content -LiteralPath $file.FullName)) {
      $trimmed = $line.Trim()
      if ($trimmed.Length -gt 0 -and -not $trimmed.StartsWith("//")) {
        $effectiveProductionLines++
      }
    }
  }

  Assert-Condition ($effectiveProductionLines -ge 7000 -and $effectiveProductionLines -le 7600) "effective production MoonBit lines are within 7000-7600 (actual: $effectiveProductionLines; physical: $productionLines)"
  Assert-Condition ($tests.Count -ge 55) "test file count >= 55 (actual: $($tests.Count))"
  Assert-Condition (Test-Path -LiteralPath "lib/governance_trace.mbt") "governance trace module exists"
  Assert-Condition (Test-Path -LiteralPath "lib/release_checklist.mbt") "release checklist module exists"
  Assert-Condition ((Get-Content README.md -Raw).Contains("8 月黑客松")) "README identifies the August Hackathon"
  Assert-Condition ((Get-Content README.md -Raw).Contains("benchmarks/latest.md")) "README links measured benchmark evidence"
  Assert-Condition ((Get-Content README.md -Raw).Contains("Apache License 2.0")) "README states the project license"
  Assert-Condition ((Get-Content OSC2026_Hackathon_Proposal.md -Raw).Contains("8月黑客松")) "proposal identifies the August Hackathon"
  Assert-Condition ((Get-Content .github/workflows/ci.yml -Raw).Contains("--target all")) "CI covers all stable targets"
  Assert-Condition ((Get-Content .github/workflows/ci.yml -Raw).Contains("moon update")) "CI updates dependencies"
  Assert-Condition ((Get-Content .github/workflows/ci.yml -Raw).Contains("moon info")) "CI checks generated interfaces"
  Assert-Condition ((Get-Content .github/workflows/publish.yml -Raw).Contains("moon publish")) "publish workflow invokes Mooncakes"
  Assert-Condition ((Get-Content .github/workflows/publish.yml -Raw).Contains("MOONCAKES_TOKEN")) "publish workflow uses a secret"
  Assert-Condition ((Get-Content lib/benchmark_fixtures.mbt -Raw).Contains("snapshot-chain-scan")) "benchmark includes snapshot chain scan"
  Assert-Condition ((Get-Content lib/benchmark_fixtures.mbt -Raw).Contains("governance-reporting")) "benchmark includes governance reporting"
  $cliCommands = Get-Content lib/cli/commands.mbt -Raw
  Assert-Condition ($cliCommands.Contains("govern") -and $cliCommands.Contains("snapshot") -and $cliCommands.Contains("plan") -and $cliCommands.Contains("policy")) "CLI includes governance commands"

  if (-not $SkipMoonCommands) {
    Invoke-Moon @("fmt", "--check")
    Invoke-Moon @("check", "--deny-warn")
    Invoke-Moon @("test", "--deny-warn")
  }

  Write-Output "SUMMARY: effective_production=$effectiveProductionLines physical_production=$productionLines test=$testLines total=$totalLines test_files=$($tests.Count)"
}
finally {
  Pop-Location
}
