function New-RUMProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [String]$ProfileName,

        [Parameter(Mandatory=$false)]
        [String]$DefaultProtocol = "RDP",

        [Parameter(Mandatory=$false)]
        [String]$DefaultRdpKeyboardLayout = "United States - English"
    )
    $RUMProfilePath = Get-RUMPath

    if(-not (Test-Path -Path $RUMProfilePath)) {
        New-Item -Path $RUMProfilePath -ItemType File -Force | Out-Null
        Write-Verbose 'Created Remote Utilities Manager settings file'

        $Globals = @{
            Name = "RUM"
            DefaultProtocol = $DefaultProtocol
            DefaultRdpKeyboardLayout = $DefaultRdpKeyboardLayout
        }

        $Profiles = @{
            Globals = $Globals
            Profiles = @()
        }

        ConvertTo-Json $Profiles -Depth 10 | Set-Content -Path $RUMProfilePath
    }
    else {
        Write-Verbose 'RUM settings file already exists'
    }

    $Settings = Get-Content -Path $RUMProfilePath -Raw | ConvertFrom-Json

    foreach($P in $Settings.Profiles) {
        if($P.Name -eq $ProfileName) {
            Write-Error "A profile with the name [$ProfileName] already exists" -ErrorAction Stop
            return
        }
    }

    $NewProfile = [ordered]@{
        Name = $ProfileName
        Guid = (New-Guid).Guid
        Connections = @()
    }

    $Settings.Profiles += $NewProfile
    ConvertTo-Json $Settings -Depth 10 | Set-Content -Path $RUMProfilePath
}