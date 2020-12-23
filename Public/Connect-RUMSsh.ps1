function Connect-RUMSsh {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [String]$ComputerName,
        
        [Parameter(Mandatory=$false)]
        [String]$UserName
    )
    
    $Port = 22

    if (Test-Connection -TargetName $ComputerName -TCPPort $Port -Quiet -ErrorAction SilentlyContinue) {
        ssh $UserName@$ComputerName
    }
    else {
        Write-Error "A connection with the server [$ComputerName] on port [$Port] could not be established." -ErrorAction Stop
        return
    }
}