; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Statistics                                  ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func SendStats()
	Global $anonymous_id
	; Little fix for AutoIT 3.3.0.0
	$os_version_long= RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "ProductName")
	if Not @error AND ( StringInStr($os_version_long,"Seven") OR StringInStr($os_version_long,"Windows 7")) Then
		$os_version="WIN_SEVEN"
	Else
		$os_version=@OSVersion
	EndIf
	SendReport("stats-id=" & $anonymous_id & "&version=" & $software_version & "&os=" & $os_version & "-" & @OSArch & "-" & @OSServicePack & "&lang=" &_Language_for_stats() )
EndFunc   ;==>SendStats

Func _Language_for_stats()
	If @MUILang <> "0000" Then
		$use_source=@MUILang
	Else
		$use_source=@OSLang
	EndIf
	Return HumanOSLang($use_source)
EndFunc   ;==>_Language_for_stats
