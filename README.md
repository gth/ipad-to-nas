# ipad-to-nas
A pair of Windows PowerShell scripts to move files such as photos and videos from MTP device folders (e.g. iOS or Android), usually via a USB connection.  All credit for how this works belongs to Daiyan Yingyu at his blog post below, I just tweaked it slightly to handle multiple folders.
https://blog.daiyanyingyu.uk/2018/03/20/powershell-mtp/

Note that while my version of the script iterates through one level of subfolders, it is not recursive.  The script would need to be changed to detect and traverse down multiple levels of subfolders.

> ***WARNING***: These scripts **MOVE** files!  The files will no longer be on the phone.  You'll need to change the code if you only want to **copy** the files.

# Parameters
I haven't fixed the script to handle being called incorrectly, so you'll need to follow the examples below carefully.

- **-phoneName** - specifies the MTP device.  If you open Windows Explorer and find your phone, this is the device name you can see there.
- **-sourceFolder** - specifies the folder on the phone to move files FROM, which most of the time is wherever the DCIM folder is.
- **-targetFolder** - specifies the folder on the PC to move files TO.  I move photos to my Network Attached Storage (NAS), hence the name of this repository.


## Example 1 - Only move January's images from your iPhone to your PC's C: drive

<!-- obviously this is not Ruby code, but the syntax highlighting makes the example command lines easier to comprehend -->
```ruby
MoveFromPhone.ps1 \
  -phoneName 'Apple iPhone' \
  -sourceFolder 'Internal Storage\DCIM\202301' \
  -targetFolder 'C:\iPhone Photos from January 2023' \
  -filter '(.JPG)$'
```

## Example 2 - Move ALL the media in your iPad's DCIM subfolders to a network drive

```ruby
MoveAllFromPhone.ps1 \
  -phoneName 'Apple iPad' \
  -sourceFolder 'Internal Storage\DCIM' \
  -targetFolder 'N:\iPad Photos\Big Cleanout' \
  -filter '(.JPG)|(.MOV)|(.PNG)$'
```

# Known issues
* Parameters are not checked in detail, nor is the user informed of what is wrong if required parameters are not provided.
* When **MoveAllFromPhone.ps1** script calls **MoveFromPhone.ps1**, none of the status information is shown on the console.  Probably just needs a tweak of the various write- functions in the secondary script, or perhaps call the second script in a different way.
* As mentioned, the **MoveAllFromPhone.ps1** script merely calls **MoveFromPhone.ps1** for each item it finds.  It should really check that the item is a directory first. My device only had subfolders in its DCIM folder, so I didn't have a need to move files as well.
* The script doesn't recurse multiple folder levels, but it probably wouldn't take much to do so.  If the code to traverse folders was a function, it could call itself in a nested fashion if it detects another level of subfolder(s).
* This probably doesn't need to even be two separate scripts - the iteration function should probably be an parameter option such as **-recursive** for the user to select, and then subsequently a function inside the script to traverse subfolders if enabled.
