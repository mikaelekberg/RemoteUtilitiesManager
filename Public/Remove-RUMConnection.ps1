function Remove-RUMConnection {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
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
        [Parameter(Mandatory=$true, Position=0)]
        [string]$DatabaseName,
    
        [ArgumentCompleter( {
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            if ($fakeBoundParameters.ContainsKey('DatabaseName'))
            {
                $DatabaseName = $fakeBoundParameters['DatabaseName']
            }
    
            Get-RUMDatabase -DatabaseName $DatabaseName | Select-Object -ExpandProperty Connections | Sort-Object -Property DisplayName | Where-Object { $_.DisplayName -like "$wordToComplete*" } | Foreach-Object { 
                $Name = $_.DisplayName
                $Pattern = "^[a-zA-Z0-9]+$"
                if ($Name -notmatch $Pattern) { $Name = "'$Name'" }
                $Connection = $_.ComputerName
                [System.Management.Automation.CompletionResult]::new($Name, $Name, "ParameterValue", $Connection)
            }
        })]
        [Parameter(Mandatory=$true, Position=1)]
        [String]$DisplayName
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

            $Connection = $DatabaseSettings.Connections | Where-Object {$_.DisplayName -eq $DisplayName}

            if ($Connection) {
                if($PSCmdlet.ShouldProcess(
                ("Removing connection {0} from database {1}" -f $DisplayName, $DatabaseName),
                ("Would you like to remove connection {0} from database {1}?" -f $DisplayName, $DatabaseName),
                "Remove Remote Utilities Manager Connection Prompt")
                ){
                    $Array = @()
                    $Array += ($DatabaseSettings).Connections
                    $NewArray = $Array | Where-Object {$_.DisplayName -ne $DisplayName}

                    ($DatabaseSettings).Connections = $NewArray

                    ConvertTo-Json $DatabaseSettings -Depth 10 | Set-Content -Path $DatabaseFilePath
                }
            }
            else {
                Write-Error "A Remote Utilities Manager connection with the display name [$DisplayName] does not exist in the database [$DatabaseName]" -ErrorAction Stop
                return
            }
        }
        else {
            Write-Error "A database with the name [$DatabaseName] does not exist." -ErrorAction Stop
            return
        }
    }
}