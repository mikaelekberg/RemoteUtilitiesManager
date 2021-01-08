function Set-RUMSetting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateSet("RDP","SSH")]
        [String]$DefaultProtocol,

        [Parameter(Mandatory=$false, Position=1)]
        [String]$DefaultRdpKeyboardLayout
    )
    
    begin {
        $RUMFolderPath = Get-RUMPath -FolderPath
    }

    process {
        $RUMSettingsFileName = "settings.json"
        $RUMSettingsPath = Join-Path -Path $RUMFolderPath -ChildPath $RUMSettingsFileName
        
        if(Test-Path -Path $RUMSettingsPath) {
            $Settings = Get-Content -Path $RUMSettingsPath -Raw | ConvertFrom-Json -AsHashtable
            
            if($PSBoundParameters.ContainsKey("DefaultProtocol")) {
                $Settings['DefaultProtocol'] = $DefaultProtocol
            }
    
            if($PSBoundParameters.ContainsKey("DefaultRdpKeyboardLayout")) {
                $Settings['DefaultRdpKeyboardLayout'] = $DefaultRdpKeyboardLayout
            }
    
            ConvertTo-Json $Settings -Depth 10 | Set-Content -Path $RUMSettingsPath
        }
        else {
            Write-Error 'Remote Utilites Manager settings file does not exist' -ErrorAction Stop
            return
        }
    }
}