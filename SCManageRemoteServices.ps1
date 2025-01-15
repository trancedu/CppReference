# Path to the file containing the list of servers
$serverListPath = "servers.txt"

# Specify the service name you want to stop and start
$serviceName = "YourServiceName"

# Read the list of servers from the file
$servers = Get-Content -Path $serverListPath

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
        Write-Host "Failed to send stop command for $serviceName service on $server: $_"
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
        Write-Host "Failed to send start command for $serviceName service on $server: $_"
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