function Set-RUMDatabase {
    [CmdletBinding()]
    param(
        [ArgumentCompleter( {
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
            Get-RUMDatabase | Sort-Object -Property Name | Where-Object { $_.Name -like "$wordToComplete*" } | Foreach-Object { 
                $Name = $_.Name
                $Pattern = "^[a-zA-Z0-9]+$"
                if ($Name -notmatch $Pattern) { $Name = "'$Name'" }
                [System.Management.Automation.CompletionResult]::new($Name, $Name, "ParameterValue", $Name)
            }
        })]
        [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
        [Alias('Name')]
        [string]$DatabaseName,
    
        [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
        [String]$NewDatabaseName
    )
    
    begin {
        $RUMFolderPath = Get-RUMPath -FolderPath
    }

    process {
        $Database = Get-RUMDatabase -DatabaseName $DatabaseName
        
        if ($Database) {
            $DatabaseFilePath = Join-Path -Path $RUMFolderPath -ChildPath $($Database.FileName)
            Write-Verbose "$DatabaseFilePath"

            $DatabaseSettings = Get-Content $DatabaseFilePath -Raw | ConvertFrom-Json -AsHashtable

            if($PSBoundParameters.ContainsKey("NewDatabaseName")) {
                $DatabaseSettings['Name'] = $NewDatabaseName
            }

            ConvertTo-Json $DatabaseSettings -Depth 10 | Set-Content -Path $DatabaseFilePath
        }
        else {
            Write-Error "A database with the name [$DatabaseName] does not exist." -ErrorAction Stop
            return
        }
    }
}