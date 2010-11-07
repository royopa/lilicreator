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
	If ReadSetting("Updates", "check_for_updates") <> "yes" Then Return 0
	$ping = Ping("www.google.com")
	If $ping Then
		; check for stable version update
		$check_result = BinaryToString(INetRead($check_updates_url & "?version"))

		; if Beta version check for beta version update too
		if (ReadSetting( "Updates", "check_for_beta_versions") = "yes") Then $check_result_beta = BinaryToString(INetRead($check_updates_url & "?beta-version"))

		if (ReadSetting( "Updates", "check_for_beta_versions") = "yes") AND VersionCompare($check_result_beta, $software_version) = 1  And Not $check_result_beta = 0 And Not $check_result_beta ="" Then
			UpdateLog("New beta version available")
			$return = MsgBox(68, Translate("There is a new Beta version available"), Translate("Your LiLi's version is not up to date.") & @CRLF & @CRLF & Translate("Last beta version is") & " : " & $check_result_beta & @CRLF & Translate("Your version is") & " : " & $software_version & @CRLF & @CRLF & Translate("Do want to download it ?"))
			If $return = 6 Then ShellExecute("http://www.linuxliveusb.com/")
		ElseIf Not $check_result = 0 And Not $check_result ="" And VersionCompare($check_result, $software_version) = 1 Then
			UpdateLog("New stable version available")
			$return = MsgBox(68, Translate("There is a new version available"), Translate("Your LiLi's version is not up to date.") & @CRLF & @CRLF & Translate("Last version is") & " : " & $check_result & @CRLF & Translate("Your version is") & " : " & $software_version & @CRLF & @CRLF & Translate("Do want to download it ?"))
			If $return = 6 Then ShellExecute("http://www.linuxliveusb.com/")
		Else
			UpdateLog("Current software version is up to date")
		EndIf
	Else
		UpdateLog("WARNING : Could not check for updates (no connection ?)")
	EndIf
EndFunc   ;==>Check_for_updates

; Check for compatibility list updates (called in Automatic_Bug_Report.au3 in second process)
Func Check_for_compatibility_list_updates()
		; Current version
		$current_compatibility_list_version=IniRead($compatibility_ini, "Compatibility_List", "Version","none")

		; Check the available version
		$available_version = BinaryToString(INetRead($check_updates_url & "?last_compatibility_list_of="&$software_version))

		; Compare with the current version
		if VersionCodeForCompatList($current_compatibility_list_version) < VersionCodeForCompatList($available_version) Then
			UpdateLog("New compatibility version found : "&$available_version)
			; There is a new version => Downloading it to new_compatibility_list.ini
			InetGet($check_updates_url&"compatibility_lists/"&$available_version, @ScriptDir &"\tools\settings\new_compatibility_list.ini")

			; if the file downloaded is the same size it means the download should be good => replace the old version by the new one
			if InetGetSize($check_updates_url&"compatibility_lists/"&$available_version) = FileGetSize(@ScriptDir &"\tools\settings\new_compatibility_list.ini") AND FileGetSize(@ScriptDir &"\tools\settings\new_compatibility_list.ini") > 0 Then
				FileMove($compatibility_ini,@ScriptDir &"\tools\settings\old_compatibility_list.ini",1)
				FileMove(@ScriptDir &"\tools\settings\new_compatibility_list.ini",$compatibility_ini,1)
				; Send a message to the main process to force reloading the file
				SendReportToMain("compatibility_updated")
				$new_linux = BinaryToString(INetRead($check_updates_url & "?new-linux-since="&$current_compatibility_list_version))
				MsgBox(64, "LinuxLive USB Creator", Translate("The compatibility list has been updated")&"."&@CRLF&@CRLF&Translate("These linuxes are now supported")&" :"&@CRLF&@CRLF&$new_linux);
			Else
				UpdateLog("WARNING : Could not download new compatibility list version")
			EndIf
		Else
			UpdateLog("Current compatibility list version is up to date")
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
	Return Int($version_number)
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
	Return Int($parse_version[Ubound($parse_version)-1])
EndFunc   ;==>VersionCode


; Return a generic version code for some Linuxes (Ubuntu mostly)
Func GenericVersionCode($version)
	Return Int(StringReplace($version,".",""))
EndFunc

Func CompareHuman($version1,$version2)
	$result = CompareVersion($version1,$version2)
	if $result=0 Then
		return $version1&" is equal to "&$version2
	Elseif $result = 1 Then
		return $version1&" is greater than "&$version2
	Elseif $result = 2 Then
		return $version2&" is greater than "&$version1
	EndIf
EndFunc

#cs
	Can compare any version using X.X.X.X format (with X = 1-10 / A-F)
	Return :
		0 if equal
		1 if var > var2 (var is newer)
		2 if var < var 2 (var2 is newer)
#ce
Func CompareVersion($var, $var2)
    $aVar1 = StringSplit($var,".")
    $aVar2 = StringSplit($var2,".")
    If $aVar1[0] > $aVar2[0] Then
        $length = $aVar2[0]
    Else
        $length =$aVar1[0]
    EndIf
    For $i = 1 to $length
        $ret = 0
		if StringIsAlpha($aVar1[$i]) AND StringIsXDigit($aVar1[$i]) Then
			$number1 = Dec($aVar1[$i])
		Else
			$number1 = number($aVar1[$i])
		EndIf

		if StringIsAlpha($aVar2[$i]) AND StringIsXDigit($aVar2[$i]) Then
			$number2 = Dec($aVar2[$i])
		Else
			$number2 = number($aVar2[$i])
		EndIf

        If $number1 >  $number2 Then
            $ret = 1
            ExitLoop
        ElseIf $number1 = $number2 Then
            If $aVar1[0] > $aVar2[0] Then
                $ret = 1
            ElseIf $aVar1[0] < $aVar2[0] Then
                $ret = 2;
            EndIf
        Else
            $ret = 2
            ExitLoop
        EndIf
    Next
    Return $ret
EndFunc
