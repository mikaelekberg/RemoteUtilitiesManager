function Set-RUMProfile {
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
    
        [Parameter(Mandatory=$true)]
        [String]$NewProfileName
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
            Write-Error "A profile with the name [$ProfileName] does not exist." -ErrorAction Stop
            return
        }

        $Prof = $Settings.Profiles | Where-Object {$_.Name -eq $ProfileName}

        if($PSBoundParameters.ContainsKey("NewProfileName")) {
            $Prof['Name'] = $NewProfileName
        }

        ConvertTo-Json $Settings -Depth 10 | Set-Content -Path $RUMProfilePath
    }
}