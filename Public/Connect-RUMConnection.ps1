function Connect-RUMConnection {
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
        [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
        [string]$DisplayName,

        [Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("RDP","SSH")]
        [string]$Protocol,

        [Parameter(Mandatory=$false, Position=3, ValueFromPipelineByPropertyName=$true)]
        [ValidateRange(1,65535)]
        [string]$Port
    )

    begin {
        $RUMFolderPath = Get-RUMPath -FolderPath
    }

    process {
        $Database = Get-RUMDatabase -DatabaseName $DatabaseName

        if ($Database) {
            $DatabaseFilePath = Join-Path -Path $RUMFolderPath -ChildPath $($Database.FileName)
            Write-Verbose "$DatabaseFilePath"

            $Connection = Get-RUMConnection -DatabaseName $DatabaseName -DisplayName $DisplayName

            if ($Connection) {
                $Settings = Get-RUMSetting
                
                if($PSBoundParameters.ContainsKey("Protocol")) {
                    $ConnectionProtocol = $Protocol
                }
                else {
                    $ConnectionProtocol = $Connection.Protocol
                }

                if($PSBoundParameters.ContainsKey("Port")) {
                    $ConnectionPort = $Port
                }
                else {
                    $ConnectionPort = $Connection.Port
                }
        
                switch ($ConnectionProtocol) {
                    RDP {
                        $ConnectionParams = @{
                            ComputerName = $Connection.ComputerName
                            Port = $ConnectionPort
                        }
                        
                        if ($Connection.CredentialName) {
                            $Credential = Get-Secret -Name $Connection.CredentialName
        
                            if ($null -ne $Credential) {
                                $ConnectionParams += @{
                                    Credential = $Credential
                                }
                            } 
                        }
                        
                        Connect-RUMRdp @ConnectionParams
                    }
                    SSH {
                        $ConnectionParams = @{
                            ComputerName = $Connection.ComputerName
                        }
                        
                        if ($Connection.CredentialName) {
                            $UserName = (Get-Secret -Name $Connection.CredentialName).UserName
        
                            if ($null -ne $UserName) {
                                $ConnectionParams += @{
                                    UserName = $UserName
                                }
                            } 
                        }
                        else {
                            $UserName = Read-Host "Please enter SSH username for $($Connection.DisplayName)"
        
                            if ($null -ne $UserName) {
                                $ConnectionParams += @{
                                    UserName = $UserName
                                }
                            }
                        }
        
                        Connect-RUMSsh @ConnectionParams
                    }
                    Default {}
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