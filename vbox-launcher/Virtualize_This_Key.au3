; AutoIt Version: 3.3.0.0
; Author        : Thibaut Lauzière (Slÿm) www.slym.fr
; e-Mail        : contact@linuxliveusb.com
; License       : GPL v3.0
; Version       : For LiLi 2.X
; Download      : http://www.linuxliveusb.com
; Support       : http://www.linuxliveusb.com
; Based on Michael Meyer (michaelm_007) works

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Virtualize_This_Key.ico
#AutoIt3Wrapper_Res_Comment=Enjoy !
#AutoIt3Wrapper_Res_Description=Launch VirtualBox for LiLi
#AutoIt3Wrapper_Res_Fileversion=2.0.0.20
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y
#AutoIt3Wrapper_Res_LegalCopyright=CopyLeft Thibaut Lauziere a.k.a Slÿm
#AutoIt3Wrapper_Res_Field=Site|http://www.linuxliveusb.com
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Constants.au3>
#include <String.au3>
#include <File.au3>
#include <Array.au3>

#RequireAdmin

Global $arch, $vmdkfile, $vbox_output, $vbox_config, $logfile
Global $g_eventerror = 0 ; to be checked to know if com error occurs. Must be reset after handling.
Global $settings_ini = @ScriptDir & "\Portable-VirtualBox\linuxlive-settings\settings.ini"
$oMyError = ObjEvent("AutoIt.Error", "MyErrFunc") ; Install a custom error handler

; preparing for logging
$logfile = @ScriptDir & "\Portable-VirtualBox\linuxlive-settings\launcher.log"
If DirGetSize(@ScriptDir & "\Portable-VirtualBox\linuxlive-settings\") == -1 Then DirCreate(@ScriptDir & "\Portable-VirtualBox\linuxlive-settings\")
If FileExists($logfile) Then FileDelete($logfile)

$vmdkfile = @ScriptDir & "\Portable-VirtualBox\data\.VirtualBox\HardDisks\LinuxLive.vmdk"
; To be sure it exists
DirCreate(@ScriptDir & "\Portable-VirtualBox\data\.VirtualBox\HardDisks\")


If Not IsAdmin() Then
	UpdateLog("ERROR : User does not have admin privileges !!!")
EndIf

If FileExists(@ScriptDir & "\Portable-VirtualBox\app32\") Then UpdateLog("VBox folder available : app32")
If FileExists(@ScriptDir & "\Portable-VirtualBox\app64\") Then UpdateLog("VBox folder available : app64")

; autoswitch from 32 Bits to 64 Bits VirtualBox
If FileExists(@ScriptDir & "\Portable-VirtualBox\app32\") And FileExists(@ScriptDir & "\Portable-VirtualBox\app64\") Then
	If @OSArch = "x86" Then
		Global $arch = "app32"
	EndIf
	If @OSArch = "x64" Then
		Global $arch = "app64"
	EndIf

	if (IniRead($settings_ini, "Others", "force_x86", "no")=="yes") Then
		Global $arch = "app32"
		UpdateLog("Forced using 32 Bits package")
	EndIf

	if (IniRead($settings_ini, "Others", "force_x64", "no")=="yes") Then
		Global $arch = "app64"
		UpdateLog("Forced using 64 Bits package")
	EndIf

Else
	If FileExists(@ScriptDir & "\Portable-VirtualBox\app32\") And Not FileExists(@ScriptDir & "\Portable-VirtualBox\app64\") Then
		Global $arch = "app32"
	EndIf
	If Not FileExists(@ScriptDir & "\Portable-VirtualBox\app32\") And FileExists(@ScriptDir & "\Portable-VirtualBox\app64\") Then
		Global $arch = "app64"
	EndIf
EndIf

UpdateLog("OS Architecture Found : " & @OSArch)
UpdateLog("VBox Architecture used : " & $arch)


; Check for installed version
If DirGetSize(@ProgramFilesDir & "\Sun\xVM VirtualBox\") > -1 Then
	UpdateLog("Error - Installed version of VBox Found")
	MsgBox(16, "Found an installed VirtualBox", "Please uninstall xVM VirtualBox (" & @ProgramFilesDir & "\Sun\xVM VirtualBox\" & ") in order to use the portable version.")
	Exit
EndIf


; Check for old config files cause otherwise it's not working
If FileExists(@UserProfileDir & "\.VirtualBox") Then
	UpdateLog("Found an old config file in user profile -> moving it to another folder")
	DirMove(@UserProfileDir & "\.VirtualBox", @UserProfileDir & "\VirtualBox-backup", 1)
EndIf

SplashTextOn("Portable-VirtualBox", "Launching VirtualBox", 220, 40, -1, -1, 1, "arial", 12)

; Launching needed services
If @OSArch = "x86" Then
	If Not FileExists(@SystemDir & "\msvcp71.dll") Or Not FileExists(@SystemDir & "\msvcr71.dll") Or Not FileExists(@SystemDir & "\msvcrt.dll") Then
		FileCopy(@ScriptDir & "\Portable-VirtualBox\app32\msvcp71.dll", @SystemDir, 9)
		FileCopy(@ScriptDir & "\Portable-VirtualBox\app32\msvcr71.dll", @SystemDir, 9)
		FileCopy(@ScriptDir & "\Portable-VirtualBox\app32\msvcrt.dll", @SystemDir, 9)
		Global $msv = 1
	Else
		Global $msv = 0
	EndIf
	UpdateLog("Presence of file " & @SystemDir & "\msvcp71.dll : " & FileExists(@SystemDir & "\msvcp71.dll"))
	UpdateLog("Presence of file " & @SystemDir & "\msvcr71.dll : " & FileExists(@SystemDir & "\msvcr71.dll"))
	UpdateLog("Presence of file " & @SystemDir & "\msvcrt.dll : " & FileExists(@SystemDir & "\msvcrt.dll"))
EndIf
If @OSArch = "x64" Then
	If Not FileExists(@SystemDir & "\msvcp80.dll") Or Not FileExists(@SystemDir & "\msvcr80.dll") Then
		FileCopy(@ScriptDir & "\Portable-VirtualBox\app64\msvcp80.dll", @SystemDir, 9)
		FileCopy(@ScriptDir & "\Portable-VirtualBox\app64\msvcr80.dll", @SystemDir, 9)
		Global $msv = 2
	Else
		Global $msv = 0
	EndIf
	UpdateLog("Presence of file " & @SystemDir & "\msvcp80.dll : " & FileExists(@SystemDir & "\msvcp80.dll"))
	UpdateLog("Presence of file " & @SystemDir & "\msvcr80.dll : " & FileExists(@SystemDir & "\msvcr80.dll"))
EndIf


$return = RunWait("Portable-VirtualBox\" & $arch & "\VBoxSVC.exe /reregserver", @ScriptDir, @SW_HIDE)
UpdateLog("VBoxSVC.exe runned - Return code : " & $return & " - error code : " & @error)

$return = RunWait("regsvr32.exe /S Portable-VirtualBox\" & $arch & "\VBoxC.dll", @ScriptDir, @SW_HIDE)
UpdateLog("VBoxC.dll runned - Return code : " & $return & " - error code : " & @error)
$return = DllCall("Portable-VirtualBox\" & $arch & "\VBoxRT.dll", "hwnd", "RTR3Init")
UpdateLog("VBoxRT.dll runned - Return code : " & $return & " - error code : " & @error)
#cs
If RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\VBoxDRV", "DisplayName") <> "VirtualBox Service" Then
	$return = RunWait("cmd /c sc create VBoxDRV binpath= ""%CD%\Portable-VirtualBox\" & $arch & "\drivers\VBoxDrv\VBoxDrv.sys"" type= kernel start= auto error= normal displayname= PortableVBoxDRV", @ScriptDir, @SW_HIDE)
	UpdateLog("VBoxDRV service created - Return code : " & $return & " - error code : " & @error)
	Global $DRV = 1
Else
	Global $DRV = 0
EndIf

If $DRV = 1 Then
	$return = RunWait("sc start VBoxDRV", @ScriptDir, @SW_HIDE)
	UpdateLog("VBoxDRV service runned - Return code : " & $return & " - error code : " & @error)
EndIf
#ce

; deleting old VMDK, Creating new one and changing back its uuid
If FileExists($vmdkfile) Then FileDelete($vmdkfile)

; recreating LinuxLive virtual Disk
RunWait3("Portable-VirtualBox\" & $arch & '\VBoxManage.exe internalcommands createrawvmdk -filename "' & $vmdkfile & '" -rawdisk ' & GiveMePhysicalDisk())

If NOT FileExists($vmdkfile) Then
	UpdateLog("VMDK not created using native method.")
	UpdateLog("Now trying legacy method.")
	LegacyVMDK()
EndIf

If FileExists($vmdkfile) Then
	ChangeUUID()
	;to avoid the bug with vbox tools
	DetachDVD()
	RelativePaths()
Else
	MsgBox(16, "WARNING", "There was a problem recreating Linux Live virtual disk." & @CRLF & "Please send log file (Portable-VirtualBox\linuxlive-settings\launcher.log) to vbox-debug@linuxliveusb.com")
EndIf

$PID = ProcessExists("VBoxSVC.exe")
If $PID Then ProcessClose($PID)

#cs
If $DRV = 1 Then
	$return = RunWait("sc stop VBoxDRV", @ScriptDir, @SW_HIDE)
	UpdateLog("VBoxDRV service stopped - Return code : " & $return & " - error code : " & @error)
EndIf
#ce

$return = RunWait("Portable-VirtualBox\" & $arch & "\VBoxSVC.exe /unregserver", @ScriptDir, @SW_HIDE)
UpdateLog("VBoxSVC unregistered - Return code : " & $return & " - error code : " & @error)
;$return = RunWait("regsvr32.exe /S /U Portable-VirtualBox\" & $arch & "\VBoxC.dll", @ScriptDir, @SW_HIDE)
;UpdateLog("VBoxC.dll unloaded - Return code : " & $return & " - error code : " & @error)


ProcessWaitClose("VBoxManage.exe")
ProcessWaitClose("VBoxSVC.exe")

LogLauncher()

; Launching Portable-VirtualBox
;Run(@ScriptDir & "\Portable-VirtualBox\Portable-VirtualBox.exe")

; Launching directly LinuxLive
Run(@ScriptDir & "\Portable-VirtualBox\Portable-VirtualBox.exe LinuxLive")


Func RunWait3($soft)
	Local $foo
	UpdateLog($soft)
	$foo = Run($soft, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$vbox_output = @CRLF
	While True
		$vbox_output &= StdoutRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog("Creating VMDK using VBoxManage - Return : " & $vbox_output)
EndFunc   ;==>RunWait3

; returns the physical disk (\\.\PhysicalDiskX) corresponding to a drive letter
Func GiveMePhysicalDisk()
	Local $physical_drive = 0
	$drive_letter = StringLeft(@ScriptDir, 2)
	UpdateLog("GiveMePhysicalDisk of : " & $drive_letter)

	Local $wbemFlagReturnImmediately, $wbemFlagForwardOnly, $objWMIService, $colItems, $objItem, $found_usb, $usb_model, $usb_size
	$wbemFlagReturnImmediately = 0x10
	$wbemFlagForwardOnly = 0x20
	$colItems = ""

	$objWMIService = ObjGet("winmgmts:\\.\root\CIMV2")
	If @error Or $g_eventerror Or Not IsObj($objWMIService) Then
		UpdateLog("ERROR with WMI : Trying alternate method (WMI impersonation)")
		$g_eventerror = 0
		$objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!//.")
	EndIf

	If @error Or $g_eventerror Then
		UpdateLog("ERROR with WMI")
	ElseIf IsObj($objWMIService) Then
		UpdateLog("WMI seems to work")

		$colItems = $objWMIService.ExecQuery("SELECT Caption, DeviceID FROM Win32_DiskDrive", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

		For $objItem In $colItems

			$colItems2 = $objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" & $objItem.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
			For $objItem2 In $colItems2
				$colItems3 = $objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" & $objItem2.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
				For $objItem3 In $colItems3
					If $objItem3.DeviceID = $drive_letter Then
						$physical_drive = $objItem.DeviceID
					EndIf
				Next
			Next

		Next

	Else
		UpdateLog("ERROR with WMI : object not created")
	EndIf

	If $physical_drive Then
		UpdateLog("PhysicalDisk is : " & $physical_drive)
		Return $physical_drive
	Else
		If StringIsDigit(IniRead($settings_ini, "Force_disk", "disk_number", "none")) Then

			UpdateLog("ERROR - PhysicalDisk NOT FOUND but found a force disk setting - returning \\.\PHYSICALDRIVE" & IniRead($settings_ini, "Force_disk", "disk_number", "none"))
			Return "\\.\PHYSICALDRIVE" & IniRead($settings_ini, "Force_disk", "disk_number", "none")
		EndIf
		UpdateLog("ERROR - PhysicalDisk NOT FOUND - Returning an ERROR")
		Return "ERROR"
	EndIf
EndFunc   ;==>GiveMePhysicalDisk

; returns the physical disk (\\.\PhysicalDiskX) corresponding to a drive letter
Func LegacyVMDK()
	Local $physical_drive = 0
	$drive_letter = StringLeft(@ScriptDir, 2)
	UpdateLog("Start LegacyVMDK")

	Local $wbemFlagReturnImmediately, $wbemFlagForwardOnly, $objWMIService, $colItems, $objItem, $found_usb, $usb_model, $usb_size
	$wbemFlagReturnImmediately = 0x10
	$wbemFlagForwardOnly = 0x20
	$colItems = ""

	$objWMIService = ObjGet("winmgmts:\\.\root\CIMV2")
	If @error Or $g_eventerror Or Not IsObj($objWMIService) Then
		UpdateLog("ERROR with WMI : Trying alternate method (WMI impersonation)")
		$g_eventerror = 0
		$objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!//.")
	EndIf

	If @error Or $g_eventerror Then
		UpdateLog("ERROR with WMI")
	ElseIf IsObj($objWMIService) Then
		UpdateLog("WMI seems to work")

		$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_DiskDrive", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

		For $objItem In $colItems
			if ($objItem.DeviceID=GiveMePhysicalDisk()) Then
							UpdateLog("Found a matching DiskDrive in WMI : "&$objItem.Caption)
							$file = FileOpen($vmdkfile, 2)
							FileWrite($file, '# Disk DescriptorFile' & @LF)
							FileWrite($file, 'version=1' & @LF)
							FileWrite($file, 'CID=f8574dda' & @LF)
							FileWrite($file, 'parentCID=ffffffff' & @LF)
							FileWrite($file, 'createType="fullDevice"' & @LF & @LF)
							FileWrite($file, '# Extent description' & @LF)
							$temp_size = Round($objItem.Size/512)
							FileWrite($file, 'RW '& $temp_size &' FLAT "' & $objItem.Name & '"' & @LF & @LF)
							FileWrite($file, '# The disk Data Base' & @LF)
							FileWrite($file, '#DDB' & @LF & @LF)
							FileWrite($file, 'ddb.virtualHWVersion = "4"' & @LF)
							FileWrite($file, 'ddb.adapterType="ide"' & @LF)
							FileWrite($file, 'ddb.geometry.cylinders="' & $objItem.TotalCylinders & '"' & @LF)
							FileWrite($file, 'ddb.geometry.heads="' & $objItem.TotalHeads & '"' & @LF)
							FileWrite($file, 'ddb.geometry.sectors="' & $objItem.SectorsPerTrack & '"' & @LF)
							FileWrite($file, 'ddb.uuid.image="435c196a-1e52-41b6-6d9a-fd72132c3dea"' & @LF)
							FileWrite($file, 'ddb.uuid.parent="00000000-0000-0000-0000-000000000000"' & @LF)
							FileWrite($file, 'ddb.uuid.modification="ed08add6-7936-436c-ad65-aa44718f5aac"' & @LF)
							FileWrite($file, 'ddb.uuid.parentmodification="00000000-0000-0000-0000-000000000000"' & @LF)
							; Useless data ?
							;FileWrite($file, 'ddb.geometry.biosCylinders="987"' & @LF)
							;FileWrite($file, 'ddb.geometry.biosHeads="128"' & @LF)
							;FileWrite($file, 'ddb.geometry.biosSectors="63"' & @LF)
							FileClose($file)
			EndIf
		Next
	Else
		UpdateLog("ERROR with WMI : object not created")
		Return "ERROR"
	EndIf
EndFunc   ;==>GiveMePhysicalDisk



; Change the UUID in order to match with the one originally affected to the disk
Func ChangeUUID()
	If FileExists(@ScriptDir & "\Portable-VirtualBox\data\.VirtualBox\VirtualBox.xml") Then
		UpdateLog("Changing UUID of virtual disk to match the one in VirtualBox.xml and LinuxLive.xml")
		; read content from VirtualBox.xml
		$file = FileOpen(@ScriptDir & "\Portable-VirtualBox\data\.VirtualBox\VirtualBox.xml", 128)
		$lines = FileRead($file)
		FileClose($file)

		;UpdateLog("VirtualBox.xml content :" & @CRLF & @CRLF & $lines)

		$current_uuid = StringRegExp($lines,'(?i)<HardDisk uuid="{(.*)}".*LinuxLive.vmdk',3)


		If StringLen($current_uuid[0]) < 10 Then
			UpdateLog("ERROR : LinuxLive VMDK was not found in VirtualBox config.")
		Else
			UpdateLog("Current UUID found : " & $current_uuid[0])

			; read content from VMDK file of LinuxLive
			$vmdk = FileOpen($vmdkfile, 128)
			$lines_vmdk = FileRead($vmdk)
			FileClose($vmdk)

			; find the actual uuid present in vmdk
			$vmdk_uuid = _StringBetween($lines_vmdk, 'ddb.uuid.image="', '"')

			If @error Then
				UpdateLog("ERROR : Did not found new LinuxLive UUID")
			Else
				UpdateLog("UUID found in VMDK : " & $vmdk_uuid[0])

				; change the VMDK's UUID with the original one in order to have virtualbox working
				$new_vmdk_lines = StringReplace($lines_vmdk, $vmdk_uuid[0], $current_uuid[0])
				$vmdk_write = FileOpen($vmdkfile, 2)
				FileWrite($vmdk_write, $new_vmdk_lines)
				FileClose($vmdk_write)
				UpdateLog("UUID Replaced : "& $vmdk_uuid[0] &" -> "&$current_uuid[0])
			EndIf
		EndIf

	Else
		UpdateLog("ERROR : Portable-VirtualBox\data\.VirtualBox\VirtualBox.xml was not found !")
		MsgBox(4096, "ERROR", "File Portable-VirtualBox\data\.VirtualBox\VirtualBox.xml was not found !")
		Exit
	EndIf
EndFunc   ;==>ChangeUUID

Func RelativePaths()
	If FileExists(@ScriptDir & "\Portable-VirtualBox\data\.VirtualBox\VirtualBox.xml") Then
		$file = FileOpen(@ScriptDir & "\Portable-VirtualBox\data\.VirtualBox\VirtualBox.xml", 128)
		If $file <> -1 Then
			$vbox_config = FileRead($file)
			FileClose($file)
			UpdateLog(@CRLF&"--------------- before relative paths ----------------"&@CRLF&$vbox_config&@CRLF&"-----------------------------------------------------")
			$new_vbox_config = StringRegExpReplace($vbox_config, '(?i)location="(.*?)Portable-VirtualBox\\', 'location="' & StringReplace(@ScriptDir,'\','\\') & '\\Portable-VirtualBox\\')
			$new_vbox_config = StringRegExpReplace($new_vbox_config, '(?i)src="(.*?)Portable-VirtualBox\\', 'src="' & StringReplace(@ScriptDir,'\','\\') & '\\Portable-VirtualBox\\')
			$file = FileOpen(@ScriptDir & "\Portable-VirtualBox\data\.VirtualBox\VirtualBox.xml", 2)
			If $file <> -1 Then
				FileWrite($file, $new_vbox_config)
				FileClose($file)
				UpdateLog(@CRLF&"--------------- after relative paths ----------------"&@CRLF&$new_vbox_config&@CRLF&"-----------------------------------------------------")
			Else
				UpdateLog("Error while trying to write new config to virtualbox.xml")
			EndIf
		EndIf
	EndIf
EndFunc   ;==>RelativePaths

Func DetachDVD()
	UpdateLog("Detaching CD/DVDs of LinuxLive VM")
	$fh = FileOpen (@ScriptDir&"\Portable-VirtualBox\data\.VirtualBox\Machines\LinuxLive\LinuxLive.xml", 128)
	If $fh = -1 Then
		UpdateLog("Error while opening (read) "&@ScriptDir&"\Portable-VirtualBox\data\.VirtualBox\Machines\LinuxLive\LinuxLive.xml")
		Return -1
	EndIf
	$lines=""

	While 1
		$line = FileReadLine($fh)
		If @error = -1 Then ExitLoop

		if (StringInStr($line,"<AttachedDevice passthrough=")>0) Then

			$line=StringReplace($line,"</AttachedDevice>","")
			if (NOT StringInStr($line,"/>")>0) Then
				$line=StringReplace($line,">","/>")
			EndIf
			$lines&=$line&@CR

			$line1 = FileReadLine($fh)
			If @error = -1 Then ExitLoop

			if  (StringInStr($line1,"</AttachedDevice")=0 )  Then
				if ((StringInStr($line1,"<Image")>0) OR (StringInStr($line1,"<Host")>0)) Then
					$line2 = FileReadLine($fh)
					If @error = -1 Then ExitLoop
				Else
					$lines&=$line1&@CR
				EndIf
			Else
				$lines&=$line1&@CR
			EndIf
		Else
			$lines&=$line&@CR
		EndIf

	Wend
	UpdateLog("Done looking for CD/DVDs of LinuxLive VM")
	FileClose($fh)

	$file    = FileOpen (@ScriptDir&"\Portable-VirtualBox\data\.VirtualBox\Machines\LinuxLive\LinuxLive.xml", 2)
	If $fh = -1 Then
		UpdateLog("Error while opening (read/write) "&@ScriptDir&"\Portable-VirtualBox\data\.VirtualBox\Machines\LinuxLive\LinuxLive.xml")
		Return -1
	EndIf
	FileWrite ($file, $lines)
	FileClose ($file)
EndFunc


Func UpdateLog($status)
	_FileWriteLog($logfile, $status)
EndFunc   ;==>UpdateLog

Func LogLauncher()
	$mem = MemGetStats()
	$line = @CRLF & "--------------------------------  System Config  --------------------------------"
	$line &= @CRLF & "OS Type : " & @OSType
	$line &= @CRLF & "OS Version : " & @OSVersion
	$line &= @CRLF & "OS Build : " & @OSBuild
	$line &= @CRLF & "OS Service Pack : " & @OSServicePack
	$line &= @CRLF & "OS Architecture : " & @OSArch
	$line &= @CRLF & "Memory : " & Round($mem[1] / 1024) & "MB  ( with " & (100 - $mem[0]) & "% free = " & Round($mem[2] / 1024) & "MB )"
	$line &= @CRLF & "Language : " & @OSLang
	$line &= @CRLF & "Keyboard : " & @KBLayout
	$line &= @CRLF & "Resolution : " & @DesktopWidth & "x" & @DesktopHeight
	$line &= @CRLF & "------------------------------  End of system config  ------------------------------"
	$line &= @CRLF & "------------------------------  Launcher log  ------------------------------"
	If FileExists($vmdkfile) Then
		$line &= @CRLF & "VMDK >> Present"
	Else
		$line &= @CRLF & "VMDK >>  Not Found"
	EndIf

	If FileExists(@ScriptDir & "\Portable-VirtualBox\Portable-VirtualBox.exe") Then
		$line &= @CRLF & "Vbox >> Present"
	Else
		$line &= @CRLF & "Vbox >>  Not Found"
	EndIf

	If DirGetSize(@ProgramFilesDir & "\Sun\xVM VirtualBox\") > -1 Then
		$line &= @CRLF & "Installed Vbox >> Present"
	Else
		$line &= @CRLF & "Installed Vbox >>  Not Found"
	EndIf

	$line &= @CRLF & "Vbox Config >>" & @CRLF & FileRead(FileOpen(@ScriptDir & "\Portable-VirtualBox\data\.VirtualBox\VirtualBox.xml", 128))
	$line &= @CRLF & "Vmdk config >>" & @CRLF & FileRead(FileOpen($vmdkfile, 128))
	$line &= @CRLF & "------------------------------  End of Launcher log  ------------------------------"
	_FileWriteLog($logfile, $line)
EndFunc   ;==>LogLauncher




; This is my custom error handler
Func MyErrFunc()
	$HexNumber = Hex($oMyError.number, 8)
	UpdateLog("ERROR : COM error intercepted !" & @CRLF & "Number is: " & $HexNumber & @CRLF & "Windescription is: " & $oMyError.windescription & @CRLF & _
			"Source is: " & $oMyError.source & @CRLF & "Scriptline is: " & $oMyError.scriptline)
	$g_eventerror = 1 ; something to check for when this function returns
EndFunc   ;==>MyErrFunc
