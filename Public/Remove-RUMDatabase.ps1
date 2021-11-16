function Remove-RUMDatabase {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    [Alias("rrumdb")]
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
        [string] $DatabaseName
    )
    
    begin {
        $RUMFolderPath = Get-RUMPath -FolderPath
    }

    process {
        $Database = Get-RUMDatabase -DatabaseName $DatabaseName

        if ($Database) {
            if($PSCmdlet.ShouldProcess(
                    ("Removing database {0} from Remote Utilites Manager" -f $DatabaseName),
                    ("Would you like to remove database {0} from Remote Utilites Manager?" -f $DatabaseName),
                    "Remove Remote Utilites Manager Database Prompt"
                )
            ){
                $DatabaseFilePath = Join-Path -Path $RUMFolderPath -ChildPath $($Database.FileName)
                Remove-Item -Path $DatabaseFilePath
            }
        }
        else {
            Write-Error "A database with the name [$DatabaseName] does not exist." -ErrorAction Stop
            return
        }
    }
}