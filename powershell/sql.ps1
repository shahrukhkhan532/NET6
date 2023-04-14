param (
    [Parameter(Mandatory = $true)]
    [string]$Instance,
    [Parameter(Mandatory = $true)]
    [string]$DbName,
    [Parameter(Mandatory = $true)]
    [string]$UID,
    [Parameter(Mandatory = $true)]
    [string]$Password,
    [Parameter(Mandatory = $true)]
    [string]$OutputSQLFilePath
)
function Export-LogsToHtml {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]$InputTable,
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $false)]
        [string]$Title
    )
    $css = @"
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
"@
    $headerRow = "<tr class='table-info'>" + ($InputTable[0].PSObject.Properties.Name | ForEach-Object { "<th>$_</th>" }) + "</tr>"
    $tableRow = ""
    foreach ($row in $InputTable) {
        if ($row.Log.ToString().Contains("Level")) {
            $tableRow += "<tr class='table-danger'>"
        }
        else {
            $tableRow += "<tr>"
        }
        $tableRow += "<td>$($row.File)</td>"
        $tableRow += "<td>$($row.'Execution Date')</td>"
        $tableRow += "<td>$($row.'Execution Time')</td>"
        $tableRow += "<td>$($row.Log)</td>"
        $tableRow += "</tr>"
    }

    $tableContent = "<table class='table table-striped table-bordered'><thead>$headerRow</thead><tbody>$tableRow</tbody></table>"
    $htmlContent = @"
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>$Title</title>
        $css
    </head>
    <body class='container'>
        <h1 class='mt-3'>$Title</h1>
        $tableContent
    </body>
    </html>
"@
    try {
        $htmlContent > $FilePath
    }
    catch {
        Write-Error "Failed to save the HTML content to '$FilePath': $_"
    }
}


$HtmlFile = [System.IO.Path]::ChangeExtension($OutputSQLFilePath, ".html")
if (-not (Test-Path $HtmlFile)) {
    New-Item -Path $HtmlFile -ItemType File -Force
}


cd "DB Script"
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

Export-LogsToHtml -InputTable $table -FilePath "$HtmlFile" -Title "Sql Scripts"
Write-Output ($table | Format-Table -AutoSize -Wrap | Out-String)
cd ..