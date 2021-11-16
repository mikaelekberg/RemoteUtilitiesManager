function New-RUMDatabase {
    [CmdletBinding()]
    [Alias("nrumdb")]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [String]$DatabaseName
    )

    begin {
        $RUMFolderPath = Get-RUMPath -FolderPath
    }
    process {
        $Database = Get-RUMDatabase -DatabaseName $DatabaseName
        
        if ($null -eq $Database) {
            $Guid = (New-Guid).Guid
            $RUMDatabaseFileName = ($Guid + ".rumdb.json").ToLower()
            $RUMDatabasePath = Join-Path -Path $RUMFolderPath -ChildPath $RUMDatabaseFileName
    
            if(-not (Test-Path -Path $RUMDatabasePath)) {
                New-Item -Path $RUMDatabasePath -ItemType File -Force | Out-Null
                Write-Verbose 'Created Remote Utilities Manager database file'
    
                $Database = @{
                    Name = $DatabaseName
                    Guid = $Guid
                    FileName = $RUMDatabaseFileName
                    Connections = @()
                }
    
                ConvertTo-Json $Database -Depth 10 | Set-Content -Path $RUMDatabasePath
            }

            $Settings = Get-RUMSetting

            if ($null -eq $Settings) {
                New-RUMSetting
            }
        }
        else {
            Write-Error "A database with the name [$DatabaseName] already exists." -ErrorAction Stop
            return
        }
    }
}