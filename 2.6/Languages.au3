; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Locales management                            ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#cs
	Select

	Case StringInStr("0413,0813", @OSLang)

	Return "Dutch"

	Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009," _

	& "2409,2809,2c09,3009,3409", @OSLang)

	Return "English"

	Case StringInStr("040c,080c,0c0c,100c,140c,180c", @OSLang)

	Return "French"

	Case StringInStr("0407,0807,0c07,1007,1407", @OSLang)

	Return "German"

	Case StringInStr("0410,0810", @OSLang)

	Return "Italian"

	Case StringInStr("0414,0814", @OSLang)

	Return "Norwegian"

	Case StringInStr("0415", @OSLang)

	Return "Polish"

	Case StringInStr("0416,0816", @OSLang)

	Return "Portuguese"

	Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a," _

	& "240a,280a,2c0a,300a,340a,380a,3c0a,400a," _
	& "440a,480a,4c0a,500a", @OSLang)

	Return "Spanish"

	Case StringInStr("041d,081d", @OSLang)

	Return "Swedish"

	Case Else

	Return "Other (can't determine with @OSLang directly)"

	EndSelect
#ce

Func _Language()
	SendReport("Start-_Language")
	$force_lang = IniRead($settings_ini, "General", "force_lang", "no")
	If $force_lang <> "no" And (FileExists($lang_ini & $force_lang & ".ini") Or $force_lang = "English") Then
		$lang_ini = $lang_ini & $force_lang & ".ini"
		SendReport("End-_Language (Force Lang=" & $force_lang & ")")
		Return $force_lang
	EndIf
	Select
		Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009,2409,2809,2c09,3009,3409", @OSLang)
			$lang_found = "English"
		Case StringInStr("040c,080c,0c0c,100c,140c,180c", @OSLang)
			$lang_found = "French"
		Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a,240a,280a,2c0a,300a,340a,380a,3c0a,400a,440a,480a,4c0a,500a", @OSLang)
			$lang_found = "Spanish"
		Case StringInStr("0407,0807,0c07,1007,1407", @OSLang)
			$lang_found = "German"
		Case StringInStr("0416,0816", @OSLang)
			$lang_found = "Portuguese"
		Case StringInStr("0410,0810", @OSLang)
			$lang_found = "Italian"
		Case StringInStr("0414,0814", @OSLang)
			$lang_found = "Norwegian"
		Case StringInStr("0411", @OSLang)
			$lang_found = "Japanese"
		Case StringInStr("041d,081d", @OSLang)
			$lang_found = "Swedish"
		Case Else
			$lang_found = "English"
	EndSelect
	$lang_ini = $lang_ini & $lang_found & ".ini"
	SendReport("End-_Language " & $lang_found)
	Return $lang_found
EndFunc   ;==>_Language

Func Translate($txt)
	Return IniRead($lang_ini, $lang, $txt, $txt)
EndFunc   ;==>Translate
