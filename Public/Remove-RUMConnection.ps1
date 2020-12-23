function Remove-RUMConnection {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
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
        [String]$DisplayName
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

        if($PSCmdlet.ShouldProcess(
                ("Removing connection {0} from profile {1}" -f $DisplayName, $ProfileName),
                ("Would you like to remove connection {0} from profile {1}?" -f $DisplayName, $ProfileName),
                "Remove Remote Utilities Manager Connection Prompt"
            )
        ){
            $Array = @()
            $Array += ($Settings.Profiles | Where-Object {$_.Name -eq $ProfileName}).Connections
            $NewArray = $Array | Where-Object {$_.DisplayName -ne $DisplayName}

            ($Settings.Profiles | Where-Object {$_.Name -eq $ProfileName}).Connections = $NewArray

            ConvertTo-Json $Settings -Depth 10 | Set-Content -Path $RUMProfilePath
        }
    }
}