function Set-RUMConnection {
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
        [string] $ProfileName,
    
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
        [String]$NewDisplayName,

        [Parameter(Mandatory=$false, Position=3)]
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
        [Parameter(Mandatory = $false, Position = 4)]
        [string]$CredentialName,

        [Parameter(Mandatory=$false, Position = 5)]
        [ValidateSet("RDP","SSH")]
        [String]$Protocol
    )
    
    begin {
        $RUMProfilePath = Get-RUMPath
    }

    process {
        if(-not (Test-Path -Path $RUMProfilePath)) {
            Write-Error "A Remote Utilities Manager profile does not exist. Create the profile with New-RUMProfile first." -ErrorAction Stop
            return
        }

        $Settings = Get-Content $RUMProfilePath -Raw | ConvertFrom-Json -AsHashtable

        if(-not (Get-RUMProfile -ProfileName $ProfileName)){
            Write-Error "A profile with the name [$ProfileName] does not exist. Create the profile with New-RUMProfile first." -ErrorAction Stop
            return
        }

        if(($Settings.Profiles | Where-Object {$_.Name -eq $ProfileName}).Connections.DisplayName -notcontains $DisplayName) {
            Write-Error "A connection with the display name [$DisplayName] does not exist in the profile [$ProfileName]" -ErrorAction Stop
            return
        }

        $Connection = $Settings.Profiles | Where-Object {$_.Name -eq $ProfileName} | ForEach-Object {$_.Connections | Where-Object {$_.DisplayName -eq $DisplayName}}

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

        ConvertTo-Json $Settings -Depth 10 | Set-Content -Path $RUMProfilePath
    }
}