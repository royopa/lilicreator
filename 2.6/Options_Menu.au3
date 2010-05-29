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
$main_menu = GUICreate("LinuxLive USB Creator", 401, 436, 389, 407)
$Tabs = GUICtrlCreateTab(8, 8, 385, 393)
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
$tab_general = GUICtrlCreateTabItem("General")
$logo = GUICtrlCreatePic(@ScriptDir & "\tools\img\logo.jpg", 32, 45, 344, 107)
$version = GUICtrlCreateLabel("LiLi : 2.5", 88, 196, 250, 25)
GUICtrlSetFont($version, 14)
$compat_version = GUICtrlCreateLabel("Compatibility List : 2.5.3", 88, 231, 250, 25)
GUICtrlSetFont($compat_version, 14)
$group_version = GUICtrlCreateGroup("Versions", 56, 160, 307, 123)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$donate = GUICtrlCreateButton("Make a donation", 32, 319, 153, 33, $WS_GROUP)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$contact = GUICtrlCreateButton("Contact me", 212, 319, 153, 33, $WS_GROUP)
GUICtrlSetFont(-1, 8, 400, 0, "Arial")
$copyright = GUICtrlCreateLabel("CopyLeft by Thibaut Lauzière - GPL v3 License",  24, 380, 360, 17)
GUICtrlSetStyle(-1,$SS_CENTER )

$tab_language = GUICtrlCreateTabItem("Language")
$language_list = GUICtrlCreateList("English", 80, 136, 180, 120)
GUICtrlSetData(-1, Available_Languages())
$label_languages = GUICtrlCreateLabel("Available languages", 32, 88, 323, 25)
GUICtrlSetFont($label_languages, 14)


$tab_proxy = GUICtrlCreateTabItem("Proxy")

$label_proxy_url = GUICtrlCreateLabel("Proxy URL", 46, 120, 87, 21)
GUICtrlSetFont($label_proxy_url, 11)
$proxy_url = GUICtrlCreateInput("", 130, 120, 225, 21)

$label_proxy_port = GUICtrlCreateLabel("Port", 46, 153, 71, 21)
GUICtrlSetFont($label_proxy_port, 11)
$proxy_port = GUICtrlCreateInput("", 130, 153, 49, 21)

$label_proxy_user = GUICtrlCreateLabel("Username", 46, 191, 84, 21)
GUICtrlSetFont($label_proxy_user, 11)
$proxy_username = GUICtrlCreateInput("", 130, 191, 160, 21)

$label_proxy_password = GUICtrlCreateLabel("Password", 46, 219, 82, 21)
GUICtrlSetFont($label_proxy_password, 11)
$proxy_password = GUICtrlCreateInput("", 130, 219, 160, 21)


$tab_updates = GUICtrlCreateTabItem("Updates")



$check_for_updates = GUICtrlCreateCheckbox("Check for updates", 56, 70, 297, 17)
GUICtrlSetFont($check_for_updates, 12)
$stable_only = GUICtrlCreateRadio("Stable releases only", 87, 115, 180, 17)
$update_release = GUICtrlCreateRadio("Stable and beta releases", 88, 146, 180, 17)
$Group1 = GUICtrlCreateGroup("", 72, 96, 220, 89)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState(-1, $GUI_HIDE)


$tab_options = GUICtrlCreateTabItem("Options")
$label_warning = GUICtrlCreateLabel("Do not modify these options unless you know what you are doing !",30, 43, 320, 30)
Display_Options()


$tab_help = GUICtrlCreateTabItem("Help")
GUICtrlCreateTabItem("")

$ok_button = GUICtrlCreateButton("OK", 304, 408, 81, 23, $WS_GROUP)
GUISetState(@SW_SHOW)



#EndRegion ### END Koda GUI section ###

While 1
$nMsg = GUIGetMsg()
Switch $nMsg
Case $GUI_EVENT_CLOSE
Exit

Case $ok_button
EndSwitch
WEnd

Func Available_Languages()
	Local $language_list="|English"

	; Shows the filenames of all files in the current directory.
	$search = FileFindFirstFile(@ScriptDir&"\tools\languages\*.ini")

	; Check if the search was successful
	If $search = -1 Then
		MsgBox(0, "Error", "No files/directories matched the search pattern")
		Exit
	EndIf

	While 1
		$file = FileFindNextFile($search)
		If @error Then ExitLoop
		$language_list&="|"&StringReplace($file,".ini","")
	WEnd
	;MsgBox(4096, "File:", $language_list)
	$language_list&="|"
	; Close the search handle
	FileClose($search)
	Return $language_list
EndFunc

Func Display_Options()

	$var = IniReadSection(@ScriptDir&"\tools\settings\settings.ini", "Advanced")
	If @error Then
		MsgBox(4096, "", "Error occurred, probably no INI file.")
	Else
		For $i = 1 To $var[0][0]
			GUICtrlCreateCheckbox($var[$i][0],100, 50+$i*23, 260, 17);=$var[$i][1]
			;MsgBox(4096, "", "Key: " & $var[$i][0] & @CRLF & "Value: " & $var[$i][1])
		Next
	EndIf
EndFunc
