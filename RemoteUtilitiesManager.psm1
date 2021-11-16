$Script:ModuleRoot = $PSScriptRoot

#Export all scripts as functions in .\Public, The functions must also be listed in the FunctionsToExport variable in the psd1 file.
Get-ChildItem $PSScriptRoot\Public\*.ps1 -Exclude *.Tests.ps1 | ForEach-Object {
	. $_.FullName
}

# Import all scripts as functions in .\Private.
Get-ChildItem $PSScriptRoot\Private\*.ps1 -Exclude *.Tests.ps1 | ForEach-Object {
	. $_.FullName
}

# Import all scripts as classes in .\Class.
Get-ChildItem $PSScriptRoot\Class\*.ps1 -Exclude *.Tests.ps1 | ForEach-Object {
	. $_.FullName
}

# Load any argument completers
if( Test-Path $PSScriptRoot\ArgumentCompleters ) {
	Get-ChildItem $PSScriptRoot\ArgumentCompleters\*.ps1 -Exclude *.Tests.ps1 | ForEach-Object {
		. $_.FullName
	}
}