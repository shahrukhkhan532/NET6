param (
    [string]$Instance,
    [string]$DbName,
    [string]$UID,
    [string]$Password
)
try {

    # $instance = "10.4.0.4"
    # $DbName = "iCM_STG"
    # $UID = "TestDeployment"
    # $Password = "TestDeployment$"
    $ConnectionString = 'Server=' + $instance + ';Database=' + $DbName + ';User Id=' + $UID + ';Password=' + $Password + ';Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'

    Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT TOP 1 * FROM [User];" -ErrorAction 'Stop'

}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    Write-Output "Finally Block..."
    # Disconnect-Vpn -ConnectionName $connectionName
}
