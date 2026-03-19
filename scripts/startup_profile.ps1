param(
  [string]$PackageName = "io.gitjournal.gitjournal",
  [string]$ActivityName = "io.gitjournal.gitjournal.MainActivity",
  [string]$DeviceId = "",
  [int]$Runs = 3,
  [int]$SleepSeconds = 1
)

$adbPrefix = @()
if (-not [string]::IsNullOrWhiteSpace($DeviceId)) {
  $adbPrefix = @("-s", $DeviceId)
}
$component = "$PackageName/$ActivityName"

$times = @()

for ($i = 1; $i -le $Runs; $i++) {
  Write-Host "Run $i/$Runs ..."
  & adb @adbPrefix shell am force-stop $PackageName | Out-Null
  Start-Sleep -Seconds $SleepSeconds

  $output = & adb @adbPrefix shell am start -W $component
  $waitLine = $output | Select-String "WaitTime"

  if ($waitLine) {
    $val = [int](($waitLine -replace '.*WaitTime:\s*', '').Trim())
    $times += $val
    Write-Host "  WaitTime: ${val}ms"
  } else {
    Write-Warning "  WaitTime not found"
  }
}

if ($times.Count -eq 0) {
  Write-Error "No startup timings were collected."
  exit 1
}

$avg = [math]::Round((($times | Measure-Object -Average).Average), 1)
$min = ($times | Measure-Object -Minimum).Minimum
$max = ($times | Measure-Object -Maximum).Maximum

Write-Host ""
Write-Host "Startup summary ($Runs runs):"
Write-Host "  Avg: ${avg}ms"
Write-Host "  Min: ${min}ms"
Write-Host "  Max: ${max}ms"
Write-Host "  All: $($times -join ', ')"
