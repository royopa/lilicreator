#include <GDIPlus.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <SliderConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Constants.au3>

#Include <Array.au3>
#include <GUIComboBox.au3>
#Include <File.au3>
#include <GuiEdit.au3>
#Include <Date.au3>
Global $AC_SRC_ALPHA=1
Opt("GUIOnEventMode", 1)
_GDIPlus_Startup()

$PNG_GUI = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\BACK_DL.png")
	$EXIT_NORM = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\close.PNG")
	$EXIT_OVER = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\close_hover.PNG")
		$MIN_NORM = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\min.PNG")
	$MIN_OVER = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\min_hover.PNG")
$GUI = GUICreate("LiLi USB Creator", 363, 105, -1, -1, $WS_POPUP, $WS_EX_LAYERED)

SetBitmap($GUI, $PNG_GUI, 255)
GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")
GUISetState(@SW_SHOW, $GUI)

; Old offset was 18
$LAYERED_GUI_CORRECTION = GetVertOffset($GUI)
$CONTROL_GUI = GUICreate("CONTROL_GUI", 363, 105, 0, $LAYERED_GUI_CORRECTION, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD), $GUI)

GUISetBkColor(0x121314)
_WinAPI_SetLayeredWindowAttributes($CONTROL_GUI, 0x121314)
GUISetState(@SW_SHOW, $CONTROL_GUI)





Dim $linux_user_select, $linux_releases, $linux_release, $linux_filename, $linux_real_size, $linux_size, $linux_need_download, $linux_user_select_file, $linux_path, $linux_no_selection, $linux_choice
Dim $fk_user_select, $fk_releases, $fk_release, $fk_filename, $fk_real_size, $fk_size, $fk_need_download, $fk_user_select_file, $fk_path, $fk_no_selection, $fk_choice
Dim $destination, $download_size, $download_completed, $download_aborted
Global $fk_releases, $linux_releases, $start_process_time, $archive_files_number, $archive_files_count
$lang="en"

$linux_ini="linux.ini"


	Global Const $R_CODE = 0,$R_NAME=1,$R_DISTRIBUTION=2, $R_VERSION_NUMBER=3,$R_FILENAME=4,$R_FILE_MD5=5,$R_RELEASE_DATE=6,$R_WEB=7,$R_DOWNLOAD_PAGE=8,$R_DOWNLOAD_SIZE=9,$R_INSTALL_SIZE=10,$R_DESCRIPTION=11
	Global Const $R_MIRROR1=12,$R_MIRROR2=13,$R_MIRROR3=14,$R_MIRROR4=15,$R_MIRROR5=16,$R_MIRROR6=17,$R_MIRROR7=18,$R_MIRROR8=19,$R_MIRROR9=20,$R_MIRROR10=21
	Global $CONTROL_GUI, $CloseGUI



$ZEROGraphic = _GDIPlus_GraphicsCreateFromHWND($CONTROL_GUI)
GUISetOnEvent($GUI_EVENT_CLOSE, "CloseGUI")

$CloseGUI = GUICtrlCreateLabel("", 300, 0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent($CloseGUI, "CloseGUI")
$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 300, 0, 20, 20)

$MinimizeGUI = GUICtrlCreateLabel("", 260, 0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent($MinimizeGUI, "MinimizeGUI")
$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 260, 0, 20, 20)

$LinuxCombo = GUICtrlCreateCombo("->", 20, 0, 200,-1,3)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetOnEvent($LinuxCombo, "LinuxComboChange")
$LinuxDetailsBtn = GUICtrlCreateButton("Détails", 100, 20 , 65, 25, 0)
GUICtrlSetOnEvent($LinuxDetailsBtn, "LinuxDetailsBtnClick")

GUISetState(@SW_SHOW)

LinuxSetData()
LinuxComboChange()
AdlibEnable ( "Control_Hover",100 ) 
While 1
sleep(60000)
WEnd

Func Control_Hover()
    Local $CursorCtrl = GUIGetCursorInfo($CONTROL_GUI)
	if WinActive("CONTROL_GUI") OR WinActive("LiLi USB Creator")  Then

		Switch $CursorCtrl[4]
			case $CloseGUI
				$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_OVER, 0, 0, 20, 20, 300, 0, 20, 20)
			case $MinimizeGUI
				$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_OVER, 0, 0, 20, 20, 260, 0, 20, 20)
			case else
					$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 260, 0, 20, 20)
					$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 300, 0, 20, 20)
		EndSwitch
		
		#cs
		If $CursorCtrl[4] =  $CloseGUI Then
			
		ElseIf $CursorCtrl[4] <> $CloseGUI Then
			$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 300, 0, 20, 20)
		EndIf
		#ce
	EndIf
EndFunc

Func LinuxSetData()
	$linux_releases = GetReleasesData($linux_ini)
	If $linux_releases=False Then Return False
	$options="|"
	for $i=1 To UBound($linux_releases)-1
		$options&=$linux_releases[$i][$R_DESCRIPTION] & "|"
	Next
	; bring an option for user to select himself is package on disk
	$options&="::Choisir moi même le fichier::|"
	$linux_user_select=$i
	; bring an option for user to select no package
	$i=$i+1
	$options&="Pas de GNU/Linux"
	$linux_no_selection=$i
	GUICtrlSetData($LinuxCombo, $options, $linux_releases[1][$R_DESCRIPTION])
EndFunc

Func ShowDetails($release)
	#Region --- CodeWizard generated code Start ---
;MsgBox features: Title=Yes, Text=Yes, Buttons=OK and Cancel, Icon=Info
if IsArray($release)=false Then Return
If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
$iMsgBoxAnswer = MsgBox(65,$release[0],"Fichier :" & $release[3] & @CRLF & "Taille Téléchargement :" & $release[4] & @CRLF & "Description :" & $release[6] & @CRLF & "Site web :" & $release[2] & @CRLF & @CRLF & "Cliquez sur OK pour voir le site.")
Select
	Case $iMsgBoxAnswer = 1 ;OK
		ShellExecute($release[2])
	Case $iMsgBoxAnswer = 2 ;Cancel

EndSelect
#EndRegion --- CodeWizard generated code End ---

EndFunc



Func GetReleasesData($file)
	$sections = IniReadSectionNames($file)
	If (Not IsArray($sections)) Or (Not FileExists($file)) Then
		MsgBox(32,"","Le fichier de releases "&$file&" est introuvable ou vide.")
		$abort=True
		return false
	EndIf
	
	Global $data[$sections[0]+1][30]
	For $i=1 to $sections[0]
		$data[$i][$R_CODE]=$sections[$i]
		$data[$i][$R_NAME]=IniGetValue($file, $sections[$i], "Name")
		$data[$i][$R_DISTRIBUTION]=IniGetValue($file, $sections[$i], "Distribution")
		$data[$i][$R_VERSION_NUMBER]=IniGetValue($file, $sections[$i], "Version_Number")
		$data[$i][$R_FILENAME]=IniGetValue($file, $sections[$i], "Filename")
		$data[$i][$R_FILE_MD5]=IniGetValue($file, $sections[$i], "File_MD5")
		$data[$i][$R_RELEASE_DATE]=IniGetValue($file, $sections[$i], "Release_Date")
		$data[$i][$R_WEB]=IniGetValue($file, $sections[$i], "Web")
		$data[$i][$R_DOWNLOAD_PAGE]=IniGetValue($file, $sections[$i], "Download_page")
		$data[$i][$R_DOWNLOAD_SIZE]=IniGetValue($file, $sections[$i], "Donwload_Size")
		$data[$i][$R_INSTALL_SIZE]=IniGetValue($file, $sections[$i], "Install_Size")
		$data[$i][$R_DESCRIPTION]=IniGetValue($file, $sections[$i], "Description")
		$data[$i][$R_MIRROR1]=IniGetValue($file, $sections[$i], "Mirror1")
		$data[$i][$R_MIRROR2]=IniGetValue($file, $sections[$i], "Mirror2")
		$data[$i][$R_MIRROR3]=IniGetValue($file, $sections[$i], "Mirror3")
		$data[$i][$R_MIRROR4]=IniGetValue($file, $sections[$i], "Mirror4")
		$data[$i][$R_MIRROR5]=IniGetValue($file, $sections[$i], "Mirror5")
		$data[$i][$R_MIRROR6]=IniGetValue($file, $sections[$i], "Mirror6")
		$data[$i][$R_MIRROR7]=IniGetValue($file, $sections[$i], "Mirror7")
		$data[$i][$R_MIRROR8]=IniGetValue($file, $sections[$i], "Mirror8")
		$data[$i][$R_MIRROR9]=IniGetValue($file, $sections[$i], "Mirror9")
		$data[$i][$R_MIRROR10]=IniGetValue($file, $sections[$i], "Mirror10")
	Next
	Return $data
EndFunc

Func DisplayRelease($i)
		Global $data
		Msgbox(4096,"Release Details" ,  "Name : " & $data[$i][$R_NAME]  & @CRLF  _
		& "Distribution : " & $data[$i][$R_DISTRIBUTION] & @CRLF  _
		& "Version : " & $data[$i][$R_VERSION_NUMBER] & @CRLF  _
		& "Filename : " & $data[$i][$R_FILENAME] & @CRLF  _
		& "MD5 : " & $data[$i][$R_FILE_MD5] & @CRLF  _
		& "Release Date : " & $data[$i][$R_RELEASE_DATE] & @CRLF  _
		& "WebSite : " & $data[$i][$R_WEB] & @CRLF  _
		& "Download Page : " & $data[$i][$R_DOWNLOAD_PAGE] & @CRLF _
		& "Download Size : " & $data[$i][$R_DOWNLOAD_SIZE] & @CRLF _
		& "Installed Size : " & $data[$i][$R_INSTALL_SIZE] & @CRLF  _
		& "Description : " & $data[$i][$R_DESCRIPTION] & @CRLF  _
		& "Mirror 1 " & $data[$i][$R_MIRROR1] & @CRLF  _
		& "Name : " & $data[$i][$R_MIRROR2] & @CRLF  _
		& "Name : " & $data[$i][$R_MIRROR3] & @CRLF  _
		& "Name : " & $data[$i][$R_MIRROR4] & @CRLF  _
		& "Name : " & $data[$i][$R_MIRROR5] & @CRLF  _
		& "Name : " & $data[$i][$R_MIRROR6] & @CRLF  _
		& "Name : " & $data[$i][$R_MIRROR7] & @CRLF  _
		& "Name : " & $data[$i][$R_MIRROR8] & @CRLF  _
		& "Name : " & $data[$i][$R_MIRROR9] & @CRLF  _
		& "Name : " & $data[$i][$R_MIRROR10])
EndFunc


;Func GetReleaseData($releases, $selected)
	;dim $data[$release_item_nb]
	;_ArrayDisplay($releases,$releases[$selected][3])
	;For $i=0 to ($release_item_nb-1)
		;$data[$i]=$releases[$selected][$i]
	;Next
	;return $data
;EndFunc

Func LinuxComboChange()
		$selected_index=_GUICtrlComboBox_GetCurSel($LinuxCombo)+1
		Return $selected_index
EndFunc

Func LinuxDetailsBtnClick()
	DisplayRelease( _GUICtrlComboBox_GetCurSel($LinuxCombo)+1) 
EndFunc

Func IniGetValue($file, $key, $value, $default = "ValueNotFound")
	$r = IniRead($file, $key, $value & "_" & $lang, $default)
	If $r <> $default Then Return $r ; we return the value in specific language
	Return IniRead($file, $key, $value, $default) ; else we return the value in generic language
EndFunc   ;==>ScriptGetValue

Func MinimizeGUI()
	GUISetState(@SW_MINIMIZE,$GUI) 
EndFunc

Func CloseGUI()
 Exit
EndFunc

Func ControlHover($hWnd, $CtrlID, ByRef $CurIsOnCtrlArr)
    Local $CursorCtrl = GUIGetCursorInfo($hWnd)
    ReDim $CurIsOnCtrlArr[UBound($CurIsOnCtrlArr)+1]
    If $CursorCtrl[4] = $CtrlID Then
        $EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_OVER, 0, 0, 20, 20, 300, 0, 20, 20)
    ElseIf $CursorCtrl[4] <> $CtrlID Then
        $EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 300, 0, 20, 20)
    EndIf
EndFunc




; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Graphical Part                                ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func GetVertOffset($hgui)
;Const $SM_CYCAPTION = 4
    Const $SM_CXFIXEDFRAME = 7
    Local $wtitle, $wclient, $wsize,$wside,$ans
    $wclient = WinGetClientSize($hgui)
    $wsize = WinGetPos($hgui)
    $wtitle = DllCall('user32.dll', 'int', 'GetSystemMetrics', 'int', $SM_CYCAPTION)
    $wside = DllCall('user32.dll', 'int', 'GetSystemMetrics', 'int', $SM_CXFIXEDFRAME)
    $ans = $wsize[3] - $wclient[1] - $wtitle[0] - 2 * $wside[0] +25
    Return $ans
EndFunc  ;==>GetVertOffset

Func WM_NCHITTEST($hWnd, $iMsg, $iwParam, $ilParam)
	If ($hWnd = $GUI) And ($iMsg = $WM_NCHITTEST) Then Return $HTCAPTION
EndFunc   ;==>WM_NCHITTEST

Func SetBitmap($hGUI, $hImage, $iOpacity)
	Local $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend

	$hScrDC = _WinAPI_GetDC(0)
	$hMemDC = _WinAPI_CreateCompatibleDC($hScrDC)
	$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
	$hOld = _WinAPI_SelectObject($hMemDC, $hBitmap)
	$tSize = DllStructCreate($tagSIZE)
	$pSize = DllStructGetPtr($tSize)
	DllStructSetData($tSize, "X", _GDIPlus_ImageGetWidth($hImage))
	DllStructSetData($tSize, "Y", _GDIPlus_ImageGetHeight($hImage))
	$tSource = DllStructCreate($tagPOINT)
	$pSource = DllStructGetPtr($tSource)
	$tBlend = DllStructCreate($tagBLENDFUNCTION)
	$pBlend = DllStructGetPtr($tBlend)
	DllStructSetData($tBlend, "Alpha", $iOpacity)
	DllStructSetData($tBlend, "Format", $AC_SRC_ALPHA)
	_WinAPI_UpdateLayeredWindow($hGUI, $hScrDC, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, $ULW_ALPHA)
	_WinAPI_ReleaseDC(0, $hScrDC)
	_WinAPI_SelectObject($hMemDC, $hOld)
	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_DeleteDC($hMemDC)
EndFunc   ;==>SetBitmap



Global Const $LWA_ALPHA = 0x2
Global Const $LWA_COLORKEY = 0x1

;############# EndExample #########

;===============================================================================
;
; Function Name: _WinAPI_SetLayeredWindowAttributes
; Description:: Sets Layered Window Attributes:) See MSDN for more informaion
; Parameter(s):
; $hwnd - Handle of GUI to work on
; $i_transcolor - Transparent color
; $Transparency - Set Transparancy of GUI
; $isColorRef - If True, $i_transcolor is a COLORREF( 0x00bbggrr ), else an RGB-Color
; Requirement(s): Layered Windows
; Return Value(s): Success: 1
; Error: 0
; @error: 1 to 3 - Error from DllCall
; @error: 4 - Function did not succeed - use
; _WinAPI_GetLastErrorMessage or _WinAPI_GetLastError to get more information
; Author(s): Prog@ndy
;
; Link : @@MsdnLink@@ SetLayeredWindowAttributes
; Example : Yes
;===============================================================================
;
Func _WinAPI_SetLayeredWindowAttributes($hWnd, $i_transcolor, $Transparency = 255, $dwFlages = 0x03, $isColorRef = False)
	; #############################################
	; You are NOT ALLOWED to remove the following lines
	; Function Name: _WinAPI_SetLayeredWindowAttributes
	; Author(s): Prog@ndy
	; #############################################
	If $dwFlages = Default Or $dwFlages = "" Or $dwFlages < 0 Then $dwFlages = 0x03

	If Not $isColorRef Then
		$i_transcolor = Hex(String($i_transcolor), 6)
		$i_transcolor = Execute('0x00' & StringMid($i_transcolor, 5, 2) & StringMid($i_transcolor, 3, 2) & StringMid($i_transcolor, 1, 2))
	EndIf
	Local $Ret = DllCall("user32.dll", "int", "SetLayeredWindowAttributes", "hwnd", $hWnd, "long", $i_transcolor, "byte", $Transparency, "long", $dwFlages)
	Select
		Case @error
			Return SetError(@error, 0, 0)
		Case $Ret[0] = 0
			Return SetError(4, _WinAPI_GetLastError(), 0)
		Case Else
			Return 1
	EndSelect
EndFunc   ;==>_WinAPI_SetLayeredWindowAttributes

;===============================================================================
;
; Function Name: _WinAPI_GetLayeredWindowAttributes
; Description:: Gets Layered Window Attributes:) See MSDN for more informaion
; Parameter(s):
; $hwnd - Handle of GUI to work on
; $i_transcolor - Returns Transparent color ( dword as 0x00bbggrr or string "0xRRGGBB")
; $Transparency - Returns Transparancy of GUI
; $isColorRef - If True, $i_transcolor will be a COLORREF( 0x00bbggrr ), else an RGB-Color
; Requirement(s): Layered Windows
; Return Value(s): Success: Usage of LWA_ALPHA and LWA_COLORKEY (use BitAnd)
; Error: 0
; @error: 1 to 3 - Error from DllCall
; @error: 4 - Function did not succeed
; - use _WinAPI_GetLastErrorMessage or _WinAPI_GetLastError to get more information
; - @extended contains _WinAPI_GetLastError
; Author(s): Prog@ndy
;
; Link : @@MsdnLink@@ GetLayeredWindowAttributes
; Example : Yes
;===============================================================================
;
Func _WinAPI_GetLayeredWindowAttributes($hWnd, ByRef $i_transcolor, ByRef $Transparency, $asColorRef = False)
	; #############################################
	; You are NOT ALLOWED to remove the following lines
	; Function Name: _WinAPI_SetLayeredWindowAttributes
	; Author(s): Prog@ndy
	; #############################################
	$i_transcolor = -1
	$Transparency = -1
	Local $Ret = DllCall("user32.dll", "int", "GetLayeredWindowAttributes", "hwnd", $hWnd, "long*", $i_transcolor, "byte*", $Transparency, "long*", 0)
	Select
		Case @error
			Return SetError(@error, 0, 0)
		Case $Ret[0] = 0
			Return SetError(4, _WinAPI_GetLastError(), 0)
		Case Else
			If Not $asColorRef Then
				$Ret[2] = Hex(String($Ret[2]), 6)
				$Ret[2] = '0x' & StringMid($Ret[2], 5, 2) & StringMid($Ret[2], 3, 2) & StringMid($Ret[2], 1, 2)
			EndIf
			$i_transcolor = $Ret[2]
			$Transparency = $Ret[3]
			Return $Ret[4]
	EndSelect
EndFunc   ;==>_WinAPI_GetLayeredWindowAttributes