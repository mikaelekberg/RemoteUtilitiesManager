function Connect-RUMRdp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [String]$ComputerName,
        
        [Parameter(Mandatory=$true, Position=1)]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory=$false, Position=2)]
        [String]$KeyboardLayout,

        [Parameter(Mandatory=$false, Position=3)]
        [String]$Port = 3389
    )

    $RdpFilePath = Get-RumRdpPath

    $ArgumentList = "/v:$ComputerName /cert-ignore /size:1920x1027 /log-level:WARN"

    if ($PSBoundParameters.ContainsKey("Credential")) {
        $ArgumentList = "$ArgumentList /u:{0} /p:{1}" -f $Credential.UserName, $Credential.GetNetworkCredential().Password
    }

    if ($PSBoundParameters.ContainsKey("KeyboardLayout")) {
        $ArgumentList = "$ArgumentList /kbd:$KeyboardLayout"
    }

    if (Test-Connection -TargetName $ComputerName -TCPPort $Port -Quiet -ErrorAction SilentlyContinue) {
        Start-Process -FilePath $RdpFilePath -ArgumentList $ArgumentList
    }
    else {
        Write-Error "A Remote Utilities Manager connection with the server [$ComputerName] on port [$Port] could not be established." -ErrorAction Stop
        return
    }
}