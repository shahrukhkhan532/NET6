param (
    [string]$Instance,
    [string]$DbName,
    [string]$UID,
    [string]$Password,
    [string]$OutputSQLFilePath
)
cd "DB Script"
$table = @()
$msg = ""
$ConnectionString = 'Server=' + $instance + ';Database=' + $DbName + ';User Id=' + $UID + ';Password=' + $Password + ';Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;'
$files = Get-ChildItem -Path . -File -Filter *.sql
for ($i = 0; $i -lt $files.Count; $i++) {
    $file = $files[$i]
    ("`n------------------- " + $file.Name + " ------------------------ `n ") >> $OutputSQLFilePath
    (Get-Date -UFormat "%d-%m-%Y %T") >> $OutputSQLFilePath
    $file__Name = [System.IO.Path]::GetFileNameWithoutExtension($file)
    $new_File = ($PWD.Path + "\" + $i + "__" + $file__Name + ".sql")
    Get-Content -Path $file.FullName -Encoding UTF8 | Set-Content -Encoding utf8 $new_File
    (Get-Content -Path $new_File -Encoding UTF8 -Raw) -replace '\u00A0', ' ' | Set-Content -Encoding UTF8 $new_File
    try {
        Invoke-Sqlcmd -ConnectionString $ConnectionString -InputFile $new_File -ErrorAction 'Stop'
        ($file.Name + " executed Successfully.`n") >> $OutputSQLFilePath
        $msg = ($file.Name + " executed Successfully.")
    }
    catch {
        "$_" >> $OutputSQLFilePath
        $msg = "$_"
    }
    $row = [PSCustomObject]@{
        "File"                    = $file.Name
        "Execution Date" = (Get-Date -UFormat "%d-%m-%Y")
        "Execution Time" = (Get-Date -UFormat "%T")
        "Log"                     = $msg
    }
    $table += $row  
}
Write-Output ($table | Format-Table -AutoSize -Wrap | Out-String)