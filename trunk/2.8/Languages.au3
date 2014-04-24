; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Locales management                            ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#cs
	Select

	Case StringInStr("0413,0813", @MUILang)

	Return "Dutch"

	Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009," _

	& "2409,2809,2c09,3009,3409", @MUILang)

	Return "English"

	Case StringInStr("040c,080c,0c0c,100c,140c,180c", @MUILang)

	Return "French"

	Case StringInStr("0407,0807,0c07,1007,1407", @MUILang)

	Return "German"

	Case StringInStr("0410,0810", @MUILang)

	Return "Italian"

	Case StringInStr("0414,0814", @MUILang)

	Return "Norwegian"

	Case StringInStr("0415", @MUILang)

	Return "Polish"

	Case StringInStr("0416,0816", @MUILang)

	Return "Portuguese"

	Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a," _

	& "240a,280a,2c0a,300a,340a,380a,3c0a,400a," _
	& "440a,480a,4c0a,500a", @MUILang)

	Return "Spanish"

	Case StringInStr("041d,081d", @MUILang)

	Return "Swedish"

	Case Else

	Return "Other (can't determine with @MUILang directly)"

	EndSelect
#ce

Func _Language()
	SendReport("Start-_Language")
	Local $use_source

	$force_lang = ReadSetting("General", "force_lang")
	If $force_lang <> "" And (FileExists($lang_folder & $force_lang & ".ini") Or $force_lang = "English") Then
		$lang_ini = $lang_folder & $force_lang & ".ini"
		$font_size=IniRead($lang_ini,$force_lang,"font_size",$font_size)
		SendReport("End-_Language (Force Lang=" & $force_lang & ")")
		Return $force_lang
	EndIf

	If @MUILang <> "0000" Then
		$use_source=@MUILang
	Else
		$use_source=@OSLang
	EndIf

	Select
		Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009,2409,2809,2c09,3009,3409", $use_source)
			$lang_found = "English"
		Case StringInStr("040c,080c,0c0c,100c,140c,180c", $use_source)
			$lang_found = "French"
		Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a,240a,280a,2c0a,300a,340a,380a,3c0a,400a,440a,480a,4c0a,500a", $use_source)
			$lang_found = "Spanish"
		Case StringInStr("0407,0807,0c07,1007,1407", $use_source)
			$lang_found = "German"
		Case StringInStr("0416", $use_source)
			$lang_found = "Portuguese (Brazilian)"
		Case StringInStr("0816", $use_source)
			$lang_found = "Portuguese (Standard)"
		Case StringInStr("0410,0810", $use_source)
			$lang_found = "Italian"
		Case StringInStr("0414,0814", $use_source)
			$lang_found = "Norwegian"
		Case StringInStr("0404,0804,0c04,1004,1404", $use_source)
			$lang_found = "Chinese"
		Case StringInStr("041a", $use_source)
			$lang_found = "Croatian"
		Case StringInStr("0418", $use_source)
			$lang_found = "Romanian"
		Case StringInStr("0406", $use_source)
			$lang_found = "Danish"
		Case StringInStr("0405", $use_source)
			$lang_found = "Czech"
		Case StringInStr("040e", $use_source)
			$lang_found = "Hungarian"
		Case StringInStr("043e", $use_source)
			$lang_found = "Malay"
		Case StringInStr("0411", $use_source)
			$lang_found = "Japanese"
		Case StringInStr("042b", $use_source)
			$lang_found = "Armenian"
		Case StringInStr("0412", $use_source)
			$lang_found = "Korean"
		Case StringInStr("041d,081d", $use_source)
			$lang_found = "Swedish"
		Case StringInStr("0419", $use_source)
			$lang_found = "Russian"
		Case StringInStr("0413,0813", $use_source)
			$lang_found = "Dutch"
		Case StringInStr("0402", $use_source)
			$lang_found = "Bulgarian"
		Case StringInStr("0421", $use_source)
			$lang_found = "Indonesian"
		Case StringInStr("0422", $use_source)
			$lang_found = "Ukrainian"
		Case StringInStr("041f", $use_source)
			$lang_found = "Turkish"
		Case StringInStr("0449", $use_source)
			$lang_found = "Tamil"
		Case StringInStr("0092,7c92,0492", $use_source)
			$lang_found = "Kurdish"
		Case Else
			$lang_found = "English"
	EndSelect
	$lang_ini = $lang_folder & $lang_found & ".ini"
	$font_size=IniRead($lang_ini,$lang_found,"font_size",$font_size)
	SendReport("End-_Language " & $lang_found)
	Return $lang_found
EndFunc   ;==>_Language

Func Translate($txt)
	Return IniRead($lang_ini, $lang, $txt, $txt)
EndFunc   ;==>Translate
