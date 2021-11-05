function Add-RUMConnection {
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
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName=$true)]
        [string]$DatabaseName,
    
        [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
        [string]$DisplayName,

        [Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)]
        [string]$ComputerName,

        [ArgumentCompleter( {
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            Get-SecretInfo | Sort-Object -Property Name | Where-Object { $_.Name -like "$wordToComplete*" } | Foreach-Object { 
                $Name = $_.Name
                $Pattern = "^[a-zA-Z0-9]+$"
                if ($Name -notmatch $Pattern) { $Name = "'$Name'" }
                [System.Management.Automation.CompletionResult]::new($Name, $Name, "ParameterValue", $Name)
            }
        })]
        [Parameter(Mandatory = $false, Position = 3, ValueFromPipelineByPropertyName=$true)]
        [string]$CredentialName,

        [Parameter(Mandatory=$false, Position=4, ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("RDP","SSH")]
        [string]$Protocol,

        [Parameter(Mandatory=$false, Position=5, ValueFromPipelineByPropertyName=$true)]
        [ValidateRange(1,65535)]
        [string]$Port,

        [Parameter(Mandatory=$false, Position=6, ValueFromPipelineByPropertyName=$true)]
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
            $Settings = Get-RUMSetting

            if($DatabaseSettings.Connections | Where-Object {$_.DisplayName -eq $DisplayName}) {
                Write-Warning "A Remote Utilities Manager connection with the display name [$DisplayName] already exists in database [$DatabaseName]"
                return
            }    

            if($PSBoundParameters.ContainsKey("Protocol")) {
                $ConnectionProtocol = $Protocol
            }
            else {
                $ConnectionProtocol = $Settings.DefaultProtocol
            }

            if($PSBoundParameters.ContainsKey("Port")) {
                $ConnectionPort = $Port
            }
            else {
                switch ($ConnectionProtocol) {
                    RDP {
                        $ConnectionPort = $Settings.DefaultRdpPort
                    }
                    SSH {
                        $ConnectionPort = $Settings.DefaultSshPort
                    }
                    Default {
                        $ConnectionPort = 69
                    }
                }
            }
    
            if($PSBoundParameters.ContainsKey("ComputerName")) {
                $ConnectionComputerName = $ComputerName
            }
            else {
                $ConnectionComputerName = $DisplayName
            }
    
            if($PSBoundParameters.ContainsKey("CredentialName")) {
                $ConnectionCredentialName = $CredentialName
            }
            else {
                $ConnectionCredentialName = ""
            }
    
            if($PSBoundParameters.ContainsKey("Tag")) {
                $ConnectionTag = $Tag
            }
            else {
                $ConnectionTag = ""
            }
    
            $Guid = (New-Guid).Guid
    
            $Connection = [PSCustomObject]@{
                DisplayName = $DisplayName
                ComputerName = $ConnectionComputerName
                CredentialName = $ConnectionCredentialName
                Protocol = $ConnectionProtocol
                Port = $ConnectionPort
                Guid = $Guid
                Tag = $ConnectionTag
            }

            $Array = @()
            $Array += ($DatabaseSettings).Connections
            $Array += $Connection

            ($DatabaseSettings).Connections = $Array

            ConvertTo-Json $DatabaseSettings -Depth 10 | Set-Content -Path $DatabaseFilePath
        }
        else {
            Write-Error "A database with the name [$DatabaseName] does not exist."
            return
        }
    }
}