function Get-RUMConnection {
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
        [Parameter(Mandatory=$false, Position=1)]
        [String]$DisplayName,

        [ArgumentCompleter( {
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            Get-SecretInfo | Sort-Object -Property Name | Where-Object { $_.Name -like "$wordToComplete*" } | Foreach-Object { 
                $Name = $_.Name
                $Pattern = "^[a-zA-Z0-9]+$"
                if ($Name -notmatch $Pattern) { $Name = "'$Name'" }
                [System.Management.Automation.CompletionResult]::new($Name, $Name, "ParameterValue", $Name)
            }
        })]
        [Parameter(Mandatory = $false, Position = 2)]
        [string]$CredentialName,

        [Parameter(Mandatory=$false, Position=3)]
        [ValidateSet("RDP","SSH")]
        [string]$Protocol,

        [Parameter(Mandatory=$false, Position=4)]
        [string]$Tag
    )

    begin {
        $RUMFolderPath = Get-RUMPath -FolderPath
    }

    process {
        if($PSBoundParameters.ContainsKey("DatabaseName")) {
            if(-not(Get-RUMDatabase -DatabaseName $DatabaseName)) {
                Write-Error "A database with the name [$DatabaseName] does not exist." -ErrorAction Stop
                return
            }
        }

        $RUMDatabases = Get-ChildItem -Path $RUMFolderPath -Filter *.rumdb.json -ErrorAction SilentlyContinue

        if ($RUMDatabases.Count -gt 0) {
            $Databases = (Get-Content -Path $($RUMDatabases.FullName) -Raw | ConvertFrom-Json | ForEach-Object {
                $_
            } | Where-Object {
                if($DatabaseName) {
                    $_.Name -like $DatabaseName
                } else {
                    $true
                }
            })

            [array]$ConnectionList = foreach ($Database in $Databases){
                $DatabaseName = $Database.Name
                $Connections = $Database.Connections
                
                if ($PSBoundParameters.ContainsKey("DisplayName")) {
                    $Connections = $Connections | Where-Object {$_.DisplayName -eq $DisplayName}
                }

                if ($CredentialName) {
                    $Connections = $Connections | Where-Object {$_.CredentialName -eq $CredentialName}
                }

                if ($PSBoundParameters.ContainsKey("Protocol")) {
                    $Connections = $Connections | Where-Object {$_.Protocol -eq $Protocol}
                }

                if ($PSBoundParameters.ContainsKey("Tag")) {
                    $Connections = $Connections | Where-Object {$_.Tag -contains $Tag}
                }

                $Connections | Add-Member -MemberType NoteProperty -Name DatabaseName -Value $DatabaseName

                $Connections
            }

            [RUMConnection[]]$ConnectionList
        }
        else {
            Write-Verbose "No Remote Utilities Manager databases exists. Create a database with New-RUMDatabase first."
        }
    }
}