#include-once

; #INDEX# ============================================================================================================
; Title .........: Toast
; AutoIt Version : 3.3.2.0 - uses AdlibRegister/Unregister
; Language ......: English
; Description ...: Show and hides slice messages from the systray in user defined colours and fonts
; Author(s) .....: Melba23.  Credit to GioVit (tray location)
; ====================================================================================================================

;#AutoIt3Wrapper_au3check_parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

; #INCLUDES# =========================================================================================================
;#include <StringSize.au3> => Below

; #GLOBAL VARIABLES# =================================================================================================
Global $iDef_Toast_Font_Size   = _Toast_GetDefFont(0)
Global $sDef_Toast_Font_Name   = _Toast_GetDefFont(1)

Global $hToast_Handle        = 0
Global $hToast_Close_X       = 9999
Global $iToast_Move          = 0
Global $iToast_Style         = 0 ; $SS_LEFT
Global $aRet = DllCall("User32.dll", "int", "GetSysColor", "int", 8) ; $COLOR_WINDOWTEXT = 8
Global $iToast_Header_BkCol  = $aRet[0]
$aRet = DllCall("User32.dll", "int", "GetSysColor", "int", 5) ; $COLOR_WINDOW = 5
Global $iToast_Header_Col    = $aRet[0]
Global $iToast_Header_Bold   = 0
Global $iToast_Message_BkCol = $iToast_Header_Col
Global $iToast_Message_Col   = $iToast_Header_BkCol
Global $iToast_Font_Size     = $iDef_Toast_Font_Size
Global $sToast_Font_Name     = $sDef_Toast_Font_Name
Global $iToast_Timer         = 0
Global $iToast_Start         = 0
Global $fToast_Close         = False

; #CURRENT# ==========================================================================================================
; _Toast_Set:  Sets text justification and optionally colours and font, for _Toast_Show function calls
; _Toast_Show: Shows a slice message from the systray
; _Toast_Hide: Hides a slice message from the systray
; ====================================================================================================================

; #INTERNAL_USE_ONLY#=================================================================================================
; _Toast_Locate:        Find Systray and determine Toast start position and movement direction
; _Toast_Timer_Check:   Checks whether Toast has timed out or closure [X] clicked
; _Toast_WM_EVENTS:     Message handler to check if closure [X] clicked
; _Toast_GetDefFont: Determine system default MsgBox font and size
; ====================================================================================================================

; #FUNCTION# =========================================================================================================
; Name...........: _Toast_Set
; Description ...: Sets text justification and optionally colours and font, for _Toast_Show function calls
; Syntax.........: _Toast_Set($vJust, [$iHdr_BkCol, [$iHdr_Col, [$iMsg_BkCol, [$iMsg_Col, [$sFont_Size, [$iFont_Name]]]]]])
; Parameters ....: $vJust     - 0 = Left justified, 1 = Centred (Default), 2 = Right justified
;                                Can use $SS_LEFT, $SS_CENTER, $SS_RIGHT
;                                + 4 = Header text in bold
;                       >>>>>    Setting this parameter to' Default' will reset ALL parameters to default values     <<<<<
;                       >>>>>    All optional parameters default to system MsgBox default values                     <<<<<
;                  $iHdr_BkCol - [Optional] The colour for the title bar background
;                  $iHdr_Col   - [Optional] The colour for the title bar text
;                  $iMsg_BkCol - [Optional] The colour for the message background
;                  $iMsg_Col   - [Optional] The colour for the message text
;                                Omitting a colour parameter or setting it to -1 leaves it unchanged
;                                Setting a colour parameter to Default resets the system colour
;                  $iFont_Size - [Optional] The font size in points to use for the Toast
;                  $sFont_Name - [Optional] The font to use for the Toast
;                       >>>>>    Omitting a font parameter, setting size to -1 or name to "" leaves it unchanged     <<<<<
;                       >>>>>    Setting a font parameter to Default resets the system message box font or size      <<<<<
; Requirement(s).: v3.3.2.0 or higher - AdlibRegister/Unregister used in _Toast_Show
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error to 1 with @extended set to parameter index number
; Author ........: Melba23
; Example........; Yes
;=====================================================================================================================

Func _Toast_Set($vJust, $iHdr_BkCol = -1, $iHdr_Col = -1, $iMsg_BkCol = -1, $iMsg_Col = -1, $iFont_Size = -1, $sFont_Name = "")

	; Set parameters
	Switch $vJust
		Case Default
			$iToast_Style         = 1; $SS_CENTER
			$aRet = DllCall("User32.dll", "int", "GetSysColor", "int", 8) ; $COLOR_WINDOWTEXT = 8
			$iToast_Header_BkCol  = $aRet[0]
			$aRet = DllCall("User32.dll", "int", "GetSysColor", "int", 5) ; $COLOR_WINDOW = 5
			$iToast_Header_Col    = $aRet[0]
			$iToast_Message_BkCol = $iToast_Header_Col
			$iToast_Message_Col   = $iToast_Header_BkCol
			$sToast_Font_Name     = $sDef_Toast_Font_Name
			$iToast_Font_Size     = $iDef_Toast_Font_Size
			Return
		Case 0, 1, 2, 4, 5, 6
			$iToast_Style = $vJust
		Case -1
			; Do nothing
		Case Else
			Return SetError(1, 1, 0)
	EndSwitch

	Switch $iHdr_BkCol
		Case Default
			$aRet = DllCall("User32.dll", "int", "GetSysColor", "int", 8) ; $COLOR_WINDOWTEXT = 8
			$iToast_Header_BkCol  = $aRet[0]
		Case 0 To 0xFFFFFF
			$iToast_Header_BkCol = Int($iHdr_BkCol)
        Case -1
			; Do nothing
		Case Else
			Return SetError(1, 2, 0)
	EndSwitch

	Switch $iHdr_Col
		Case Default
			$aRet = DllCall("User32.dll", "int", "GetSysColor", "int", 5) ; $COLOR_WINDOW = 5
			$iToast_Header_Col  = $aRet[0]
		Case 0 To 0xFFFFFF
			$iToast_Header_Col = Int($iHdr_Col)
        Case -1
			; Do nothing
		Case Else
			Return SetError(1, 3, 0)
	EndSwitch

	Switch $iMsg_BkCol
		Case Default
			$aRet = DllCall("User32.dll", "int", "GetSysColor", "int", 5) ; $COLOR_WINDOW = 5
			$iToast_Message_BkCol  = $aRet[0]
		Case 0 To 0xFFFFFF
			$iToast_Message_BkCol = Int($iMsg_BkCol)
        Case -1
			; Do nothing
		Case Else
			Return SetError(1, 4, 0)
	EndSwitch

	Switch $iMsg_Col
		Case Default
			$aRet = DllCall("User32.dll", "int", "GetSysColor", "int", 8) ; $COLOR_WINDOWTEXT = 8
			$iToast_Message_Col  = $aRet[0]
		Case 0 To 0xFFFFFF
			$iToast_Message_Col = Int($iMsg_Col)
        Case -1
			; Do nothing
		Case Else
			Return SetError(1, 5, 0)
	EndSwitch

	Switch $iFont_Size
		Case Default
			$iToast_Font_Size = $iDef_Toast_Font_Size
		Case 8 To 72
			$iToast_Font_Size = Int($iFont_Size)
        Case -1
			; Do nothing
		Case Else
			Return SetError(1, 6, 0)
	EndSwitch

	Switch $sFont_Name
		Case Default
			$sToast_Font_Name = $sDef_Toast_Font_Name
		Case ""
			; Do nothing
		Case Else
			If IsString($sFont_Name) Then
				$sToast_Font_Name = $sFont_Name
			Else
				Return SetError(1, 7, 0)
			EndIf
	EndSwitch

	Return 1

EndFunc ; => _Toast_Set

; #FUNCTION# =========================================================================================================
; Name...........: _Toast_Show
; Description ...: Shows a slice message from the systray
; Syntax.........: _Toast_Show($vIcon, $sTitle, $sMessage, [$iDelay [, $fWait [, $fRaw]]])
; Parameters ....: $vIcon    - 0 - No icon, 8 - UAC, 16 - Stop, 32 - Query, 48 - Exclamation, 64 - Information
;                              The $MB_ICON constant can also be used for the last 4 above
;                              If set to the name of an exe, the main icon of that exe will be displayed
;                              Any other value returns -1, error 1
;                  $sTitle   - Text to display on Title bar
;                  $sMessage - Text to display in Toast body
;                  $iDelay   - The delay in seconds before the Toast retracts or script continues (Default = 0)
;                              If negative, an [X] is added to the title bar. Clicking [X] retracts/continues immediately
;                  $fWait    - True  - Script waits for delay time before continuing and Toast remains visible
;                              False - Script continues and Toast retracts automatically after delay time
;                  $fRaw     - True  - Message is not wrapped and Toast expands to show full width
;                            - False - Message is wrapped if over max preset Toast width
; Requirement(s).: v3.3.1.5 or higher - AdlibRegister/Unregister used in _Toast_Show
; Return values .: Success: Returns 2-element array: [Toast width, Toast height]
;                  Failure:	Returns -1 and sets @error as follows:
;                           1 = Toast GUI creation failed
;                           2 = Taskbar not found
;                           4 = When using Raw, the Toast is too wide for the display
;                           3 = StringSize error
; Author ........: Melba23, based on some original code by GioVit for the Toast
; Notes .........; Any visible Toast is retracted by a subsequent _Toast_Hide or _Toast_Show, or clicking a visible [X]
; Example........; Yes
;=====================================================================================================================

Func _Toast_Show($vIcon, $sTitle, $sMessage, $iDelay = 0, $fWait = True, $fRaw = False)

	; Store current GUI mode and set Message mode
	Local $nOldOpt = Opt('GUIOnEventMode', 0)

	; Retract any Toast already in place
	If $hToast_Handle <> 0 Then _Toast_Hide()

	; Reset non-reacting Close [X] ControlID
	$hToast_Close_X = 9999

	; Set default auto-sizing Toast widths
	Local $iToast_Width_max = 500
	Local $iToast_Width_min = 300

	; Check for icon
	Local $iIcon_Style = 0
	Local $iIcon_Reduction = 50
	Local $sDLL = "user32.dll"
	If StringIsDigit($vIcon) Then
		Switch $vIcon
			Case 0
				$iIcon_Reduction = 0
			Case 8
				$sDLL = "imageres.dll"
				$iIcon_Style = 78
			Case 16 ; Stop
				$iIcon_Style = -4
			Case 32 ; Query
				$iIcon_Style = -3
			Case 48 ; Exclam
				$iIcon_Style = -2
			Case 64 ; Info
				$iIcon_Style = -5
			Case Else
				$nOldOpt = Opt('GUIOnEventMode', $nOldOpt)
				Return SetError(1, 0, -1)
		EndSwitch
	Else
		$sDLL = $vIcon
		$iIcon_Style = 0
	EndIf

	; Determine max message width
	Local $iMax_Label_Width = $iToast_Width_max - 20 - $iIcon_Reduction
	If $fRaw = True Then $iMax_Label_Width = 0

	; Get message label size
	Local $aLabel_Pos = _StringSize($sMessage, $iToast_Font_Size, Default, Default, $sToast_Font_Name, $iMax_Label_Width)
	If @error Then
		$nOldOpt = Opt('GUIOnEventMode', $nOldOpt)
		Return SetError(3, 0, -1)
	EndIf

	; Reset text to match rectangle
	$sMessage = $aLabel_Pos[0]

	;Set line height for this font
	Local $iLine_Height = $aLabel_Pos[1]

	; Set label size
	Local $iLabelwidth  = $aLabel_Pos[2]
	Local $iLabelheight = $aLabel_Pos[3]

	; Set Toast size
	Local $iToast_Width = $iLabelwidth + 20 + $iIcon_Reduction
	; Check if Toast will fit on screen
	If $iToast_Width > @DesktopWidth - 20 Then
		$nOldOpt = Opt('GUIOnEventMode', $nOldOpt)
		Return SetError(4, 0, -1)
	EndIf
	; Increase if below min size
	If $iToast_Width < $iToast_Width_min + $iIcon_Reduction Then
		$iToast_Width = $iToast_Width_min + $iIcon_Reduction
		$iLabelwidth  = $iToast_Width_min - 20
	EndIf

	; Set title bar height - with minimum for [X]
	Local $iTitle_Height = 0
	If $sTitle = "" Then
		If $iDelay < 0 Then $iTitle_Height = 6
	Else
		$iTitle_Height = $iLine_Height + 2
		If $iDelay < 0 Then
			If $iTitle_Height < 17 Then $iTitle_Height = 17
		EndIf
	EndIf

	; Set Toast height as label height + title bar + bottom margin
	Local $iToast_Height = $iLabelheight + $iTitle_Height + 20
	; Ensure enough room for icon if displayed
	If $iIcon_Reduction Then
		If $iToast_Height < $iTitle_Height + 42 Then $iToast_Height = $iTitle_Height + 47
	EndIf

	; Get Toast starting position and direction
	Local $aToast_Data = _Toast_Locate($iToast_Width, $iToast_Height)

	; Create Toast slice with $WS_POPUPWINDOW, $WS_EX_TOOLWINDOW style and $WS_EX_TOPMOST extended style
	$hToast_Handle = GUICreate("", $iToast_Width, $iToast_Height, $aToast_Data[0], $aToast_Data[1], 0x80880000, BitOr(0x00000080, 0x00000008))
	If @error Then
		$nOldOpt = Opt('GUIOnEventMode', $nOldOpt)
		Return SetError(1, 0, -1)
	EndIf
		GUISetFont($iToast_Font_Size, Default, Default, $sToast_Font_Name)
		GUISetBkColor($iToast_Message_BkCol)

	; Set centring parameter
	Local $iLabel_Style = 0 ; $SS_LEFT
	If BitAND($iToast_Style, 1) = 1 Then
		$iLabel_Style = 1 ; $SS_CENTER
	ElseIf BitAND($iToast_Style, 2) = 2 Then
		$iLabel_Style = 2 ; $SS_RIGHT
	EndIf

	; Check installed fonts
	Local $sX_Font = "WingDings"
	Local $sX_Char = "x"
	Local $i = 1
	While 1
		Local $sInstalled_Font = RegEnumVal("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts", $i)
		If @error Then ExitLoop
		If StringInStr($sInstalled_Font, "WingDings 2") Then
			$sX_Font = "WingDings 2"
			$sX_Char = "T"
		EndIf
		$i += 1
	WEnd

	; Create title bar if required
	If $sTitle <> "" Then

		; Create disabled background strip
		GUICtrlCreateLabel("", 0, 0, $iToast_Width, $iTitle_Height)
			GUICtrlSetBkColor(-1, $iToast_Header_BkCol)
			GUICtrlSetState(-1, 128) ; $GUI_DISABLE

		; Set title bar width to offset text
		Local $iTitle_Width = $iToast_Width - 10

		; Create closure [X] if needed
		If $iDelay < 0 Then
			; Create [X]
			Local $iX_YCoord = Int(($iTitle_Height - 17) / 2)
			$hToast_Close_X = GUICtrlCreateLabel($sX_Char, $iToast_Width - 18, $iX_YCoord, 17, 17)
				GUICtrlSetFont(-1, 14, Default, Default, $sX_Font)
				GUICtrlSetBkColor(-1, -2) ; $GUI_BKCOLOR_TRANSPARENT
				GUICtrlSetColor(-1, $iToast_Header_Col)
			; Reduce title bar width to allow [X] to activate
			$iTitle_Width -= 18
		EndIf

		; Create Title label with bold text, centred vertically in case bar is higher than line
		GUICtrlCreateLabel($sTitle, 10, 0, $iTitle_Width, $iTitle_Height, 0x0200) ; $SS_CENTERIMAGE
			GUICtrlSetBkColor(-1,$iToast_Header_BkCol)
			GUICtrlSetColor(-1, $iToast_Header_Col)
			If BitAND($iToast_Style, 4) = 4 Then GUICtrlSetFont(-1, $iToast_Font_Size, 600)

	Else

		If $iDelay < 0 Then
			; Only need [X]
			$hToast_Close_X = GUICtrlCreateLabel($sX_Char, $iToast_Width - 18, 0, 17, 17)
				GUICtrlSetFont(-1, 14, Default, Default, $sX_Font)
				GUICtrlSetBkColor(-1, -2) ; $GUI_BKCOLOR_TRANSPARENT
				GUICtrlSetColor(-1, $iToast_Message_Col)
		EndIf

	EndIf

	; Create icon
	If $iIcon_Reduction Then GUICtrlCreateIcon($sDLL, $iIcon_Style, 10, 10 + $iTitle_Height)

	; Create Message label
	$toast_label = GUICtrlCreateLabel($sMessage, 10 + $iIcon_Reduction, 10 + $iTitle_Height, $iLabelwidth, $iLabelheight)
		GUICtrlSetStyle(-1, $iLabel_Style)
		If $iToast_Message_Col <> Default Then GUICtrlSetColor(-1, $iToast_Message_Col)

	; Slide Toast Slice into view from behind systray and activate
	DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $hToast_Handle, "int", 1000, "long", $aToast_Data[2])

	; Activate Toast without stealing focus
	GUISetState(@SW_SHOWNOACTIVATE, $hToast_Handle)

	; If script is to pause
	If $fWait = True Then

		; Begin timeout counter
		Local $iTimeout_Begin = TimerInit()

		; Wait for timeout or closure
		While 1
			If GUIGetMsg() = $hToast_Close_X Or TimerDiff($iTimeout_Begin) / 1000 >= Abs($iDelay) Then ExitLoop
		WEnd

	; If script is to continue and delay has been set
	ElseIf Abs($iDelay) > 0 Then

		; Store timer info
		$iToast_Timer = Abs($iDelay * 1000)
		$iToast_Start = TimerInit()

		; Register Adlib function to run timer
		AdlibRegister("_Toast_Timer_Check", 100)
		; Register message handler to check for [X] click
		GUIRegisterMsg(0x0021, "_Toast_WM_EVENTS") ; $WM_MOUSEACTIVATE

	EndIf

	; Reset original mode
	$nOldOpt = Opt('GUIOnEventMode', $nOldOpt)

	; Create array to return Toast dimensions
	Local $aToast_Data[3] = [$iToast_Width, $iToast_Height, $iLine_Height]

	Return $aToast_Data

EndFunc ; => _Toast_Show

; #FUNCTION# ========================================================================================================
; Name...........: _Toast_Hide
; Description ...: Hides a slice message from the systray
; Syntax.........: _Toast_Hide()
; Requirement(s).: v3.3.1.5 or higher - AdlibRegister used in _Toast_Show
; Return values .: Success: Returns 0
;                  Failure:	If Toast does not exist returns -1 and sets @error to 1
; Author ........: Melba23
; Example........; Yes
;=====================================================================================================================

Func _Toast_Hide()

	; If no Toast to hide, return
	If $hToast_Handle = 0 Then Return SetError(1, 0, -1)

	; Slide Toast back behind systray
	DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $hToast_Handle, "int", 500, "long", $iToast_Move)

	; Delete Toast slice
	GUIDelete($hToast_Handle)

	; Set flag for "no Toast"
	$hToast_Handle = 0

EndFunc ; => _Toast_Hide


; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Toast_Locate
; Description ...: Find Systray and determine Toast start position and movement direction
; Syntax ........: _Toast_Locate($iToast_Width, $iToast_Height)
; Parameters ....: $iToast_Width  - required width of slice
;                  $iToast_Height - required height of slice
; Author ........: Melba23, based on some original code by GioVit
; Modified.......:
; Remarks .......: This function is used internally by _Toast_Show
; ===============================================================================================================================
Func _Toast_Locate($iToast_Width, $iToast_Height)

	; Define return array
	Local $aToast_Data[3]

	; Find systray
	Local $iPrevMode = Opt("WinTitleMatchMode", 4)
    Local $aTray_Pos = WinGetPos("[CLASS:Shell_TrayWnd]")
    Opt("WinTitleMatchMode", $iPrevMode)

	; If error in finding systray
	If Not IsArray($aTray_Pos) Then Return SetError(2, 0, -1)

	; Determine direction of Toast motion and starting position
	If $aTray_Pos[1] > 0 Then
        $iToast_Move = 0x00050004 ; $AW_SLIDE_OUT_BOTTOM
        $aToast_Data[0] = @DesktopWidth - $iToast_Width - 10
        $aToast_Data[1] = $aTray_Pos[1] - $iToast_Height
		$aToast_Data[2] = 0x00040008 ; $AW_SLIDE_IN_BOTTOM
    Elseif $aTray_Pos[0] > 0 Then
        $iToast_Move = 0x00050001 ; $AW_SLIDE_OUT_RIGHT
        $aToast_Data[0] = $aTray_Pos[0] - $iToast_Width
        $aToast_Data[1] = @DesktopHeight - $iToast_Height - 10
		$aToast_Data[2] = 0x00040002 ; $AW_SLIDE_IN_RIGHT
    ElseIf $aTray_Pos[2] = @DesktopWidth Then
        $iToast_Move = 0x00050008 ; $AW_SLIDE_OUT_TOP
        $aToast_Data[0] = @DesktopWidth - $iToast_Width - 10
        $aToast_Data[1] = $aTray_Pos[1] + $aTray_Pos[3]
		$aToast_Data[2] = 0x00040004 ; $AW_SLIDE_IN_TOP
    ElseIf $aTray_Pos[3] = @DesktopHeight Then
        $iToast_Move = 0x00050002 ; $AW_SLIDE_OUT_LEFT
        $aToast_Data[0] = $aTray_Pos[0] + $aTray_Pos[2]
        $aToast_Data[1] = @DesktopHeight - $iToast_Height - 10
		$aToast_Data[2] = 0x00040001 ; $AW_SLIDE_IN_LEFT
    EndIf

	Return $aToast_Data

EndFunc ; => _Toast_Locate

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Toast_Timer_Check
; Description ...: Checks whether Toast has timed out or closure [X] clicked
; Syntax ........: _Toast_Locate($iToast_Width, $iToast_Height)
; Author ........: Melba23
; Modified.......:
; Remarks .......: This function is used internally by _Toast_Show if the Wait parameter is set to False
; ===============================================================================================================================
Func _Toast_Timer_Check()

	; Return if timeout not elapsed and [X] not clicked
	If TimerDiff($iToast_Start) < $iToast_Timer And $fToast_Close = False Then Return

	; Unregister message handler
	GUIRegisterMsg(0x0021, "") ; $WM_MOUSEACTIVATE
	; Unregister this function
	AdlibUnRegister("_Toast_Timer_Check")
	; Reset flag
	$fToast_Close = False
	; Retract slice
	_Toast_Hide()

EndFunc; => _Toast_Timer_Check

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Toast_WM_EVENTS
; Description ...: Message handler to check if closure [X] clicked
; Author ........: Melba23
; Modified.......:
; Remarks .......: This function is used internally by _Toast_Show if the Wait parameter is set to False
; ===============================================================================================================================
Func _Toast_WM_EVENTS($hWnd, $Msg, $wParam, $lParam)

	#forceref $wParam, $lParam
    If $hWnd = $hToast_Handle Then
		If $Msg = 0x0021 Then ; $WM_MOUSEACTIVATE
			; Check mouse position
            Local $aPos = GUIGetCursorInfo($hToast_Handle)
            If $aPos[4] = $hToast_Close_X Then $fToast_Close = True
		EndIf
    EndIf
    Return 'GUI_RUNDEFMSG'

EndFunc; => _Toast_WM_EVENTS

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Toast_GetDefFont
; Description ...: Determine system default MsgBox font and size
; Syntax ........: _Toast_GetDefFont($iData)
; Parameters ....: $iData - 0 = Font point size, 1 = Font name
; Author ........: Melba23
; Modified.......:
; Remarks .......: This function is used internally by _Toast functions
; ===============================================================================================================================
Func _Toast_GetDefFont($iData)

	; Get default system font data
	Local $tNONCLIENTMETRICS = DllStructCreate("uint;int;int;int;int;int;byte[60];int;int;byte[60];int;int;byte[60];byte[60];byte[60]")
	DLLStructSetData($tNONCLIENTMETRICS, 1, DllStructGetSize($tNONCLIENTMETRICS))
	DLLCall("user32.dll", "int", "SystemParametersInfo", "int", 41, "int", DllStructGetSize($tNONCLIENTMETRICS), "ptr", DllStructGetPtr($tNONCLIENTMETRICS), "int", 0)
	; Read font data for MsgBox font
	Local $tLOGFONT = DllStructCreate("long;long;long;long;long;byte;byte;byte;byte;byte;byte;byte;byte;char[32]", DLLStructGetPtr($tNONCLIENTMETRICS, 15))
	Switch $iData
		Case 0
			; Font size as integer
			Return Int((Abs(DllStructGetData($tLOGFONT, 1)) + 1) * .75)
		Case 1
			; Font name
			Return DllStructGetData($tLOGFONT, 14)
	EndSwitch

EndFunc ;=>_Toast_GetDefFont

#include-once

; #INDEX# ============================================================================================================
; Title .........: _StringSize
; AutoIt Version : v3.2.12.1 or higher
; Language ......: English
; Description ...: Returns size of rectangle required to display string - maximum width can be chosen
; Remarks .......:
; Note ..........:
; Author(s) .....:  Melba23 - thanks to trancexx for the default DC code
; ====================================================================================================================

;#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

; #CURRENT# ==========================================================================================================
; _StringSize: Returns size of rectangle required to display string - maximum width can be chosen
; ====================================================================================================================

; #INTERNAL_USE_ONLY#=================================================================================================
; _StringSize_Error_Close: Releases DC and deletes font object after error
; _StringSize_DefaultFontName: Determines Windows default font
; ====================================================================================================================

; #FUNCTION# =========================================================================================================
; Name...........: _StringSize
; Description ...: Returns size of rectangle required to display string - maximum permitted width can be chosen
; Syntax ........: _StringSize($sText[, $iSize[, $iWeight[, $iAttrib[, $sName[, $iWidth[, $hWnd]]]]]])
; Parameters ....: $sText   - String to display
;                  $iSize   - [optional] Font size in points - (default = 8.5)
;                  $iWeight - [optional] Font weight - (default = 400 = normal)
;                  $iAttrib - [optional] Font attribute (0-Normal (default), 2-Italic, 4-Underline, 8 Strike)
;                             + 1 if tabs are to be expanded before sizing
;                  $sName   - [optional] Font name - (default = Tahoma)
;                  $iWidth  - [optional] Max width for rectangle - (default = 0 => width of original string)
;                  $hWnd    - [optional] GUI in which string will be displayed - (default 0 => normally not required)
; Requirement(s) : v3.2.12.1 or higher
; Return values .: Success - Returns 4-element array: ($iWidth set // $iWidth not set)
;                  |$array[0] = String reformatted with additonal @CRLF // Original string
;                  |$array[1] = Height of single line in selected font // idem
;                  |$array[2] = Width of rectangle required for reformatted // original string
;                  |$array[3] = Height of rectangle required for reformatted // original string
;                  Failure - Returns 0 and sets @error:
;                  |1 - Incorrect parameter type (@extended = parameter index)
;                  |2 - DLL call error - extended set as follows:
;                       |1 - GetDC failure
;                       |2 - SendMessage failure
;                       |3 - GetDeviceCaps failure
;                       |4 - CreateFont failure
;                       |5 - SelectObject failure
;                       |6 - GetTextExtentPoint32 failure
;                  |3 - Font too large for chosen max width - a word will not fit
; Author ........: Melba23 - thanks to trancexx for the default DC code
; Modified ......:
; Remarks .......: The use of the $hWnd parameter is not normally necessary - it is only required if the UDF does not
;                   return correct dimensions without it.
; Related .......:
; Link ..........:
; Example .......: Yes
;=====================================================================================================================
Func _StringSize($sText, $iSize = 8.5, $iWeight = 400, $iAttrib = 0, $sName = "", $iMaxWidth = 0, $hWnd = 0)

	; Set parameters passed as Default
	If $iSize = Default Then $iSize = 8.5
	If $iWeight = Default Then $iWeight = 400
	If $iAttrib = Default Then $iAttrib = 0
	If $sName = "" Or $sName = Default Then	$sName = _StringSize_DefaultFontName()

	; Check parameters are correct type
	If Not IsString($sText) Then Return SetError(1, 1, 0)
	If Not IsNumber($iSize) Then Return SetError(1, 2, 0)
	If Not IsInt($iWeight) Then Return SetError(1, 3, 0)
	If Not IsInt($iAttrib) Then Return SetError(1, 4, 0)
	If Not IsString($sName) Then Return SetError(1, 5, 0)
	If Not IsNumber($iMaxWidth) Then Return SetError(1, 6, 0)
	If Not IsHwnd($hWnd) And $hWnd <> 0 Then Return SetError(1, 7, 0)

	Local $aRet, $hDC, $hFont, $hLabel = 0, $hLabel_Handle

	; Check for tab expansion flag
	Local $iExpTab = BitAnd($iAttrib, 1)
	; Remove possible tab expansion flag from font attribute value
	$iAttrib = BitAnd($iAttrib, BitNot(1))

	; If GUI handle was passed
	If IsHWnd($hWnd) Then
		; Create label outside GUI borders
		$hLabel = GUICtrlCreateLabel("", -10, -10, 10, 10)
		$hLabel_Handle = GUICtrlGetHandle(-1)
		GUICtrlSetFont(-1, $iSize, $iWeight, $iAttrib, $sName)
		; Create DC
		$aRet = DllCall("user32.dll", "handle", "GetDC", "hwnd", $hLabel_Handle)
		If @error Or $aRet[0] = 0 Then
			GUICtrlDelete($hLabel)
			Return SetError(2, 1, 0)
		EndIf
		$hDC = $aRet[0]
		$aRet = DllCall("user32.dll", "lparam", "SendMessage", "hwnd", $hLabel_Handle, "int", 0x0031, "wparam", 0, "lparam", 0) ; $WM_GetFont
		If @error Or $aRet[0] = 0 Then
			GUICtrlDelete($hLabel)
			Return SetError(2, _StringSize_Error_Close(2, $hDC), 0)
		EndIf
		$hFont = $aRet[0]
	Else
		; Get default DC
		$aRet = DllCall("user32.dll", "handle", "GetDC", "hwnd", $hWnd)
		If @error Or $aRet[0] = 0 Then Return SetError(2, 1, 0)
		$hDC = $aRet[0]
		; Create required font
		$aRet = DllCall("gdi32.dll", "int", "GetDeviceCaps", "handle", $hDC, "int", 90) ; $LOGPIXELSY
		If @error Or $aRet[0] = 0 Then Return SetError(2, _StringSize_Error_Close(3, $hDC), 0)
		Local $iInfo = $aRet[0]
		$aRet = DllCall("gdi32.dll", "handle", "CreateFontW", "int", -$iInfo * $iSize / 72, "int", 0, "int", 0, "int", 0, _
			"int", $iWeight, "dword", BitAND($iAttrib, 2), "dword", BitAND($iAttrib, 4), "dword", BitAND($iAttrib, 8), "dword", 0, "dword", 0, _
			"dword", 0, "dword", 5, "dword", 0, "wstr", $sName)
		If @error Or $aRet[0] = 0 Then Return SetError(2, _StringSize_Error_Close(4, $hDC), 0)
		$hFont = $aRet[0]
	EndIf

	; Select font and store previous font
	$aRet = DllCall("gdi32.dll", "handle", "SelectObject", "handle", $hDC, "handle", $hFont)
	If @error Or $aRet[0] = 0 Then Return SetError(2, _StringSize_Error_Close(5, $hDC, $hFont, $hLabel), 0)
	Local $hPrevFont = $aRet[0]

	; Declare variables
    Local $avSize_Info[4], $iLine_Length, $iLine_Height = 0, $iLine_Count = 0, $iLine_Width = 0, $iWrap_Count, $iLast_Word, $sTest_Line
	; Declare and fill Size structure
	Local $tSize = DllStructCreate("int X;int Y")
	DllStructSetData($tSize, "X", 0)
	DllStructSetData($tSize, "Y", 0)

	; Ensure EoL is @CRLF and break text into lines
	$sText = StringRegExpReplace($sText, "((?<!\x0d)\x0a|\x0d(?!\x0a))", @CRLF)
	Local $asLines = StringSplit($sText, @CRLF, 1)

	; For each line
	For $i = 1 To $asLines[0]
		; Expand tabs if required
		If $iExpTab Then
			$asLines[$i] = StringReplace($asLines[$i], @TAB, " XXXXXXXX")
		EndIf
		; Size line
		$iLine_Length = StringLen($asLines[$i])
		DllCall("gdi32.dll", "bool", "GetTextExtentPoint32W", "handle", $hDC, "wstr", $asLines[$i], "int", $iLine_Length, "ptr", DllStructGetPtr($tSize))
		If @error Then Return SetError(2, _StringSize_Error_Close(6, $hDC, $hFont, $hLabel), 0)
		If DllStructGetData($tSize, "X") > $iLine_Width Then $iLine_Width = DllStructGetData($tSize, "X")
		If DllStructGetData($tSize, "Y") > $iLine_Height Then $iLine_Height = DllStructGetData($tSize, "Y")
	Next

	; Check if $iMaxWidth has been both set and exceeded
	If $iMaxWidth <> 0 And $iLine_Width > $iMaxWidth Then ; Wrapping required
		; For each Line
		For $j = 1 To $asLines[0]
			; Size line unwrapped
			$iLine_Length = StringLen($asLines[$j])
			DllCall("gdi32.dll", "bool", "GetTextExtentPoint32W", "handle", $hDC, "wstr", $asLines[$j], "int", $iLine_Length, "ptr", DllStructGetPtr($tSize))
			If @error Then Return SetError(2, _StringSize_Error_Close(6, $hDC, $hFont, $hLabel), 0)
			; Check wrap status
			If DllStructGetData($tSize, "X") < $iMaxWidth - 4 Then
				; No wrap needed so count line and store
				$iLine_Count += 1
				$avSize_Info[0] &= $asLines[$j] & @CRLF
			Else
				; Wrap needed so zero counter for wrapped lines
				$iWrap_Count = 0
				; Build line to max width
				While 1
					; Zero line width
					$iLine_Width = 0
					; Initialise pointer for end of word
					$iLast_Word = 0
					; Add characters until EOL or maximum width reached
					For $i = 1 To StringLen($asLines[$j])
						; Is this just past a word ending?
						If StringMid($asLines[$j], $i, 1) = " " Then $iLast_Word = $i - 1
						; Increase line by one character
						$sTest_Line = StringMid($asLines[$j], 1, $i)
						; Get line length
						$iLine_Length = StringLen($sTest_Line)
						DllCall("gdi32.dll", "bool", "GetTextExtentPoint32W", "handle", $hDC, "wstr", $sTest_Line, "int", $iLine_Length, "ptr", DllStructGetPtr($tSize))
						If @error Then Return SetError(2, _StringSize_Error_Close(6, $hDC, $hFont, $hLabel), 0)
						$iLine_Width = DllStructGetData($tSize, "X")
						; If too long exit the loop
						If $iLine_Width >= $iMaxWidth - 4 Then ExitLoop
					Next
					; End of the line of text?
					If $i > StringLen($asLines[$j]) Then
						; Yes, so add final line to count
						$iWrap_Count += 1
						; Store line
						$avSize_Info[0] &= $sTest_Line & @CRLF
						ExitLoop
					Else
						; No, but add line just completed to count
						$iWrap_Count += 1
						; Check at least 1 word completed or return error
						If $iLast_Word = 0 Then Return SetError(3, _StringSize_Error_Close(0, $hDC, $hFont, $hLabel), 0)
						; Store line up to end of last word
						$avSize_Info[0] &= StringLeft($sTest_Line, $iLast_Word) & @CRLF
						; Strip string to point reached
						$asLines[$j] = StringTrimLeft($asLines[$j], $iLast_Word)
						; Trim leading whitespace
						$asLines[$j] = StringStripWS($asLines[$j], 1)
						; Repeat with remaining characters in line
					EndIf
				WEnd
				; Add the number of wrapped lines to the count
				$iLine_Count += $iWrap_Count
			EndIf
		Next
		; Reset any tab expansions
		If $iExpTab Then
			$avSize_Info[0] = StringRegExpReplace($avSize_Info[0], "\x20?XXXXXXXX", @TAB)
		EndIf
		; Complete return array
		$avSize_Info[1] = $iLine_Height
		$avSize_Info[2] = $iMaxWidth
		; Convert lines to pixels and add drop margin
		$avSize_Info[3] = ($iLine_Count * $iLine_Height) + 4
	Else ; No wrapping required
		; Create return array (add drop margin to height)
		Local $avSize_Info[4] = [$sText, $iLine_Height, $iLine_Width, ($asLines[0] * $iLine_Height) + 4]
	EndIf

	; Clear up
    DllCall("gdi32.dll", "handle", "SelectObject", "handle", $hDC, "handle", $hPrevFont)
	DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $hFont)
	DllCall("user32.dll", "int", "ReleaseDC", "hwnd", 0, "handle", $hDC)
	If $hLabel Then GUICtrlDelete($hLabel)

	Return $avSize_Info

EndFunc ;==>_StringSize

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _StringSize_Error_Close
; Description ...: Releases DC and deleted font object if required after error
; Syntax ........: _StringSize_Error_Close ($iExtCode, $hDC, $hGUI)
; Parameters ....: $iExtCode   - code to return
;                  $hDC, $hGUI - handles as set in _StringSize function
; Return value ..: $iExtCode as passed
; Author ........: Melba23
; Modified.......:
; Remarks .......: This function is used internally by _StringSize
; ===============================================================================================================================
Func _StringSize_Error_Close($iExtCode, $hDC = 0, $hFont = 0, $hLabel = 0)

	If $hFont <> 0 Then DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $hFont)
	If $hDC <> 0 Then DllCall("user32.dll", "int", "ReleaseDC", "hwnd", 0, "handle", $hDC)
	If $hLabel Then GUICtrlDelete($hLabel)

	Return $iExtCode

EndFunc ;=>_StringSize_Error_Close

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _StringSize_DefaultFontName
; Description ...: Determines Windows default font
; Syntax ........: _StringSize_DefaultFontName()
; Parameters ....: None
; Return values .: Success - Returns name of system default font
;                  Failure - Returns "Tahoma"
; Author ........: Melba23, based on some original code by Larrydalooza
; Modified.......:
; Remarks .......: This function is used internally by _StringSize
; ===============================================================================================================================
Func _StringSize_DefaultFontName()

	; Get default system font data
	Local $tNONCLIENTMETRICS = DllStructCreate("uint;int;int;int;int;int;byte[60];int;int;byte[60];int;int;byte[60];byte[60];byte[60]")
	DLLStructSetData($tNONCLIENTMETRICS, 1, DllStructGetSize($tNONCLIENTMETRICS))
	DLLCall("user32.dll", "int", "SystemParametersInfo", "int", 41, "int", DllStructGetSize($tNONCLIENTMETRICS), "ptr", DllStructGetPtr($tNONCLIENTMETRICS), "int", 0)
	Local $tLOGFONT = DllStructCreate("long;long;long;long;long;byte;byte;byte;byte;byte;byte;byte;byte;char[32]", DLLStructGetPtr($tNONCLIENTMETRICS, 13))
	If IsString(DllStructGetData($tLOGFONT, 14)) Then
		Return DllStructGetData($tLOGFONT, 14)
	Else
		Return "Tahoma"
	EndIf

EndFunc ;=>_StringSize_DefaultFontName
