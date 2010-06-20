
#Region ### START Koda GUI section ### Form=Menu.kxf
;GUI_Options_Menu()

Global $proxy_status,$available_languages[50]

Global $check_for_updates,$stable_only,$all_release,$hTreeView,$treeview_items


Func GUI_Options_Menu()
	;WinSetState($CONTROL_GUI, "", @SW_DISABLE)


	Opt("GUIOnEventMode", 0)
	$main_menu = GUICreate("Options", 401, 436, -1, -1,-1, -1,$CONTROL_GUI)
	$Tabs = GUICtrlCreateTab(8, 8, 385, 393)
	GUICtrlSetResizing(-1, $GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
	$tab_general = GUICtrlCreateTabItem("General")
	$logo = GUICtrlCreatePic(@ScriptDir & "\tools\img\logo.jpg", 32, 45, 344, 107)
	$version = GUICtrlCreateLabel("LiLi : "&$software_version, 88, 196, 250, 25)
	GUICtrlSetFont($version, 14)
	$compat_version = GUICtrlCreateLabel("Compatibility List : "&IniRead($compatibility_ini, "Compatibility_List", "Version","none"), 88, 231, 250, 25)
	GUICtrlSetFont($compat_version, 14)
	$group_version = GUICtrlCreateGroup("Versions", 56, 160, 307, 123)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$donate = GUICtrlCreateButton("Make a donation", 32, 319, 153, 33, $WS_GROUP)
	$contact = GUICtrlCreateButton("Contact me", 212, 319, 153, 33, $WS_GROUP)
	$copyright = GUICtrlCreateLabel("CopyLeft by Thibaut Lauzière - ",  84, 380, 150, 17)
	$licence=GUICtrlCreateLabel("GPL v3 License", 232, 379, 360, 17)
	GUICtrlSetFont(-1,-1,-1,4)
	GUICtrlSetColor(-1,0x0000cc)
	GUICtrlSetCursor(-1,0)

	$tab_language = GUICtrlCreateTabItem("Language")
	$language_list = GUICtrlCreateList("English", 80, 136, 180, 200,$WS_BORDER+$WS_VSCROLL)
	GUICtrlSetData(-1, Available_Languages())

	$forced_lang=ReadSetting("General","force_lang")
	if $forced_lang="" Then
		_GUICtrlListBox_SelectString($language_list,"Automatic")
	Else
		_GUICtrlListBox_SelectString($language_list,$forced_lang)
	EndIf

	$label_languages = GUICtrlCreateLabel("Available languages", 32, 88, 323, 25)
	GUICtrlSetFont($label_languages, 14)


	$tab_proxy = GUICtrlCreateTabItem("Proxy")


	$group_proxy_settings = GUICtrlCreateGroup("Proxy settings", 24, 56, 353, 169)
	GUICtrlSetFont(-1, 10)
	$label_proxy_url = GUICtrlCreateLabel("Proxy URL", 42, 85, 87, 21, $WS_GROUP)

	$proxy_url = GUICtrlCreateInput(ReadSetting( "Proxy", "proxy_url"), 150, 85, 217, 22, $WS_GROUP)

	$label_proxy_port = GUICtrlCreateLabel("Port", 42, 118, 71, 21, $WS_GROUP)

	$proxy_port = GUICtrlCreateInput(ReadSetting( "Proxy", "proxy_port"), 150, 118, 49, 22, $WS_GROUP+$ES_NUMBER)

	$label_proxy_user = GUICtrlCreateLabel("Username", 42, 148, 84, 21, $WS_GROUP)

	$proxy_username = GUICtrlCreateInput(ReadSetting( "Proxy", "proxy_username"), 150, 148, 160, 22, $WS_GROUP)

	$label_proxy_password = GUICtrlCreateLabel("Password", 42, 184, 82, 21, $WS_GROUP)

	$proxy_password = GUICtrlCreateInput(ReadSetting( "Proxy", "proxy_password"), 150, 184, 160, 22, $WS_GROUP+$ES_PASSWORD)


	$group_status = GUICtrlCreateGroup("Status", 22, 263, 353, 65)
	GUICtrlSetFont(-1, 10)
	$test_proxy = GUICtrlCreateButton("Test settings", 204, 288, 161, 25, $WS_GROUP)
	$proxy_status = GUICtrlCreateLabel("Not tested yet", 32, 291, 164, 26,$WS_GROUP)
	GUICtrlSetColor($proxy_status,0x007f00)
	GUICtrlSetFont($proxy_status, 12)




	#cs
	$label_proxy_url = GUICtrlCreateLabel("Proxy URL", 46, 120, 87, 21)
	GUICtrlSetFont($label_proxy_url, 11)
	$proxy_url = GUICtrlCreateInput(IniRead($settings_ini, "Proxy", "proxy_url", ""), 130, 120, 225, 21)

	$label_proxy_port = GUICtrlCreateLabel("Port", 46, 153, 71, 21)
	GUICtrlSetFont($label_proxy_port, 11)
	$proxy_port = GUICtrlCreateInput(IniRead($settings_ini, "Proxy", "proxy_port", ""), 130, 153, 49, 21)

	$label_proxy_user = GUICtrlCreateLabel("Username", 46, 191, 84, 21)
	GUICtrlSetFont($label_proxy_user, 11)
	$proxy_username = GUICtrlCreateInput(IniRead($settings_ini, "Proxy", "proxy_username", ""), 130, 191, 160, 21)

	$label_proxy_password = GUICtrlCreateLabel("Password", 46, 219, 82, 21)
	GUICtrlSetFont($label_proxy_password, 11)
	$proxy_password = GUICtrlCreateInput(IniRead($settings_ini, "Proxy", "proxy_password", ""), 130, 219, 160, 21)
	$test_proxy = GUICtrlCreateButton("Test settings", 120, 264, 161, 25)
	#ce

	$tab_updates = GUICtrlCreateTabItem("Updates")
	$check_for_updates = GUICtrlCreateCheckbox("Check for updates", 56, 70, 297, 17)
	GUICtrlSetFont($check_for_updates, 12)
	$stable_only = GUICtrlCreateRadio("Stable releases only", 87, 115, 180, 17)
	$all_release = GUICtrlCreateRadio("Stable and beta releases", 88, 146, 180, 17)
	$group_updates = GUICtrlCreateGroup("", 72, 96, 220, 89)
	InitUpdateTab()


	$tab_options = GUICtrlCreateTabItem("Settings")
	$label_warning = GUICtrlCreateLabel("Do not modify these options unless you know what you are doing !",30, 43, 320, 30)
	GUICtrlSetColor($label_warning,0xAA0000)
	;Display_Options()
	;-------------------------

	$iStyle = BitOR($TVS_HASBUTTONS, $TVS_DISABLEDRAGDROP,$TVS_CHECKBOXES, $TVS_SHOWSELALWAYS)

	$hTreeView = GUICtrlCreateTreeView(16, 74, 369, 319,$iStyle)
	Populate_Treeview($hTreeView)



	;-----------------------

	;$tab_help = GUICtrlCreateTabItem("Help")
	;GUICtrlCreateTabItem("")

	;$tab_credits = GUICtrlCreateTabItem("Credits")
	;GUICtrlCreateTabItem("")

	$ok_button = GUICtrlCreateButton("OK", 304, 408, 81, 23, $WS_GROUP)


	GUISetState(@SW_SHOW, $main_menu)
	Check_Internet_Status()


	#EndRegion ### END Koda GUI section ###

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				WriteAdvancedSettings()
				GUIDelete($main_menu)
				ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
				;GUIRegisterMsg($WM_PAINT, "DrawAll")
				;WinActivate($for_winactivate)
				;GuiSetState($GUI_SHOW,$CONTROL_GUI)
				Opt("GUIOnEventMode", 1)
				Return ""
			Case $test_proxy
				Check_Internet_Status()
			Case $ok_button
				WriteAdvancedSettings()
				GUIDelete($main_menu)
				ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
				;GUIRegisterMsg($WM_PAINT, "DrawAll")
				;WinActivate($for_winactivate)
				;GuiSetState($GUI_SHOW,$CONTROL_GUI)
				Opt("GUIOnEventMode", 1)
				Return ""
			Case $language_list
				$language_selected=GUICtrlRead($language_list)
				if $language_selected="Automatic" OR StringInStr($language_selected,"—")>0 Then
					WriteSetting("General", "force_lang","")
				Else
					WriteSetting("General", "force_lang",$language_selected)
				EndIf
			Case $check_for_updates
				Checkbox_To_Setting($check_for_updates,"Updates","check_for_updates")
			Case $licence
				ShellExecute("http://www.linuxliveusb.com/licence")
			Case $all_release
				Checkbox_To_Setting($all_release,"Updates","check_for_beta_versions")
			Case $stable_only
				Checkbox_To_Setting_Reverse($stable_only,"Updates","check_for_beta_versions")
			Case $proxy_url
				WriteSetting("Proxy", "proxy_url",GUICtrlRead($proxy_url))
			Case $proxy_port
				WriteSetting("Proxy", "proxy_port",GUICtrlRead($proxy_port))
			Case $proxy_username
				WriteSetting("Proxy", "proxy_username",GUICtrlRead($proxy_username))
			Case $proxy_password
				WriteSetting("Proxy", "proxy_password",GUICtrlRead($proxy_password))
			Case $test_proxy
				; Apply proxy settings
				$proxy_url = ReadSetting( "Proxy", "proxy_url")
				$proxy_port = ReadSetting( "Proxy", "proxy_port")
				$proxy_username = ReadSetting( "Proxy", "proxy_username")
				$proxy_password = ReadSetting( "Proxy", "proxy_password")

				If $proxy_url <> "" AND  $proxy_port <> "" Then
					$proxy_url &= ":" & $proxy_port
					If $proxy_username <> "" Then
						If $proxy_password <> "" Then
							HttpSetProxy(2, $proxy_url, $proxy_username, $proxy_password)
						Else
							HttpSetProxy(2, $proxy_url, $proxy_username)
						EndIf
					Else
						HttpSetProxy(2, $proxy_url)
					EndIf
				Else
					HttpSetProxy(0)
				EndIf
				GUICtrlSetColor($proxy_status,0x007f00)
				GUICtrlSetData($proxy_status,"Testing")
				Check_Internet_Status()

		EndSwitch
	WEnd

EndFunc

Func WriteAdvancedSettings()
	for $i=1 To Ubound($treeview_items)-1
		$item_text = _GUICtrlTreeView_GetText($hTreeView,$treeview_items[$i])
		if $item_text<>"" Then
			If _GUICtrlTreeView_GetChecked($hTreeView, $treeview_items[$i]) Then
				WriteSetting("Advanced",$item_text,"yes")
			Else
				WriteSetting("Advanced",$item_text,"no")
			EndIf
		EndIf
	Next
EndFunc

Func Setting_To_Checkbox($checkbox,$setting_category,$setting_key)
	If ReadSetting($setting_category,$setting_key)="yes" Then
		GUICtrlSetState($checkbox,$GUI_CHECKED)
	Else
		GUICtrlSetState($checkbox,$GUI_UNCHECKED)
	EndIf
EndFunc

Func Setting_To_Checkbox_Reverse($checkbox,$setting_category,$setting_key)
	If ReadSetting($setting_category,$setting_key)="yes" Then
		GUICtrlSetState($checkbox,$GUI_UNCHECKED)
	Else
		GUICtrlSetState($checkbox,$GUI_CHECKED)
	EndIf
EndFunc

Func Checkbox_To_Setting($checkbox,$setting_category,$setting_key)
	If GUICtrlRead($checkbox)==$GUI_CHECKED Then
		WriteSetting( $setting_category,$setting_key , "yes")
	Else
		WriteSetting( $setting_category, $setting_key, "no")
	EndIf
EndFunc

Func Checkbox_To_Setting_Reverse($checkbox,$setting_category,$setting_key)
	If GUICtrlRead($checkbox)==$GUI_CHECKED Then
		WriteSetting( $setting_category,$setting_key , "no")
	Else
		WriteSetting( $setting_category, $setting_key, "yes")
	EndIf
EndFunc


Func Available_Languages()
	Local $language_list="|Automatic|————————————————————|English"
	$available_languages[0]="English"
	; Shows the filenames of all files in the current directory.
	$search = FileFindFirstFile(@ScriptDir&"\tools\languages\*.ini")

	; Check if the search was successful
	If $search = -1 Then
		MsgBox(0, "Error", "No files/directories matched the search pattern")
		Exit
	EndIf
	$i=1
	While 1
		$file = FileFindNextFile($search)
		If @error Then ExitLoop
		$language_list&="|"&StringReplace($file,".ini","")
		$available_languages[$i]=StringReplace($file,".ini","")
		$i+=1
	WEnd
	;MsgBox(4096, "File:", $language_list)
	;$language_list&="|"
	; Close the search handle
	FileClose($search)
	Return $language_list
EndFunc

Func InitUpdateTab()

	Setting_To_Checkbox($check_for_updates,"Updates", "check_for_updates")

	if (isBeta() OR ReadSetting( "Updates", "check_for_beta_versions") = "yes") Then
		GUICtrlSetState($all_release,$GUI_CHECKED)
	Else
		GUICtrlSetState($stable_only,$GUI_CHECKED)
	EndIf
EndFunc

Func Display_Options()

	$var = IniReadSection($settings_ini, "Advanced")
	If @error Then
		MsgBox(4096, "", "Error occurred, probably no INI file.")
	Else
		For $i = 1 To $var[0][0]
			$current_checkbox = GUICtrlCreateCheckbox($var[$i][0],100, 50+$i*23, 260, 17);=$var[$i][1]
			Setting_To_Checkbox($current_checkbox, "Advanced",$var[$i][0])
			;if ReadSetting( "Advanced", $var[$i][0])="yes" Then GUICtrlSetState(-1,$GUI_CHECKED)
			;MsgBox(4096, "", "Key: " & $var[$i][0] & @CRLF & "Value: " & $var[$i][1])
		Next
	EndIf
EndFunc

Func Populate_Treeview($htree)

	$var = IniReadSection($settings_ini, "Advanced")
	Global $treeview_items[$var[0][0]+1]
	If @error Then
		MsgBox(4096, "", "Error occurred, probably no INI file.")
	Else
		_GUICtrlTreeView_BeginUpdate($htree)
		For $i = 1 To $var[0][0]
			$treeview_items[$i] = _GUICtrlTreeView_Add($htree, 0,$var[$i][0])
			;Setting_To_Checkbox($current_item, "Advanced",$var[$i][0])
			if ReadSetting( "Advanced", $var[$i][0])="yes" Then _GUICtrlTreeView_SetChecked($htree,$treeview_items[$i],true)
		Next
		_GUICtrlTreeView_EndUpdate($htree)
	EndIf
EndFunc

Func Check_Internet_Status()
	if OnlineStatus()=1 Then
		GUICtrlSetColor($proxy_status,0x007f00)
		GUICtrlSetData($proxy_status,"You are connected")
	Else
		GUICtrlSetColor($proxy_status,0xAA0000)
		GUICtrlSetData($proxy_status,"You are disconnected")
	EndIf
EndFunc

Func OnlineStatus()
	$inet = InetGet("http://www.google.com", @TempDir & "\connectivity-test.tmp",3,0)
    If @error OR $inet=0 Then
		return 0
    Else
		return 1
    EndIf
EndFunc