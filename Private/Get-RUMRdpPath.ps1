function Get-RUMRdpPath {
    $RUMProfilePath = Get-RUMPath -FolderPath

    if(-not (Test-Path -Path $RUMProfilePath)) {
        Write-Error "A Remote Utilities Manager profile does not exist. Create the profile with New-RUMProfile first." -ErrorAction Stop
        return
    }

    switch ($true) {
        $IsWindows {
            $RdpFilePath = Join-Path -Path $RUMProfilePath -ChildPath "bin\wfreerdp.exe"

            if(-not (Test-Path -Path $RdpFilePath)) {
                Write-Error "Cannot find FreeRdp in path $RdpFilePath." -ErrorAction Stop
                return
            }
        
            $RdpFilePath
        }
        $IsMacOS {
            Write-Error "MacOS is not supported. Yet..." -ErrorAction Stop
            return
        }
        $IsLinux {
            $RdpFilePath = "xfreerdp"

            try {
                Start-Process -FilePath $RdpFilePath -ArgumentList "--version" -ErrorAction Stop
            }
            catch {
                Write-Error "Cannot find FreeRdp on the system, please make sure it's installed." -ErrorAction Stop
                return
            }

            $RdpFilePath
        }
        Default {
            Write-Error "Could not identify operating system, aborting." -ErrorAction Stop
            return
        }
    }
}