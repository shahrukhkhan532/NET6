param (
    [string]$Base64File
)
function Import-Base64EncodedXML {
    param (
        [string]$EncodedFile
    )
    
    $decodedBytes = [System.Convert]::FromBase64String($EncodedFile)
    Set-Content -Path "VpnServerRoot.cer" -Value $decodedBytes -Encoding Byte
    certutil -addstore -f -enterprise -user Root ".\VpnServerRoot.cer"
    Remove-Item "VpnServerRoot.cer" -ErrorAction SilentlyContinue
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
