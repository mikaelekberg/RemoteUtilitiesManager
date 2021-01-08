function New-RUMSetting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateSet("RDP","SSH")]
        [String]$DefaultProtocol = "RDP",

        [Parameter(Mandatory=$false, Position=1)]
        [String]$DefaultRdpKeyboardLayout = "United States - English"
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
            }
    
            ConvertTo-Json $Settings -Depth 10 | Set-Content -Path $RUMSettingsPath
        }
        else {
            Write-Verbose 'Remote Utilites Manager settings file already exists'
        }
    }
}