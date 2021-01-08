class RUMConnection {
    [String]$DisplayName
    [String]$ComputerName
    [String]$CredentialName
    [String]$Protocol
    [String]$Guid

    RUMConnection(){}
}

class RUMDatabase {
    [string]$Name
    [string]$Guid
    [string]$FileName
    [RUMConnection[]]$Connections

    RUMDatabase(){}
}