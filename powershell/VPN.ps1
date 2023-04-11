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

function Install-Certificate {
    param (
        [string]$CertificateString
    )

    $certificateBytes = [System.Convert]::FromBase64String($CertificateString)
    Set-Content -Path "VpnServerRoot.cer" -Value $certificateBytes -Encoding Byte
    certutil -addstore -f -enterprise -user Root ".\VpnServerRoot.cer"
    Remove-Item "VpnServerRoot.cer" -ErrorAction SilentlyContinue
}

function Connect-Vpn {
    param (
        [string]$ConnectionName,
        [string]$VpnServer,
        [string]$Routes
    )

    Add-VpnConnection -Name $ConnectionName -ServerAddress $VpnServer -TunnelType SSTP -EncryptionLevel Required -AuthenticationMethod MSCHAPv2 -RememberCredential -AllUserConnection -SplitTunneling -Force

    foreach ($route in $Routes.Split(',')) {
        Add-VpnConnectionRoute -ConnectionName $ConnectionName -DestinationPrefix $route
    }

    rasdial $ConnectionName webnetworks\Shahrukhsrk skR00t@1234!!
}

function Disconnect-Vpn {
    param (
        [string]$ConnectionName
    )

    rasdial $ConnectionName /disconnect
}

function Invoke-SQL {
    param (
        [string]$Instance,
        [string]$DbName,
        [string]$UID,
        [string]$Password
    )

    $ConnectionString = 'Server=' + $Instance + ';Database=' + $DbName + ';User Id=' + $UID + ';Password=' + $Password + ';Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'
    Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT TOP 1 * FROM [User];" -ErrorAction 'Stop'
}

try {

    $config = Import-Base64EncodedXML -EncodedXML $Base64XMLFile
    $vpnServer = $config.VpnProfile.VpnServer
    $certificateString = $config.VpnProfile.CaCerts.string
    $connectionName = $config.VpnProfile.VnetName
    $routes = $config.VpnProfile.Routes

    Install-Certificate -CertificateString $certificateString
    Connect-Vpn -ConnectionName $connectionName -VpnServer $vpnServer -Routes $routes
    
    $instance = "10.4.0.4"
    $DbName = "iCM_STG"
    $UID = "TestDeployment"
    $Password = "TestDeployment$"
    $ConnectionString = 'Server=' + $instance + ';Database=' + $DbName + ';User Id=' + $UID + ';Password=' + $Password + ';Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'

    Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT TOP 1 * FROM [User];" -ErrorAction 'Stop'

}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    Write-Output "Finally Block..."
    Disconnect-Vpn -ConnectionName $connectionName
}
