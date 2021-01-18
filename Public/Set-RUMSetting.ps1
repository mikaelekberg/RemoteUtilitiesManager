function Set-RUMSetting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateSet("RDP","SSH")]
        [string]$DefaultProtocol,

        [Parameter(Mandatory=$false, Position=1)]
        [ValidateRange(1,65535)]
        [string]$DefaultRdpPort,

        [Parameter(Mandatory=$false, Position=2)]
        [ValidateRange(1,65535)]
        [string]$DefaultSshPort,

        [Parameter(Mandatory=$false, Position=3)]
        [string]$DefaultRdpFlags
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

            if($PSBoundParameters.ContainsKey("DefaultRdpPort")) {
                $Settings['DefaultRdpPort'] = $DefaultRdpPort
            }

            if($PSBoundParameters.ContainsKey("DefaultSshPort")) {
                $Settings['DefaultSshPort'] = $DefaultSshPort
            }

            if($PSBoundParameters.ContainsKey("DefaultRdpFlags")) {
                $Settings['DefaultRdpFlags'] = $DefaultRdpFlags
            }
    
            ConvertTo-Json $Settings -Depth 10 | Set-Content -Path $RUMSettingsPath
        }
        else {
            Write-Error 'Remote Utilites Manager settings file does not exist' -ErrorAction Stop
            return
        }
    }
}