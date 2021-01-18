function Connect-RUMRdp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ComputerName,
        
        [Parameter(Mandatory=$true, Position=1)]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory=$false, Position=2)]
        [string]$Port = "3389"
    )

    $RdpFilePath = Get-RumRdpPath
    $Settings = Get-RUMSetting

    $ArgumentList = "/v:$($ComputerName):$($Port)"

    if (-not ($null -eq $Settings.DefaultRdpFlags)) {
        $ArgumentList = "$ArgumentList $($Settings.DefaultRdpFlags)"
    } 

    if ($PSBoundParameters.ContainsKey("Credential")) {
        $ArgumentList = "$ArgumentList /u:{0} /p:{1}" -f $Credential.UserName, $Credential.GetNetworkCredential().Password
    }

    if (Test-Connection -TargetName $ComputerName -TCPPort $Port -Quiet -ErrorAction SilentlyContinue) {
        Start-Process -FilePath $RdpFilePath -ArgumentList $ArgumentList
    }
    else {
        Write-Error "A Remote Utilities Manager connection with the server [$ComputerName] on port [$Port] could not be established." -ErrorAction Stop
        return
    }
}