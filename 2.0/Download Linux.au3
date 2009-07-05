#include <GuiConstantsEx.au3>
#include <GDIPlus.au3>
#include <Constants.au3>
#include <ProgressConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <Releases.au3>
#include <Graphics.au3>
#Include <File.au3>


; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// reste à faire : status dans un controle type label, bouton go back, menu de fin, communication avec lili                           ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Opt("GUIOnEventMode", 1)

Global $lang,$lang_ini = @ScriptDir & "\tools\settings\langs.ini"
Global $settings_ini = @ScriptDir & "\tools\settings\settings.ini"
Global $GUI,$CONTROL_GUI
$lang = _Language()

	_GDIPlus_Startup()

	$GUI_DOWNLOAD_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\GUI_Download.png")
	$EXIT_NORM = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\close.PNG")
	$width = _GDIPlus_ImageGetWidth($GUI_DOWNLOAD_PNG)
	$height = _GDIPlus_ImageGetHeight($GUI_DOWNLOAD_PNG)
	$GUI = GUICreate("LiLi Download", $width, $height, -1, -1, $WS_POPUP, $WS_EX_LAYERED)

	SetBitmap($GUI, $GUI_DOWNLOAD_PNG, 255)
	GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")
	GUISetState(@SW_SHOW, $GUI)

	; Old offset was 18
	$LAYERED_GUI_CORRECTION = GetVertOffset($GUI)
	$CONTROL_GUI = GUICreate("CONTROL_GUI2", $width, $height, 0, $LAYERED_GUI_CORRECTION, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD), $GUI)
$EXIT_AREA = GUICtrlCreateLabel("", 325, 0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Exit")

Global $combo,$download_manual,$download_auto

$combo = GUICtrlCreateCombo(">> " & "Select your favourite Linux", 20, 40, 300,-1,3)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetOnEvent(-1, "GUI_Select_Linux")
Get_Compatibility_List()
GUICtrlSetData($combo, Print_For_ComboBox())

$download_manual = GUICtrlCreateButton("Download Manually", 20, 80, 130)
GUICtrlSetOnEvent(-1, "GUI_Download_Manually")
GUICtrlSetState ( -1, $GUI_DISABLE )


$download_auto = GUICtrlCreateButton("Download Automatically", 200, 80, 130)
GUICtrlSetOnEvent(-1, "GUI_Download_Automatically")
GUICtrlSetState ( -1, $GUI_DISABLE )

GUISetBkColor(0x121314)
_WinAPI_SetLayeredWindowAttributes($CONTROL_GUI, 0x121314)
GUISetState(@SW_SHOW, $CONTROL_GUI)

$ZEROGraphic = _GDIPlus_GraphicsCreateFromHWND($CONTROL_GUI)
$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 325, 0, 20, 20)

While 1
	sleep(60000)
WEnd

Func GUI_Exit()
	InetGet("abort")
	GUIDelete($CONTROL_GUI)
	GUIDelete($GUI)
	_GDIPlus_Shutdown()
	 Exit
 EndFunc

Func GUI_Select_Linux()
	$selected_linux = StringSplit(GUICtrlRead($combo), "//",1)
	if $selected_linux[0] >= 2 Then
		GUICtrlSetState ( $download_manual, $GUI_ENABLE )
		GUICtrlSetState ( $download_auto, $GUI_ENABLE )
	Else
		MsgBox(48, "Attention","Please select a linux to continue")
		GUICtrlSetState ( $download_manual, $GUI_DISABLE )
		GUICtrlSetState ( $download_auto, $GUI_DISABLE )
	EndIf
EndFunc

Func GUI_Download_Automatically()
	$selected_linux = StringSplit(GUICtrlRead($combo), "//",1)
	$release_in_list = FindReleaseFromDescription($selected_linux[1])
	;DisplayRelease($release_in_list)
	DownloadRelease($release_in_list)
EndFunc

Func GUI_Download_Manually()

EndFunc

Func DownloadRelease($release_in_list)
	Local $latency[50],$i,$mirror,$available_mirrors=0,$tested_mirrors=0
	Global $best_mirror,$iso_size,$filename,$progress_bar, $status
	GUICtrlSetState($combo, $GUI_HIDE)
	GUICtrlSetState($download_manual, $GUI_HIDE)
	GUICtrlSetState($download_auto, $GUI_HIDE)
	$progress_bar = _ProgressCreate(20, 40, 300, 30)
	_ProgressSetImages($progress_bar, @ScriptDir & "\tools\img\progress_green.jpg", @ScriptDir & "\tools\img\progress_background.jpg")
	_ProgressSetFont($progress_bar, "", -1, -1, 0x000000,0)

	$status = GUICtrlCreateLabel("Looking for the fastest mirror", 20, 80, 300,80)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0xFFFFFF)
	UpdateStatus("Choosing fastest mirror")

	for $i=$R_MIRROR1 to $R_MIRROR10
		$mirror = $releases[$release_in_list][$i]
		if  StringStripWS ($mirror,1) <> "" Then $available_mirrors = $available_mirrors +1
	Next

	for $i=$R_MIRROR1 to $R_MIRROR10
		$mirror = $releases[$release_in_list][$i]
		if  StringStripWS ($mirror,1) <> "" Then
			$temp_latency = Ping(URLToHostname($mirror),1000)
			if @error = 0 Then
				$tested_mirrors = $tested_mirrors +1
				_ProgressSet($progress_bar, $tested_mirrors*100/$available_mirrors)
				_ProgressSetText($progress_bar, "Testing : " & URLToHostname($mirror))
			Else
				$temp_latency= 10000
			EndIf
		Else
			$temp_latency = 10000
		EndIf
		$latency[$i] = $temp_latency

	Next

	if _ArrayMin($latency,1,$R_MIRROR1,$R_MIRROR10) = 10000 Then
		UpdateStatus("No online mirror found !" & @CRLF & "Please check your internet connection or try with another linux"  )
		_ProgressSet($progress_bar, 100)

		Return "NoMirror"
	Else
		UpdateStatus("Best mirror found"& @CRLF &"Download will start in a few seconds" )
		_ProgressSet($progress_bar, 100)
		Sleep(3000)

		$best_mirror = $releases[$release_in_list][_ArrayMinIndex($latency,1,$R_MIRROR1,$R_MIRROR10)]
		$iso_size = InetGetSize($best_mirror)
		$filename = unix_path_to_name($best_mirror)
		$inet_success = InetGet($best_mirror, @ScriptDir & "\" & $filename, 1, 1)
		if $inet_success Then
			UpdateStatus("Downloading "& $filename & @CRLF &"From " & URLToHostname($best_mirror))
			AdlibEnable ( "Download_State", 150 )
		Else
			UpdateStatus("Error while trying to download, please check you internet connection or try another linux")
		EndIf

	EndIf
EndFunc

Func Download_State()
		While @InetGetActive
			$percent_downloaded = Int((100 * @InetGetBytesRead / $iso_size))
			_ProgressSet($progress_bar,$percent_downloaded)
			_ProgressSetText($progress_bar, $percent_downloaded & "% ( " & RoundForceDecimal(@InetGetBytesRead / (1024 * 1024)) & " / " & RoundForceDecimal($iso_size / (1024 * 1024)) & " " & "MB" & " )")
			Sleep(300)
		WEnd
		_ProgressSet($progress_bar,100)
		_ProgressSetText($progress_bar,"100% ( " & Round($iso_size / (1024 * 1024)) & " / " & Round($iso_size / (1024 * 1024)) & " " & "MB" & " )")
		AdlibDisable ()
		If CountISO() = 1 Then
			UpdateStatus("Please close this window, LiLi USB Creator will automatically choose this file as source for the key.")
		Else
			UpdateStatus("You can now select this file as source in LiLi USB Creator.Please close this window")
		EndIf
EndFunc

Func RoundForceDecimal($number)
	$rounded = Round($number,1)
	If Not StringInStr($rounded, ".") Then $rounded = $rounded & ".0"
	Return $rounded
EndFunc


; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Locales management                            ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func _Language()

	#cs
		Case StringInStr("0413,0813", @OSLang)
		Return "Dutch"

		Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009, 2409,2809,2c09,3009,3409", @OSLang)
		Return "English"

		Case StringInStr("0410,0810", @OSLang)
		Return "Italian"

		Case StringInStr("0414,0814", @OSLang)
		Return "Norwegian"

		Case StringInStr("0415", @OSLang)
		Return "Polish"

		Case StringInStr("0416,0816", @OSLang)
		Return "Portuguese";

		Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a,240a,280a,2c0a,300a,340a,380a,3c0a,400a, 440a,480a,4c0a,500a", @OSLang)
		Return "Spanish"

		Case StringInStr("041d,081d", @OSLang)
		Return "Swedish"
	#ce

	$force_lang = IniRead($settings_ini, "General", "force_lang", "no")
	$temp = IniReadSectionNames($lang_ini)
	$available_langs = _ArrayToString($temp)
	If $force_lang <> "no" And (StringInStr( $available_langs, $force_lang) > 0) Then
		Return $force_lang
	EndIf
	Select
		Case StringInStr("040c,080c,0c0c,100c,140c,180c", @OSLang)
			Return "French"
		Case StringInStr("0403,040a,080a,0c0a,100a,140a,180a,1c0a,200a,240a,280a,2c0a,300a,340a,380a,3c0a,400a,440a,480a,4c0a,500a", @OSLang)
			Return "Spanish"
		Case StringInStr("0407,0807,0c07,1007,1407,0413,0813", @OSLang)
			Return "German"
		Case StringInStr("0410,0810", @OSLang)
			Return "Italian"
		Case Else
			Return "English"
	EndSelect
EndFunc   ;==>_Language

Func Translate($txt)
	Return IniRead($lang_ini, $lang, $txt, $txt)
EndFunc   ;==>Translate

Func UpdateStatus($status_text)
	GUICtrlSetData($status,Translate($status_text))
EndFunc






