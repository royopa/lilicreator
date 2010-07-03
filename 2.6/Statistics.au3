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

	SendReport("stats-id=" & $anonymous_id & "&version=" & $software_version & "&os=" & $os_version & "-" & @OSArch & "-" & @OSServicePack & "&lang=" & _Language_for_stats())
EndFunc   ;==>SendStats

Func _Language_for_stats()
	Select
		Case StringInStr("0413,0813", @OSLang)
			Return "Dutch"

		Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009, 2409,2809,2c09,3009,3409", @OSLang)
			Return "English"

		Case StringInStr("0407,0807,0c07,1007,1407,0413,0813", @OSLang)
			Return "German"

		Case StringInStr("0410,0810", @OSLang)
			Return "Italian"

		Case StringInStr("0414,0814", @OSLang)
			Return "Norwegian"

		Case StringInStr("0415", @OSLang)
			Return "Polish"

		Case StringInStr("0416,0816", @OSLang)
			Return "Portuguese";

		Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a, 240a,280a,2c0a,300a,340a,380a,3c0a,400a, 440a,480a,4c0a,500a", @OSLang)
			Return "Spanish"

		Case StringInStr("0411", @OSLang)
			Return "Japanese"

		Case StringInStr("0412", @OSLang)
			Return "Korean"

		Case StringInStr("041d,081d", @OSLang)
			Return "Swedish"

		Case StringInStr("0419", @OSLang)
			Return "Russian"

		Case StringInStr("0404,0804,0c04,1004,1404", @OSLang)
			Return "Chinese"

		Case StringInStr("040c,080c,0c0c,100c,140c,180c", @OSLang)
			Return "French";remove and return function specifally to oslang
		Case Else
			Return @OSLang
	EndSelect
EndFunc   ;==>_Language_for_stats
