#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.0.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Updates management                            ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Check for LiLi's updates
Func Check_for_updates()
	$ping = Ping("www.google.com")
	If $ping Then
		;SendReport("IN-Check_for_updates : start checking")
		$check_result = _INetGetSource($check_updates_url & "?version")
		if isBeta() Then $check_result_beta = _INetGetSource($check_updates_url & "?beta-version")
		;SendReport("IN-Check_for_updates ( Last version found : " & $check_result & " )")
		if isBeta() AND VersionCompare($check_result_beta, $software_version) = 1 Then
			$return = MsgBox(68, Translate("There is a new Beta version available"), Translate("Your LiLi's version is not up to date.") & @CRLF & @CRLF & Translate("Last beta version is") & " : " & $check_result_beta & @CRLF & Translate("Your version is") & " : " & $software_version & @CRLF & @CRLF & Translate("Do want to download it ?"))
			If $return = 6 Then ShellExecute("http://www.linuxliveusb.com/")
		ElseIf Not $check_result = 0 And VersionCompare($check_result, $software_version) = 1 Then
			$return = MsgBox(68, Translate("There is a new version available"), Translate("Your LiLi's version is not up to date.") & @CRLF & @CRLF & Translate("Last version is") & " : " & $check_result & @CRLF & Translate("Your version is") & " : " & $software_version & @CRLF & @CRLF & Translate("Do want to download it ?"))
			If $return = 6 Then ShellExecute("http://www.linuxliveusb.com/")
		EndIf
	else
		;SendReport("no checking : "&$ping)
	EndIf
EndFunc   ;==>Check_for_updates

; Check for compatibility list updates
Func Check_for_compatibility_list_updates()
		; Current version
		$current_compatibility_list_version=IniRead($compatibility_ini, "Compatibility_List", "Version","none")

		; Check the available version
		$available_version = _InetGetSource($check_updates_url & "?last_compatibility_list_of="&$software_version)

		; Compare with the current version
		if VersionCodeForCompatList($current_compatibility_list_version) < VersionCodeForCompatList($available_version) Then
			; There is a new version => Downloading it to new_compatibility_list.ini
			InetGet($check_updates_url&"compatibility_lists/"&$available_version, @ScriptDir &"\tools\settings\new_compatibility_list.ini")

			; if the file downloaded is the same size it means the download should be good => replace the old version by the new one
			if InetGetSize($check_updates_url&"compatibility_lists/"&$available_version) = FileGetSize(@ScriptDir &"\tools\settings\new_compatibility_list.ini") AND FileGetSize(@ScriptDir &"\tools\settings\new_compatibility_list.ini") > 0 Then
				FileMove($compatibility_ini,@ScriptDir &"\tools\settings\old_compatibility_list.ini",1)
				FileMove(@ScriptDir &"\tools\settings\new_compatibility_list.ini",$compatibility_ini,1)

				; Send a message to the main process to force reloading the file
				SendReportToMain("compatibility_updated")
			EndIf
		EndIf
EndFunc


; Compare 2 versions
;	0 =  Versions are equals
;	1 =  Version 1 is higher
;   2 =  Version 2 is higher
Func VersionCompare($version1, $version2)
	If VersionCode($version1) = VersionCode($version2) Then
		Return 0
	ElseIf VersionCode($version1) > VersionCode($version2) Then
		Return 1
	Else
		Return 2
	EndIf
EndFunc   ;==>VersionCompare

; Transform a label to a number
Func SortVersionLabel($version_label)
	Switch StringLower($version_label)
		Case "alpha"
			Return 0
		Case "beta"
			Return 1
		Case "beta1"
			Return 2
		Case "beta2"
			Return 3
		Case "beta3"
			Return 4
		Case "rc1"
			Return 5
		Case "rc2"
			Return 6
		Case "rc3"
			Return 7
		Case Else
			Return 8
	EndSwitch
EndFunc   ;==>SortVersionLabel

; Transform a version name to a version code to be compared up to 3 digits like "2.3.1 Beta"
Func VersionCode($version)
	$parse_version = StringSplit($version, " ")
	$version_number = StringReplace($parse_version[1], ".", "")
	If StringLen($version_number) = 2 Then $version_number &= "0"
	If $parse_version[0] >= 2 Then
		$version_number &= SortVersionLabel($parse_version[2])
	Else
		$version_number &= "8"
	EndIf
	Return $version_number
EndFunc   ;==>VersionCode

Func isBeta()
	If StringInStr($software_version, "RC") Or StringInStr($software_version, "Beta") Or StringInStr($software_version, "Alpha") Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>isBeta

; Return the last number of compatibility list version
Func VersionCodeForCompatList($version)
	$parse_version = StringSplit($version, ".")
	Return $parse_version[Ubound($parse_version)-1]
EndFunc   ;==>VersionCode
