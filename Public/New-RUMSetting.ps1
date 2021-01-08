function New-RUMSetting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateSet("RDP","SSH")]
        [string]$DefaultProtocol = "RDP",

        [Parameter(Mandatory=$false, Position=1)]
        [string]$DefaultRdpKeyboardLayout = "United States - English",

        [Parameter(Mandatory=$false, Position=2)]
        [ValidateRange(1,65535)]
        [string]$DefaultRdpPort = "3389",

        [Parameter(Mandatory=$false, Position=3)]
        [ValidateRange(1,65535)]
        [string]$DefaultSshPort = "22",

        [Parameter(Mandatory=$false, Position=4)]
        [string]$DefaultRdpFlags = "/cert-ignore /size:1920x1027 /log-level:WARN"
    )
    begin {
        $RUMFolderPath = Get-RUMPath -FolderPath
    }

    process {
        $RUMSettingsFileName = "settings.json"
        $RUMSettingsPath = Join-Path -Path $RUMFolderPath -ChildPath $RUMSettingsFileName
        
        if(-not (Test-Path -Path $RUMSettingsPath)) {
            New-Item -Path $RUMSettingsPath -ItemType File -Force | Out-Null
            Write-Verbose 'Created Remote Utilities Manager settings file'
    
            $Settings = @{
                DefaultProtocol = $DefaultProtocol
                DefaultRdpKeyboardLayout = $DefaultRdpKeyboardLayout
                DefaultRdpPort = $DefaultRdpPort
                DefaultSshPort = $DefaultSshPort
                DefaultRdpFlags = $DefaultRdpFlags
            }
    
            ConvertTo-Json $Settings -Depth 10 | Set-Content -Path $RUMSettingsPath
        }
        else {
            Write-Verbose 'Remote Utilites Manager settings file already exists'
        }
    }
}