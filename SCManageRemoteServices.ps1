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

# Initialize an error list
$errors = @()

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
        Write-Host "Failed to send stop command for $serviceName service on $server." -ForegroundColor Red
        $errors += "Stop failed on $server"
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
        Write-Host "Failed to send start command for $serviceName service on $server." -ForegroundColor Red
        $errors += "Start failed on $server"
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
        $queryResult = sc.exe \\$server queryex $serviceName
        if ($queryResult -notmatch "STATE\s*:\s*4\s*RUNNING") {
            Write-Host "Service $serviceName is not running on $server." -ForegroundColor Yellow
            $errors += "Service not running on $server"
        }
    } catch {
        Write-Host "Failed to query status for $serviceName service on $server." -ForegroundColor Red
        $errors += "Query failed on $server"
    }
}

# Stop the service on all servers
foreach ($server in $servers) {
    Stop-ServiceOnServer -server $server -serviceName $serviceName
}

# Wait for a few seconds to ensure all services are stopped
Start-Sleep -Seconds 5

# Start the service on all servers
foreach ($server in $servers) {
    Start-ServiceOnServer -server $server -serviceName $serviceName
}

# Query the status of the service on all servers
foreach ($server in $servers) {
    Query-ServiceStatus -server $server -serviceName $serviceName
}

# Display any errors
if ($errors.Count -gt 0) {
    Write-Host "`nErrors encountered:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host $_ -ForegroundColor Red }
} else {
    Write-Host "`nAll operations completed successfully." -ForegroundColor Green
}