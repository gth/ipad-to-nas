# Windows Powershell Script to move a set of files (based on a filter) from a folder
# on an MTP device (e.g. Android phone) to a folder on a computer, using the Windows Shell.
# By Daiyan Yingyu, 19 March 2018, based on the (non-working) script found here:
#   https://www.pstips.net/access-file-system-against-mtp-connection.html
# as referenced here:
#   https://powershell.org/forums/topic/powershell-mtp-connections/
#
#
# This Powershell script is provided 'as-is', without any express or implied warranty.
# In no event will the author be held liable for any damages arising from the use of this script.
#
# Again, please note that used 'as-is' this script will MOVE files from you phone:
# the files will be DELETED from the source (the phone) and MOVED to the computer.
#
# If you want to copy files instead, you can replace the MoveHere function call with "CopyHere" instead.
# But once again, I can take any responsibility for the use, or misuse, of this script.
#
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
echo "Moving $phoneFolderPath to $destinationFolderPath matching $filter"

# Optionally add additional sub-folders to the destination path, such as one based on date

$phone = Get-Phone -phoneName $phoneName
$folder = Get-SubFolder -parent $phone -path $phoneFolderPath


$items = @( $folder.GetFolder.items() | where { $_.Name -match $filter } )
if ($items) {
	$totalItems = $items.count
	echo "Found $totalItems items."
	if ($totalItems -gt 0)
	{
		# If destination path doesn't exist, create it only if we have some items to move
		if (-not (test-path $destinationFolderPath) )
		{
			$created = new-item -itemtype directory -path $destinationFolderPath
		}

		Write-Verbose "Processing Path : $phoneName\$phoneFolderPath"
		Write-Verbose "Moving to : $destinationFolderPath"

		$shell = Get-ShellProxy
		$destinationFolder = $shell.Namespace($destinationFolderPath).self
		$count = 0;
		foreach ($item in $items)
		{
			$fileName = $item.Name

			++$count
			$percent = [int](($count * 100) / $totalItems)
			Write-Progress -Activity "Processing Files in $phoneName\$phoneFolderPath" `
				-status "Processing File ${count} / ${totalItems} (${percent}%)" `
				-CurrentOperation $fileName `
				-PercentComplete $percent

			# Check the target file doesn't exist:
			$targetFilePath = join-path -path $destinationFolderPath -childPath $fileName
			if (test-path -path $targetFilePath)
			{
				write-error "Destination file exists - file not moved:`n`t$targetFilePath"
			}
			else
			{
				# The next line is what you'd need to change to make the script to a COPY instead of a MOVE.
				$destinationFolder.GetFolder.MoveHere($item)
				if (test-path -path $targetFilePath)
				{
					# Optionally do something with the file, such as modify the name (e.g. removed phone-added prefix, etc.)
				}
				else
				{
					write-error "Failed to move file to destination:`n`t$targetFilePath"
				}
			}
		}
	}
} else {
    echo "No matching files found."
}
