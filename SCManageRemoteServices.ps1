# Allow the user to pass the service name as a script argument
param (
    [string]$serviceName
)

# Prompt for service name if not provided
if (-not $serviceName) {
    $serviceName = Read-Host "Please enter the service name"
}

# Path to the file containing the list of servers
$serverListPath = "servers.txt"

# Read the list of servers from the file
$servers = Get-Content -Path $serverListPath

# Initialize an error list as a global variable
$global:errors = @()

# Function to stop a service on a server
function Stop-ServiceOnServer {
    param (
        [string]$server,
        [string]$serviceName
    )
    try {
        Write-Host "Stopping $serviceName service on $server..."
        $stopCommand = "sc.exe \\$server stop $serviceName"
        Invoke-Expression $stopCommand
        Write-Host "$serviceName service stop command sent to $server."
    } catch {
        Write-Host "Failed to send stop command for $serviceName service on $server: $_" -ForegroundColor Red
        $global:errors += "Stop failed on $server"
        Write-Host "Current error count: $($global:errors.Count)" -ForegroundColor Yellow
    }
}

# Function to start a service on a server
function Start-ServiceOnServer {
    param (
        [string]$server,
        [string]$serviceName
    )
    try {
        Write-Host "Starting $serviceName service on $server..."
        $startCommand = "sc.exe \\$server start $serviceName"
        Invoke-Expression $startCommand
        Write-Host "$serviceName service start command sent to $server."
    } catch {
        Write-Host "Failed to send start command for $serviceName service on $server: $_" -ForegroundColor Red
        $global:errors += "Start failed on $server"
        Write-Host "Current error count: $($global:errors.Count)" -ForegroundColor Yellow
    }
}

# Function to query the status of a service on a server
function Query-ServiceStatus {
    param (
        [string]$server,
        [string]$serviceName
    )
    try {
        Write-Host "Querying status of $serviceName service on $server..."
        $queryResult = & sc.exe \\$server queryex $serviceName 2>&1
        $queryResultString = $queryResult -join "`n"  # Convert to a single string
        Write-Host $queryResultString  # Debugging: Print the output to verify its content
        if ($queryResultString -notmatch "STATE\s*:\s*4\s*RUNNING") {
            Write-Host "Service $serviceName is not running on $server." -ForegroundColor Yellow
            $global:errors += "Service not running on $server"
        } else {
            Write-Host "Service $serviceName is running on $server." -ForegroundColor Green
        }
    } catch {
        Write-Host "Failed to query status for $serviceName service on $server." -ForegroundColor Red
        $global:errors += "Query failed on $server"
    }
}

# Prompt user for operation choice
$choice = Read-Host "Enter 1 to Stop, Start, and Query; 2 to Start and Query; 3 to only Query"

# Execute operations based on user choice
foreach ($server in $servers) {
    if ($choice -eq "1") {
        Stop-ServiceOnServer -server $server -serviceName $serviceName
    } 
    if ($choice -eq "1" -or $choice -eq "2") {
        Start-ServiceOnServer -server $server -serviceName $serviceName
    }
    if ($choice -eq "1" -or $choice -eq "2" -or $choice -eq "3") {
        Query-ServiceStatus -server $server -serviceName $serviceName
    }
}

# Display any errors
if ($global:errors.Count -gt 0) {
    Write-Host "`nErrors encountered:" -ForegroundColor Red
    $global:errors | ForEach-Object { Write-Host $_ -ForegroundColor Red }
} else {
    Write-Host "`nAll operations completed successfully." -ForegroundColor Green
}