; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Logs and status                               ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func InitLog()
	DirCreate($log_dir)
	$logfile = @ScriptDir & "\logs\" & @MDAY & "-" & @MON & "-" & @YEAR & " (" & @HOUR & "h" & @MIN & "s" & @SEC & ").log"
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
	$line &= @CRLF & "OS Type : " & @OSType
	$line &= @CRLF & "OS Version : " & $os_version
	$line &= @CRLF & "OS Build : " & @OSBuild
	$line &= @CRLF & "OS Service Pack : " & @OSServicePack
	$line &= @CRLF & "Architecture : " & @OSArch
	$line &= @CRLF & "Memory : " & Round($mem[1] / 1024) & "MB  ( with " & (100 - $mem[0]) & "% free = " & Round($mem[2] / 1024) & "MB )"
	$line &= @CRLF & "Language : " & @OSLang
	$line &= @CRLF & "Keyboard : " & @KBLayout
	$line &= @CRLF & "Resolution : " & @DesktopWidth & "x" & @DesktopHeight
	$line &= @CRLF & "Chosen Key : " & $selected_drive
	$line &= @CRLF & "Filesystem : " & DriveGetFileSystem($selected_drive)
	If $selected_drive Then $space = Round(DriveSpaceFree($selected_drive))
	$line &= @CRLF & "Free space on key : " & $space & "MB"
	If $file_set_mode == "iso" Then
		$line &= @CRLF & "Selected ISO : " & path_to_name($file_set)
		$line &= @CRLF & "ISO Hash : " & $MD5_ISO
	Else
		$line &= @CRLF & "Selected source : " & $file_set
	EndIf
	$line &= @CRLF & "Step Status : (STEP1=" & $STEP1_OK & ") (STEP2=" & $STEP2_OK & ") (STEP3=" & $STEP3_OK & ") "
	$line &= @CRLF & "------------------------------  End of system config  ------------------------------" & @CRLF
	SendReport("End-LogSystemConfig")
	Return $line
EndFunc   ;==>LogSystemConfig

Func UpdateStatus($status)
	SendReport(IniRead($lang_ini, "English", $status, $status))
	_FileWriteLog($logfile, "Status : " & Translate($status))
	GUICtrlSetData($label_step5_status, Translate($status))
EndFunc   ;==>UpdateStatus

Func UpdateStatusStep2($status)
	SendReport(IniRead($lang_ini, "English", $status, $status))
	_FileWriteLog($logfile, "Status : " & Translate($status))
	GUICtrlSetData($label_step2_status, Translate($status))
EndFunc   ;==>UpdateStatusStep2

Func UpdateLog($status)
	_FileWriteLog($logfile, $status) ; No translation in logs
EndFunc   ;==>UpdateLog

Func UpdateStatusNoLog($status)
	GUICtrlSetData($label_step5_status, Translate($status))
EndFunc   ;==>UpdateStatusNoLog

Func SendReport($report)
	If IniRead($settings_ini, "General", "verbose_logging", "no") = "yes" Then UpdateLog($report)
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
