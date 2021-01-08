function Get-RUMDatabase {
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
        [Parameter(Mandatory=$false, Position=0)]
        [string] $DatabaseName
    )

    $RUMFolderPath = Get-RUMPath -FolderPath

    $RUMDatabases = Get-ChildItem -Path $RUMFolderPath -Filter *.rumdb.json -ErrorAction SilentlyContinue

    if ($RUMDatabases.Count -gt 0) {
        [RUMDatabase[]](Get-Content -Path $($RUMDatabases.FullName) -Raw | ConvertFrom-Json | ForEach-Object {
            $_
        } | Where-Object {
            if($DatabaseName) {
                $_.Name -like $DatabaseName
            } else {
                $true
            }
        })
    }
    else {
        Write-Verbose "No Remote Utilities Manager databases exists. Create a database with New-RUMDatabase first."
    }
}