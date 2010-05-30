#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <GuiTreeView.au3>
#include <GuiImageList.au3>
#include <Array.au3>

#Region ### START Koda GUI section ### Form=Menu.kxf
;GUI_Options_Menu()

Global $proxy_status,$available_languages[50]

Global $check_for_updates,$stable_only,$all_release

Func GUI_Options_Menu()

	Opt("GUIOnEventMode", 0)

	$main_menu = GUICreate("LinuxLive USB Creator >> Options", 401, 436, 389, 407)
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
	$language_list = GUICtrlCreateList("English", 80, 136, 180, 120)
	GUICtrlSetData(-1, Available_Languages())

	 _GUICtrlListBox_SelectString($language_list,$lang)
	$label_languages = GUICtrlCreateLabel("Available languages", 32, 88, 323, 25)
	GUICtrlSetFont($label_languages, 14)


	$tab_proxy = GUICtrlCreateTabItem("Proxy")


	$group_proxy_settings = GUICtrlCreateGroup("Proxy settings", 24, 56, 353, 169)
	GUICtrlSetFont(-1, 10)
	$label_proxy_url = GUICtrlCreateLabel("Proxy URL", 42, 85, 87, 21, $WS_GROUP)

	$proxy_url = GUICtrlCreateInput("", 150, 85, 217, 22, $WS_GROUP)

	$label_proxy_port = GUICtrlCreateLabel("Port", 42, 118, 71, 21, $WS_GROUP)

	$proxy_port = GUICtrlCreateInput("", 150, 118, 49, 22, $WS_GROUP)

	$label_proxy_user = GUICtrlCreateLabel("Username", 42, 148, 84, 21, $WS_GROUP)

	$proxy_username = GUICtrlCreateInput("", 150, 148, 160, 22, $WS_GROUP)

	$label_proxy_password = GUICtrlCreateLabel("Password", 42, 184, 82, 21, $WS_GROUP)

	$proxy_password = GUICtrlCreateInput("", 150, 184, 160, 22, $WS_GROUP)


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

	$hTreeView = GUICtrlCreateTreeView(16, 74, 369, 319,$iStyle,$WS_EX_CLIENTEDGE)
	Populate_Treeview($hTreeView)


	;-----------------------

	$tab_help = GUICtrlCreateTabItem("Help")
	GUICtrlCreateTabItem("")

	$tab_credits = GUICtrlCreateTabItem("Credits")
	GUICtrlCreateTabItem("")

	$ok_button = GUICtrlCreateButton("OK", 304, 408, 81, 23, $WS_GROUP)


	GUISetState()
	Check_Internet_Status()


	#EndRegion ### END Koda GUI section ###

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUIDelete($main_menu)
				Opt("GUIOnEventMode", 1)
				GUIRegisterMsg($WM_PAINT, "DrawAll")
				WinActivate($for_winactivate)
				GuiSetState($GUI_SHOW,$CONTROL_GUI)
				Return ""
			Case $test_proxy
				Check_Internet_Status()
			Case $ok_button
				Return ""
			Case $language_list
					IniWrite($settings_ini, "General", "force_lang", GUICtrlRead($language_list))
			Case $check_for_updates
				If GUICtrlRead($check_for_updates)==$GUI_CHECKED Then
					IniWrite($settings_ini, "Updates", "check_for_updates", "yes")
				Else
					IniWrite($settings_ini, "Updates", "check_for_updates", "no")
				EndIf
			Case $licence
				MsgBox(0,"mlkml","lkmlk")
				ShellExecute("http://www.linuxliveusb.com/licence")
			Case $all_release OR $stable_only
				If GUICtrlRead($stable_only)==$GUI_CHECKED Then
					IniWrite($settings_ini, "Updates", "check_for_beta_versions", "no")
				Else
					IniWrite($settings_ini, "Updates", "check_for_beta_versions", "yes")
				EndIf

		EndSwitch
	WEnd



EndFunc

Func Available_Languages()
	Local $language_list="|English"
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
	$language_list&="|"
	; Close the search handle
	FileClose($search)
	Return $language_list
EndFunc

Func InitUpdateTab()
	if IniRead($settings_ini, "Updates", "check_for_updates", "yes") = "no" Then
		GUICtrlSetState($check_for_updates,$GUI_UNCHECKED)
	Else
		GUICtrlSetState($check_for_updates,$GUI_CHECKED)
	EndIf

	if (isBeta() OR IniRead($settings_ini, "Updates", "check_for_beta_versions", "no") = "yes") Then
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
			GUICtrlCreateCheckbox($var[$i][0],100, 50+$i*23, 260, 17);=$var[$i][1]
			if IniRead($settings_ini, "Advanced", $var[$i][0], "no")="yes" Then GUICtrlSetState(-1,$GUI_CHECKED)
			;MsgBox(4096, "", "Key: " & $var[$i][0] & @CRLF & "Value: " & $var[$i][1])
		Next
	EndIf
EndFunc

Func Populate_Treeview($htree)

	$var = IniReadSection($settings_ini, "Advanced")
	If @error Then
		MsgBox(4096, "", "Error occurred, probably no INI file.")
	Else
		_GUICtrlTreeView_BeginUpdate($htree)
		For $i = 1 To $var[0][0]
			_GUICtrlTreeView_Add($htree, 0,$var[$i][0])
			if IniRead($settings_ini, "Advanced", $var[$i][0], "no")="yes" Then GUICtrlSetState(-1,$GUI_CHECKED)
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
	$ping = Ping("www.google.com")
    If $ping Then
		return 1
    Else
		return 0
    EndIf
EndFunc
