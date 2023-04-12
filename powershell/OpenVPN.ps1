param (
    [string]$Base64File
)
function Import-Base64EncodedXML {
    param (
        [string]$EncodedFile
    )
    $decodedBytes = [System.Convert]::FromBase64String($EncodedFile)
    cd "D:\Program Files\OpenVPN\bin"
    Set-Content -Path "D:\Program Files\OpenVPN\config\output.ovpn" -Value $decodedBytes -Encoding Byte
    openvpn --help
    #openvpn --config "D:\Program Files\OpenVPN\config\output.ovpn"
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
