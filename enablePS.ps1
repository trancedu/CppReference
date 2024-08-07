$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -Command `"Enable-PSRemoting -Force; gpupdate /force`""
$trigger = New-ScheduledTaskTrigger -Daily -At 3am
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings -TaskName "EnableWinRMTask" -Description "Enable WinRM and update group policy"

# Define the PowerShell command to run
$command = 'Enable-PSRemoting -Force'

# Create the scheduled task action
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""

# Define the PowerShell command to run
$psCommand = 'Enable-PSRemoting -Force'

# Create the scheduled task action using cmd.exe to invoke PowerShell
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `"$psCommand`""
