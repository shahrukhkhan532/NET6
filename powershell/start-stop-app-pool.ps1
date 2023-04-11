param (
    [string]$remote__Machine,
    [string]$username,
    [string]$password
)
try {
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $remote__Machine -Concatenate -Force
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword
    Invoke-Command -ComputerName $remote__Machine -Credential $credential -ScriptBlock {
        Get-ChildItem -Path "C:\" -Directory | Select-Object -ExpandProperty Name  
    }
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    Write-Output "Finally Block..."
    # Disconnect-Vpn -ConnectionName $connectionName
}
