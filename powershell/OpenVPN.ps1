param (
    [string]$Base64File
)
function Import-Base64EncodedXML {
    param (
        [string]$EncodedFile
    )
    Invoke-WebRequest -Uri "https://swupdate.openvpn.org/community/releases/openvpn-install-2.4.9-I601-Win10.exe" -OutFile "openvpn-install-2.4.9-I601-Win10.exe"
    Start-Process -FilePath ".\openvpn-install-2.4.9-I601-Win10.exe" -ArgumentList "/S" -Wait
    $env:Path += ";C:\Program Files\OpenVPN\bin"
    openvpn --version
    $decodedBytes = [System.Convert]::FromBase64String($EncodedFile)
    Set-Content -Path "output.ovpn" -Value $decodedBytes -Encoding Byte
    
    Rename-NetAdapter -InterfaceDescription "TAP-Windows Adapter V9" -NewName "Webnetworks"
    # Start-Job -ScriptBlock { openvpn --config "output.ovpn" }
    Start-Process -FilePath "openvpn" -ArgumentList "--config", '"output.ovpn"' -WindowStyle Hidden -RedirectStandardOutput "logs.txt"
    Start-Sleep -Seconds 10
    Get-Content "logs.txt"
    # openvpn --config "output.ovpn"
}
try {
    Import-Base64EncodedXML -EncodedFile $Base64File
    Write-Output "✅"
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    Write-Output "Finally Block..."
}
