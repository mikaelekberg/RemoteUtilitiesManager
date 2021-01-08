function Connect-RUMSsh {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [String]$ComputerName,
        
        [Parameter(Mandatory=$false, Position=1)]
        [String]$UserName,

        [Parameter(Mandatory=$false, Position=2)]
        [String]$Port = 22
    )

    if (Test-Connection -TargetName $ComputerName -TCPPort $Port -Quiet -ErrorAction SilentlyContinue) {
        [console]::beep(659,250)
        [console]::beep(659,250)
        [console]::beep(659,300)
        [console]::beep(523,250)
        [console]::beep(659,250)
        [console]::beep(784,500)
        [console]::beep(392,300)
        ssh $UserName@$ComputerName
        
    }
    else {
        Write-Error "A connection with the server [$ComputerName] on port [$Port] could not be established." -ErrorAction Stop
        return
    }
}