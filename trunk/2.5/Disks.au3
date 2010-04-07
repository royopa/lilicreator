; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Disks Management                              ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Refresh_DriveList()
	SendReport("Start-Refresh_DriveList")
	$system_letter = StringLeft(@SystemDir, 2)
	; récupére la liste des disques
	$drive_list = DriveGetDrive("REMOVABLE")
	$all_drives = "|-> " & Translate("Choose a USB Key") & "|"
	If Not @error Then
		Dim $description[100]
		If UBound($drive_list) >= 1 Then
			For $i = 1 To $drive_list[0]
				$label = DriveGetLabel($drive_list[$i])
				$fs = DriveGetFileSystem($drive_list[$i])
				$space = DriveSpaceTotal($drive_list[$i])
				If Not (($fs = "") Or ($space = 0) Or ($drive_list[$i] = $system_letter)) Then
					$all_drives &= StringUpper($drive_list[$i]) & " " & $label & " - " & $fs & " - " & Round($space / 1024, 1) & " " & Translate("GB") & "|"
				EndIf
			Next
		EndIf
	EndIf
	SendReport("Start-Refresh_DriveList-Removable Listed")
	$drive_list = DriveGetDrive("FIXED")
	If Not @error Then
		$all_drives &= "-> " & Translate("Hard drives") & " -------------|"
		Dim $description[100]
		If UBound($drive_list) >= 1 Then
			For $i = 1 To $drive_list[0]
				$label = DriveGetLabel($drive_list[$i])
				$fs = DriveGetFileSystem($drive_list[$i])
				$space = DriveSpaceTotal($drive_list[$i])
				If Not (($fs = "") Or ($space = 0) Or ($drive_list[$i] = $system_letter)) Then
					$all_drives &= StringUpper($drive_list[$i]) & " " & $label & " - " & $fs & " - " & Round($space / 1024, 1) & " " & Translate("GB") & "|"
				EndIf
			Next
		EndIf
	EndIf
	SendReport("Start-Refresh_DriveList-2")
	If $all_drives <> "|-> " & Translate("Choose a USB Key") & "|" Then
		GUICtrlSetData($combo, $all_drives, "-> " & Translate("Choose a USB Key"))
		GUICtrlSetState($combo, $GUI_ENABLE)
	Else
		GUICtrlSetData($combo, "|-> " & Translate("No key found"), "-> " & Translate("No key found"))
		GUICtrlSetState($combo, $GUI_DISABLE)
	EndIf
	SendReport("End-Refresh_DriveList")
EndFunc   ;==>Refresh_DriveList

Func SpaceAfterLinuxLiveMB($disk)
	SendReport("Start-SpaceAfterLinuxLiveMB (Disk: " & $disk & " )")
	Local $install_size

	If ReleaseGetCodename($release_number) = "default" Then
		$install_size = Round(FileGetSize($file_set) / 1048576) + 20
	Else
		$install_size = ReleaseGetInstallSize($release_number)
	EndIf

	If GUICtrlRead($virtualbox) == $GUI_CHECKED Then
		; Need 140MB for VirtualBox
		$install_size = $install_size + 140
	EndIf

	If GUICtrlRead($formater) == $GUI_CHECKED Then
		$spacefree = DriveSpaceTotal($disk) - $install_size
		If $spacefree >= 0 And $spacefree <= 3950 Then
			Return Round($spacefree / 100, 0) * 100
		ElseIf $spacefree >= 0 And $spacefree > 3950 Then
			SendReport("End-SpaceAfterLinuxLiveGB (Free : 3950MB )")
			Return 3950
		Else
			SendReport("End-SpaceAfterLinuxLiveGB (Free : 0MB )")
			Return 0
		EndIf
	Else
		$spacefree = DriveSpaceFree($disk) - $install_size
		If $spacefree >= 0 And $spacefree <= 3950 Then
			Return Round($spacefree / 100, 0) * 100
		ElseIf $spacefree >= 0 And $spacefree > 3950 Then
			SendReport("End-SpaceAfterLinuxLiveGB (Free : 3950MB )")
			Return 3950
		Else
			SendReport("End-SpaceAfterLinuxLiveMB (Free : 0MB )")
			Return 0
		EndIf
	EndIf
EndFunc   ;==>SpaceAfterLinuxLiveMB

Func SpaceAfterLinuxLiveGB($disk)
	SendReport("Start-SpaceAfterLinuxLiveGB (Disk: " & $disk & " )")

	If ReleaseGetCodename($release_number) = "default" Then
		$install_size = Round(FileGetSize($file_set) / 1048576) + 20
	Else
		$install_size = ReleasegetInstallSize($release_number)
	EndIf

	If GUICtrlRead($virtualbox) == $GUI_CHECKED Then
		; Need 140MB for VirtualBox
		$install_size = $install_size + 140
	EndIf

	If GUICtrlRead($formater) == $GUI_CHECKED Then
		$spacefree = DriveSpaceTotal($disk) - ReleasegetInstallSize($release_number)
		If $spacefree >= 0 Then
			SendReport("End-SpaceAfterLinuxLiveGB (Free : " & Round($spacefree / 1024, 1) & "GB )")
			Return Round($spacefree / 1024, 1)
		Else
			SendReport("End-SpaceAfterLinuxLiveGB (Free : 0GB )")
			Return 0
		EndIf
	Else
		$spacefree = DriveSpaceFree($disk) - ReleasegetInstallSize($release_number)
		If $spacefree >= 0 Then
			SendReport("End-SpaceAfterLinuxLiveGB (Free : " & Round($spacefree / 1024, 1) & "GB )")
			Return Round($spacefree / 1024, 1)
		Else
			SendReport("End-SpaceAfterLinuxLiveGB (Free : 0GB )")
			Return 0
		EndIf
	EndIf

EndFunc   ;==>SpaceAfterLinuxLiveGB

; returns the physical disk (\\.\PhysicalDiskX) corresponding to a drive letter
Func GiveMePhysicalDisk($drive_letter)
	Local $physical_drive,$g_eventerror

	UpdateLog("GiveMePhysicalDisk of : "&$drive_letter)

	Local $wbemFlagReturnImmediately, $wbemFlagForwardOnly, $objWMIService, $colItems, $objItem, $found_usb, $usb_model, $usb_size
	$wbemFlagReturnImmediately = 0x10
	$wbemFlagForwardOnly = 0x20
	$colItems = ""

	$objWMIService = ObjGet("winmgmts:\\.\root\CIMV2")
	if @error OR $g_eventerror OR NOT IsObj($objWMIService) Then
		UpdateLog("ERROR with WMI : Trying alternate method (WMI impersonation)")
		$g_eventerror =0
		$objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!//.")
	EndIf

	if @error OR $g_eventerror then
		UpdateLog("ERROR with WMI")
	Elseif IsObj($objWMIService) Then
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
	endif

	if $physical_drive Then
		UpdateLog("PhysicalDisk is : "& $physical_drive)
		Return StringReplace($physical_drive,"\\.\PHYSICALDRIVE","")
	Else
		Return "ERROR"
	EndIf
EndFunc   ;==>GiveMePhysicalDisk
