#include <File.au3>
#include <Array.au3>


Global $arch, $vmdkfile, $vbox_output, $vbox_config, $logfile
Global $g_eventerror = 0 ; to be checked to know if com error occurs. Must be reset after handling.
Global $settings_ini = @ScriptDir & "\linuxlive\settings.ini"
Global $oMyError
Global $timer

CheckIfInstalled()

; Check if virtualbox is installed or runned
Func CheckIfInstalled()
	if @OSArch="X64" Then
		$add="64"
	Else
		$add=""
	EndIf

	$version_new = RegRead("HKLM"&$add&"\SOFTWARE\Oracle\VirtualBox","Version")
	$version_old = RegRead("HKLM"&$add&"\SOFTWARE\Sun\VirtualBox","Version")
	$version=$version_old&$version_new
	If $version <> "" AND IniRead($settings_ini,"Others","force_portable","no")<>"yes" Then
		;MsgBox(16, "Found an installed VirtualBox", "Please uninstall VirtualBox "&$version&" in order to use the portable version.")
		;$iMsgBoxAnswer=MsgBox(65, "Found an installed VirtualBox", "This is a beta feature."&@CRLF&"LinuxLive USB will try to run in your non-portable VirtualBox."&@CRLF&"Click OK to continue or Cancel to abandon.")
		;Select
			;Case $iMsgBoxAnswer = 2 ;Cancel
				;Exit
		;EndSelect
		PrepareForLinuxLive()
		EnvSet("VBOX_USER_HOME",@ScriptDir&"\data\.VirtualBox")
		$nonportable_install_dir=RegRead("HKLM"&$add&"\SOFTWARE\Oracle\VirtualBox","InstallDir")
		if $CmdLine[0] = 1 Then
			Run('cmd /c ""'&$nonportable_install_dir&'VBoxManage.exe" startvm "'&$CmdLine[1]&'""',@ScriptDir,@SW_HIDE)
		Else
			Run($nonportable_install_dir&"VirtualBox.exe")
		EndIf



		exit
	EndIf
	EnvSet("VBOX_USER_HOME",@ScriptDir&"\data\.VirtualBox")
	ProcessClose ("VirtualBox.exe")
	ProcessClose ("VBoxManage.exe")
	ProcessClose ("VBoxSVC.exe")
	$timer=TimerInit()
EndFunc

Func PrepareForLinuxLive()
	$oMyError = ObjEvent("AutoIt.Error", "MyErrFunc") ; Install a custom error handler

	; preparing for logging
	$logfile = @ScriptDir & "\linuxlive\launcher.log"
	If DirGetSize(@ScriptDir & "\linuxlive\") == -1 Then DirCreate(@ScriptDir & "\linuxlive\")
	If FileExists($logfile) Then FileDelete($logfile)

	$vmdkfile = @ScriptDir & "\data\.VirtualBox\HardDisks\LinuxLive.vmdk"
	; To be sure it exists
	DirCreate(@ScriptDir & "\data\.VirtualBox\HardDisks\")
	; deleting old VMDK, Creating new one and changing back its uuid
	If FileExists($vmdkfile) Then FileDelete($vmdkfile)

	; recreating LinuxLive virtual Disk
	RunWait3($arch & '\VBoxManage.exe internalcommands createrawvmdk -filename "' & $vmdkfile & '" -rawdisk ' & GiveMePhysicalDisk())

	If NOT FileExists($vmdkfile) Then
		UpdateLog("VMDK not created using native method.")
		UpdateLog("Now trying legacy method.")
		LegacyVMDK()
	EndIf

	If FileExists($vmdkfile) Then
		ChangeUUID()
		;to avoid the bug with vbox tools
		;DetachDVD()
		RelativePaths()
		ThreeSecLegalNotice()
	Else
		SplashOff()
		MsgBox(16, "WARNING", "There was a problem recreating Linux Live virtual disk." & @CRLF & "Please send log file (Portable-VirtualBox\linuxlive\launcher.log) to vbox-debug@linuxliveusb.com")
	EndIf
EndFunc

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
					UpdateLog("Found a mounted disk in WMI : "&$objItem3.DeviceID &" mounted on "&$objItem.DeviceID)
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
	If FileExists(@ScriptDir & "\data\.VirtualBox\VirtualBox.xml") Then
		UpdateLog("Changing UUID of virtual disk to match the one in VirtualBox.xml and LinuxLive.xml")
		; read content from VirtualBox.xml
		$file = FileOpen(@ScriptDir & "\data\.VirtualBox\VirtualBox.xml", 128)
		if @error Then MsgBox(0,"kjk","Error while trying to open VirtualBox.xml")
		$lines = FileRead($file)
		FileClose($file)

		UpdateLog("VirtualBox.xml content :" & @CRLF & @CRLF & $lines)

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
	$nonportable_install_dir=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Oracle\VirtualBox","InstallDir")
	If FileExists(@ScriptDir & "\data\.VirtualBox\VirtualBox.xml") Then
		$file = FileOpen(@ScriptDir & "\data\.VirtualBox\VirtualBox.xml", 128)
		If $file <> -1 Then
			$vbox_config = FileRead($file)
			FileClose($file)
			UpdateLog(@CRLF&"--------------- before relative paths ----------------"&@CRLF&$vbox_config&@CRLF&"-----------------------------------------------------")
			$new_vbox_config = StringRegExpReplace($vbox_config, '(?i)location="(.*?)Portable-VirtualBox\\', 'location="' & StringReplace(@ScriptDir,'\','\\') & '\\Portable-VirtualBox\\')
			$new_vbox_config = StringRegExpReplace($new_vbox_config, '(?i)src="(.*?)Portable-VirtualBox\\', 'src="' & StringReplace(@ScriptDir,'\','\\') & '\\Portable-VirtualBox\\')
			if NOT $nonportable_install_dir = "" Then
				$new_vbox_config = StringRegExpReplace($new_vbox_config,  '(?i)location="(.*?)Additions.iso', 'location="' & StringReplace($nonportable_install_dir,'\','\\') & 'VBoxGuestAdditions.iso')
			EndIf
			$file = FileOpen(@ScriptDir & "\data\.VirtualBox\VirtualBox.xml", 2)
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
	$fh = FileOpen (@ScriptDir&"\data\.VirtualBox\Machines\LinuxLive\LinuxLive.xml", 128)
	If $fh = -1 Then
		UpdateLog("Error while opening (read) "&@ScriptDir&"\data\.VirtualBox\Machines\LinuxLive\LinuxLive.xml")
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

	$file    = FileOpen (@ScriptDir&"\data\.VirtualBox\Machines\LinuxLive\LinuxLive.xml", 2)
	If $fh = -1 Then
		UpdateLog("Error while opening (read/write) "&@ScriptDir&"\data\.VirtualBox\Machines\LinuxLive\LinuxLive.xml")
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

	If FileExists(@ScriptDir & "\Portable-VirtualBox.exe") Then
		$line &= @CRLF & "Vbox >> Present"
	Else
		$line &= @CRLF & "Vbox >>  Not Found"
	EndIf

	If DirGetSize(@ProgramFilesDir & "\Sun\xVM VirtualBox\") > -1 Then
		$line &= @CRLF & "Installed Vbox >> Present"
	Else
		$line &= @CRLF & "Installed Vbox >>  Not Found"
	EndIf

	$line &= @CRLF & "Vbox Config >>" & @CRLF & FileRead(FileOpen(@ScriptDir & "\data\.VirtualBox\VirtualBox.xml", 128))
	$line &= @CRLF & "Vmdk config >>" & @CRLF & FileRead(FileOpen($vmdkfile, 128))
	$line &= @CRLF & "------------------------------  End of Launcher log  ------------------------------"
	_FileWriteLog($logfile, $line)
EndFunc   ;==>LogLauncher


; Display legal Notice For at least 3 sec
Func ThreeSecLegalNotice()
	While TimerDiff($timer)<3000
		Sleep(300)
	WEnd
	SplashOff ()
EndFunc

; This is my custom error handler
Func MyErrFunc()
	$HexNumber = Hex($oMyError.number, 8)
	UpdateLog("ERROR : COM error intercepted !" & @CRLF & "Number is: " & $HexNumber & @CRLF & "Windescription is: " & $oMyError.windescription & @CRLF & _
			"Source is: " & $oMyError.source & @CRLF & "Scriptline is: " & $oMyError.scriptline)
	$g_eventerror = 1 ; something to check for when this function returns
EndFunc   ;==>MyErrFunc