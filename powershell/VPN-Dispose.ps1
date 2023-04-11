param (
    [string]$Base64XMLFile
)
function Import-Base64EncodedXML {
    param (
        [string]$EncodedXML
    )

    $decodedBytes = [System.Convert]::FromBase64String($EncodedXML)
    Set-Content -Path "output.xml" -Value $decodedBytes -Encoding Byte

    net use Z: \\10.4.0.5\C$ /user:webnetworks\Shahrukhsrk skR00t@1234!!
    Write-Output "Z Drive created successfully"
    Copy-Item -Path "output.xml" -Destination "Z:\"
    Write-Output "File Copied successfully"
    net use Z: /delete
    Write-Output "Z Drive deleted successfully"


    [xml]$config = Get-Content "output.xml"
    Remove-Item "output.xml" -ErrorAction SilentlyContinue
    return $config
}
try {
    $config = Import-Base64EncodedXML -EncodedXML $Base64XMLFile
    $connectionName = $config.VpnProfile.VnetName
    rasdial $ConnectionName /disconnect
    Write-Output "VPN has been gracefully disconnected. ✅"
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    Write-Output "Finally Block..."
}
