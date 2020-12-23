function Add-RUMConnection {
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
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ProfileName,
    
        [Parameter(Mandatory=$true, Position=1)]
        [String]$DisplayName,

        [Parameter(Mandatory=$false, Position=2)]
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
        [Parameter(Mandatory = $false, Position = 3)]
        [string]$CredentialName,

        [Parameter(Mandatory=$false, Position=4)]
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
            Write-Error "A Remote Utilities Manager profile with the name [$ProfileName] does not exist. Create the profile with New-RUMProfile first." -ErrorAction Stop
            return
        }

        if(($Settings.Profiles | Where-Object {$_.Name -eq $ProfileName}).Connections.DisplayName -contains $DisplayName) {
            Write-Error "A Remote Utilities Manager connection with the display name [$DisplayName] already exists in profile [$ProfileName]" -ErrorAction Stop
            return
        }

        if($PSBoundParameters.ContainsKey("Protocol")) {
            $ConnectionProtocol = $Protocol
        }
        else {
            $ConnectionProtocol = $Settings.Globals.DefaultProtocol
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

        $Guid = (New-Guid).Guid

        $Connection = [PSCustomObject]@{
            DisplayName = $DisplayName
            ComputerName = $ConnectionComputerName
            CredentialName = $ConnectionCredentialName
            Protocol = $ConnectionProtocol
            Guid = $Guid
        }

        $Array = @()
        $Array += ($Settings.Profiles | Where-Object {$_.Name -eq $ProfileName}).Connections
        $Array += $Connection

        ($Settings.Profiles | Where-Object {$_.Name -eq $ProfileName}).Connections = $Array

        ConvertTo-Json $Settings -Depth 10 | Set-Content -Path $RUMProfilePath
    }
}