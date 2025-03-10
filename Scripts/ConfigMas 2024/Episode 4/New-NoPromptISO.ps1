# Requires the script to be run under an administrative account context.
#Requires -RunAsAdministrator

# Settings
$WinPE_Architecture = "amd64" # Or x86
$WinPE_InputISOfile = "E:\Setup\Bootimage.iso"
$WinPE_OutputISOfile = "E:\Setup\Bootimage_NoPrompt.iso"
 
$ADK_Path = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit"
$WinPE_ADK_Path = $ADK_Path + "\Windows Preinstallation Environment"
$OSCDIMG_Path = $ADK_Path + "\Deployment Tools" + "\$WinPE_Architecture\Oscdimg"

# Validate locations
If (!(Test-path $WinPE_InputISOfile)){ Write-Warning "WinPE Input ISO file does not exist, aborting...";Break}
If (!(Test-path $ADK_Path)){ Write-Warning "ADK Path does not exist, aborting...";Break}
If (!(Test-path $WinPE_ADK_Path)){ Write-Warning "WinPE ADK Path does not exist, aborting...";Break}
If (!(Test-path $OSCDIMG_Path)){ Write-Warning "OSCDIMG Path does not exist, aborting...";Break}

# Mount the Original ISO (WinPE_InputISOfile) and figure out the drive-letter
Mount-DiskImage -ImagePath $WinPE_InputISOfile
$ISOImage = Get-DiskImage -ImagePath $WinPE_InputISOfile | Get-Volume
$ISODrive = [string]$ISOImage.DriveLetter+":"

# Create a new bootable WinPE ISO file, based on the Original ISO, but using efisys_noprompt.bin instead
$BootData='2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$OSCDIMG_Path\etfsboot.com","$OSCDIMG_Path\efisys_noprompt.bin"
   
$Proc = Start-Process -FilePath "$OSCDIMG_Path\oscdimg.exe" -ArgumentList @("-bootdata:$BootData",'-u2','-udfver102',"$ISODrive\","`"$WinPE_OutputISOfile`"") -PassThru -Wait -NoNewWindow
if($Proc.ExitCode -ne 0)
{
    Throw "Failed to generate ISO with exitcode: $($Proc.ExitCode)"
}

# Dismount the Original ISO
Dismount-DiskImage -ImagePath $WinPE_InputISOfile