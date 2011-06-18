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


Func GetLastUpdateIni()
	If ReadSetting("Updates", "check_for_updates") <> "yes" Then Return 0

	FileDelete($updates_ini)
	; Downloading the info for updates
	$server_response = INetGet($check_updates_url & "?current="&$current_compatibility_list_version,$updates_ini,3)

	If Not @error Then
		$last_stable=IniRead($updates_ini,"Software","last_stable","")
		$last_stable_update=IniRead($updates_ini,"Software","last_stable_update","")
		$last_beta=IniRead($updates_ini,"Software","last_beta","")
		$last_beta_update=IniRead($updates_ini,"Software","last_beta_update","")
		$what_is_new=StringReplace(IniRead($updates_ini,"Software","what_is_new",""),"/#/",@CRLF&"-> ")

		$virtualbox_pack=IniRead($updates_ini,"VirtualBox","version","")
		$virtualbox_in_pack=IniRead($updates_ini,"VirtualBox","vbox_version","")

		if $last_stable="" Then
			UpdateLog("Checking for update, update.ini downloaded but format is incorrect !")
			Return 0
		Else
			UpdateLog("Checking for update, LiLi's server answer = Last stable : "&$last_stable&" ("&$last_stable_update&") / Last Beta : "&$last_beta&" ("&$last_beta_update&") / Last Virtualbox : "&$virtualbox_pack&" ("&$virtualbox_in_pack&")")
			Return 1
		EndIf
	Else
		UpdateLog("WARNING : Could not check for updates (no connection ?)")
		Return 0
	EndIf
EndFunc



; Check for LiLi's updates
Func CheckForMajorUpdate()
		if $last_stable="" OR $last_beta="" Then Return 0

	; Checking for major software update
	if (ReadSetting( "Updates", "check_for_beta_versions") = "yes") AND VersionCompare($last_beta, $software_version) = 1  And Not $last_beta ="" Then
		UpdateLog("New beta version available")
		$return = MsgBox(68, Translate("There is a new Beta version available"), Translate("Your LiLi's version is not up to date")&"." & @CRLF & @CRLF & Translate("Last beta version is") & " : " & $last_beta & @CRLF & Translate("Your version is") & " : " & $software_version & @CRLF & @CRLF & Translate("Do want to download it")&" ?")
		If $return = 6 Then
			ShellExecute("http://www.linuxliveusb.com/more-downloads")
			GUI_Exit()
		EndIf
		Return 1
	ElseIf Not $last_stable = 0 And Not $last_stable ="" And VersionCompare($last_stable, $software_version) = 1 Then
		UpdateLog("New stable version available")
		$return = MsgBox(68, Translate("There is a new version available"), Translate("Your LiLi's version is not up to date") &"."& @CRLF & @CRLF & Translate("Last version is") & " : " & $last_stable & @CRLF & Translate("Your version is") & " : " & $software_version & @CRLF & @CRLF & Translate("Do want to download it")&" ?")
		If $return = 6 Then
			ShellExecute("http://www.linuxliveusb.com/")
			GUI_Exit()
		EndIf
		Return 1
	Else
		UpdateLog("Current software version is up to date")
		Return 0
	EndIf
EndFunc   ;==>Check_for_updates

; Check for compatibility list updates (called in Automatic_Bug_Report.au3 in second process)
Func CheckForMinorUpdate()

		if isBeta() Then Return 0

		; Compare with the current version
		if VersionCodeForCompatList($current_compatibility_list_version) < VersionCodeForCompatList($last_stable_update) AND MajorVersionCode($current_compatibility_list_version)=MajorVersionCode($last_stable_update) Then
			UpdateLog("Compatibility list can be updated")
			; There is a new version => Downloading it to new_compatibility_list.ini
			InetGet($check_updates_url&"compatibility_lists/"&$last_stable_update, @ScriptDir &"\tools\settings\new_compatibility_list.ini",3)

			; if the file downloaded is the same size it means the download should be good => replace the old version by the new one
			if InetGetSize($check_updates_url&"compatibility_lists/"&$last_stable_update,3) = FileGetSize(@ScriptDir &"\tools\settings\new_compatibility_list.ini") AND FileGetSize(@ScriptDir &"\tools\settings\new_compatibility_list.ini") > 0 Then
				FileMove($compatibility_ini,@ScriptDir &"\tools\settings\old_compatibility_list.ini",1)
				FileMove(@ScriptDir &"\tools\settings\new_compatibility_list.ini",$compatibility_ini,1)
				; Send a message to the main process to force reloading the file
				;SendReportToMain("compatibility_updated")
				MsgBox(64, "LinuxLive USB Creator", Translate("The compatibility list has been updated")&"."&@CRLF&@CRLF&Translate("These linuxes are now supported")&" :"&@CRLF&@CRLF&$what_is_new)
				return 1
			Else
				UpdateLog("WARNING : Could not download new compatibility list version")
				return 0
			EndIf
		Else
			UpdateLog("Current compatibility list version is up to date")
			Return 0
		EndIf
	EndFunc

Func CheckForVirtualBoxUpdate()
	; Setting VirtualBox size
	$current_vbox_version=IniRead(@ScriptDir&"\tools\VirtualBox\Portable-VirtualBox\linuxlive\settings.ini","General","pack_version","ERROR")
	$lastupdate_vbox_version=IniRead($updates_ini,"VirtualBox","version","0.0.0.0")
	if $current_vbox_version==$lastupdate_vbox_version Then
		; Downloaded version is equal to the one described in VirtualBox.ini => using real size set in VirtualBox.ini
		$virtualbox_realsize=IniRead($updates_ini,"VirtualBox","realsize",$virtualbox_default_realsize)
		SendReport("VirtualBox folder exists, version is "&$current_vbox_version&" and is the latest. Its size is "&$virtualbox_realsize&"MB")
	Elseif FileExists(@ScriptDir&"\tools\VirtualBox\") Then
		; No match, computing size directly
		$virtualbox_realsize =Round(DirGetSize(@ScriptDir&"\tools\VirtualBox\")/(1024*1024))
		SendReport("VirtualBox folder exists but does not match version of last update ( "&$current_vbox_version&"!="&$lastupdate_vbox_version&" ). Its size is "&$virtualbox_realsize&"MB")
	Else
		; No match and no downloaded version, default size is set to default size
		$virtualbox_realsize=$virtualbox_default_realsize
		SendReport("No VirtualBox folder. Default size is "&$virtualbox_realsize&"MB")
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

Func GetFullVersion()
	Global $current_compatibility_list_version
	if isBeta() Then
		return $software_version
	Else
		$current_compatibility_list_version = IniRead($compatibility_ini, "Compatibility_List", "Version", $software_version & ".0")
		$compat_version = VersionCodeForCompatList($current_compatibility_list_version)
		if $compat_version > 0 Then
			return $software_version&" Update "&$compat_version
		Else
			return $software_version
		EndIf
	EndIf
EndFunc

; Return the last number of compatibility list version (ie 2.6.10 will return 10)
Func VersionCodeForCompatList($version)
	$parse_version = StringSplit($version, ".")
	Return Int($parse_version[Ubound($parse_version)-1])
EndFunc   ;==>VersionCode

; Return Major version code for compatibility list version (ie 2.6.10 will return 26)
Func MajorVersionCode($version)
	Return Int(StringReplace(StringLeft($version,3),".",""))
EndFunc



; Return a generic version code for some Linuxes (Ubuntu mostly)
Func GenericVersionCode($version)
	Return Int(StringReplace($version,".",""))
EndFunc

; Return a generic version code without minor (10.10.2 will return 10.10) for some Linuxes (Ubuntu mostly)
Func GenericVersionCodeWithoutMinor($version)
	$splitted = StringSplit($version,".",2)
	if Ubound($splitted) >= 2 Then
		$major = $splitted[0]&$splitted[1]
		Return Int($major)
	Else
		Return Int(StringReplace($version,".",""))
	EndIf
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
