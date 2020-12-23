function Get-RUMPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [Switch]$FolderPath
    )

    $RUMFolderPath = Join-Path -Path $HOME -ChildPath '.remoteutilitiesmanager'

    if ($FolderPath) {
        $RUMProfilePath = $RUMFolderPath
    }
    else {
        $RUMProfilePath = Join-Path -Path $RUMFolderPath -ChildPath 'profiles.json'
    }

    $RUMProfilePath
}