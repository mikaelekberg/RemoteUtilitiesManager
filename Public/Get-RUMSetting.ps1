function Get-RUMSetting {
    begin {
        $RUMFolderPath = Get-RUMPath -FolderPath
    }

    process {
        $RUMSettingsFileName = "settings.json"
        $RUMSettingsPath = Join-Path -Path $RUMFolderPath -ChildPath $RUMSettingsFileName
        
        if(Test-Path -Path $RUMSettingsPath) {
            Get-Content -Path $RUMSettingsPath -Raw | ConvertFrom-Json
        }
        else {
            Write-Verbose 'A Remote Utilites Manager settings file does not exist'
        }
    }
}