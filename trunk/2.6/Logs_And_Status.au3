; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Logs and status                               ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func InitLog()
	DirCreate($log_dir)
	$logfile = @ScriptDir & "\logs\" & @MDAY & "-" & @MON & "-" & @YEAR&".log"
	UpdateLog(LogSystemConfig())
	SendReport("logfile-" & $logfile)
EndFunc   ;==>InitLog

Func LogSystemConfig()
	SendReport("Start-LogSystemConfig")
	Local $space = -1

	; Little fix for AutoIT 3.3.0.0
	$os_version_long= RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "ProductName")
	if Not @error AND ( StringInStr($os_version_long,"Seven") OR StringInStr($os_version_long,"Windows 7")) Then
		$os_version=$os_version_long
	Else
		$os_version=@OSVersion
	EndIf

	$mem = MemGetStats()
	$line = @CRLF & "--------------------------------  System Config  --------------------------------"
	$line &= @CRLF & "LiLi USB Creator : " & $software_version
	$line &= @CRLF & "Compatibility List Version : " & $current_compatibility_list_version
	$line &= @CRLF & "Unique ID : " & ReadSetting("General","unique_id")
	$line &= @CRLF & "OS Type : " & @OSType
	$line &= @CRLF & "OS Version : " & $os_version
	$line &= @CRLF & "OS Build : " & @OSBuild
	$line &= @CRLF & "OS Service Pack : " & @OSServicePack
	$line &= @CRLF & "Architecture : " & @OSArch
	$line &= @CRLF & "Memory : " & Round($mem[1] / 1024) & "MB  ( with " & (100 - $mem[0]) & "% free = " & Round($mem[2] / 1024) & "MB )"
	$line &= @CRLF & "Language : " & HumanOSLang(@OSLang) & " ("& @OSLang&")"
	$line &= @CRLF & "Keyboard : " & @KBLayout
	$line &= @CRLF & "Resolution : " & @DesktopWidth & "x" & @DesktopHeight
	$line &= @CRLF & "Proxy settings : " & ProxySettingsReport()
	$line &= @CRLF & "Chosen Key : " & $selected_drive
	$line &= @CRLF & "Filesystem : " & DriveGetFileSystem($selected_drive)
	If $selected_drive Then $space = Round(DriveSpaceFree($selected_drive))
	$line &= @CRLF & "Free space on key : " & $space & "MB"
	$line &= @CRLF & "Previous install : "&PreviousInstallReport()
	If $file_set_mode == "iso" Then
		$line &= @CRLF & "Selected ISO : " &path_to_name($file_set)
		$line &= @CRLF & "Recognized as : "&ReleaseGetDescription($release_number)&"("&ReleaseGetCodename($release_number)&")"
		$line &= @CRLF & "ISO Hash : " & $MD5_ISO
	Else
		$line &= @CRLF & "Selected source : " & $file_set
		$line &= @CRLF & "Selected file : " &path_to_name($file_set)
	EndIf
	$line &= @CRLF & "Step Status : (STEP1=" & HumanStepCheck($STEP1_OK) & ") (STEP2=" & HumanStepCheck($STEP2_OK) & ") (STEP3=" & HumanStepCheck($STEP3_OK) & ") "
	$line &= @CRLF & "------------------------------  End of system config  ------------------------------" & @CRLF
	SendReport("End-LogSystemConfig")
	Return $line
EndFunc   ;==>LogSystemConfig

Func PreviousInstallReport()
	if FileExists($selected_drive&"\"&$autoclean_settings) Then
		$installed_linux=IniRead($selected_drive&"\"&$autoclean_settings,"General","Installed_Linux","NotFound")
		$linux_codename=IniRead($selected_drive&"\"&$autoclean_settings,"General","Installed_Linux_Codename","NotFound")
		$install_size=GetPreviousInstallSizeMB($selected_drive)
		Return $installed_linux&" ("&$linux_codename&") using "&$install_size&"MB"
	Else
		Return "No previous install found on key"
	EndIf
EndFunc



Func ProxySettingsReport()
	; Apply proxy settings
	$proxy_mode = ReadSetting( "Proxy", "proxy_mode")
	$proxy_url = ReadSetting( "Proxy", "proxy_url")
	$proxy_port = ReadSetting( "Proxy", "proxy_port")

	if $proxy_mode =2 Then
		If $proxy_url <> "" AND  $proxy_port <> "" Then
			$proxy_url &= ":" & $proxy_port
		EndIf
		Return "Use custom settings ( "&$proxy_url&" )"
	Elseif $proxy_mode =1 Then
		Return "No proxy (direct access)"
	Else
		Return "Use system settings"
	EndIf
EndFunc

Func UpdateStatus($status)
	Global $label_step5_status
	SendReport(IniRead($lang_ini, "English", $status, $status))
	GUICtrlSetData($label_step5_status, "")
	GUICtrlSetData($label_step5_status, Translate($status))
	_FileWriteLog($logfile, "Status : " & Translate($status))
EndFunc   ;==>UpdateStatus

Func UpdateStatusStep2($status)
	Global $label_step2_status
	SendReport(IniRead($lang_ini, "English", $status, $status))
	GUICtrlSetData($label_step2_status, "")
	GUICtrlSetData($label_step2_status, Translate($status))
	_FileWriteLog($logfile, "Status : " & Translate($status))
EndFunc   ;==>UpdateStatusStep2

Func UpdateLog($status)
	_FileWriteLog($logfile, $status) ; No translation in logs
EndFunc   ;==>UpdateLog

Func UpdateStatusNoLog($status)
	Global $label_step5_status
	GUICtrlSetData($label_step5_status, "")
	GUICtrlSetData($label_step5_status, Translate($status))
EndFunc   ;==>UpdateStatusNoLog

Func SendReport($report)
	If ReadSetting( "General", "verbose_logging") = "yes" Then UpdateLog($report)
	_SendData($report, "lili-Reporter")
EndFunc   ;==>SendReport

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Checking steps states                      ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Step1_Check($etat)
	Global $STEP1_OK
	If $etat = "good" Then
		$STEP1_OK = 1
		$DRAW_CHECK_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $GOOD, 0, 0, 25, 40, 338 + $offsetx0, 150 + $offsety0, 25, 40)
	Else
		$STEP1_OK = 0
		$DRAW_CHECK_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BAD, 0, 0, 25, 40, 338 + $offsetx0, 150 + $offsety0, 25, 40)
	EndIf
EndFunc   ;==>Step1_Check

Func Step2_Check($etat)
	Global $STEP2_OK
	If $etat = "good" Then
		$STEP2_OK = 1
		$DRAW_CHECK_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $GOOD, 0, 0, 25, 40, 338 + $offsetx0, 287 + $offsety0, 25, 40)
	ElseIf $etat = "bad" Then
		$STEP2_OK = 0
		$DRAW_CHECK_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BAD, 0, 0, 25, 40, 338 + $offsetx0, 287 + $offsety0, 25, 40)
	Else
		$STEP2_OK = 2
		$DRAW_CHECK_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $WARNING, 0, 0, 25, 40, 338 + $offsetx0, 287 + $offsety0, 25, 40)
	EndIf
EndFunc   ;==>Step2_Check

Func Step3_Check($etat)
	Global $STEP3_OK
	If $etat = "good" Then
		$STEP3_OK = 1
		$DRAW_CHECK_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $GOOD, 0, 0, 25, 40, 338 + $offsetx0, 398 + $offsety0, 25, 40)
	ElseIf $etat = "bad" Then
		$STEP3_OK = 0
		$DRAW_CHECK_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BAD, 0, 0, 25, 40, 338 + $offsetx0, 398 + $offsety0, 25, 40)
	Else
		$STEP3_OK = 2
		$DRAW_CHECK_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $WARNING, 0, 0, 25, 40, 338 + $offsetx0, 398 + $offsety0, 25, 40)
	EndIf
EndFunc   ;==>Step3_Check

Func HumanStepCheck($state_number)
	Switch $state_number
		Case 0
			Return "OK"
		Case 1
			Return "NOT OK"
		Case 2
			Return "WARNING"
	EndSwitch
EndFunc   ;==> HumanStepCheck

Func GUI_Show_Check_status($status)
	;$step2_display_menu=2

	;GUI_Hide_Step2_Default_Menu()
	;GUI_Hide_Step2_Download_Menu()
	$cleaner = GUICtrlCreateLabel("", 38 + $offsetx0, 238 + $offsety0, 300, 90)
	GUICtrlSetState($cleaner, $GUI_SHOW)
	GUICtrlSetState($cleaner,$GUI_HIDE)

	GUICtrlSetState($label_step2_status,$GUI_HIDE)

	$label_step2_status2 = GUICtrlCreateLabel("", 38 + $offsetx0, 235 + $offsety0, 300, 80)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetState($label_step2_status2,$GUI_SHOW)

	GUICtrlSetData($label_step2_status2,$status)

EndFunc

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