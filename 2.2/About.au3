; Pour la transparence
Global Const $AC_SRC_ALPHA = 1

Func _About($Title, $MainLabel, $CopyRLabel, $VerLabel, $NameURL1, $URL1, $NameURL2, $URL2, $NameURL3, $URL3, $IconFile="", $LinkColor=0x0000FF, $BkColor=0xFFFFFF, $Left=-1, $Top=-1, $Style=-1, $ExStyle=-1, $Parent=0)
    Local $OldEventOpt = Opt("GUIOnEventMode", 0)

    Local $GUI, $LinkTop=120, $Msg
    Local $CurIsOnCtrlArr[1]

    Local $LinkVisitedColor[4] = [3, $LinkColor, $LinkColor, $LinkColor]
    Local $LinkLabel[4]

    WinSetState($Parent, "", @SW_DISABLE)

    If $ExStyle = -1 Then $ExStyle = ""
    $GUI = GUICreate($Title, 350, 240, $Left, $Top, $Style, 0x00000080+$ExStyle, $Parent)
    GUISetBkColor($BkColor)

    GUICtrlCreateLabel($MainLabel, 40, 20, 280, 25, 1)
    GUICtrlSetFont(-1, 16)

    GUICtrlCreateIcon($IconFile, 0, 10, 20)

    GUICtrlCreateGraphic(5, 75, 310, 3, $SS_ETCHEDFRAME)

    For $i = 1 To 3
        $LinkLabel[$i] = GUICtrlCreateLabel(Eval("NameURL" & $i), 150, $LinkTop, 200, 20, 1)
        GUICtrlSetCursor(-1, 0)
        GUICtrlSetColor(-1, $LinkColor)
        GUICtrlSetFont(-1, 9, 400, 0)
        $LinkTop += 30
    Next

    GUICtrlCreateLabel(Translate("Version")&": " & @LF & $VerLabel, 10, 130, 150, 35, 1)
    GUICtrlSetFont(-1, 10, 600, 0, "Tahoma")

    GUICtrlCreateLabel($CopyRLabel, 0, 220, 320, -1, 1)

    GUISetState(@SW_SHOW, $GUI)

    While 1
        $Msg = GUIGetMsg()
        If $Msg = -3 Then ExitLoop
        For $i = 1 To 3
            If $Msg = $LinkLabel[$i] Then
                $LinkVisitedColor[$i] = 0xAC00A9
                GUICtrlSetColor($LinkLabel[$i], $LinkVisitedColor[$i])
					ShellExecute(Eval("URL" & $i))
		   EndIf
        Next
        If WinActive($GUI) Then
            For $i = 1 To 3
                ControlHover($GUI, $LinkLabel[$i], $i, $CurIsOnCtrlArr, 0xFF0000, $LinkVisitedColor[$i])
            Next
        EndIf
    WEnd
    WinSetState($Parent, "", @SW_ENABLE)
    GUIDelete($GUI)
	Opt("GUIOnEventMode", 1)
	GUIRegisterMsg($WM_PAINT, "DrawAll")
	WinActivate($for_winactivate)
	GuiSetState($GUI_SHOW,$CONTROL_GUI)

EndFunc

Func ControlHover($hWnd, $CtrlID, $CtrlNum, ByRef $CurIsOnCtrlArr, $HoverColor=0xFF0000, $LinkColor=0x0000FF)
    Local $CursorCtrl = GUIGetCursorInfo($hWnd)
    ReDim $CurIsOnCtrlArr[UBound($CurIsOnCtrlArr)+1]
    If $CursorCtrl[4] = $CtrlID And $CurIsOnCtrlArr[$CtrlNum] = 1 Then
        GUICtrlSetFont($CtrlID, 9, 400, 6)
        GUICtrlSetColor($CtrlID, $HoverColor)
        $CurIsOnCtrlArr[$CtrlNum] = 0
    ElseIf $CursorCtrl[4] <> $CtrlID And $CurIsOnCtrlArr[$CtrlNum] = 0 Then
        GUICtrlSetFont($CtrlID, 9, 400, 0)
        GUICtrlSetColor($CtrlID, $LinkColor)
        $CurIsOnCtrlArr[$CtrlNum] = 1
    EndIf
EndFunc
