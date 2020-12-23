class RUMConnection {
    [String]$DisplayName
    [String]$ComputerName
    [String]$CredentialName
    [String]$Protocol
    [String]$Guid

    RUMConnection(){}
}

class RUMProfile {
    [string]$Name
    [string]$Guid
    [RUMConnection[]]$Connections

    RUMProfile(){}
}