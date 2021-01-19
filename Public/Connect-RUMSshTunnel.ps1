function Connect-RUMSshTunnel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [String]$TunnelComputerName,
        
        [Parameter(Mandatory=$false, Position=1)]
        [String]$UserName,

        [Parameter(Mandatory=$false, Position=2)]
        [String]$TunnelPort = "22",
        
        [Parameter(Mandatory=$false, Position=3)]
        [String]$RemoteHostName,

        [Parameter(Mandatory=$false, Position=4)]
        [String]$LocalPort = "10022",

        [Parameter(Mandatory=$false, Position=5)]
        [String]$RemoteHostPort = "22"
    )

    if (Test-Connection -TargetName $TunnelComputerName -TCPPort $TunnelPort -Quiet -ErrorAction SilentlyContinue) {
        
        switch ($true) {
            $IsWindows { 
                $Forwarding = "$($LocalPort):$($RemoteHostName):$($RemoteHostPort)"
                $Command = "ssh $TunnelComputerName -l $UserName -p $TunnelPort -L $Forwarding -N"
                $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Command)
                $EncodedCommand = [Convert]::ToBase64String($Bytes)

                Start-Process -FilePath pwsh -ArgumentList "-EncodedCommand $EncodedCommand"
            }
            $IsMacOS {
                Write-Error "MacOS is not supported. Yet..." -ErrorAction Stop
                return
            }
            $IsLinux {
                $Forwarding = "$($LocalPort):$($RemoteHostName):$($RemoteHostPort)"
                ssh $TunnelComputerName -l $UserName -p $TunnelPort -L $Forwarding -f sleep 30
            }
            Default {
                Write-Error "Could not identify operating system, aborting." -ErrorAction Stop
                return
            }
        }
        
    }
    else {
        Write-Error "A connection with the server [$TunnelComputerName] on port [$TunnelPort] could not be established." -ErrorAction Stop
        return
    }
}