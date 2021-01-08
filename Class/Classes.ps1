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

class RUMDatabase {
    [string]$Name
    [string]$Guid
    [string]$FileName
    [RUMConnection[]]$Connections

    RUMDatabase(){}
}