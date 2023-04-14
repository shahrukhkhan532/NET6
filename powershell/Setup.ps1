param (
    [Parameter(Mandatory = $true)]
    [string]$branch,
    [Parameter(Mandatory = $true)]
    [string]$github__actor,
    [Parameter(Mandatory = $true)]
    [string]$username,
    [Parameter(Mandatory = $true)]
    [string]$password,
    [Parameter(Mandatory = $true)]
    [string]$machine__ip
)
function Add-DirectoryIfNotExists {
    param (
        [string]$path
    )
    if (-not (Test-Path -Path $path)) {
        New-Item -ItemType Directory -Path $path
    }
}
function Add-LogFileIfNotExists {
    param (
        [string]$path,
        [string]$fileName
    )

    $logFilePath = Join-Path -Path $path -ChildPath $fileName
    if (-not (Test-Path -Path $logFilePath)) {
        New-Item -ItemType File -Path $logFilePath -ErrorAction Stop
    }
    "" > $logFilePath
    return $logFilePath
}
function Set-TrustedHosts {
    param (
        [string]$machine__ip
    )
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $machine__ip -Concatenate -Force
}
function Get-Config {
    param (
        [string]$branch,
        [string]$baseDestinationDir
    )

    $config = @{
        'staging' = @{
            'sourcePath'               = (".\${branch}_out")
            'appPoolName'              = 'API'
            'CT__appPoolName'          = 'CareTrackerAPI'
            'CT__sourcePath'           = ".\$branch_CTout"
            'CT__destinationPath'      = Join-Path -Path $baseDestinationDir -ChildPath 'Working Directory\CareTrackerAPI'
            'destinationPath'          = Join-Path -Path $baseDestinationDir -ChildPath 'Working Directory\API'
            'Reports__destinationPath' = Join-Path -Path $baseDestinationDir -ChildPath 'Working Directory\APIReports\bin'
            'SQL_LOG_File_Path'        = Join-Path -Path $baseDestinationDir -ChildPath "${branch}_SQL_Logs\$((Get-Date -UFormat "%d-%m-%Y") + '.log')"
            'BUILD_LOG_File_Path'      = Join-Path -Path $baseDestinationDir -ChildPath "${branch}_Build_Logs\$((Get-Date -UFormat "%d-%m-%Y") + '.log')"
            'URL__Webhook'             = 'https://icaremanagerllc.webhook.office.com/webhookb2/d3a03a5f'
        }
        'master'  = @{
            'sourcePath'               = (".\${branch}_out")
            'appPoolName'              = 'API-Sandbox'
            'CT__appPoolName'          = 'CT-Sandbox'
            'CT__sourcePath'           = ".\$branch_CTout"
            'CT__destinationPath'      = Join-Path -Path $baseDestinationDir -ChildPath 'Working Directory - Sandbox\CareTrackerAPI'
            'Reports__destinationPath' = Join-Path -Path $baseDestinationDir -ChildPath 'Working Directory - Sandbox\APIReports\bin'
            'destinationPath'          = Join-Path -Path $baseDestinationDir -ChildPath 'Working Directory - Sandbox\API'
            'SQL_LOG_File_Path'        = Join-Path -Path $baseDestinationDir -ChildPath "${branch}_SQL_Logs\$((Get-Date -UFormat "%d-%m-%Y") + '.log')"
            'BUILD_LOG_File_Path'      = Join-Path -Path $baseDestinationDir -ChildPath "${branch}_Build_Logs\$((Get-Date -UFormat "%d-%m-%Y") + '.log')"
            'URL__Webhook'             = 'https://icaremanagerllc.webhook.office.com/webhookb2/bf69bc38'
        }
    }

    return $config[$branch]
}

$baseDestinationDir = 'Z:'
Set-TrustedHosts -machine__ip $machine__ip
net use Z: \\$machine__ip\C$ /user:$username $password
Write-Output "Connected to Drive Successfully. ✅"
$config = Get-Config -branch $branch -baseDestinationDir $baseDestinationDir

if ($null -eq $config) {
    Write-Output "The branch is unknown.❌"
    exit 1
}
foreach ($key in $config.Keys) {
    [System.Environment]::SetEnvironmentVariable($key, $config[$key], "User")
}
[System.Environment]::SetEnvironmentVariable("branch", "$branch", "User")

# foreach ($key in $config.Keys) {
#     $val = [System.Environment]::GetEnvironmentVariable($key, "User")
#     Write-Output ("$key = $val")
# }

$User = Invoke-RestMethod -Method Get -Uri ("https://api.github.com/users/$github__actor")
$username = @{$true = $User.login; $false = $User.name }[[string]::IsNullOrEmpty($User.name)]
[System.Environment]::SetEnvironmentVariable("Developer__Name", "$username", "User")