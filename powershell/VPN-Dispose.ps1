param (
    [string]$Base64XMLFile
)
function Import-Base64EncodedXML {
    param (
        [string]$EncodedXML
    )

    $decodedBytes = [System.Convert]::FromBase64String($EncodedXML)
    Set-Content -Path "output.xml" -Value $decodedBytes -Encoding Byte

    [xml]$config = Get-Content "output.xml"
    Remove-Item "output.xml" -ErrorAction SilentlyContinue
    return $config
}
try {
    $config = Import-Base64EncodedXML -EncodedXML $Base64XMLFile
    $connectionName = $config.VpnProfile.VnetName
    net use Z: /delete
    rasdial $ConnectionName /disconnect
    Write-Output "VPN has been gracefully disconnected. ✅"
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    Write-Output "Finally Block..."
}
