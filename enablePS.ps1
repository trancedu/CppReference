# C:\service\EnablePSRemoting.ps1

# Define the log file path
$logFile = "C:\service\EnablePSRemoting.log"

# Write start time to the log file
"Start: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $logFile -Append

# Enable PSRemoting
Enable-PSRemoting -Force

# Write operation message to the log file
"PSRemoting Enabled" | Out-File -FilePath $logFile -Append

# Write end time to the log file
"End: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $logFile -Append


# Define the path to the PowerShell script
$scriptPath = "C:\service\EnablePSRemoting.ps1"

# Create the scheduled task action using cmd.exe to invoke PowerShell
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

# Create the trigger to run once, one minute from now
$trigger = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddMinutes(1))

# Create the principal to run as SYSTEM with the highest privileges
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Create the settings
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

# Register the scheduled task
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings -TaskName "EnableWinRMTask" -Description "Enable WinRM"

# Output the task for verification
Get-ScheduledTask -TaskName "EnableWinRMTask"
