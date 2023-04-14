param (
    [Parameter(Mandatory = $true)]
    [string]$branch,
    [Parameter(Mandatory = $true)]
    [string]$appPoolName,
    [Parameter(Mandatory = $true)]
    [string]$sourcePath,
    [Parameter(Mandatory = $true)]
    [string]$destinationPath,
    [Parameter(Mandatory = $true)]
    [string]$machine__ip,
    [Parameter(Mandatory = $true)]
    [string]$username,
    [Parameter(Mandatory = $true)]
    [string]$password
)

function Write-DeploymentInfo {
    param(
        $branch,
        $appPoolName,
        $sourcePath,
        $destinationPath
    )
    Write-Output ($branch + " Branch Deployment. App Pool: " + $appPoolName + ", Source: " + $sourcePath + ", Destination: " + $destinationPath)
}
function Create-Credential {
    param(
        $username,
        $password
    )
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
    return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword
}
function Stop-AppPool {
    param(
        $appPoolName,
        $credential,
        $machine__ip
    )
    Invoke-Command -ComputerName $machine__ip -Credential $credential -ScriptBlock {
        param($appPoolName)
        C:\Windows\system32\inetsrv\AppCmd.exe stop apppool /apppool.name:$appPoolName
    } -ArgumentList $appPoolName
}
function Start-AppPool {
    param(
        $appPoolName,
        $credential,
        $machine__ip
    )
    Invoke-Command -ComputerName $machine__ip -Credential $credential -ScriptBlock {
        param($appPoolName)
        C:\Windows\system32\inetsrv\AppCmd.exe start apppool /apppool.name:$appPoolName
    } -ArgumentList $appPoolName
}

Write-DeploymentInfo -branch $branch -appPoolName $appPoolName -sourcePath $sourcePath -destinationPath $destinationPath

$credential = Create-Credential -username $username -password $password

Stop-AppPool -appPoolName $appPoolName -credential $credential -machine__ip $machine__ip

$excludeFolders = "cs", "de", "es", "fr", "it", "ja", "ko", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant"
robocopy $sourcePath $destinationPath /E /COPY:DAT /DCOPY:T /XO /NFL /NDL /R:5 /W:10 /MT:8 /XD $excludeFolders

Start-AppPool -appPoolName $appPoolName -credential $credential -machine__ip $machine__ip

Set-Location ..
