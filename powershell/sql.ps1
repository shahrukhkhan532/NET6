param (
    [string]$Instance,
    [string]$DbName,
    [string]$UID,
    [string]$Password,
    [string]$OutputSQLFilePath
)
Set-Location "DB Script"
$table = @()
$LogMessage = ""
$ConnectionString = 'Server=' + $instance + ';Database=' + $DbName + ';User Id=' + $UID + ';Password=' + $Password + ';Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'
$SqlFiles = Get-ChildItem -Path . -File -Filter *.sql
foreach ($SqlFile in $SqlFiles) {
    ("`n------------------- " + $SqlFile.Name + " ------------------------ `n ") >> $OutputSQLFilePath
    (Get-Date -UFormat "%d-%m-%Y %T") >> $OutputSQLFilePath
    $file__Name = [System.IO.Path]::GetFileNameWithoutExtension($SqlFile)
    $new_File = ($PWD.Path + "\" + $SqlFiles.IndexOf($SqlFile) + "__" + $file__Name + ".sql")
    Get-Content -Path $SqlFile.FullName -Encoding UTF8 | Set-Content -Encoding UTF8 $new_File
    (Get-Content -Path $new_File -Encoding UTF8 -Raw) -replace '\u00A0', ' ' | Set-Content -Encoding UTF8 $new_File
    try {
        Invoke-Sqlcmd -ConnectionString $ConnectionString -InputFile $new_File -ErrorAction 'Stop'
        ($SqlFile.Name + " executed Successfully.`n") >> $OutputSQLFilePath
        $LogMessage = ($SqlFile.Name + " executed Successfully.")
    }
    catch {
        "$_" >> $OutputSQLFilePath
        $LogMessage = "$_"
    }
    $row = [PSCustomObject]@{
        "File"           = $SqlFile.Name
        "Execution Date" = (Get-Date -UFormat "%d-%m-%Y")
        "Execution Time" = (Get-Date -UFormat "%T")
        "Log"            = $LogMessage
    }
    $table += $row  
}
Write-Output ($table | Format-Table -AutoSize -Wrap | Out-String)