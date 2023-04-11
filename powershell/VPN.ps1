﻿param (
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
    # $base64XMLFile = "PD94bWwgdmVyc2lvbj0iMS4wIj8+DQo8VnBuUHJvZmlsZSB4bWxuczp4c2Q9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvWE1MU2NoZW1hIg0KICB4bWxuczp4c2k9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvWE1MU2NoZW1hLWluc3RhbmNlIj4NCiAgPFZwblNlcnZlcj5henVyZWdhdGV3YXktZWZiMTAwNzctNTFjNC00MWFmLWFiNWYtMGJiZDEzYzk4YjczLWEzZTE3MjU3MTNhMy52cG4uYXp1cmUuY29tPC9WcG5TZXJ2ZXI+DQogIDxWcG5UeXBlPlNTVFA8L1ZwblR5cGU+DQogIDxDYUNlcnRzPg0KICAgIDxzdHJpbmc+DQogICAgICBNSUlEcnpDQ0FwZWdBd0lCQWdJUUNEdmdWcEJDUnJHaGRXckpXWkhIU2pBTkJna3Foa2lHOXcwQkFRVUZBREJoTVFzd0NRWURWUVFHRXdKVlV6RVZNQk1HQTFVRUNoTU1SR2xuYVVObGNuUWdTVzVqTVJrd0Z3WURWUVFMRXhCM2QzY3VaR2xuYVdObGNuUXVZMjl0TVNBd0hnWURWUVFERXhkRWFXZHBRMlZ5ZENCSGJHOWlZV3dnVW05dmRDQkRRVEFlRncwd05qRXhNVEF3TURBd01EQmFGdzB6TVRFeE1UQXdNREF3TURCYU1HRXhDekFKQmdOVkJBWVRBbFZUTVJVd0V3WURWUVFLRXd4RWFXZHBRMlZ5ZENCSmJtTXhHVEFYQmdOVkJBc1RFSGQzZHk1a2FXZHBZMlZ5ZEM1amIyMHhJREFlQmdOVkJBTVRGMFJwWjJsRFpYSjBJRWRzYjJKaGJDQlNiMjkwSUVOQk1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBNGp2aEVYTGVxS1RUbzFlcVVLS1BDM2VReWFLbDdoTE9sbHNCQ1NETUFaT25UakMzVS9kRHhHa0FWNTNpalNMZGh3WkFBSUVKenM0Ymc3L2Z6VHR4UnVMV1pzY0ZzM1luRm85N25oNlZmZTYzU0tNSTJ0YXZlZ3c1Qm1WL1NsMGZ2QmY0cTc3dUtOZDBmM3A0bVZtRmFHNWNJekpMdjA3QTZGcHQ0M0MvZHhDLy9BSDJoZG1vUkJCWU1xbDFHTlhSb3I1SDRpZHE5Sm96K0VrSVlJdlVYN1E2aEwraHFrcE1mVDdQVDE5c2RsNmdTemVSbnR3aTVtM09GQnFPYXN2K3piTVVaQmZIV3ltZU1yL3k3dnJUQzBMVXE3ZEJNdG9NMU8vNGdkVzdqVmcvdFJ2b1NTaWljTm94Qk4zM3NoYnlUQXBPQjZqdFNqMWV0WCtqa01Pdkp3SURBUUFCbzJNd1lUQU9CZ05WSFE4QkFmOEVCQU1DQVlZd0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBZEJnTlZIUTRFRmdRVUE5NVFOVmJSVEx0bThLUGlHeHZEbDdJOTBWVXdId1lEVlIwakJCZ3dGb0FVQTk1UU5WYlJUTHRtOEtQaUd4dkRsN0k5MFZVd0RRWUpLb1pJaHZjTkFRRUZCUUFEZ2dFQkFNdWNONnBJRXhJSyt0MUVuRTlTc1BUZnJnVDFlWGtJb3lRWS9Fc3JoTUF0dWRYSC92VEJIMWpMdUcyY2VuVG5tQ21yRWJYamNLQ2h6VXlJbVpPTWtYRGlxdzhjdnBPcC8yUFY1QWRnMDZPL25Wc0o4ZFdPNDFQMGptUDZQNmZidEdiZlltYlcwVzVCamZJdHRlcDNTcCtkV09JcldjQkFJKzB0S0lKRlBubFVraWFZNElCSXFEZnY4Tlo1WUJiZXJPZ096VzZzUkJjNEwwbmE0VVUrS3JrMlU4ODZVQWIzTHVqRVYwbHNZU0VZMVFTdGVEd3NPb0JycCt1dkZSVHAySW5CdVRoczRwRnNpdjlrdVhjbFZ6REFHeVNqNGR6cDMwZDh0YlFrQ0FVdzdDMjlDNzlGdjFDNXFmUHJtQUVTcmNpSXhwZzBYNDBLUE1icDFaV1ZiZDQ9PC9zdHJpbmc+DQogIDwvQ2FDZXJ0cz4NCiAgPFJvdXRlcz4xMC40LjAuMC8xNiwxMC4xLjAuMC8yNDwvUm91dGVzPg0KICA8QXV0aD5FQVBNU0NIQVBWMjwvQXV0aD4NCiAgPFZuZXROYW1lPlN0YWdpbmctdm5ldDwvVm5ldE5hbWU+DQogIDxWbmV0SWQ+ZWZiMTAwNzctNTFjNC00MWFmLWFiNWYtMGJiZDEzYzk4YjczPC9WbmV0SWQ+DQogIDxTZXJ2ZXJDZXJ0c1Jvb3RDbj4NCiAgICA8c3RyaW5nPkRpZ2lDZXJ0IEdsb2JhbCBSb290IENBPC9zdHJpbmc+DQogIDwvU2VydmVyQ2VydHNSb290Q24+DQogIDxTZXJ2ZXJDZXJ0c0lzc3VlckNuPg0KICAgIDxzdHJpbmc+RGlnaUNlcnQgR2xvYmFsIFJvb3QgQ0E8L3N0cmluZz4NCiAgPC9TZXJ2ZXJDZXJ0c0lzc3VlckNuPg0KICA8VnBuQ2xpZW50QWRkcmVzc1Bvb2w+MTcyLjI1LjAuMC8yNDwvVnBuQ2xpZW50QWRkcmVzc1Bvb2w+DQogIDxBYWRJc3N1ZXIgLz4NCiAgPEFhZFRlbmFudCAvPg0KICA8QWFkQXVkaWVuY2UgLz4NCiAgPEN1c3RvbURuc1NlcnZlcnMgLz4NCjwvVnBuUHJvZmlsZT4="
    $config = Import-Base64EncodedXML -EncodedXML $Base64XMLFile
    $vpnServer = $config.VpnProfile.VpnServer
    $certificateString = $config.VpnProfile.CaCerts.string
    $connectionName = $config.VpnProfile.VnetName
    $routes = $config.VpnProfile.Routes

    Install-Certificate -CertificateString $certificateString
    Connect-Vpn -ConnectionName $connectionName -VpnServer $vpnServer -Routes $routes
    Write-Output "Hello World !"
    # Invoke-SQL -Instance $Instance -DbName $DbName -UID $UID -Password $Password

}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    Disconnect-Vpn -ConnectionName $connectionName
}
