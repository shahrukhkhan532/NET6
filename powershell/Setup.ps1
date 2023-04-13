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

net use Z: \\$machine__ip\C$ /user:$username $password
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $machine__ip -Concatenate -Force

$branch = "staging"
$baseDestinationDir = "Z:"

$path__SQL__To__Directory = ""
$path__Build__To__Directory = ""
$URL__Webhook = ""
          
$sourcePath = (".\" + $branch + "_out")
$destinationPath = ""
$appPoolName = ""
          
$CT__appPoolName = ""
$CT__destinationPath = ""
$CT__sourcePath = (".\" + $branch + "_CTout")
          
$Reports__destinationPath = ""
switch ($branch) {
    "staging" {
        $Reports__destinationPath = "Z:\Working Directory\APIReports\bin"
        $appPoolName = "API"
        $destinationPath = "Z:\Working Directory\API"
        $CT__appPoolName = "CareTrackerAPI"
        $CT__destinationPath = "Z:\Working Directory\CareTrackerAPI"
        $CT__sourcePath = (".\" + $branch + "_CTout")
        $path__SQL__To__Directory = Join-Path -Path $baseDestinationDir -ChildPath "${branch}_SQL_Logs"
        $path__Build__To__Directory = Join-Path -Path $baseDestinationDir -ChildPath "${branch}_Build_Logs"
        $URL__Webhook = "https://icaremanagerllc.webhook.office.com/webhookb2/d3a03a5f-65bc-4bd7-9dd3-58953f34a223@89e9d208-fb4a-4579-a02e-ae453b60c3a6/IncomingWebhook/3455d9958ea94d459fb034b46426e612/22a4babb-2d32-4af5-bb41-4df9d477e8a8"
    }
    "master" {
        $Reports__destinationPath = "Z:\Working Directory - Sandbox\APIReports\bin"
        $appPoolName = "API-Sandbox"
        $destinationPath = "Z:\Working Directory - Sandbox\API"
        $CT__appPoolName = "CT-Sandbox"
        $CT__destinationPath = "Z:\Working Directory - Sandbox\CareTrackerAPI"
        $CT__sourcePath = (".\" + $branch + "_CTout")
        $path__SQL__To__Directory = ("C:\Users\" + $env:USERNAME + "\actions-runner-sandbox-api\" + $branch + "_SQL_Logs")
        $path__Build__To__Directory = ("C:\Users\" + $env:USERNAME + "\actions-runner-sandbox-api\" + $branch + "_Build_Logs")
        $URL__Webhook = "https://icaremanagerllc.webhook.office.com/webhookb2/bf69bc38-8713-4cf6-a1fd-0c87a7601bb7@89e9d208-fb4a-4579-a02e-ae453b60c3a6/IncomingWebhook/502cd05e24774afdbe883905ce7edf6d/8e024608-9591-4ea0-bab2-13d07d76ef11"
    }
    Default {
        Write-Output "The branch is unknown."
        exit 1
    }
}

"appPoolName=$appPoolName" >> $Env:GITHUB_OUTPUT
"destinationPath=$destinationPath" >> $Env:GITHUB_OUTPUT
"sourcePath=$sourcePath" >> $Env:GITHUB_OUTPUT
"URL__Webhook=$URL__Webhook" >> $Env:GITHUB_OUTPUT
"CT__appPoolName=$CT__appPoolName" >> $Env:GITHUB_OUTPUT
"CT__destinationPath=$CT__destinationPath" >> $Env:GITHUB_OUTPUT
"CT__sourcePath=$CT__sourcePath" | Out-File -FilePath $Env:GITHUB_OUTPUT
"Reports__destinationPath=$Reports__destinationPath" >> $Env:GITHUB_OUTPUT

$SQL_LOG_File_Path = ($path__SQL__To__Directory + "\" + (Get-Date -UFormat "%d-%m-%Y") + ".html")
$BUILD_LOG_File_Path = ($path__Build__To__Directory + "\" + (Get-Date -UFormat "%d-%m-%Y") + ".log")

if (-not (Test-Path -Path $path__SQL__To__Directory)) {
    New-Item -ItemType Directory -Path $path__SQL__To__Directory
}
(Test-Path -Path $SQL_LOG_File_Path) -eq $false | New-Item -ItemType File -Path $SQL_LOG_File_Path -ErrorAction SilentlyContinue
"" > $SQL_LOG_File_Path


if (-not (Test-Path -Path $path__Build__To__Directory)) {
    New-Item -ItemType Directory -Path $path__Build__To__Directory
}
(Test-Path -Path $BUILD_LOG_File_Path) -eq $false | New-Item -ItemType File -Path $BUILD_LOG_File_Path -ErrorAction SilentlyContinue
"" > $BUILD_LOG_File_Path

"SQL_LOG_File_Path=$SQL_LOG_File_Path" >> $Env:GITHUB_OUTPUT
"BUILD_LOG_File_Path=$BUILD_LOG_File_Path" >> $Env:GITHUB_OUTPUT

$User = Invoke-RestMethod -Method Get -Uri ("https://api.github.com/users/" + $github__actor)
$username = @{$true = $User.login; $false = $User.name }[[string]::IsNullOrEmpty($User.name)]
"Developer__Name=$username" >> $Env:GITHUB_OUTPUT

$message = (Get-Content $Env:GITHUB_OUTPUT) | Out-String
Write-Output $message


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