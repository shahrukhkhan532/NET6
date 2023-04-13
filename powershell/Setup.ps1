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
        New-Item -ItemType File -Path $logFilePath -ErrorAction SilentlyContinue
    }
    "" > $logFilePath
    return $logFilePath
}
function Set-TrustedHosts {
    param (
        [string]$machine__ip
    )
    net use Z: \\$machine__ip\C$ /user:$username $password
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $machine__ip -Concatenate -Force
}

function Get-Config {
    param (
        [string]$branch,
        [string]$baseDestinationDir
    )

    $config = @{
        'staging' = @{
            'Reports__destinationPath'   = 'Z:\Working Directory\APIReports\bin'
            'appPoolName'                = 'API'
            'destinationPath'            = 'Z:\Working Directory\API'
            'CT__appPoolName'            = 'CareTrackerAPI'
            'CT__destinationPath'        = 'Z:\Working Directory\CareTrackerAPI'
            'CT__sourcePath'             = ".\$branch_CTout"
            'path__SQL__To__Directory'   = Join-Path -Path $baseDestinationDir -ChildPath "${branch}_SQL_Logs"
            'path__Build__To__Directory' = Join-Path -Path $baseDestinationDir -ChildPath "${branch}_Build_Logs"
            'URL__Webhook'               = 'https://icaremanagerllc.webhook.office.com/webhookb2/d3a03a5f'
        }
        'master'  = @{
            'Reports__destinationPath'   = 'Z:\Working Directory - Sandbox\APIReports\bin'
            'appPoolName'                = 'API-Sandbox'
            'destinationPath'            = 'Z:\Working Directory - Sandbox\API'
            'CT__appPoolName'            = 'CT-Sandbox'
            'CT__destinationPath'        = 'Z:\Working Directory - Sandbox\CareTrackerAPI'
            'CT__sourcePath'             = ".\$branch_CTout"
            'path__SQL__To__Directory'   = "C:\Users\$env:USERNAME\actions-runner-sandbox-api\$branch_SQL_Logs"
            'path__Build__To__Directory' = "C:\Users\$env:USERNAME\actions-runner-sandbox-api\$branch_Build_Logs"
            'URL__Webhook'               = 'https://icaremanagerllc.webhook.office.com/webhookb2/bf69bc38'
        }
    }

    return $config[$branch]
}

$baseDestinationDir = 'Z:'
$branch = "staging"

Set-TrustedHosts -machine__ip $machine__ip

$config = Get-Config -branch $branch -baseDestinationDir $baseDestinationDir

if ($null -eq $config) {
    Write-Output "The branch is unknown."
    exit 1
}

foreach ($key in $config.Keys) {
    "$key=$($config[$key])" >> $Env:GITHUB_OUTPUT
}

Add-DirectoryIfNotExists -path $config['path__SQL__To__Directory']
Add-DirectoryIfNotExists -path $config['path__Build__To__Directory']

$SQL_LOG_File_Path = Add-LogFileIfNotExists -path $config['path__SQL__To__Directory'] -fileName (Get-Date -UFormat "%d-%m-%Y") + ".html"
$BUILD_LOG_File_Path = Add-LogFileIfNotExists -path $config['path__Build__To__Directory'] -fileName (Get-Date -UFormat "%d-%m-%Y") + ".log"

"SQL_LOG_File_Path=$SQL_LOG_File_Path" >> $Env:GITHUB_OUTPUT
"BUILD_LOG_File_Path=$BUILD_LOG_File_Path" >> $Env:GITHUB_OUTPUT


# Invoke-Command -ComputerName $machine__ip -Credential $credential -ScriptBlock {
#     param(
#         $path__SQL__To__Directory,
#         $SQL_LOG_File_Path
#     )
#     Write-Output "Connected to staging"
#     # if (-not (Test-Path -Path $path__SQL__To__Directory)) {
#     #     New-Item -ItemType Directory -Path $path__SQL__To__Directory
#     # }
#     # (Test-Path -Path $SQL_LOG_File_Path) -eq $false | New-Item -ItemType File -Path $SQL_LOG_File_Path -ErrorAction SilentlyContinue
#     # "" > $SQL_LOG_File_Path
# } -ArgumentList $path__SQL__To__Directory, $SQL_LOG_File_Path