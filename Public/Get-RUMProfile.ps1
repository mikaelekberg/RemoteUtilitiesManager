function Get-RUMProfile {
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
        [Parameter(Mandatory=$false, Position=0)]
        [string] $ProfileName
    )

    $RUMProfilePath = Get-RUMPath

    if(-not (Test-Path -Path $RUMProfilePath)) {
        Write-Error "A Remote Utilities Manager profile does not exist. Create the profile with New-RUMProfile first." -ErrorAction Stop
        return
    }

    [RUMProfile[]](Get-Content -Path $RUMProfilePath -Raw | ConvertFrom-Json | ForEach-Object {
        $_.Profiles
    } | Where-Object {
        if($ProfileName) {
            $_.Name -like $ProfileName
        } else {
            $true
        }
    })
}