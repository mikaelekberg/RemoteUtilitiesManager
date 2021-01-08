function Get-RUMRdpPath {
    $RUMFolderPath = Get-RUMPath -FolderPath

    if(-not (Test-Path -Path $RUMFolderPath)) {
        Write-Error "A Remote Utilities Manager profile does not exist. Create a database with New-RUMDatabase first." -ErrorAction Stop
        return
    }

    switch ($true) {
        $IsWindows {
            $RdpFilePath = Join-Path -Path $RUMFolderPath -ChildPath "bin\wfreerdp.exe"

            if(-not (Test-Path -Path $RdpFilePath)) {
                Write-Error "Cannot find FreeRdp in path $RdpFilePath. Can be downloaded from https://ci.freerdp.com/job/freerdp-nightly-windows/" -ErrorAction Stop
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