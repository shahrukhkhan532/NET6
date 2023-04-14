$branch = "ftp_2"
$sourcePath = $Env.sourcePath
$destinationPath = $Env.destinationPath
$appPoolName = $Env.appPoolName

Write-Output ($branch + " Branch Deployment. App Pool: " + $appPoolName + ", Source: " + $sourcePath + ", Destination: " + $destinationPath)

$username = "webnetworks\Shahrukhsrk"
$password = "skR00t@1234!!"
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword
          
Invoke-Command -ComputerName 10.4.0.5 -Credential $credential -ScriptBlock {
    param(
        $appPoolName
    )
    C:\Windows\system32\inetsrv\AppCmd.exe stop apppool /apppool.name:$appPoolName
} -ArgumentList $appPoolName

$destinationPath = "Z:\test\"
$excludeFolders = "cs", "de", "es", "fr", "it", "ja", "ko", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant"
robocopy $sourcePath $destinationPath /E /COPY:DAT /DCOPY:T /XO /NFL /NDL /R:5 /W:10 /MT:8 /XD $excludeFolders

Invoke-Command -ComputerName 10.4.0.5 -Credential $credential -ScriptBlock {
    param(
        $appPoolName
    )
    C:\Windows\system32\inetsrv\AppCmd.exe start apppool /apppool.name:$appPoolName
} -ArgumentList $appPoolName
Set-Location ..