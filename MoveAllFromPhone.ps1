# This file just uses the first part of Daiyan's script (see the other file in this repository),
# to find the folder names, which it iterates through, calling the second script.
#
param([string]$phoneName,[string]$sourceFolder,[string]$targetFolder,[string]$filter='(.jpg)|(.mp4)$')

function Get-ShellProxy
{
	if( -not $global:ShellProxy)
	{
		$global:ShellProxy = new-object -com Shell.Application
	}
	$global:ShellProxy
}

function Get-Phone
{
	param($phoneName)
	$shell = Get-ShellProxy
	# 17 (0x11) = ssfDRIVES from the ShellSpecialFolderConstants (https://msdn.microsoft.com/en-us/library/windows/desktop/bb774096(v=vs.85).aspx)
	# => "My Computer" — the virtual folder that contains everything on the local computer: storage devices, printers, and Control Panel.
	# This folder can also contain mapped network drives.
	$shellItem = $shell.NameSpace(17).self
	$phone = $shellItem.GetFolder.items() | where { $_.name -eq $phoneName }
	return $phone
}

function Get-SubFolder
{
	param($parent,[string]$path)
	$pathParts = @( $path.Split([system.io.path]::DirectorySeparatorChar) )
	$current = $parent
	foreach ($pathPart in $pathParts)
	{
		if ($current -and $pathPart)
		{
			$current = $current.GetFolder.items() | where { $_.Name -eq $pathPart }
		}
	}
	return $current
}

$phoneFolderPath = $sourceFolder
$destinationFolderPath = $targetFolder

$phone = Get-Phone -phoneName $phoneName
$folder = Get-SubFolder -parent $phone -path $phoneFolderPath

$items = @( $folder.GetFolder.items() )
$totalItems = $items.count

if ($totalItems -gt 0) {
    echo "Found $totalItems items."
} else {
    echo "Zero items found in $phoneFolderPath."
    exit
}

foreach ($item in $items) {
    echo " "
    $subfolder = $item.Name
    $launchcmd = ("MoveFromPhone.ps1")
    $launchargs = (-join( `
                    " -phoneName '",$phoneName,`
                    "' -sourceFolder '\",$phoneFolderPath,"\",$subfolder, `
                    "' -targetFolder '", $destinationFolderPath,"\",$subfolder, `
                    "' -filter '(.JPG)|(.MOV)|(.PNG)$'" `
                                  ))
    powershell.exe "$launchcmd $launchargs"
}
