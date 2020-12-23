function Connect-RUMConnection {
    [CmdletBinding()]
    param(
        [ArgumentCompleter( {
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
            Get-RUMProfile | Sort-Object -Property Name | Where-Object { $_.Name -like "$wordToComplete*" } | Foreach-Object { 
                $Name = $_.Name
                $Pattern = "^[a-zA-Z0-9]+$"
                if ($Name -notmatch $Pattern) { $Name = "'$Name'" }
                [System.Management.Automation.CompletionResult]::new($Name, $Name, "ParameterValue", $Name)
            }
        })]
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ProfileName,
        
        [ArgumentCompleter( {
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            if ($fakeBoundParameters.ContainsKey('ProfileName'))
            {
                $ProfileName = $fakeBoundParameters['ProfileName']
            }
    
            Get-RUMProfile -ProfileName $ProfileName | Select-Object -ExpandProperty Connections | Sort-Object -Property DisplayName | Where-Object { $_.DisplayName -like "$wordToComplete*" } | Foreach-Object { 
                $Name = $_.DisplayName
                $Pattern = "^[a-zA-Z0-9]+$"
                if ($Name -notmatch $Pattern) { $Name = "'$Name'" }
                $Connection = $_.ComputerName
                [System.Management.Automation.CompletionResult]::new($Name, $Name, "ParameterValue", $Connection)
            }
        })]
        [Parameter(Mandatory=$true, Position=1)]
        [String]$DisplayName,

        [Parameter(Mandatory=$false, Position=2)]
        [ValidateSet("RDP","SSH")]
        [String]$Protocol
    )

    begin {
        
    }

    process {
        $RUMProfilePath = Get-RUMPath

        $Settings = Get-Content $RUMProfilePath -Raw | ConvertFrom-Json -AsHashtable

        if(-not (Get-RUMProfile -ProfileName $ProfileName)){
            Write-Error "A Remote Utilities Manager profile with the name [$ProfileName] does not exist. Create the profile with New-RUMProfile first." -ErrorAction Stop
            return
        }

        if(($Settings.Profiles | Where-Object {$_.Name -eq $ProfileName}).Connections.DisplayName -notcontains $DisplayName) {
            Write-Error "A Remote Utilities Manager connection with the display name [$DisplayName] does not exist in the profile [$ProfileName]" -ErrorAction Stop
            return
        }

        $Connection = $Settings.Profiles | Where-Object {$_.Name -eq $ProfileName} | ForEach-Object {$_.Connections | Where-Object {$_.DisplayName -eq $DisplayName}}

        if($PSBoundParameters.ContainsKey("Protocol")) {
            $ConnectionProtocol = $Protocol
        }
        else {
            $ConnectionProtocol = $Connection.Protocol
        }

        switch ($ConnectionProtocol) {
            RDP {
                $ConnectionParams = @{
                    ComputerName = $Connection.ComputerName
                    KeyboardLayout = $Settings.Globals.DefaultRdpKeyboardLayout
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
}