#include  "File.au3"
#include  "Array.au3"
#include  "WinAPIFiles.au3"

Global $vmdkfile, $vbox_output, $vbox_config
Global $g_eventerror = 0 ; to be checked to know if com error occurs. Must be reset after handling.
Global $settings_ini = @ScriptDir & "\linuxlive\settings.ini"
Global $oMyError
Global $timer
Global 	$logfile = @ScriptDir & "\linuxlive\launcher.log"
Global $append_arch =""

If DirGetSize(@ScriptDir & "\linuxlive\") == -1 Then DirCreate(@ScriptDir & "\linuxlive\")
If FileExists($logfile) Then FileDelete($logfile)

LogLauncher()
CheckIfInstalled()

; Check if virtualbox is installed or runned
Func CheckIfInstalled()
	UpdateLog("Start-CheckIfInstalled")
	if @OSArch="X64" Then
		UpdateLog("64 Bits OS detected")
		$append_arch="64"
	Else
		UpdateLog("32 Bits OS detected")
		$append_arch=""
	EndIf

	$version_new = RegRead("HKLM"&$append_arch&"\SOFTWARE\Oracle\VirtualBox","Version")
	if $version_new = "%VER%" Then
		$version_new = RegRead("HKLM"&$append_arch&"\SOFTWARE\Oracle\VirtualBox","VersionExt")
	EndIf

	$version_old = RegRead("HKLM"&$append_arch&"\SOFTWARE\Sun\VirtualBox","Version")

	If $version_new <> "" Then
		UpdateLog("Found an Oracle VM VirtualBox installed, version is "&$version_new)
		if Int(StringLeft($version_new,1))>=4 Then UpdateLog("It's a VirtualBox 4.X.X or superior installed => can be used instead of portable one.")
	Else
		UpdateLog("No Oracle VM VirtualBox installed.")
	EndIf

	if $version_old <> "" Then
		UpdateLog("Found an old Sun VM VirtualBox installed, version is "&$version_old&", portable mode should be used instead.")
	Else
		UpdateLog("No Sun xVM VirtualBox installed.")
	EndIf

	if ($version_new <> "" AND Int(StringLeft($version_new,1))<4 ) OR $version_old <> "" Then
		MsgBox(16,"Sorry","Please update your version of VirtualBox to 4.X or uninstall it from your computer to be able to run this portable version"&@CRLF&@CRLF&"This is a security in order to avoid corrupting your current installed version."&@CRLF&@CRLF &"Thank you for your comprehension.")
		Exit
	EndIf

	$portable_mode = IniRead($settings_ini,"Others","force_portable","no")

	UpdateLog("Portable mode forced : "&$portable_mode)
	UpdateLog("Setting Environment variable VBOX_USER_HOME="&@ScriptDir&"\data\.VirtualBox")
	EnvSet("VBOX_USER_HOME",@ScriptDir&"\data\.VirtualBox")

	If $version_new <> ""AND StringLeft($version_new,1)>=4 AND $portable_mode<>"yes" Then
		;MsgBox(16, "Found an installed VirtualBox", "Please uninstall VirtualBox "&$version&" in order to use the portable version.")
		;$iMsgBoxAnswer=MsgBox(65, "Found an installed VirtualBox", "This is a beta feature."&@CRLF&"LinuxLive USB will try to run in your non-portable VirtualBox."&@CRLF&"Click OK to continue or Cancel to abandon.")
		;Select
			;Case $iMsgBoxAnswer = 2 ;Cancel
				;Exit
		;EndSelect

		$nonportable_install_dir=RegRead("HKLM"&$append_arch&"\SOFTWARE\Oracle\VirtualBox","InstallDir")
		UpdateLog("Virtualbox install directory is : "&$nonportable_install_dir)

		PrepareForLinuxLive($nonportable_install_dir)

		if $CmdLine[0] = 1 Then
			UpdateLog("Automatically starting VM named "&$CmdLine[1])
			$cmd_vbox='cmd /c ""'&$nonportable_install_dir&'VBoxManage.exe" startvm "'&$CmdLine[1]&'""'
			UpdateLog('Command line used : '&$cmd_vbox)
			Run($cmd_vbox,@ScriptDir,@SW_HIDE)
		Else
			$cmd_vbox=$nonportable_install_dir&"VirtualBox.exe"
			UpdateLog("Command line used : "&$cmd_vbox)
			Run($cmd_vbox)
		EndIf
		UpdateLog("Done launching regular VirtualBox, now exiting")
		UpdateLog("END-CheckIfInstalled")
		exit
	Else
		UpdateLog("Using portable mode")
	EndIf
	#cs
	UpdateLog("Closing process VirtualBox.exe")
	ProcessClose ("VirtualBox.exe")
	UpdateLog("Closing process VBoxManage.exe")
	ProcessClose ("VBoxManage.exe")
	UpdateLog("Closing process VBoxSVC.exe")
	ProcessClose ("VBoxSVC.exe")
	#ce
	$timer=TimerInit()
	UpdateLog("END-CheckIfInstalled")
EndFunc

Func PrepareForLinuxLive($installdir="")
	UpdateLog("Start-PrepareForLinuxLive")
	$oMyError = ObjEvent("AutoIt.Error", "MyErrFunc") ; Install a custom error handler

	$vmdkfile = @ScriptDir & "\data\.VirtualBox\Machines\LinuxLive\HardDisks\LinuxLive.vmdk"
	; To be sure it exists
	DirCreate(@ScriptDir & "\data\.VirtualBox\Machines\LinuxLive\HardDisks\")
	; deleting old VMDK, Creating new one and changing back its uuid
	If FileExists($vmdkfile) Then FileDelete($vmdkfile)

	UpdateLog("VMDK File is "&$vmdkfile)
	$drive_letter = StringLeft(@ScriptDir, 2)
	$physical_drive=GiveMePhysicalDisk($drive_letter)

	; For partitions manage
	If StringLen(IniRead($settings_ini, "Force_disk", "disk_partitions", "")) > 0 Then
		UpdateLog("PrepareForLinuxLive: Found partitions disk setting - using " & IniRead($settings_ini, "Force_disk", "disk_partitions", ""))
		$disk_partitions = " -partitions " & IniRead($settings_ini, "Force_disk", "disk_partitions", "")
	Else
		$disk_partitions = ""
	EndIf

	  If FileExists (@ScriptDir&"\app32\") AND FileExists (@ScriptDir&"\app64\") Then
			If @OSArch = "x86" Then
			  Global $arch = "app32"
			EndIf
			If @OSArch = "x64" Then
			  Global $arch = "app64"
			EndIf
		  Else
			If FileExists (@ScriptDir&"\app32\") AND NOT FileExists (@ScriptDir&"\app64\") Then
			  Global $arch = "app32"
			EndIf
			If NOT FileExists (@ScriptDir&"\app32\") AND FileExists (@ScriptDir&"\app64\") Then
			  Global $arch = "app64"
			EndIf
		EndIf

	RelativePathMichael()

	; recreating LinuxLive virtual Disk
	if $installdir="" Then
		$biou='"'&$arch & '\VBoxManage.exe" internalcommands createrawvmdk -filename "' & $vmdkfile & '" -rawdisk ' & $physical_drive & $disk_partitions
	Else
		$biou='"'&$installdir & 'VBoxManage.exe" internalcommands createrawvmdk -filename "' & $vmdkfile & '" -rawdisk ' & $physical_drive & $disk_partitions
	EndIf
	UpdateLog("Updating VMDK File using CLI : "&$biou)
	RunWait3($biou)

	If NOT FileExists($vmdkfile) Then
		UpdateLog("VMDK not created using native method.")
		UpdateLog("Now trying legacy method.")
		LegacyVMDK()
	EndIf

	If FileExists($vmdkfile) Then
		UpdateLog("VMDK has been successfully created")
		ChangeUUID()
		;to avoid the bug with vbox tools
		;DetachDVD()
		;RelativePaths()
		;ThreeSecLegalNotice()
	Else
		SplashOff()
		MsgBox(16, "WARNING", "There was a problem recreating Linux Live virtual disk." & @CRLF & "Please send log file (Portable-VirtualBox\linuxlive\launcher.log) to vbox-debug@linuxliveusb.com")
	EndIf
	UpdateLog("End-PrepareForLinuxLive")
EndFunc

Func RunWait3($soft)
	Local $foo
	$foo = Run($soft, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$vbox_output = @CRLF
	While True
		$vbox_output &= StdoutRead($foo)
		If @error Then ExitLoop
	WEnd
	if $vbox_output=@CRLF Then
		UpdateLog("ERROR : No return from command line ! Wrong command")
	Else
		UpdateLog("Creating VMDK using VBoxManage - Return : " & @CRLF &$vbox_output)
	EndIf
EndFunc   ;==>RunWait3

; returns the physical disk (\\.\PhysicalDiskX) corresponding to a drive letter
Func GiveMePhysicalDisk($drive_letter)
	UpdateLog("Start-GiveMePhysicalDisk of : "&$drive_letter)
	$windows_drive_letter = StringLeft(@WindowsDir, 2)

	if $drive_letter = $windows_drive_letter Then
		$return = MsgBox(262144+52+256,"Warning !", "You are trying to virtualize your Windows drive."&@crlf&@crlf&"Please be aware that this could lead to data corruption !!"&@CRLF&@CRLF&"If you know what you are doing and accept the risk, click YES."&@CRLF&"If you are not sure then click NO (recommended).")
		if $return=7 or $return=-1 then Exit
	EndIf

	$drive_infos = _WinAPI_GetDriveNumber($drive_letter)
	If NOT @error AND IsArray($drive_infos) Then
		$physical_drive="\\.\PHYSICALDRIVE"&$drive_infos[1]
		UpdateLog("End-GiveMePhysicalDisk ( SUCCESS : "&$drive_letter&" is on physical disk "&$physical_drive&" )")
		Return $physical_drive
	Else
		UpdateLog("IN-GiveMePhysicalDisk ( WARNING : Falling back to WMI Mode )")
		Return GiveMePhysicalDiskWMI($drive_letter)
	EndIf
EndFunc

Func GiveMePhysicalDiskWMI($drive_letter)
	Local $physical_drive,$g_eventerror

	UpdateLog("Start-GiveMePhysicalDiskWMI of : "&$drive_letter)

	Local $wbemFlagReturnImmediately, $wbemFlagForwardOnly, $objWMIService, $colItems, $objItem, $found_usb, $usb_model, $usb_size
	$wbemFlagReturnImmediately = 0x10
	$wbemFlagForwardOnly = 0x20
	$colItems = ""

	$objWMIService = ObjGet("winmgmts:\\.\root\CIMV2")
	if @error OR $g_eventerror OR NOT IsObj($objWMIService) Then
		UpdateLog("IN-GiveMePhysicalDiskWMI ( ERROR with WMI : Trying alternate method (WMI impersonation) )")
		$g_eventerror =0
		$objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!//.")
	EndIf

	if @error OR $g_eventerror then
		UpdateLog("IN-GiveMePhysicalDiskWMI ( ERROR with WMI )")
	Elseif IsObj($objWMIService) Then
		UpdateLog("IN-GiveMePhysicalDiskWMI ( WMI seems to work )")

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
		UpdateLog("IN-GiveMePhysicalDiskWMI ( ERROR with WMI : object not created, cannot find PhysicalDisk)")
	endif

	if $physical_drive Then
		UpdateLog("End-GiveMePhysicalDiskWMI ( SUCCESS : "&$drive_letter&" is on physical disk "&$physical_drive&" )")
		Return $physical_drive
	Else
		If StringIsDigit(IniRead($settings_ini, "Force_disk", "disk_number", "none")) Then
			UpdateLog("END-GiveMePhysicalDisk : ERROR - PhysicalDisk NOT FOUND but found a force disk setting - returning \\.\PHYSICALDRIVE" & IniRead($settings_ini, "Force_disk", "disk_number", "none"))
			Return "\\.\PHYSICALDRIVE" & IniRead($settings_ini, "Force_disk", "disk_number", "none")
		EndIf
		UpdateLog("End-GiveMePhysicalDiskWMI ( ERROR : No physical disk found for: "& $drive_letter&" )")
		Return "ERROR"
	EndIf
EndFunc

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
			if ($objItem.DeviceID=GiveMePhysicalDisk($drive_letter)) Then
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
	UpdateLog("Start-ChangeUUID")
	$linuxlive_config_file=@ScriptDir & "\data\.VirtualBox\Machines\LinuxLive\LinuxLive.vbox"

	If FileExists($linuxlive_config_file) Then
		UpdateLog("Changing UUID of virtual disk to match the one in LinuxLive.vbox")
		; read content from VirtualBox.xml
		$file = FileOpen($linuxlive_config_file, 128)
		if @error Then
			UpdateLog("ERROR : Could not open LinuxLive.vbox file.")
			MsgBox(0,"Error","ERROR : Could not open LinuxLive.vbox file.")
			return ""
		EndIf
		$lines = FileRead($file)
		FileClose($file)

		;UpdateLog("VirtualBox.xml content :" & @CRLF & @CRLF & $lines)

		$current_uuid = StringRegExp($lines,'(?i)<HardDisk uuid="{(.*)}".*LinuxLive.vmdk',3)
		if @error Then
			UpdateLog("ERROR : LinuxLive VMDK was not found in VirtualBox config.")
			Return ""
		EndIf
		If StringLen($current_uuid[0]) < 10 Then
			UpdateLog("ERROR : LinuxLive VMDK was found but length is invalid in VirtualBox config.")
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
		UpdateLog("END-ChangeUUID")
	Else
		UpdateLog("ERROR : .VirtualBox\Machines\LinuxLive\LinuxLive.vbox not found !")
		MsgBox(4096, "ERROR", "File .VirtualBox\Machines\LinuxLive\LinuxLive.vbox not found !")
		UpdateLog("END-ChangeUUID : FATAL, exiting now")
		Exit
	EndIf
EndFunc   ;==>ChangeUUID

Func RelativePaths()
	UpdateLog("Start-RelativePaths")
	$nonportable_install_dir=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Oracle\VirtualBox","InstallDir")
	If FileExists(@ScriptDir & "\data\.VirtualBox\VirtualBox.xml") Then
		$file = FileOpen(@ScriptDir & "\data\.VirtualBox\VirtualBox.xml", 128)
		If $file <> -1 Then
			$vbox_config = FileRead($file)
			FileClose($file)
			;UpdateLog(@CRLF&"--------------- before relative paths ----------------"&@CRLF&$vbox_config&@CRLF&"-----------------------------------------------------")
			$new_vbox_config = StringRegExpReplace($vbox_config, '(?i)location="(.*?)Portable-VirtualBox\\', 'location="' & StringReplace(@ScriptDir,'\','\\') & '\\Portable-VirtualBox\\')
			$new_vbox_config = StringRegExpReplace($new_vbox_config, '(?i)src="(.*?)Portable-VirtualBox\\', 'src="' & StringReplace(@ScriptDir,'\','\\') & '\\Portable-VirtualBox\\')
			if NOT $nonportable_install_dir = "" Then
				$new_vbox_config = StringRegExpReplace($new_vbox_config,  '(?i)location="(.*?)Additions.iso', 'location="' & StringReplace($nonportable_install_dir,'\','\\') & 'VBoxGuestAdditions.iso')
			EndIf
			$file = FileOpen(@ScriptDir & "\data\.VirtualBox\VirtualBox.xml", 2)
			If $file <> -1 Then
				FileWrite($file, $new_vbox_config)
				FileClose($file)
				;UpdateLog(@CRLF&"--------------- after relative paths ----------------"&@CRLF&$new_vbox_config&@CRLF&"-----------------------------------------------------")
				UpdateLog("END-RelativePaths")
			Else
				UpdateLog("Error while trying to write new config to virtualbox.xml")
				UpdateLog("END-RelativePaths")
			EndIf
		EndIf
	Else
		UpdateLog("ERROR : Portable-VirtualBox\data\.VirtualBox\VirtualBox.xml not found !")
		MsgBox(4096, "ERROR", "File Portable-VirtualBox\data\.VirtualBox\VirtualBox.xml not found !")
		UpdateLog("END-RelativePaths : FATAL, exiting now")
		Exit
	EndIf
EndFunc   ;==>RelativePaths

Func RelativePathMichael()
  If FileExists (@ScriptDir&"\data\.VirtualBox\VirtualBox.xml") OR (FileExists (@ScriptDir&"\data\.VirtualBox\Machines\") AND FileExists (@ScriptDir&"\data\.VirtualBox\HardDisks\")) Then
		Local $line, $i, $j, $k, $l, $m
		Local $values0, $values1, $values2, $values3, $values4, $values5, $values6, $values7, $values8, $values9, $values10, $values11, $values12
		Local $file = FileOpen (@ScriptDir&"\data\.VirtualBox\VirtualBox.xml", 128)
		If $file <> -1 Then
		  $line    = FileRead ($file)
		  $values0 = _StringBetween ($line, '<MachineRegistry>', '</MachineRegistry>')
		  If $values0 = 0 Then
			$values1 = 0
		  Else
			$values1 = _StringBetween ($values0[0], 'src="', '"')
		  EndIf
		  $values2 = _StringBetween ($line, '<HardDisks>', '</HardDisks>')
		  If $values2 = 0 Then
			$values3 = 0
		  Else
			$values3 = _StringBetween ($values2[0], 'location="', '"')
		  EndIf
		  $values4 = _StringBetween ($line, '<DVDImages>', '</DVDImages>')
		  If $values4 = 0 Then
			$values5 = 0
		  Else
			$values5 = _StringBetween ($values4[0], '<Image', '/>')
		  EndIf
		  $values10 = _StringBetween ($line, '<Global>', '</Global>')
		  If $values10 = 0 Then
			$values11 = 0
		  Else
			$values11 = _StringBetween ($values10[0], '<SystemProperties', '/>')
		  EndIf

		  For $i = 0 To UBound ($values1) - 1
			$values6 = _StringBetween ($values1[$i], 'Machines', '.xml')
			If $values6 <> 0 Then
			  $content = FileRead (FileOpen (@ScriptDir&"\data\.VirtualBox\VirtualBox.xml", 128))
			  $file    = FileOpen (@ScriptDir&"\data\.VirtualBox\VirtualBox.xml", 2)
			  FileWrite ($file, StringReplace ($content, $values1[$i], @ScriptDir&"\data\.VirtualBox\Machines" & $values6[0] & ".xml"))
			  FileClose ($file)
			EndIf
		  Next

		  For $j = 0 To UBound ($values3) - 1
			$values7 = _StringBetween ($values3[$j], 'HardDisks', '.vdi')
			If $values7 <> 0 Then
			  $content = FileRead (FileOpen (@ScriptDir&"\data\.VirtualBox\VirtualBox.xml", 128))
			  $file    = FileOpen (@ScriptDir&"\data\.VirtualBox\VirtualBox.xml", 2)
			  FileWrite ($file, StringReplace ($content, $values3[$j], "HardDisks" & $values7[0] & ".vdi"))
			  FileClose ($file)
			EndIf
		  Next

		  For $k = 0 To UBound ($values3) - 1
			$values8 = _StringBetween ($values3[$k], 'Machines', '.vdi')
			If $values8 <> 0 Then
			  $content = FileRead (FileOpen (@ScriptDir&"\data\.VirtualBox\VirtualBox.xml", 128))
			  $file    = FileOpen (@ScriptDir&"\data\.VirtualBox\VirtualBox.xml", 2)
			  FileWrite ($file, StringReplace ($content, $values3[$k], "Machines" & $values8[0] & ".vdi"))
			  FileClose ($file)
			EndIf
		  Next

		  For $l = 0 To UBound ($values5) - 1
			$values9 = _StringBetween ($values5[$l], 'location="', '"')
			If $values9 <> 0 Then
			  If NOT FileExists ($values9[0]) Then
				$content = FileRead (FileOpen (@ScriptDir&"\data\.VirtualBox\VirtualBox.xml", 128))
				$file    = FileOpen (@ScriptDir&"\data\.VirtualBox\VirtualBox.xml", 2)
				FileWrite ($file, StringReplace ($content, "<Image" & $values5[$l] & "/>", ""))
				FileClose ($file)
			  EndIf
			EndIf
		  Next

		  For $m = 0 To UBound ($values11) - 1
			$values12 = _StringBetween ($values11[$m], 'defaultMachineFolder="', '"')
			If $values12 <> 0 Then
			  If NOT FileExists ($values10[0]) Then
				$content = FileRead (FileOpen (@ScriptDir&"\data\.VirtualBox\VirtualBox.xml", 128))
				$file    = FileOpen (@ScriptDir&"\data\.VirtualBox\VirtualBox.xml", 2)
				FileWrite ($file, StringReplace ($content, $values12[0], @ScriptDir&"\data\.VirtualBox\Machines"))
				FileClose ($file)
			  EndIf
			EndIf
		  Next

		  FileClose ($file)
	  EndIf
  EndIf
EndFunc

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
	$line &= @CRLF & "Processor Architecture : " & @CPUArch
	$line &= @CRLF & "Processor Model : " & RegRead("HKEY_LOCAL_MACHINE"&$append_arch&"\HARDWARE\DESCRIPTION\System\CentralProcessor\0","ProcessorNameString")
	$line &= @CRLF & "Memory : " & Round($mem[1] / 1024) & "MB  ( with " & (100 - $mem[0]) & "% free = " & Round($mem[2] / 1024) & "MB )"
	$line &= @CRLF & "OS Lang :  " & HumanOSLang(@OSLang) & " ("& @OSLang&")"
	$line &= @CRLF & "Language : " & HumanOSLang(@MUILang) & " ("& @MUILang&")"
	$line &= @CRLF & "Keyboard : " & @KBLayout
	$line &= @CRLF & "Resolution : " & @DesktopWidth & "x" & @DesktopHeight
	$line &= @CRLF & "------------------------------  End of system config  ------------------------------"
	UpdateLog($line)
EndFunc

Func VMDKLog()
	$line=""
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
EndFunc


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

Func HumanOSLang($code)
	if $code="0436" Then
		 Return "Afrikaans"
	Elseif $code="041c" Then
		 Return "Albanian"
	Elseif $code="0401" Then
		 Return "Arabic_Saudi_Arabia"
	Elseif $code="0801" Then
		 Return "Arabic_Iraq"
	Elseif $code="0c01" Then
		 Return "Arabic_Egypt"
	Elseif $code="1001" Then
		 Return "Arabic_Libya"
	Elseif $code="1401" Then
		 Return "Arabic_Algeria"
	Elseif $code="1801" Then
		 Return "Arabic_Morocco"
	Elseif $code="1c01" Then
		 Return "Arabic_Tunisia"
	Elseif $code="2001" Then
		 Return "Arabic_Oman"
	Elseif $code="2401" Then
		 Return "Arabic_Yemen"
	Elseif $code="2801" Then
		 Return "Arabic_Syria"
	Elseif $code="2c01" Then
		 Return "Arabic_Jordan"
	Elseif $code="3001" Then
		 Return "Arabic_Lebanon"
	Elseif $code="3401" Then
		 Return "Arabic_Kuwait"
	Elseif $code="3801" Then
		 Return "Arabic_UAE"
	Elseif $code="3c01" Then
		 Return "Arabic_Bahrain"
	Elseif $code="4001" Then
		 Return "Arabic_Qatar"
	Elseif $code="042b" Then
		 Return "Armenian"
	Elseif $code="042c" Then
		 Return "Azeri_Latin"
	Elseif $code="082c" Then
		 Return "Azeri_Cyrillic"
	Elseif $code="042d" Then
		 Return "Basque"
	Elseif $code="0423" Then
		 Return "Belarusian"
	Elseif $code="0402" Then
		 Return "Bulgarian"
	Elseif $code="0403" Then
		 Return "Catalan"
	Elseif $code="0404" Then
		 Return "Chinese_Taiwan"
	Elseif $code="0804" Then
		 Return "Chinese_PRC"
	Elseif $code="0c04" Then
		 Return "Chinese_Hong_Kong"
	Elseif $code="1004" Then
		 Return "Chinese_Singapore"
	Elseif $code="1404" Then
		 Return "Chinese_Macau"
	Elseif $code="041a" Then
		 Return "Croatian"
	Elseif $code="0405" Then
		 Return "Czech"
	Elseif $code="0406" Then
		 Return "Danish"
	Elseif $code="0413" Then
		 Return "Dutch_Standard"
	Elseif $code="0813" Then
		 Return "Dutch_Belgian"
	Elseif $code="0409" Then
		 Return "English_United_States"
	Elseif $code="0809" Then
		 Return "English_United_Kingdom"
	Elseif $code="0c09" Then
		 Return "English_Australian"
	Elseif $code="1009" Then
		 Return "English_Canadian"
	Elseif $code="1409" Then
		 Return "English_New_Zealand"
	Elseif $code="1809" Then
		 Return "English_Irish"
	Elseif $code="1c09" Then
		 Return "English_South_Africa"
	Elseif $code="2009" Then
		 Return "English_Jamaica"
	Elseif $code="2409" Then
		 Return "English_Caribbean"
	Elseif $code="2809" Then
		 Return "English_Belize"
	Elseif $code="2c09" Then
		 Return "English_Trinidad"
	Elseif $code="3009" Then
		 Return "English_Zimbabwe"
	Elseif $code="3409" Then
		 Return "English_Philippines"
	Elseif $code="0425" Then
		 Return "Estonian"
	Elseif $code="0438" Then
		 Return "Faeroese"
	Elseif $code="0429" Then
		 Return "Farsi"
	Elseif $code="040b" Then
		 Return "Finnish"
	Elseif $code="040c" Then
		 Return "French_Standard"
	Elseif $code="080c" Then
		 Return "French_Belgian"
	Elseif $code="0c0c" Then
		 Return "French_Canadian"
	Elseif $code="100c" Then
		 Return "French_Swiss"
	Elseif $code="140c" Then
		 Return "French_Luxembourg"
	Elseif $code="180c" Then
		 Return "French_Monaco"
	Elseif $code="0437" Then
		 Return "Georgian"
	Elseif $code="0407" Then
		 Return "German_Standard"
	Elseif $code="0807" Then
		 Return "German_Swiss"
	Elseif $code="0c07" Then
		 Return "German_Austrian"
	Elseif $code="1007" Then
		 Return "German_Luxembourg"
	Elseif $code="1407" Then
		 Return "German_Liechtenstei"
	Elseif $code="408" 	Then
		 Return "Greek"
	Elseif $code="040d" Then
		 Return "Hebrew"
	Elseif $code="0439" Then
		 Return "Hindi"
	Elseif $code="040e" Then
		 Return "Hungarian"
	Elseif $code="040f" Then
		 Return "Icelandic"
	Elseif $code="0421" Then
		 Return "Indonesian"
	Elseif $code="0410" Then
		 Return "Italian_Standard"
	Elseif $code="0810" Then
		 Return "Italian_Swiss"
	Elseif $code="0411" Then
		 Return "Japanese"
	Elseif $code="043f" Then
		 Return "Kazakh"
	Elseif $code="0457" Then
		 Return "Konkani"
	Elseif $code="0412" Then
		 Return "Korean"
	Elseif $code="0426" Then
		 Return "Latvian"
	Elseif $code="0427" Then
		 Return "Lithuanian"
	Elseif $code="042f" Then
		 Return "Macedonian"
	Elseif $code="043e" Then
		 Return "Malay_Malaysia"
	Elseif $code="083e" Then
		 Return "Malay_Brunei_Darussalam"
	Elseif $code="044e" Then
		 Return "Marathi"
	Elseif $code="0414" Then
		 Return "Norwegian_Bokmal"
	Elseif $code="0814" Then
		 Return "Norwegian_Nynorsk"
	Elseif $code="0415" Then
		 Return "Polish"
	Elseif $code="0416" Then
		 Return "Portuguese_Brazilian"
	Elseif $code="0816" Then
		 Return "Portuguese_Standard"
	Elseif $code="0418" Then
		 Return "Romanian"
	Elseif $code="0419" Then
		 Return "Russian"
	Elseif $code="044f" Then
		 Return "Sanskrit"
	Elseif $code="081a" Then
		 Return "Serbian_Latin"
	Elseif $code="0c1a" Then
		 Return "Serbian_Cyrillic"
	Elseif $code="041b" Then
		 Return "Slovak"
	Elseif $code="0424" Then
		 Return "Slovenian"
	Elseif $code="040a" Then
		 Return "Spanish_Traditional_Sort"
	Elseif $code="080a" Then
		 Return "Spanish_Mexican"
	Elseif $code="0c0a" Then
		 Return "Spanish_Modern_Sort"
	Elseif $code="100a" Then
		 Return "Spanish_Guatemala"
	Elseif $code="140a" Then
		 Return "Spanish_Costa_Rica"
	Elseif $code="180a" Then
		 Return "Spanish_Panama"
	Elseif $code="1c0a" Then
		 Return "Spanish_Dominican_Republic"
	Elseif $code="200a" Then
		 Return "Spanish_Venezuela"
	Elseif $code="240a" Then
		 Return "Spanish_Colombia"
	Elseif $code="280a" Then
		 Return "Spanish_Peru"
	Elseif $code="2c0a" Then
		 Return "Spanish_Argentina"
	Elseif $code="300a" Then
		 Return "Spanish_Ecuador"
	Elseif $code="340a" Then
		 Return "Spanish_Chile"
	Elseif $code="380a" Then
		 Return "Spanish_Uruguay"
	Elseif $code="3c0a" Then
		 Return "Spanish_Paraguay"
	Elseif $code="400a" Then
		 Return "Spanish_Bolivia"
	Elseif $code="440a" Then
		 Return "Spanish_El_Salvador"
	Elseif $code="480a" Then
		 Return "Spanish_Honduras"
	Elseif $code="4c0a" Then
		 Return "Spanish_Nicaragua"
	Elseif $code="500a" Then
		 Return "Spanish_Puerto_Rico"
	Elseif $code="0441" Then
		 Return "Swahili"
	Elseif $code="041d" Then
		 Return "Swedish"
	Elseif $code="081d" Then
		 Return "Swedish_Finland"
	Elseif $code="0449" Then
		 Return "Tamil"
	Elseif $code="0444" Then
		 Return "Tatar"
	Elseif $code="041e" Then
		 Return "Thai"
	Elseif $code="041f" Then
		 Return "Turkish"
	Elseif $code="0422" Then
		 Return "Ukrainian"
	Elseif $code="0420" Then
		 Return "Urdu"
	Elseif $code="0443" Then
		 Return "Uzbek_Latin"
	Elseif $code="0843" Then
		 Return "Uzbek_Cyrillic"
	Elseif $code="042a" Then
		 Return "Vietnamese"
	 Else
		 Return "ERROR"
	EndIf
EndFunc