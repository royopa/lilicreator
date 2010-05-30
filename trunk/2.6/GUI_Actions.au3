; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Gui Buttons handling                        ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Disable_Persistent_Mode()
	GUICtrlSetState($slider, $GUI_HIDE)
	GUICtrlSetState($slider_visual, $GUI_HIDE)
	GUICtrlSetState($label_max, $GUI_HIDE)
	GUICtrlSetState($label_min, $GUI_HIDE)
	GUICtrlSetState($slider_visual_Mo, $GUI_HIDE)
	GUICtrlSetState($slider_visual_mode, $GUI_HIDE)
	GUICtrlSetData($live_mode_label,Translate("Live Mode"))
	GUICtrlSetState($live_mode_label,$GUI_SHOW)
	Step3_Check("good")
EndFunc   ;==>Disable_Persistent_Mode

Func Enable_Persistent_Mode()
	GUICtrlSetState($live_mode_label, $GUI_HIDE)
	GUICtrlSetState($slider, $GUI_SHOW)
	GUICtrlSetState($slider_visual, $GUI_SHOW)
	GUICtrlSetState($label_max, $GUI_SHOW)
	GUICtrlSetState($label_min, $GUI_SHOW)
	GUICtrlSetState($slider_visual_Mo, $GUI_SHOW)
	GUICtrlSetState($slider_visual_mode, $GUI_SHOW)
EndFunc   ;==>Enable_Persistent_Mode

Func BuiltIn_Persistent_Mode()
	GUICtrlSetState($slider, $GUI_HIDE)
	GUICtrlSetState($slider_visual, $GUI_HIDE)
	GUICtrlSetState($label_max, $GUI_HIDE)
	GUICtrlSetState($label_min, $GUI_HIDE)
	GUICtrlSetState($slider_visual_Mo, $GUI_HIDE)
	GUICtrlSetState($slider_visual_mode, $GUI_HIDE)
	GUICtrlSetData($live_mode_label,Translate("Built-in Persistency"))
	GUICtrlSetState($live_mode_label,$GUI_SHOW)
	Step3_Check("good")
EndFunc   ;==>DBuiltIn_Persistent_Mode

Func Disable_VirtualBox_Option()
	GUICtrlSetState($virtualbox, $GUI_UNCHECKED)
	GUICtrlSetState($virtualbox, $GUI_DISABLE)
EndFunc   ;==>Disable_VirtualBox_Option

Func Enable_VirtualBox_Option()
	GUICtrlSetState($virtualbox, $GUI_CHECKED)
	GUICtrlSetState($virtualbox, $GUI_ENABLE)
EndFunc   ;==>Enable_VirtualBox_Option

Func Disable_Hide_Option()
	GUICtrlSetState($hide_files, $GUI_UNCHECKED)
	GUICtrlSetState($hide_files, $GUI_DISABLE)
EndFunc   ;==>Disable_Hide_Option

Func Enable_Hide_Option()
	GUICtrlSetState($hide_files, $GUI_CHECKED)
	GUICtrlSetState($hide_files, $GUI_ENABLE)
EndFunc   ;==>Enable_Hide_Option

; Clickable parts of images
Func GUI_Exit()
	Global $current_download
	If WinActive("LinuxLive USB Creator") Or WinActive("LiLi USB Creator") Then
		SendReport("Start-GUI_Exit")
		InetClose($current_download)
		If $foo Then ProcessClose($foo)
		GUIDelete($CONTROL_GUI)
		GUIDelete($GUI)
		_ProgressDelete($progress_bar)
		_GDIPlus_GraphicsDispose($ZEROGraphic)
		_GDIPlus_ImageDispose($EXIT_NORM)
		_GDIPlus_ImageDispose($EXIT_OVER)
		_GDIPlus_ImageDispose($MIN_NORM)
		_GDIPlus_ImageDispose($MIN_OVER)
		_GDIPlus_ImageDispose($PNG_GUI)
		_GDIPlus_ImageDispose($CD_PNG)
		_GDIPlus_ImageDispose($CD_HOVER_PNG)
		_GDIPlus_ImageDispose($ISO_PNG)
		_GDIPlus_ImageDispose($ISO_HOVER_PNG)
		_GDIPlus_ImageDispose($DOWNLOAD_PNG)
		_GDIPlus_ImageDispose($DOWNLOAD_HOVER_PNG)
		_GDIPlus_ImageDispose($LAUNCH_PNG)
		_GDIPlus_ImageDispose($LAUNCH_HOVER_PNG)
		_GDIPlus_ImageDispose($HELP)
		_GDIPlus_ImageDispose($BAD)
		_GDIPlus_ImageDispose($GOOD)
		_GDIPlus_ImageDispose($WARNING)
		_GDIPlus_ImageDispose($BACK_PNG)
		_GDIPlus_ImageDispose($BACK_HOVER_PNG)
		_GDIPlus_Shutdown()
		SendReport("End-GUI_Exit")
		Exit
	EndIf
EndFunc   ;==>GUI_Exit


Func GUI_MoveUp()
	If WinActive("LinuxLive USB Creator") Or WinActive("LiLi USB Creator") Then
		$position = WinGetPos("LiLi USB Creator")
		WinMove("LiLi USB Creator", "", $position[0], $position[1] - 10)
		;Fix the focus issue
		ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
	Else
		HotKeySet("{UP}")
		Send("{UP}")
		HotKeySet("{UP}", "GUI_MoveUp")
	EndIf
EndFunc   ;==>GUI_MoveUp

Func GUI_MoveDown()
	If WinActive("LinuxLive USB Creator") Or WinActive("LiLi USB Creator") Then
		$position = WinGetPos("LiLi USB Creator")
		WinMove("LiLi USB Creator", "", $position[0], $position[1] + 10)
		ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
	Else
		HotKeySet("{DOWN}")
		Send("{DOWN}")
		HotKeySet("{DOWN}", "GUI_MoveDown")
	EndIf
EndFunc   ;==>GUI_MoveDown

Func GUI_MoveLeft()
	If WinActive("LinuxLive USB Creator") Or WinActive("LiLi USB Creator") Then
		$position = WinGetPos("LiLi USB Creator")
		WinMove("LiLi USB Creator", "", $position[0] - 10, $position[1])
		ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
	Else
		HotKeySet("{LEFT}")
		Send("{LEFT}")
		HotKeySet("{LEFT}", "GUI_MoveLeft")
	EndIf
EndFunc   ;==>GUI_MoveLeft

Func GUI_MoveRight()
	If WinActive("LinuxLive USB Creator") Or WinActive("LiLi USB Creator") Then
		$position = WinGetPos("LiLi USB Creator")
		WinMove("LiLi USB Creator", "", $position[0] + 10, $position[1])
		ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
	Else
		HotKeySet("{RIGHT}")
		Send("{RIGHT}")
		HotKeySet("{RIGHT}", "GUI_MoveRight")
	EndIf
EndFunc   ;==>GUI_MoveRight

Func GUI_Minimize()
	GUISetState(@SW_MINIMIZE, $GUI)
EndFunc   ;==>GUI_Minimize

Func GUI_Restore()
	GUISetState($GUI_SHOW, $GUI)
	GUISetState($GUI_SHOW, $CONTROL_GUI)
	GUIRegisterMsg($WM_PAINT, "DrawAll")
	ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
EndFunc   ;==>GUI_Restore

Func GUI_Choose_Drive()
	SendReport("Start-GUI_Choose_Drive")
	$selected_drive = StringLeft(GUICtrlRead($combo), 2)
	If (StringInStr(DriveGetFileSystem($selected_drive), "FAT") >= 1 And SpaceAfterLinuxLiveMB($selected_drive) > 0) Then
		; State is OK ( FAT32 or FAT format and 700MB+ free)
		Step1_Check("good")

		If GUICtrlRead($slider) > 0 Then
			GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("MB"))
			GUICtrlSetLimit($slider, Round(SpaceAfterLinuxLiveMB($selected_drive) / 10), 0)
			; State is OK ( FAT32 or FAT format and 700MB+ free) and warning for live mode only on step 3
			Step3_Check("good")
		Else
			GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("MB"))
			GUICtrlSetLimit($slider, Round(SpaceAfterLinuxLiveMB($selected_drive) / 10), 0)
			; State is OK but warning for live mode only on step 3
			Step3_Check("warning")
		EndIf
	ElseIf (StringInStr(DriveGetFileSystem($selected_drive), "FAT") <= 0 And GUICtrlRead($formater) <> $GUI_CHECKED) Then

		MsgBox(4096, "", Translate("Please choose a FAT32 or FAT formated key or check the formating option"))

		; State is NOT OK (no selected key)
		GUICtrlSetData($label_max, "?? " & Translate("MB"))
		Step1_Check("bad")

		; State for step 3 is NOT OK according to step 1
		GUICtrlSetData($label_max, "?? " & Translate("MB"))
		GUICtrlSetLimit($slider, 0, 0)
		Step3_Check("bad")
	ElseIf $file_set_mode = "img" Then
		Step3_Check("good")
		GUICtrlSetState($slider, $GUI_DISABLE)
		GUICtrlSetState($slider_visual, $GUI_DISABLE)
		If DriveSpaceTotal($selected_drive) > Round(FileGetSize($file_set)/1048576,1) Then
			Step1_Check("good")
		Else
			Step1_Check("bad")
		EndIf
	Else
		If (DriveGetFileSystem($selected_drive) = "") Then
			MsgBox(4096, "", Translate("No disk selected"))
		EndIf
		; State is NOT OK (no selected key)
		GUICtrlSetData($label_max, "?? " & Translate("MB"))
		Step1_Check("bad")

		; State for step 3 is NOT OK according to step 1
		GUICtrlSetData($label_max, "?? " & Translate("MB"))
		GUICtrlSetLimit($slider, 0, 0)
		Step3_Check("bad")

	EndIf
	SendReport("End-GUI_Choose_Drive")
EndFunc   ;==>GUI_Choose_Drive

Func GUI_Refresh_Drives()
	Refresh_DriveList()
EndFunc   ;==>GUI_Refresh_Drives

Func GUI_Choose_ISO()
	SendReport("Start-GUI_Choose_ISO")
	$source_file = FileOpenDialog(Translate("Choisir l'image ISO d'un CD live de Linux"), "", "ISO / IMG / ZIP (*.iso;*.img;*.zip)", 1)
	If @error Then
		SendReport("IN-ISO_AREA (no iso)")
		MsgBox(4096, "", Translate("No file selected"))
		$file_set = 0;
		Step2_Check("bad")
	Else
		$file_set = $source_file
		Check_source_integrity($file_set)
	EndIf
	SendReport("End-GUI_Choose_ISO")
EndFunc   ;==>GUI_Choose_ISO


Func GUI_Choose_CD()
	SendReport("Start-GUI_Choose_CD")
	#cs
		TODO : Recode support for CD
		MsgBox(16, "Sorry", "Sorry but CD Support is broken. Please use ISO or Download button.")
		Step2_Check("bad")
		$file_set = 0;
		Return ""
	#ce

	$folder_file = FileSelectFolder(Translate("Please choose a CD of LinuxLive Live or its folder"), "")
	If @error Then
		SendReport("IN-CD_AREA (no CD)")
		MsgBox(4096, "", Translate("No folder or CD selected"))
		Step2_Check("bad")
		$file_set = 0;
	Else
		Disable_Persistent_Mode()
		SendReport("IN-CD_AREA (CD selected :" & $folder_file & ")")
		$file_set = $folder_file;
		$file_set_mode = "folder"
		;Check_folder_integrity($folder_file)

		; Used to avoid redrawing the old elements of Step 2 (ISO, CD and download)
		$step2_display_menu = 1
		GUI_Hide_Step2_Default_Menu()

		GUI_Show_Back_Button()

		$temp_index = _ArraySearch($compatible_filename, "regular_linux.iso")
		$release_number = $temp_index
		GUI_Show_Check_status(Translate("This Linux is not in the compatibility list")& "." & @CRLF &Translate("However, LinuxLive USB Creator will try to use same install parameters as for") & @CRLF & @CRLF & @TAB & ReleaseGetDescription($release_number))
		Step2_Check("good")
	EndIf
	SendReport("End-GUI_Choose_CD")
EndFunc   ;==>GUI_Choose_CD

Func GUI_Download()
	SendReport("Start-GUI_Download")
	; Used to avoid redrawing the old elements of Step 2 (ISO, CD and download)
	$step2_display_menu = 1
	GUI_Hide_Step2_Default_Menu()

	;$cleaner = GUICtrlCreateLabel("", 38 + $offsetx0, 238 + $offsety0, 300, 30)
	;GUICtrlSetState($cleaner, $GUI_SHOW)
	;GUICtrlSetState($cleaner,$GUI_HIDE)

	if NOT $combo_linux Then
		$combo_linux = GUICtrlCreateCombo(">> " & Translate("Select your favourite Linux"), 38 + $offsetx0, 240 + $offsety0, 300, -1, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))

		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetOnEvent(-1, "GUI_Select_Linux")
		GUICtrlSetState($combo_linux, $GUI_SHOW)

		GUICtrlSetData($combo_linux, $prefetched_linux_list)

		$download_label2 = GUICtrlCreateLabel(Translate("Download"), 38 + $offsetx0 + 110, 210 + $offsety0 + 55, 150)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetFont(-1, 10)

		$download_manual = GUICtrlCreateButton(Translate("Manually"), 38 + $offsetx0 + 20, 235 + $offsety0 + 50, 110)
		GUICtrlSetOnEvent(-1, "GUI_Download_Manually")
		GUICtrlSetState(-1, $GUI_DISABLE)

		$OR_label = GUICtrlCreateLabel(Translate("OR"), 38 + $offsetx0 + 135, 235 + $offsety0 + 55, 20)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetFont(-1, 10)
		$download_auto = GUICtrlCreateButton(Translate("Automatically"), 38 + $offsetx0 + 160, 235 + $offsety0 + 50, 110)
		GUICtrlSetOnEvent(-1, "GUI_Download_Automatically")
		GUICtrlSetState(-1, $GUI_DISABLE)
	Else
		GUI_Show_Step2_Download_Menu()
		GUICtrlSetState($combo_linux, $GUI_SHOW)
	Endif

	GUI_Show_Back_Button()

	SendReport("End-GUI_Download")
EndFunc   ;==>GUI_Download

Func GUI_Show_Back_Button()
	GUICtrlDelete($cleaner2)
	$BACK_AREA = GUICtrlCreateLabel("", 5 + $offsetx0, 300 + $offsety0, 32, 32)
	$DRAW_BACK = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
	GUICtrlSetCursor($BACK_AREA, 0)
	GUICtrlSetOnEvent($BACK_AREA, "GUI_Back_Download")
EndFunc

Func GUI_Hide_Back_Button()
	;GUICtrlDelete($BACK_AREA)
	GUICtrlSetState($BACK_AREA, $GUI_HIDE)
	$cleaner2 = GUICtrlCreateLabel("", 5 + $offsetx0, 300 + $offsety0, 32, 32)
EndFunc

Func GUI_Show_Step2_Download_Menu()
	GUICtrlSetState($download_manual, $GUI_SHOW)
	GUICtrlSetState($download_auto, $GUI_SHOW)
	GUICtrlSetState($label_step2_status, $GUI_HIDE)
	GUICtrlSetState($download_label2, $GUI_SHOW)
	GUICtrlSetState($OR_label, $GUI_SHOW)
	GUICtrlSetState($combo_linux, $GUI_SHOW)
EndFunc

Func GUI_Hide_Step2_Download_Menu()
	;_ProgressDelete($progress_bar)
	GUICtrlSetState($combo_linux, $GUI_HIDE)
	GUICtrlSetState($download_manual, $GUI_HIDE)
	GUICtrlSetState($download_auto, $GUI_HIDE)
	GUICtrlSetState($label_step2_status, $GUI_HIDE)
	GUICtrlSetState($download_label2, $GUI_HIDE)
	GUICtrlSetState($OR_label, $GUI_HIDE)
	$cleaner = GUICtrlCreateLabel("", 38 + $offsetx0, 238 + $offsety0, 300, 30)

	GUICtrlSetState($cleaner, $GUI_SHOW)
EndFunc

Func GUI_Show_Step2_Default_Menu()
	GUICtrlSetState($ISO_AREA, $GUI_SHOW)
	GUICtrlSetState($CD_AREA, $GUI_SHOW)
	GUICtrlSetState($DOWNLOAD_AREA, $GUI_SHOW)
	GUICtrlSetState($label_cd, $GUI_SHOW)
	GUICtrlSetState($label_download, $GUI_SHOW)
	GUICtrlSetState($label_iso, $GUI_SHOW)
	GUICtrlSetState($cleaner, $GUI_HIDE)
	GUICtrlSetState($cleaner2, $GUI_HIDE)
	$step2_display_menu = 0
	$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146 + $offsetx0, 231 + $offsety0, 75, 75)
	$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260 + $offsetx0, 230 + $offsety0, 75, 75)
	$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38 + $offsetx0, 231 + $offsety0, 75, 75)
	GUICtrlSetState($cleaner2, $GUI_SHOW)
EndFunc

Func GUI_Hide_Step2_Default_Menu()
	; hiding old elements
	GUICtrlSetState($ISO_AREA, $GUI_HIDE)
	GUICtrlSetState($CD_AREA, $GUI_HIDE)
	GUICtrlSetState($DOWNLOAD_AREA, $GUI_HIDE)
	GUICtrlSetState($label_cd, $GUI_HIDE)
	GUICtrlSetState($label_download, $GUI_HIDE)
	GUICtrlSetState($label_iso, $GUI_HIDE)
EndFunc


Func GUI_Back_Download()
	SendReport("Start-GUI_Back_Download")
	Global $label_step2_status,$label_step2_status2
	Global $current_download
	_ProgressDelete($progress_bar)
	InetClose($current_download)
	GUI_Hide_Step2_Download_Menu()
	GUI_Hide_Back_Button()
	GUICtrlSetState($label_step2_status,$GUI_HIDE)
	GUICtrlSetState($label_step2_status2,$GUI_HIDE)
	; Showing old elements again
	GUI_Show_Step2_Default_Menu()
	SendReport("End-GUI_Back_Download")
EndFunc   ;==>GUI_Back_Download

Func GUI_Select_Linux()
	SendReport("Start-GUI_Select_Linux")
	$selected_linux = GUICtrlRead($combo_linux)
	If StringInStr($selected_linux, ">>") = 0 Then
		GUICtrlSetState($download_manual, $GUI_ENABLE)
		GUICtrlSetState($download_auto, $GUI_ENABLE)
	Else
		MsgBox(48, Translate("Please read"), Translate("Please select a linux to continue"))
		GUICtrlSetState($download_manual, $GUI_DISABLE)
		GUICtrlSetState($download_auto, $GUI_DISABLE)
	EndIf
	SendReport("End-GUI_Select_Linux")
EndFunc   ;==>GUI_Select_Linux

Func GUI_Download_Automatically()
	SendReport("Start-GUI_Download_Automatically")
	$selected_linux = GUICtrlRead($combo_linux)
	$release_in_list = FindReleaseFromDescription($selected_linux)
	DownloadRelease($release_in_list, 1)
	SendReport("End-GUI_Download_Automatically")
EndFunc   ;==>GUI_Download_Automatically

Func GUI_Download_Manually()
	SendReport("Start-GUI_Download_Manually")
	$selected_linux = GUICtrlRead($combo_linux)
	$release_in_list = FindReleaseFromDescription($selected_linux)
	DownloadRelease($release_in_list, 0)
	SendReport("End-GUI_Download_Manually")
EndFunc   ;==>GUI_Download_Manually

Func DownloadRelease($release_in_list, $automatic_download)
	SendReport("Start-DownloadRelease (Release=" & $release_in_list & " - Auto_DL=" & $automatic_download & " )")
	Local $latency[50], $i, $mirror, $available_mirrors = 0, $tested_mirrors = 0

	GUI_Hide_Step2_Download_Menu()

	GUI_Show_Back_Button()
	;$BACK_AREA = GUICtrlCreateLabel("", 5 + $offsetx0, 300 + $offsety0, 32, 32)
	;$DRAW_BACK = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
	;GUICtrlSetCursor($BACK_AREA, 0)
	;GUICtrlSetOnEvent($BACK_AREA, "GUI_Back_Download")

	$progress_bar = _ProgressCreate(38 + $offsetx0, 238 + $offsety0, 300, 30)
	_ProgressSetImages($progress_bar, @ScriptDir & "\tools\img\progress_green.jpg", @ScriptDir & "\tools\img\progress_background.jpg")
	_ProgressSetFont($progress_bar, "", -1, -1, 0x000000, 0)

	if NOT $progress_bar Then
		$progress_bar = _ProgressCreate(38 + $offsetx0, 238 + $offsety0, 300, 30)
		_ProgressSetImages($progress_bar, @ScriptDir & "\tools\img\progress_green.jpg", @ScriptDir & "\tools\img\progress_background.jpg")
		_ProgressSetFont($progress_bar, "", -1, -1, 0x000000, 0)
	EndIf

	$label_step2_status = GUICtrlCreateLabel(Translate("Looking for the fastest mirror"), 38 + $offsetx0, 231 + $offsety0 + 50, 300, 80)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0xFFFFFF)
	UpdateStatusStep2("Looking for the fastest mirror")

	For $i = $R_MIRROR1 To $R_MIRROR10
		$mirror = $releases[$release_in_list][$i]
		If StringStripWS($mirror, 1) <> "" Then $available_mirrors = $available_mirrors + 1
	Next

	For $i = $R_MIRROR1 To $R_MIRROR10
		$mirror = $releases[$release_in_list][$i]
		If StringStripWS($mirror, 1) <> "" Then
			_ProgressSet($progress_bar, $tested_mirrors * 100 / $available_mirrors)
			_ProgressSetText($progress_bar, Translate("Testing mirror") & " : " & URLToHostname($mirror))
			$temp_latency = Ping(URLToHostname($mirror))
			$tested_mirrors = $tested_mirrors + 1
			If @error = 0 Then
				$temp_size = Round(InetGetSize($mirror,3) / 1048576)
				If $temp_size < 5 Or $temp_size > 5000 Then
					$temp_latency = 10000
				EndIf
			Else
				$temp_latency = 10000
			EndIf

		Else
			$temp_latency = 10000
		EndIf
		$latency[$i] = $temp_latency

	Next
	If _ArrayMin($latency, 1, $R_MIRROR1, $R_MIRROR10) = 10000 Then
		SendReport("ck2")
		UpdateStatusStep2(Translate("No online mirror found") & " !" & @CRLF & Translate("Please check your internet connection or try with another linux"))
		_ProgressSet($progress_bar, 100)
		Sleep(3000)
	Else
		_ProgressSet($progress_bar, 100)
		$best_mirror = $releases[$release_in_list][_ArrayMinIndex($latency, 1, $R_MIRROR1, $R_MIRROR10)]
		If $automatic_download = 0 Then
			; Download manually
			UpdateStatusStep2("Select this file as the source when download will be completed")
			DisplayMirrorList($latency, $release_in_list)
		Else
			; Download automatically
			$iso_size = InetGetSize($best_mirror)
			$filename = unix_path_to_name($best_mirror)
			$current_download = InetGet($best_mirror, @ScriptDir & "\" & $filename, 1, 1)
			If InetGetInfo($current_download, 4)=0 Then
				UpdateStatusStep2(Translate("Downloading") & " " & $filename & @CRLF & Translate("from") & " " & URLToHostname($best_mirror))
				Download_State()
			Else
				UpdateStatusStep2(Translate("Error while trying to download") & @CRLF & Translate("Please check your internet connection or try with another linux"))
				Sleep(3000)
				_ProgressDelete($progress_bar)
				GUI_Back_Download()
			EndIf
		EndIf
	EndIf

	SendReport("End-DownloadRelease")
EndFunc   ;==>DownloadRelease

; Let the user select a mirror
Func DisplayMirrorList($latency_table, $release_in_list)
	Local $hImage, $hListView

	; Create GUI
	$gui_mirrors = GUICreate("Select the mirror", 350, 250)
	Opt("GUIOnEventMode", 0)
	$hListView = GUICtrlCreateListView("  " & Translate("Latency") & "  |  " & Translate("Server Name") & "  | ", 0, 0, 350, 200)
	_GUICtrlListView_SetColumnWidth($hListView, 0, 80)
	_GUICtrlListView_SetColumnWidth($hListView, 1, 230)
	$hImage = _GUIImageList_Create()
	$copy_it = GUICtrlCreateButton(Translate("Copy link"), 30, 210, 120, 30)
	$launch_it = GUICtrlCreateButton(Translate("Launch in my browser"), 180, 210, 150, 30)


	Local $latency_server[$R_MIRROR10 - $R_MIRROR1 + 1][3]
	For $i = $R_MIRROR1 To $R_MIRROR10
		$mirror = $releases[$release_in_list][$i]
		If $mirror <> "NotFound" AND $mirror <> "" Then
			$latency_server[$i - $R_MIRROR1][0] = $latency_table[$i]
			$latency_server[$i - $R_MIRROR1][1] = URLToHostname($mirror)
			$latency_server[$i - $R_MIRROR1][2] = $mirror
		EndIf
	Next

	_GUICtrlListView_EnableGroupView($hListView)
	_GUICtrlListView_InsertGroup($hListView, -1, 1, Translate("Best mirrors"))
	_GUICtrlListView_InsertGroup($hListView, -1, 2, Translate("Good mirrors"))
	_GUICtrlListView_InsertGroup($hListView, -1, 3, Translate("Bad mirrors"))
	_GUICtrlListView_InsertGroup($hListView, -1, 4, Translate("Dead mirrors"))

	_ArraySort($latency_server, 0, 0, 0, 0)

	; Add items
	$item = 0
	For $i = $R_MIRROR1 To $R_MIRROR10
		If $latency_server[$i - $R_MIRROR1][2] Then
			$latency = $latency_server[$i - $R_MIRROR1][0]
			GUICtrlCreateListViewItem($latency & " | " & $latency_server[$i - $R_MIRROR1][1] & " |" & $latency_server[$i - $R_MIRROR1][2], $hListView)
			If $latency < 60 Then
				_GUICtrlListView_SetItemGroupID($hListView, $item, 1)
				_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0x00FF00, 16, 16))
			ElseIf $latency < 150 Then
				_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0x00FF00, 16, 16))
				_GUICtrlListView_SetItemGroupID($hListView, $item, 2)
			ElseIf $latency < 10000 Then
				_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0xFF0000, 16, 16))
				_GUICtrlListView_SetItemGroupID($hListView, $item, 3)
			Else
				_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0x000000, 16, 16))
				_GUICtrlListView_SetItemGroupID($hListView, $item, 4)
			EndIf
			$item = $item + 1
		EndIf
	Next

	_GUICtrlListView_SetImageList($hListView, $hImage, 1)
	_GUICtrlListView_HideColumn($hListView, 2)
	GUISetState(@SW_SHOW,$gui_mirrors)

	; Loop until user exits
	while 1
		$msg = GUIGetMsg()
		If $msg = $GUI_EVENT_CLOSE Then ExitLoop

		If $msg = $copy_it Then
			If GUICtrlRead($hListView) Then
				$item_selected = GUICtrlRead(GUICtrlRead($hListView))
				$url_for_download_temp = StringSplit($item_selected, "|")
				$url_for_download = $url_for_download_temp[UBound($url_for_download_temp) - 2]
				ClipPut(StringStripWS($url_for_download, 3))
			Else
				ClipPut($best_mirror)
			EndIf
		ElseIf $msg = $launch_it Then
			If GUICtrlRead($hListView) Then
				$item_selected = GUICtrlRead(GUICtrlRead($hListView))
				$url_for_download_temp = StringSplit($item_selected, "|")
				$url_for_download = $url_for_download_temp[UBound($url_for_download_temp) - 2]
				ShellExecute(StringStripWS($url_for_download, 3))
			Else
				ShellExecute($best_mirror)
			EndIf
		EndIf

	wend
	Opt("GUIOnEventMode", 1)
	GUIDelete($gui_mirrors)

	GUIRegisterMsg($WM_PAINT, "DrawAll")
	WinActivate($for_winactivate)
	GUISetState($GUI_SHOW, $CONTROL_GUI)
EndFunc   ;==>DisplayMirrorList

Func Download_State()
	SendReport("Start-Download_State")
	Global $current_download
	Local $begin, $oldgetbytesread, $estimated_time = ""

	$begin = TimerInit()
	$oldgetbytesread = InetGetInfo($current_download, 0)

	$iso_size_mb = RoundForceDecimal($iso_size / (1024 * 1024))
	Do
		$percent_downloaded = Int((100 * InetGetInfo($current_download, 0) / $iso_size))
		_ProgressSet($progress_bar, $percent_downloaded)
		$dif = TimerDiff($begin)
		$newgetbytesread = InetGetInfo($current_download, 0)
		If $dif > 1000 Then
			$bytes_per_ms = ($newgetbytesread - $oldgetbytesread) / $dif
			$estimated_time = HumanTime(($iso_size - $newgetbytesread) / (1000 * $bytes_per_ms))
			$begin = TimerInit()
			$oldgetbytesread = $newgetbytesread
		EndIf
		_ProgressSetText($progress_bar, $percent_downloaded & "% ( " & RoundForceDecimal($newgetbytesread / (1024 * 1024)) & " / " & $iso_size_mb & " " & "MB" & " ) " & $estimated_time)
		Sleep(300)
	Until InetGetInfo($current_download, 2)

	_ProgressSet($progress_bar, 100)
	_ProgressSetText($progress_bar, "100% ( " & Round($iso_size / (1024 * 1024)) & " / " & Round($iso_size / (1024 * 1024)) & " " & "MB" & " )")

	UpdateStatusStep2(Translate("Download complete") & @CRLF & Translate("Check will begin shortly"))
	Sleep(3000)
	_ProgressDelete($progress_bar)
	GUI_Hide_Step2_Download_Menu()
	$file_set = @ScriptDir & "\" & $filename
	Check_source_integrity($file_set)
	SendReport("End-Download_State")
EndFunc   ;==>Download_State

Func HumanTime($sec)
	If $sec <= 0 Then Return ""

	$hours = Floor($sec / 3600)
	If $hours > 5 Then Return ""

	$minutes = Floor($sec / 60) - $hours * 60
	$seconds = Floor($sec) - $minutes * 60

	; to avoid displaying bullshit
	If $minutes < 0 Or $hours < 0 Or $seconds < 0 Then Return ""

	If $sec > 3600 Then
		$human_time = $hours & "h " & $minutes & "m "
	ElseIf $sec <= 3600 And $sec > 60 Then
		$human_time = $minutes & "m " & $seconds & "s "
	ElseIf $sec <= 60 Then
		$human_time = $seconds & "s "
	EndIf
	Return $human_time
EndFunc   ;==>HumanTime



Func RoundForceDecimal($number)
	$rounded = Round($number, 1)
	If Not StringInStr($rounded, ".") Then $rounded = $rounded & ".0"
	Return $rounded
EndFunc   ;==>RoundForceDecimal


Func GUI_Persistence_Slider()
	SendReport("Start-GUI_Persistence_Slider")
	If GUICtrlRead($slider) > 0 Then
		GUICtrlSetData($slider_visual, GUICtrlRead($slider) * 10)
		GUICtrlSetData($slider_visual_mode, Translate("(Persistent Mode)"))
		; State is OK (value > 0)
		Step3_Check("good")
	Else
		GUICtrlSetData($slider_visual, GUICtrlRead($slider) * 10)
		GUICtrlSetData($slider_visual_mode, Translate("(Live mode only)"))
		; State is OK but warning (value = 0)
		Step3_Check("warning")
	EndIf
	SendReport("End-GUI_Persistence_Slider")
EndFunc   ;==>GUI_Persistence_Slider

Func GUI_Persistence_Input()
	SendReport("Start-GUI_Persistence_Input")
	$selected_drive = StringLeft(GUICtrlRead($combo), 2)
	If StringIsInt(GUICtrlRead($slider_visual)) And GUICtrlRead($slider_visual) <= SpaceAfterLinuxLiveMB($selected_drive) And GUICtrlRead($slider_visual) > 0 Then
		GUICtrlSetData($slider, Round(GUICtrlRead($slider_visual) / 10))
		GUICtrlSetData($slider_visual_mode, Translate("(Persistent Mode)"))
		; State is  OK (persistent mode)
		Step3_Check("good")
	ElseIf GUICtrlRead($slider_visual) = 0 Then
		GUICtrlSetData($slider_visual_mode, Translate("(Live mode only)"))
		; State is WARNING (live mode only)
		Step3_Check("warning")
	Else
		GUICtrlSetData($slider, 0)
		GUICtrlSetData($slider_visual, 0)
		GUICtrlSetData($slider_visual_mode, Translate("(Live mode only)"))
		; State is WARNING (live mode only)
		Step3_Check("warning")
	EndIf
	SendReport("End-GUI_Persistence_Input")
EndFunc   ;==>GUI_Persistence_Input

Func GUI_Format_Key()
	SendReport("Start-GUI_Format_Key")
	If GUICtrlRead($formater) == $GUI_CHECKED Then
		GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("MB"))
		GUICtrlSetLimit($slider, SpaceAfterLinuxLiveMB($selected_drive) / 10, 0)
	Else
		GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("MB"))
		GUICtrlSetLimit($slider, SpaceAfterLinuxLiveMB($selected_drive) / 10, 0)
	EndIf

	If ((StringInStr(DriveGetFileSystem($selected_drive), "FAT") >= 1 Or GUICtrlRead($formater) == $GUI_CHECKED) And SpaceAfterLinuxLiveMB($selected_drive) > 0) Then
		; State is OK ( FAT32 or FAT format and 700MB+ free)
		GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("MB"))
		GUICtrlSetLimit($slider, Round(SpaceAfterLinuxLiveMB($selected_drive) / 10), 0)
		Step1_Check("good")

	ElseIf (StringInStr(DriveGetFileSystem($selected_drive), "FAT") <= 0 And GUICtrlRead($formater) <> $GUI_CHECKED) Then
		MsgBox(4096, "", Translate("Please choose a FAT32 or FAT formated key or check the formating option"))
		GUICtrlSetData($label_max, "?? Mo")
		Step1_Check("bad")

	Else
		If (DriveGetFileSystem($selected_drive) = "") Then
			MsgBox(4096, "", Translate("No disk selected"))
		EndIf
		;State is NOT OK (no selected key)
		GUICtrlSetData($label_max, "?? " & Translate("MB"))
		Step1_Check("bad")

	EndIf
	SendReport("End-GUI_Format_Key")
EndFunc   ;==>GUI_Format_Key

Func GUI_Launch_Creation()

	; to avoid to create the key twice in a row
	if $already_create_a_key >0 Then
		$return = MsgBox(33,Translate("Please read"),Translate("You have already created a key")&"."&@CRLF&Translate("Are you sure that you want to recreate one")&" ?")
		if $return == 2 Then Return ""
	EndIf
	SendReport(LogSystemConfig())
	SendReport("Start-GUI_Launch_Creation")
	; Disable the controls and re-enable after creation

	$selected_drive = StringLeft(GUICtrlRead($combo), 2)

	; force cleaning old status (little bug fix)
	UpdateStatus("")
	Sleep(200)

	UpdateStatus("Start creation of LinuxLive USB")

	If $STEP1_OK >= 1 And $STEP2_OK >= 1 And $STEP3_OK >= 1 Then
		$annuler = 0
	Else
		$annuler = 2
		UpdateStatus("Please validate step 1 to 3")
	EndIf

	; Initializing log file, already initialized when using verbose_logging
	If IniRead($settings_ini, "General", "verbose_logging", "no") = "no" Then InitLog()

	; Format option has been selected
	If (GUICtrlRead($formater) == $GUI_CHECKED) And $annuler <> 2 Then
		$annuler = 0
		$annuler = MsgBox(49, Translate("Please read") & "!!!", Translate("Are you sure you want to format this disk and lose your data ?") & @CRLF & @CRLF & "       " & Translate("Label") & " : ( " & $selected_drive & " ) " & DriveGetLabel($selected_drive) & @CRLF & "       " & Translate("Size") & " : " & Round(DriveSpaceTotal($selected_drive) / 1024, 1) & " " & Translate("GB") & @CRLF & "       " & Translate("Formatted in") & " : " & DriveGetFileSystem($selected_drive) & @CRLF)
		If $annuler = 1 Then
			Format_FAT32($selected_drive)
		EndIf
	EndIf

	; Starting creation if not cancelled
	If $annuler <> 2 Then

		UpdateStatus("Step 1 to 3 OK")

		; Cleaning old installs only if needed
		If $file_set_mode <> "img" Then
			InitializeFilesInSource($file_set)
			If GUICtrlRead($formater) <> $GUI_CHECKED Then Clean_old_installs($selected_drive, $release_number)
		EndIf

		If GUICtrlRead($virtualbox) == $GUI_CHECKED Then $virtualbox_check = Download_virtualBox()

		; Uncompressing ou copying files on the key
		If $file_set_mode = "iso" Then
			Uncompress_ISO_on_key($selected_drive, $file_set, $release_number)
		ElseIf $file_set_mode = "folder" Then
			Create_Stick_From_CD($selected_drive, $file_set)
		ElseIf $file_set_mode = "img" Then
			Create_Stick_From_IMG($selected_drive, $file_set)
		EndIf

		; If it's not an IMG file, we have to do all these things :
		If $file_set_mode <> "img" Then
			Rename_and_move_files($selected_drive, $release_number)

			Create_boot_menu($selected_drive, $release_number)

			Create_persistence_file($selected_drive, $release_number, GUICtrlRead($slider_visual), GUICtrlRead($hide_files))

			Install_boot_sectors($selected_drive,$release_number, GUICtrlRead($hide_files))

			; Create Autorun menu
			Create_autorun($selected_drive, $release_number)
		EndIf

		If (GUICtrlRead($hide_files) == $GUI_CHECKED) Then Hide_live_files($selected_drive)

		If GUICtrlRead($virtualbox) == $GUI_CHECKED And $virtualbox_check >= 1 Then

			If $virtualbox_check <> 2 Then Check_virtualbox_download()

			; maybe check downloaded file ?

			; Next step : uncompressing vbox on the key
			Uncompress_virtualbox_on_key($selected_drive)

			UpdateStatus("Applying VirtualBox settings")
			Setup_RAM_for_VM($selected_drive,$release_number)

			;Run($selected_drive & "\Portable-VirtualBox\Launch_usb.exe", @ScriptDir, @SW_HIDE)

		EndIf



		; Creation is now done
		UpdateStatus("Your LinuxLive key is now up and ready !")
		$already_create_a_key+=1
		If GUICtrlRead($virtualbox) == $GUI_CHECKED And $virtualbox_check >= 1 Then Final_check()

		Sleep(1000)

		ShellExecute("http://www.linuxliveusb.com/using-lili.html", "", "", "", 7)
		If isBeta() Then Ask_For_Feedback()
	Else
		UpdateStatus("Please validate step 1 to 3")
	EndIf
	SendReport("End-GUI_Launch_Creation")
EndFunc   ;==>GUI_Launch_Creation


Func Ask_For_Feedback()
	$return = MsgBox(65, "Help me to improve LiLi", "This is a Beta or RC version, click OK to leave a feedback or click Cancel to close this window")
	If $return = 1 Then ShellExecute("http://www.linuxliveusb.com/feedback/?version="&$software_version, "", "", "", 7)
EndFunc   ;==>Ask_For_Feedback

Func GUI_Events()

	SendReport("Start-GUI_Events (GUI_CtrlID=" & @GUI_CtrlId & " )")
	Select
		Case @GUI_CtrlId = $GUI_EVENT_CLOSE
			GUI_Exit()
		Case @GUI_CtrlId = $GUI_EVENT_MINIMIZE
			GUISetState(@SW_MINIMIZE, @GUI_WinHandle)
			GUISetState(@SW_MINIMIZE, $GUI)
			GUISetState(@SW_MINIMIZE, $CONTROL_GUI)
		Case @GUI_CtrlId = $GUI_EVENT_RESTORE
			GUISetState($GUI_SHOW, @GUI_WinHandle)
			GUISetState($GUI_SHOW, $GUI)
			GUISetState($GUI_SHOW, $CONTROL_GUI)
			GUIRegisterMsg($WM_PAINT, "DrawAll")
			WinActivate($for_winactivate)
			ControlFocus("LiLi USB Creator", "", $REFRESH_AREA)
	EndSelect
	SendReport("End-GUI_Events")
EndFunc   ;==>GUI_Events

Func GUI_Events2()
	SendReport("Start-GUI_Events2 (GUI_CtrlID=" & @GUI_CtrlId & " )")
	Select
		Case @GUI_CtrlId = $GUI_EVENT_CLOSE
			GUIDelete(@GUI_WinHandle)
			Sleep(1000)
			$return = MsgBox(65, "This is a RC Version", "This is a Release Candidate version, click OK to leave a feedback or click Cancel to close this window")
			If $return = 1 Then ShellExecute("http://www.linuxliveusb.com/feedback/rc1.php", "", "", "", 7)
		Case @GUI_CtrlId = $GUI_EVENT_MINIMIZE
			GUISetState(@SW_MINIMIZE, @GUI_WinHandle)
		Case @GUI_CtrlId = $GUI_EVENT_RESTORE
			GUISetState(@SW_SHOW, @GUI_WinHandle)

	EndSelect
	SendReport("End-GUI_Events2")
EndFunc   ;==>GUI_Events2

Func GUI_Help_Step1()
	SendReport("Start-GUI_Help_Step1")
	ShellExecute("http://www.linuxliveusb.com/step1.html")
	SendReport("End-GUI_Help_Step1")
EndFunc   ;==>GUI_Help_Step1

Func GUI_Help_Step2()
	SendReport("Start-GUI_Help_Step2")
	ShellExecute("http://www.linuxliveusb.com/step2.html")
	SendReport("End-GUI_Help_Step2")
EndFunc   ;==>GUI_Help_Step2

Func GUI_Help_Step3()
	SendReport("Start-GUI_Help_Step3")
	ShellExecute("http://www.linuxliveusb.com/step3.html")
	SendReport("End-GUI_Help_Step3")
EndFunc   ;==>GUI_Help_Step3

Func GUI_Help_Step4()
	SendReport("Start-GUI_Help_Step4")
	ShellExecute("http://www.linuxliveusb.com/step4.html")
	SendReport("End-GUI_Help_Step4")
EndFunc   ;==>GUI_Help_Step4

Func GUI_Help_Step5()
	SendReport("Start-GUI_Help_Step5")
	;_About(Translate("About this software"), "LiLi USB Creator", "CopyLeft by Thibaut Lauzi�re - GPL v3 License", $software_version, Translate("User's Guide"), "http://www.linuxliveusb.com/how-to.html", Translate("Homepage"), "http://www.linuxliveusb.com", Translate("Donate"), "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8297661", @AutoItExe, 0x0000FF, 0xFFFFFF, -1, -1, -1, -1, $CONTROL_GUI)
	GUI_Options_Menu()
	SendReport("End-GUI_Help_Step5")
EndFunc   ;==>GUI_Help_Step5
