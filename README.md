# Remote Utilities Manager

**Remote Utilities Manager** is a PowerShell module that is used to manage connections to remote systems. Supported protocols at the moment are *RDP* and *SSH*.

> **Important**
>
> The module is a work in progress and has a lot of missing features

## Dependencies

### Credentials

Credentials are managed through the [SecretManagement PowerShell Module](https://github.com/PowerShell/SecretManagement). If you want to use saved credentials in **Remote Utilities Manager**, install the module and register your vault.

### External Programs

***Remote Utilities Manager*** uses external programs to start connections to remote systems. FreeRDP is used for RDP connections and SSH client is used for SSH connections.

On Linux, install FreeRDP with your preferred package manager and then make sure FreeRDP is available on $PATH.

On Windows, get FreeRDP from for example [ci.freerdp.com](https://ci.freerdp.com/job/freerdp-nightly-windows/) and then place the executable **wfreerdp.exe** in *~\\.remoteutilitiesmanager\bin* (the folder *.remoteutilitiesmanager* is created after you create your first database).

## Remote Utilities Manager CmdLets

### Add-RUMConnection

Used to add a connection to a RUM database.

### Connect-RUMConnection

Used to connect to a remote system with connection info saved in a RUM database.

### Connect-RUMRdp

Used to manually start a RDP session to a remote system.

### Connect-RUMSsh

Used to manually start a SSH session to a remote system.

### Get-RUMConnection

Used to list saved connections in a RUM database.

### Get-RUMDatabase

Used to list RUM databases.

### Get-RUMSetting

Used to list RUM settings.

### New-RUMDatabase

Used to create a new RUM database.

### New-RUMSetting

Used to create a RUM settings file. Includes some default settings, for example default protocol and keyboard layout. Default settings can be overridden when you add a connection or manually connects to a remote system.

### Remove-RUMConnection

Used to remove a connection from a RUM database.

### Remove-RUMDatabase

Used to remove a RUM database.

### Set-RUMConnection

Used to update an existing connection in a RUM database.

### Set-RUMDatabase

Used to update an existing RUM database.

### Set-RUMSetting

Used to update RUM settings.

## Examples

### Example 1: Create a RUM settings file

```PowerShell
New-RUMSetting -DefaultProtocol 'RDP' -DefaultRdpKeyboardLayout 'English'
```

### Example 2: Create a RUM database

```PowerShell
New-RUMDatabase -DatabaseName 'Prod Servers'
```

### Example 3: Add a connection to a RUM database

This example adds a connections to the RUM database **Prod Servers**. Since the parameters `ComputerName`, `CredentialName` and `Protocol` is omitted the ComputerName will inherit the value of `DisplayName`, `CredentialName` will be empty, and `Protocol` will inherit from `DefaultProtocol` in RUM settings.

`ComputerName` is what is used at connection time.

If `CredentialName` is empty, you will have to enter credentials manually at connection time.

```PowerShell
Add-RUMConnection -DatabaseName 'Prod Servers' -DisplayName 'WEB01'
```

### Example 4: Add a connection to a RUM database, explicitly specify all settings

This example adds a connections to the RUM database **Prod Servers**. All settings are entered explicitly.

The `CredentialName` entered must be available in a registered SecretManagement vault

```PowerShell
Add-RUMConnection -DatabaseName 'Prod Servers' -DisplayName 'WEB02' -ComputerName '192.168.1.22' -Protocol 'RDP' -CredentialName 'Web Admin'
```

### Example 5: Update a connection in a RUM database

This example updates the connection **WEB01** in the RUM database **Prod Servers** with `ComputerName` and `CredentialName`.

The `CredentialName` entered must be available in a registered SecretManagement vault

```PowerShell
Set-RUMConnection -DatabaseName 'Prod Servers' -DisplayName 'WEB01' -ComputerName '192.168.1.21' -CredentialName 'Web Admin'
```

### Example 6: List all connections in a RUM database

```PowerShell
Get-RUMConnection -DatabaseName 'Prod Servers'
```

```Output
DisplayName          ComputerName                   Protocol   CredentialName
-----------          ------------                   --------   --------------
WEB01                192.168.1.21                   RDP        Web Admin
WEB02                192.168.1.22                   RDP        Web Admin
```

### Example 7: Connect to a connection saved in a RUM database

```PowerShell
Connect-RUMConnection -DatabaseName 'Prod Servers' -DisplayName 'WEB02'
```

### Example 8: Remove a connection from a RUM database

```PowerShell
Remove-RUMConnection -DatabaseName 'Prod Servers' -DisplayName 'WEB01'
```

```Output
Remove Remote Utilities Manager Connection Prompt
Would you like to remove connection WEB01 from database Prod Servers?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): Y
```

### Example 9: Remove a RUM database

```PowerShell
Remove-RUMDatabase -DatabaseName 'Prod Servers'
```

```Output
Remove Remote Utilites Manager Database Prompt
Would you like to remove database Prod Servers from Remote Utilites Manager?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): Y
```

## Credits

Written by: Mikael Ekberg
