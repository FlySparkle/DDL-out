param(
  [Parameter(Mandatory = $true)][string]$Bundle
)
$ErrorActionPreference = 'Stop'
$bundlePath = (Resolve-Path -LiteralPath $Bundle).Path
$executable = Join-Path $bundlePath 'ddl_out.exe'
$harness = Join-Path $bundlePath 'alarm_scheduler_test.exe'
if (-not (Test-Path -LiteralPath $executable) -or -not (Test-Path -LiteralPath $harness)) {
  throw 'Build INSTALL and alarm_scheduler_test, then copy the test harness into the bundle.'
}
if (Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -eq $executable }) {
  throw 'The test bundle must not already be running.'
}
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class AlarmPopupProbe {
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr window);
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr window, uint message, IntPtr w, IntPtr l);
}
'@
$taskId = & $harness create $executable
if ($LASTEXITCODE -ne 0 -or $taskId -notmatch '^\{[0-9A-Fa-f-]{36}\}$') {
  throw 'Test alarm registration failed.'
}
$alarmProcess = $null
try {
  $deadline = (Get-Date).AddSeconds(75)
  do {
    $nativeProcess = Get-CimInstance Win32_Process | Where-Object {
      $_.ExecutablePath -eq $executable -and $_.CommandLine -like ('*--ddl-alarm ' + $taskId + '*')
    }
    if ($nativeProcess) {
      $alarmProcess = Get-Process -Id $nativeProcess.ProcessId
      $alarmProcess.Refresh()
      if ($alarmProcess.MainWindowHandle -ne 0 -and
          [AlarmPopupProbe]::IsWindowVisible($alarmProcess.MainWindowHandle)) { break }
    }
    Start-Sleep -Milliseconds 500
  } while ((Get-Date) -lt $deadline)
  if (-not $alarmProcess -or $alarmProcess.MainWindowHandle -eq 0) { throw 'No alarm popup appeared.' }
  if ($alarmProcess.MainWindowTitle -ne 'DDL out! · Alarm') { throw 'Wrong window launched.' }
  # Hold the process handle so the normal exit code remains available.
  $alarmProcess.Handle | Out-Null
  # WM_CLOSE runs the same Dart dismissal handler as the button. The button's
  # silence/disable/destroy order is covered by system_alarm_test.dart.
  if (-not [AlarmPopupProbe]::PostMessage($alarmProcess.MainWindowHandle, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)) {
    throw 'Could not send normal window-close message.'
  }
  if (-not $alarmProcess.WaitForExit(15000)) { throw 'Alarm did not exit normally.' }
  if ($alarmProcess.ExitCode -ne 0) { throw ('Alarm crash: ' + $alarmProcess.ExitCode) }
  $task = Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskId }
  if ($task.State -ne 'Disabled') { throw 'Dismissed alarm task is still enabled.' }
  Write-Output 'PASS: fresh scheduler-launched visible popup, normal dismissal, exit code 0, task disabled.'
} finally {
  if ($alarmProcess -and -not $alarmProcess.HasExited) {
    # Only the disposable process whose path and unique task ID were verified.
    Stop-Process -Id $alarmProcess.Id
  }
  & $harness delete $taskId
}
