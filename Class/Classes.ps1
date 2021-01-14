class RUMConnection {
    [string]$DisplayName
    [string]$DatabaseName
    [string]$ComputerName
    [string]$CredentialName
    [string]$Protocol
    [string]$Port
    [string]$Guid

    RUMConnection(){}
}

class RUMDatabase {
    [string]$Name
    [string]$Guid
    [string]$FileName
    [RUMConnection[]]$Connections

    RUMDatabase(){}
}