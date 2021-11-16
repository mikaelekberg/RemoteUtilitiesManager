function Set-RUMConnection {
    [CmdletBinding()]
    [Alias("srumcn")]
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
        [string] $DatabaseName,
    
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
        [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
        [String]$DisplayName,
        
        [Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)]
        [String]$NewDisplayName,

        [Parameter(Mandatory=$false, Position=3, ValueFromPipelineByPropertyName=$true)]
        [String]$ComputerName,

        [ArgumentCompleter( {
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            Get-SecretInfo | Sort-Object -Property Name | Where-Object { $_.Name -like "$wordToComplete*" } | Foreach-Object { 
                $Name = $_.Name
                $Pattern = "^[a-zA-Z0-9]+$"
                if ($Name -notmatch $Pattern) { $Name = "'$Name'" }
                [System.Management.Automation.CompletionResult]::new($Name, $Name, "ParameterValue", $Name)
            }
        })]
        [Parameter(Mandatory = $false, Position = 4, ValueFromPipelineByPropertyName=$true)]
        [string]$CredentialName,

        [Parameter(Mandatory=$false, Position = 5, ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("RDP","SSH")]
        [String]$Protocol,

        [Parameter(Mandatory=$false, Position=6, ValueFromPipelineByPropertyName=$true)]
        [ValidateRange(1,65535)]
        [string]$Port,

        [Parameter(Mandatory=$false, Position=7, ValueFromPipelineByPropertyName=$true)]
        [string[]]$Tag
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
                if($PSBoundParameters.ContainsKey("NewDisplayName")) {
                    $Connection['DisplayName'] = $NewDisplayName
                }
        
                if($PSBoundParameters.ContainsKey("ComputerName")) {
                    $Connection['ComputerName'] = $ComputerName
                }
        
                if($PSBoundParameters.ContainsKey("CredentialName")) {
                    $Connection['CredentialName'] = $CredentialName
                }
        
                if($PSBoundParameters.ContainsKey("Protocol")) {
                    $Connection['Protocol'] = $Protocol
                }

                if($PSBoundParameters.ContainsKey("Port")) {
                    $Connection['Port'] = $Port
                }

                if($PSBoundParameters.ContainsKey("Tag")) {
                    $Connection['Tag'] = $Tag
                }
        
                ConvertTo-Json $DatabaseSettings -Depth 10 | Set-Content -Path $DatabaseFilePath
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