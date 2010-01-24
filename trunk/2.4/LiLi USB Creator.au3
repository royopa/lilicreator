#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=tools\img\lili.ico
#AutoIt3Wrapper_Compression=3
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=Enjoy !
#AutoIt3Wrapper_Res_Description=Easily create a Linux Live USB
#AutoIt3Wrapper_Res_Fileversion=2.3.88.28
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y
#AutoIt3Wrapper_Res_LegalCopyright=CopyLeft Thibaut Lauziere a.k.a Slÿm
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_Field=AutoIt Version|%AutoItVer%
#AutoIt3Wrapper_Res_Field=Site|http://www.linuxliveusb.com
#AutoIt3Wrapper_Au3Check_Parameters=-w 4
#AutoIt3Wrapper_Run_After=upx.exe --best --compress-resources=0 "%out%"
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; Author           : Thibaut Lauzière (Slÿm)
; Author's Website : www.slym.fr
; e-Mail           : contact@linuxliveusb.com
; License          : GPL v3.0
; Version          : 2.3
; Download         : http://www.linuxliveusb.com
; Support          : http://www.linuxliveusb.com/bugs/
; Compiled with    : AutoIT v3.3.0.0


; Global constants
Global Const $software_version = "2.3"
Global $lang_ini = @ScriptDir & "\tools\languages\"
Global Const $settings_ini = @ScriptDir & "\tools\settings\settings.ini"
Global Const $compatibility_ini = @ScriptDir & "\tools\settings\compatibility_list.ini"
Global Const $blacklist_ini = @ScriptDir & "\tools\settings\black_list.ini"
Global Const $log_dir = @ScriptDir & "\logs\"
Global Const $check_updates_url = "http://www.linuxliveusb.com/updates/"

Global $lang, $anonymous_id,$logfile
Global $downloaded_virtualbox_filename

; Global variables used for the onEvent Functions
; Globals images and GDI+ elements
Global $GUI, $CONTROL_GUI, $EXIT_BUTTON, $MIN_BUTTON, $DRAW_REFRESH, $DRAW_ISO, $DRAW_CD, $DRAW_DOWNLOAD, $DRAW_BACK, $DRAW_BACK_HOVER, $DRAW_LAUNCH, $HELP_STEP1, $HELP_STEP2, $HELP_STEP3, $HELP_STEP4, $HELP_STEP5, $label_iso, $label_cd, $label_download, $label_step2_status, $download_label2, $OR_label, $live_mode_only_label,$builtin_persistence_label, $virtualbox
Global $ZEROGraphic, $EXIT_NORM, $EXIT_OVER, $MIN_NORM, $MIN_OVER, $PNG_GUI, $CD_PNG, $CD_HOVER_PNG, $ISO_PNG, $ISO_HOVER_PNG, $DOWNLOAD_PNG, $DOWNLOAD_HOVER_PNG, $BACK_PNG, $BACK_HOVER_PNG, $LAUNCH_PNG, $LAUNCH_HOVER_PNG, $HELP, $BAD, $GOOD, $WARNING, $BACK_AREA
Global $step2_display_menu = 0, $cleaner, $cleaner2
Global $combo_linux, $download_manual, $download_auto, $slider, $slider_visual
Global $best_mirror, $iso_size, $filename, $progress_bar, $label_step2_status
Global $MD5_ISO = "", $compatible_md5, $compatible_filename, $release_number = -1, $files_in_source, $prefetched_linux_list,$recommended_ram = 256
Global $foo
Global $for_winactivate

; $step2_display_menu = 0 when displaying default menu, 1 when displaying download menu, 2 when displaying checking.

; Setting up all global vars and local vars
Global $combo
Global $selected_drive, $virtualbox_check, $virtualbox_size
Global $STEP1_OK, $STEP2_OK, $STEP3_OK
Global $DRAW_CHECK_STEP1, $DRAW_CHECK_STEP2, $DRAW_CHECK_STEP3
Global $MD5_ISO, $version_in_file
Global $variante

$selected_drive = "->"
$file_set = 0;
$file_set_mode = "none"
$annuler = 0
$combo_updated = 0

$STEP1_OK = 0
$STEP2_OK = 0
$STEP3_OK = 0

$MD5_ISO = "none"
$version_in_file = "none"


Opt("GUIOnEventMode", 1)

; Checking if Tools folder exists (contains tools and settings)
If DirGetSize(@ScriptDir & "\tools\", 2) <> -1 Then
	If Not FileExists($lang_ini) Then
		MsgBox(48, "ERROR", "Language file not found !!!")
		Exit
	EndIf

	If Not FileExists($settings_ini) Then
		MsgBox(48, "ERROR", "Settings file not found !!!")
		Exit
	Else
		; Generate an unique ID for anonymous crash reports and stats
		If IniRead($settings_ini, "General", "unique_ID", "none") = "none" Or IniRead($settings_ini, "General", "unique_ID", "none") = "" Then
			$anonymous_id = RegRead("HKEY_CURRENT_USER\SOFTWARE\LinuxLive\", "AnonymousID")
			If $anonymous_id = "" Then
				$anonymous_id = Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1))
				RegWrite("HKEY_CURRENT_USER\SOFTWARE\LinuxLive\", "AnonymousID", "REG_SZ", $anonymous_id)
				IniWrite($settings_ini, "General", "unique_ID", $anonymous_id)
			Else

				IniWrite($settings_ini, "General", "unique_ID", $anonymous_id)
			EndIf
		Else
			$anonymous_id = IniRead($settings_ini, "General", "unique_ID", "none")
		EndIf
	EndIf
Else
	MsgBox(48, "ERROR", "Please put the 'tools' directory back")
	Exit
EndIf



#include <GuiConstants.au3>
#include <GuiConstantsEx.au3>
#include <GuiListView.au3>
#include <GuiImageList.au3>
#include <WinApi.au3>
#include <GDIPlus.au3>
#include <Constants.au3>
#include <ProgressConstants.au3>
#include <ComboConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <Array.au3>
#include <String.au3>
#include <File.au3>
#include <INet.au3>
#include <IE.au3>
#include <WinHTTP.au3>

; LiLi's components
#include <About.au3>
#include <Automatic_Bug_Report.au3>
#include <Ressources.au3>
#include <Graphics.au3>
#include <md5.au3>
#include <Releases.au3>
#include <LiLis_heart.au3>

; Apply proxy settings
If IniRead($settings_ini, "General", "proxy_url", "none") <> "none" And IniRead($settings_ini, "General", "proxy_url", "none") <> "" Then
	$proxy_url = IniRead($settings_ini, "General", "proxy_url", "none")
	If IniRead($settings_ini, "General", "proxy_port", "none") <> "none" And IniRead($settings_ini, "General", "proxy_port", "none") <> "" Then $proxy_url &= ":" & IniRead($settings_ini, "General", "proxy_port", "none")
	If IniRead($settings_ini, "General", "proxy_username", "none") <> "none" And IniRead($settings_ini, "General", "proxy_username", "none") <> "" Then
		$proxy_username = IniRead($settings_ini, "General", "proxy_username", "none")
		If IniRead($settings_ini, "General", "proxy_password", "none") <> "none" And IniRead($settings_ini, "General", "proxy_password", "none") <> "" Then
			$proxy_password = IniRead($settings_ini, "General", "proxy_password", "none")
			HttpSetProxy(2, $proxy_url, $proxy_username, $proxy_password)
		Else
			HttpSetProxy(2, $proxy_url, $proxy_username)
		EndIf
	Else
		HttpSetProxy(2, $proxy_url)
	EndIf
EndIf

; Initializing log file for verbose logging
If IniRead($settings_ini, "General", "verbose_logging", "no") = "yes" Then InitLog()

SendReport("Starting LiLi USB Creator " & $software_version)

; initialize list of compatible releases (load the compatibility_list.ini)
Get_Compatibility_List()

_GDIPlus_Startup()

; Loading PNG Files
$EXIT_NORM = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\close.PNG")
$EXIT_OVER = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\close_hover.PNG")
$MIN_NORM = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\min.PNG")
$MIN_OVER = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\min_hover.PNG")
$BAD = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\bad.png")
$WARNING = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\warning.png")
$GOOD = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\good.png")
$HELP = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\help.png")
$CD_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\cd.png")
$CD_HOVER_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\cd_hover.png")
$ISO_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\iso.png")
$ISO_HOVER_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\iso_hover.png")
$DOWNLOAD_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\download.png")
$DOWNLOAD_HOVER_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\download_hover.png")
$LAUNCH_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\launch.png")
$LAUNCH_HOVER_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\launch_hover.png")
$REFRESH_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\refresh.png")
$BACK_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\back.png")
$BACK_HOVER_PNG = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\back_hover.png")
$PNG_GUI = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\GUI.png")

SendReport("Creating GUI")

$GUI = GUICreate("LiLi USB Creator", 450, 750, -1, -1, $WS_POPUP, $WS_EX_LAYERED)
GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_Events")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "GUI_Minimize")
GUISetOnEvent($GUI_EVENT_RESTORE, "GUI_Restore")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "GUI_Restore")
HotKeySet("{UP}", "GUI_MoveUp")
HotKeySet("{DOWN}", "GUI_MoveDown")
HotKeySet("{LEFT}", "GUI_MoveLeft")
HotKeySet("{RIGHT}", "GUI_MoveRight")

GUIRegisterMsg($WM_LBUTTONDOWN, "moveGUI")

SetBitmap($GUI, $PNG_GUI, 255)
GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")
GUISetState(@SW_SHOW, $GUI)

$CONTROL_GUI = GUICreate("LinuxLive USB Creator", 450, 750, 0,0, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD), $GUI)

; Offset applied on every items
$offsetx0 = 27
$offsety0 = 42

; Label of Step 1
GUICtrlCreateLabel(Translate("STEP 1 : CHOOSE YOUR KEY"), 28 + $offsetx0, 108 + $offsety0, 400, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")

; Clickable parts of images
$EXIT_AREA = GUICtrlCreateLabel("", 335 + $offsetx0, -20 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Exit")
$MIN_AREA = GUICtrlCreateLabel("", 305 + $offsetx0, -20 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Minimize")
$REFRESH_AREA = GUICtrlCreateLabel("", 300 + $offsetx0, 145 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Refresh_Drives")
$ISO_AREA = GUICtrlCreateLabel("", 38 + $offsetx0, 231 + $offsety0, 75, 75)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Choose_ISO")
$CD_AREA = GUICtrlCreateLabel("", 146 + $offsetx0, 231 + $offsety0, 75, 75)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Choose_CD")
$DOWNLOAD_AREA = GUICtrlCreateLabel("", 260 + $offsetx0, 230 + $offsety0, 75, 75)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Download")
$LAUNCH_AREA = GUICtrlCreateLabel("", 35 + $offsetx0, 600 + $offsety0, 22, 43)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Launch_Creation")
$HELP_STEP1_AREA = GUICtrlCreateLabel("", 335 + $offsetx0, 105 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step1")
$HELP_STEP2_AREA = GUICtrlCreateLabel("", 335 + $offsetx0, 201 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step2")
$HELP_STEP3_AREA = GUICtrlCreateLabel("", 335 + $offsetx0, 339 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step3")
$HELP_STEP4_AREA = GUICtrlCreateLabel("", 335 + $offsetx0, 451 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step4")
$HELP_STEP5_AREA = GUICtrlCreateLabel("", 335 + $offsetx0, 565 + $offsety0, 20, 20)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, "GUI_Help_Step5")

GUISetBkColor(0x121314)
_WinAPI_SetLayeredWindowAttributes($CONTROL_GUI, 0x121314)


GUISetState(@SW_SHOW, $CONTROL_GUI)


$ZEROGraphic = _GDIPlus_GraphicsCreateFromHWND($CONTROL_GUI)

; Firt display (initialization) of images
$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 335 + $offsetx0, -20 + $offsety0, 20, 20)
$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 305 + $offsetx0, -20 + $offsety0, 20, 20)
$DRAW_REFRESH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $REFRESH_PNG, 0, 0, 20, 20, 300 + $offsetx0, 145 + $offsety0, 20, 20)
$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38 + $offsetx0, 231 + $offsety0, 75, 75)
$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146 + $offsetx0, 231 + $offsety0, 75, 75)
$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260 + $offsetx0, 230 + $offsety0, 75, 75)
$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_PNG, 0, 0, 22, 43, 35 + $offsetx0, 600 + $offsety0, 22, 43)
$HELP_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 105 + $offsety0, 20, 20)
$HELP_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 201 + $offsety0, 20, 20)
$HELP_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 339 + $offsety0, 20, 20)
$HELP_STEP4 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 451 + $offsety0, 20, 20)
$HELP_STEP5 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 565 + $offsety0, 20, 20)

; Put the state for the first 3 steps
Step1_Check("bad")
Step2_Check("bad")
Step3_Check("bad")

SendReport("Creating GUI (buttons)")

; Text for step 2

GUICtrlCreateLabel(Translate("STEP 2 : CHOOSE A SOURCE"), 28 + $offsetx0, 204 + $offsety0, 400, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")

$label_iso = GUICtrlCreateLabel("ISO / IMG / ZIP", 40 + $offsetx0, 302 + $offsety0, 80, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)


$label_cd = GUICtrlCreateLabel("CD", 175 + $offsetx0, 302 + $offsety0, 20, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

$label_download = GUICtrlCreateLabel(Translate("Download"), 262 + $offsetx0, 302 + $offsety0, 70, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; Text and controls for step 3
$offsetx3 = 60
$offsety3 = 150

GUICtrlCreateLabel(Translate("STEP 3 : PERSISTENCE"), 28 + $offsetx0, 194 + $offsety3 + $offsety0, 400, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")

$label_min = GUICtrlCreateLabel("0 " & Translate("MB"), 30 + $offsetx3 + $offsetx0, 228 + $offsety3 + $offsety0, 30, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$label_max = GUICtrlCreateLabel("?? " & Translate("MB"), 250 + $offsetx3 + $offsetx0, 228 + $offsety3 + $offsety0, 50, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

$slider = GUICtrlCreateSlider(60 + $offsetx3 + $offsetx0, 225 + $offsety3 + $offsety0, 180, 20)
GUICtrlSetLimit($slider, 0, 0)
GUICtrlSetOnEvent(-1, "GUI_Persistence_Slider")
$slider_visual = GUICtrlCreateInput("0", 90 + $offsetx3 + $offsetx0, 255 + $offsety3 + $offsety0, 40, 20)
GUICtrlSetOnEvent(-1, "GUI_Persistence_Input")
$slider_visual_Mo = GUICtrlCreateLabel(Translate("MB"), 135 + $offsetx3 + $offsetx0, 258 + $offsety3 + $offsety0, 20, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$slider_visual_mode = GUICtrlCreateLabel(Translate("(Live mode only)"), 160 + $offsetx3 + $offsetx0, 258 + $offsety3 + $offsety0, 100, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

$builtin_persistence_label = GUICtrlCreateLabel(Translate("Built-in Persistency"), 50 + $offsetx3 + $offsetx0, 233 + $offsety3 + $offsety0, 300, 100)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont($builtin_persistence_label, 16)
GUICtrlSetState($builtin_persistence_label,$GUI_HIDE)

$live_mode_only_label = GUICtrlCreateLabel(Translate("Live Mode"), 77 + $offsetx3 + $offsetx0, 233 + $offsety3 + $offsety0, 300, 100)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont($live_mode_only_label, 16)

Disable_Persistent_Mode()

; Text and controls for step 4
$offsetx4 = 10
$offsety4 = 195

GUICtrlCreateLabel(Translate("STEP 4 : OPTIONS"), 28 + $offsetx0, 259 + $offsety4 + $offsety0, 400, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")

$hide_files = GUICtrlCreateCheckbox("", 30 + $offsetx4 + $offsetx0, 285 + $offsety4 + $offsety0, 13, 13)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$hide_files_label = GUICtrlCreateLabel(Translate("Hide created files on key"), 50 + $offsetx4 + $offsetx0, 285 + $offsety4 + $offsety0, 300, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; No more reason to keep that option because menu is integrated on right click of the key
$except_wubi = GUICtrlCreateDummy()
;$except_wubi = GUICtrlCreateCheckbox("", 200 + $offsetx4+$offsetx0, 285 + $offsety4+$offsety0, 13, 13)
;$except_wubi_label = GUICtrlCreateLabel(Translate("(except for Umenu.exe)"), 220 + $offsetx4+$offsetx0, 285 + $offsety4+$offsety0, 200, 20)
;GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
;GUICtrlSetColor(-1, 0xFFFFFF)

$formater = GUICtrlCreateCheckbox("", 30 + $offsetx4 + $offsetx0, 305 + $offsety4 + $offsety0, 13, 13)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetOnEvent(-1, "GUI_Format_Key")
$formater_label = GUICtrlCreateLabel(Translate("Format the key in FAT32 (this will erase your data !!)"), 50 + $offsetx4 + $offsetx0, 305 + $offsety4 + $offsety0, 300, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$virtualbox = GUICtrlCreateCheckbox("", 30 + $offsetx4 + $offsetx0, 325 + $offsety4 + $offsety0, 13, 13)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$virtualbox_label = GUICtrlCreateLabel(Translate("Enable launching LinuxLive in Windows (requires internet to install)"), 50 + $offsetx4 + $offsetx0, 325 + $offsety4 + $offsety0, 300, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)


; Text and controls for step 5

GUICtrlCreateLabel(Translate("STEP 5 : CREATE"), 28 + $offsetx0, 371 + $offsety4 + $offsety0, 400, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")

$label_step6_statut = GUICtrlCreateLabel("<- " & Translate("Click the lightning icon to start the installation"), 50 + $offsetx4 + $offsetx0, 410 + $offsety4 + $offsety0, 300, 60)
GUICtrlSetFont($label_step6_statut, 9, 800, 0, "Arial")
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)


; Filling the combo box with drive list

$combo = GUICtrlCreateCombo("-> " & Translate("Choose a USB Key"), 90 + $offsetx0, 145 + $offsety0, 200, -1, 3)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetOnEvent(-1, "GUI_Choose_Drive")
Refresh_DriveList()


; Sending anonymous statistics
SendStats()
SendReport(LogSystemConfig())
Check_for_updates()


$prefetched_linux_list = Print_For_ComboBox()

; Hovering Buttons
AdlibEnable("Control_Hover", 150)


GUIRegisterMsg($WM_PAINT, "DrawAll")
WinActivate($for_winactivate)
GUISetState($GUI_SHOW, $CONTROL_GUI)

Func MoveGUI($hW)
	_SendMessage($GUI, $WM_SYSCOMMAND, 0xF012, 0)
	ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
EndFunc   ;==>MoveGUI

; Main part
While 1
	; Force retracing the combo box (bugfix)
	If $combo_updated <> 1 Then
		GUICtrlSetData($combo, GUICtrlRead($combo))
		$combo_updated = 1
	EndIf
	Sleep(5000)
	DrawAll()
WEnd

Func DrawAll()
	_WinAPI_RedrawWindow($CONTROL_GUI, 0, 0, $RDW_UPDATENOW)
	$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 335 + $offsetx0, -20 + $offsety0, 20, 20)
	$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 305 + $offsetx0, -20 + $offsety0, 20, 20)
	$DRAW_REFRESH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $REFRESH_PNG, 0, 0, 20, 20, 300 + $offsetx0, 145 + $offsety0, 20, 20)
	If $step2_display_menu = 0 Then
		$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146 + $offsetx0, 231 + $offsety0, 75, 75)
		$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260 + $offsetx0, 230 + $offsety0, 75, 75)
		$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38 + $offsetx0, 231 + $offsety0, 75, 75)
	Else
		$DRAW_BACK = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
	EndIf
	$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_PNG, 0, 0, 22, 43, 35 + $offsetx0, 600 + $offsety0, 22, 43)

	$HELP_STEP1 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 105 + $offsety0, 20, 20)
	$HELP_STEP2 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 201 + $offsety0, 20, 20)
	$HELP_STEP3 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 339 + $offsety0, 20, 20)
	$HELP_STEP4 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 451 + $offsety0, 20, 20)
	$HELP_STEP5 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 565 + $offsety0, 20, 20)
	Redraw_Traffic_Lights()
	_WinAPI_RedrawWindow($CONTROL_GUI, 0, 0, $RDW_VALIDATE) ; then force no-redraw of GUI
	Return $GUI_RUNDEFMSG
EndFunc   ;==>DrawAll

Func Redraw_Traffic_Lights()
	; Re-checking step (to retrace traffic lights)
	Select
		Case $STEP1_OK = 0
			Step1_Check("bad")
		Case $STEP1_OK = 1
			Step1_Check("good")
		Case $STEP1_OK = 2
			Step1_Check("warning")
	EndSelect
	Select
		Case $STEP2_OK = 0
			Step2_Check("bad")
		Case $STEP2_OK = 1
			Step2_Check("good")
		Case $STEP2_OK = 2
			Step2_Check("warning")
	EndSelect
	Select
		Case $STEP3_OK = 0
			Step3_Check("bad")
		Case $STEP3_OK = 1
			Step3_Check("good")
		Case $STEP3_OK = 2
			Step3_Check("warning")
	EndSelect
EndFunc   ;==>Redraw_Traffic_Lights


Func Control_Hover()
	Global $previous_hovered_control
	Local $CursorCtrl
	If WinActive("LinuxLive USB Creator") Or WinActive("LiLi USB Creator") Then

		$CursorCtrl = GUIGetCursorInfo()
		If Not @error Then
			Switch $previous_hovered_control
				Case $EXIT_AREA
					If $CursorCtrl[2] = 1 Then GUI_Exit()
					$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 335 + $offsetx0, -20 + $offsety0, 20, 20)
				Case $MIN_AREA
					If $CursorCtrl[2] = 1 Then GUI_Minimize()
					$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 305 + $offsetx0, -20 + $offsety0, 20, 20)
				Case $ISO_AREA
					If $step2_display_menu = 0 Then $DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38 + $offsetx0, 231 + $offsety0, 75, 75)
				Case $CD_AREA
					If $step2_display_menu = 0 Then $DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146 + $offsetx0, 231 + $offsety0, 75, 75)
				Case $DOWNLOAD_AREA
					If $step2_display_menu = 0 Then $DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260 + $offsetx0, 230 + $offsety0, 75, 75)
				Case $LAUNCH_AREA
					$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_PNG, 0, 0, 22, 43, 35 + $offsetx0, 600 + $offsety0, 22, 43)
				Case $BACK_AREA
					If $step2_display_menu = 1 Then $DRAW_BACK = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
			EndSwitch

			Switch $CursorCtrl[4]
				Case $EXIT_AREA
					If $CursorCtrl[2] = 1 Then GUI_Exit()
					$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_OVER, 0, 0, 20, 20, 335 + $offsetx0, -20 + $offsety0, 20, 20)
				Case $MIN_AREA
					If $CursorCtrl[2] = 1 Then GUI_Minimize()
					$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_OVER, 0, 0, 20, 20, 305 + $offsetx0, -20 + $offsety0, 20, 20)
				Case $ISO_AREA
					If $step2_display_menu = 0 Then $DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_HOVER_PNG, 0, 0, 75, 75, 38 + $offsetx0, 231 + $offsety0, 75, 75)
				Case $CD_AREA
					If $step2_display_menu = 0 Then $DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_HOVER_PNG, 0, 0, 75, 75, 146 + $offsetx0, 231 + $offsety0, 75, 75)
				Case $DOWNLOAD_AREA
					If $step2_display_menu = 0 Then $DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_HOVER_PNG, 0, 0, 75, 75, 260 + $offsetx0, 230 + $offsety0, 75, 75)
				Case $LAUNCH_AREA
					$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_HOVER_PNG, 0, 0, 22, 43, 35 + $offsetx0, 600 + $offsety0, 22, 43)
				Case $BACK_AREA
					If $step2_display_menu = 1 Then $DRAW_BACK_HOVER = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_HOVER_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
			EndSwitch
			$previous_hovered_control = $CursorCtrl[4]
		EndIf
	EndIf
EndFunc   ;==>Control_Hover

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Files management                      ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func DirRemove2($arg1, $arg2)
	SendReport("Start-DirRemove2 ( " & $arg1 & " )")
	UpdateLog("Deleting folder : " & $arg1)
	If DirRemove($arg1, $arg2) Then
		UpdateLog("                   " & "Folder deleted")
	Else
		If DirGetSize($arg1) >= 0 Then
			UpdateLog("                   " & "Error while deleting")
		Else
			UpdateLog("                   " & "Folder not found")
		EndIf
	EndIf
	SendReport("End-DirRemove2")
EndFunc   ;==>DirRemove2

Func FileDelete2($arg1)
	SendReport("Start-FileDelete2 ( " & $arg1 & " )")
	UpdateLog("Deleting file : " & $arg1)
	If FileDelete($arg1) == 1 Then
		UpdateLog("                   " & "File deleted")
	Else
		If FileExists($arg1) Then
			UpdateLog("                   " & "Error while deleting")
		Else
			UpdateLog("                   " & "File not found")
		EndIf
	EndIf
	SendReport("End-FileDelete2")
EndFunc   ;==>FileDelete2

Func HideFilesInDir($list_of_files)
	For $file In $list_of_files
		HideFile($selected_drive & "\" & $file)
	Next
EndFunc   ;==>HideFilesInDir

Func isDir($file_to_test)
	Return StringInStr(FileGetAttrib($file_to_test), "D")
EndFunc   ;==>isDir

Func DeleteFilesInDir($list_of_files)
	For $file In $list_of_files
		If isDir($selected_drive & "\" & $file) Then
			DirRemove2($selected_drive & "\" & $file, 1)
		Else
			FileDelete2($selected_drive & "\" & $file)
		EndIf
	Next
EndFunc   ;==>DeleteFilesInDir

Func HideFile($file_or_folder)
	SendReport("Start-HideFile ( " & $file_or_folder & " )")
	UpdateLog("Hiding file : " & $file_or_folder)
	If FileSetAttrib($file_or_folder, "+SH") == 1 Then
		UpdateLog("                   " & "File hided")
	Else
		If FileExists($file_or_folder) Then
			UpdateLog("                   " & "File not found")
		Else
			UpdateLog("                   " & "Error while hiding")
		EndIf
	EndIf
	SendReport("End-HideFile")
EndFunc   ;==>HideFile

Func ShowFile($file_or_folder)
	SendReport("Start-HideFile ( " & $file_or_folder & " )")
	UpdateLog("Showing file : " & $file_or_folder)
	If FileSetAttrib($file_or_folder, "-SH") == 1 Then
		UpdateLog("                   " & "File showed")
	Else
		If FileExists($file_or_folder) Then
			UpdateLog("                   " & "File not showed")
		Else
			UpdateLog("                   " & "Error while showing")
		EndIf
	EndIf
	SendReport("End-HideFile")
EndFunc   ;==>ShowFile

Func FileRename($file1, $file2)
	SendReport("Start-FileRename ( " & $file1 & "-->" & $file2 & " )")
	UpdateLog("Renaming File : " & $file1 & "-->" & $file2)

	If FileMove($file1, $file2, 1) == 1 Then
		UpdateLog("                   File renamed successfully")
	Else
		UpdateLog("                   Error : " & $file1 & " cannot be moved")
	EndIf

	SendReport("End-FileRename")
EndFunc   ;==>FileRename

Func FileCopyShell($fromFile, $tofile)
	SendReport("Start-_FileCopyShell (" & $fromFile & " -> " & $tofile & " )")
	Local $FOF_RESPOND_YES = 16
	Local $FOF_SIMPLEPROGRESS = 256
	$winShell = ObjCreate("shell.application")
	$winShell.namespace($tofile).CopyHere($fromFile, $FOF_RESPOND_YES)
	SendReport("End-_FileCopyShell")
EndFunc   ;==>_FileCopy

Func FileCopy2($arg1, $arg2)
	SendReport("Start-_FileCopy2 ( " & $arg1 & " -> " & $arg2 & " )")
	UpdateLog("Copying file(s) " & $arg1 & " to " & $arg2)
	If FileCopy($arg1, $arg2,1) Then
		UpdateLog("                   File copied successfully")
	Else
		UpdateLog("                   Error : " & $arg1 & " has not been copied")
	EndIf
	SendReport("End-_FileCopy2")
EndFunc   ;==>_FileCopy2



Func InitializeFilesInSource($path)
	If isDir($path) == 1 Then
		InitializeFilesInCD($path)
	Else
		InitializeFilesInISO($path)
	EndIf
EndFunc   ;==>InitializeFilesInSource

; Create a list of files in ISO
Func InitializeFilesInISO($iso_to_list)
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	FileDelete(@ScriptDir & "\tools\filelist.txt")
	$foo = RunWait(@ComSpec & " /c " & '7z.exe' & ' l -slt "' & $iso_to_list & '" > filelist.txt', @ScriptDir & "\tools\", @SW_HIDE)
	AnalyzeFileList()
EndFunc   ;==>InitializeFilesInISO

; Analyze the listfile and only select files and folders at the root (will be used to clean previous installs and hide the newly created)
Func AnalyzeFileList()
	Local $line, $filelist, $files[1]
	Global $files_in_source
	$filelist = FileOpen(@ScriptDir & "\tools\filelist.txt", 0)
	While 1
		$line = FileReadLine($filelist)
		If @error = -1 Then ExitLoop
		If StringRegExp($line, "^Path = ", 0) And StringInStr($line, "\") == 0 And StringInStr($line, "[BOOT]") == 0 Then
			_ArrayAdd($files, StringReplace($line, "Path = ", ""))
		EndIf
	WEnd
	FileClose($filelist)
	FileDelete(@ScriptDir & "\tools\filelist.txt")
	_ArrayDelete($files, 0)
	$files_in_source = $files
EndFunc   ;==>AnalyzeFileList

Func InitializeFilesInCD($searchdir)
	Local $files[1]
	Global $files_in_source
	If StringRight($searchdir, 1) <> "\" Then $searchdir = $searchdir & "\"

	$search = FileFindFirstFile($searchdir & "*")
	If isDir($searchdir & $search) Then _ArrayAdd($files, $search)

	; Check if the search was successful
	If $search = -1 Then
		SendReport("IN-InitializeFilesInCD : No files/directories matched the search pattern")
		FileClose($search)
		Return ""
	EndIf

	$attrib = ""
	While 1
		$file = FileFindNextFile($search)
		If @error Then ExitLoop
		_ArrayAdd($files, $file)
	WEnd
	; Close the search handle
	FileClose($search)
	_ArrayDelete($files, 0)
	$files_in_source = $files
EndFunc   ;==>InitializeFilesInCD


; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Launching third party tools                       ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Run7zip($cmd, $taille)
	Local $percentage, $line
	$initial = DriveSpaceFree($selected_drive)
	SendReport("Start-Run7zip ( Command :" & $cmd & " - Size:" & $taille & " )")

	UpdateLog($cmd)
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = ""

	While ProcessExists($foo) > 0
		$percentage = Round((($initial - DriveSpaceFree($selected_drive)) * 100 / $taille), 0)
		If $percentage > 0 And $percentage < 101 Then
			UpdateStatusNoLog(Translate("Extracting ISO file on key") & " ( ± " & $percentage & "% )")
		EndIf
		;If @error Then ExitLoop
		Sleep(500)
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$line &= StderrRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog($line)
	SendReport("End-Run7zip")
EndFunc   ;==>Run7zip

Func Run7zip2($cmd, $taille)
	Local $percentage, $line
	$initial = DriveSpaceFree($selected_drive)
	SendReport("Start-Run7zip2 ( Command :" & $cmd & " - Size:" & $taille & " )")
	UpdateLog($cmd)
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = ""
	While ProcessExists($foo) > 0
		$percentage = Round((($initial - DriveSpaceFree($selected_drive)) * 100 / $taille), 0)
		If $percentage > 0 And $percentage < 101 Then
			UpdateStatusNoLog(Translate("Extracting VirtualBox on key") & " ( ± " & $percentage & "% )")
		EndIf
		;If @error Then ExitLoop
		;UpdateStatus2($line)
		Sleep(500)
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$line &= StderrRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog($line)
	SendReport("End-Run7zip2")
EndFunc   ;==>Run7zip2

Func Create_Empty_File($file_to_create, $size)
	SendReport("Start-Create_Empty_File (file : " & $file_to_create & " - Size:" & $size & " )")
	Local $cmd, $line
	$cmd = @ScriptDir & '\tools\dd.exe if=/dev/zero of=' & $file_to_create & ' count=' & $size & ' bs=1024k'
	UpdateLog($cmd)
	If ProcessExists("dd.exe") > 0 Then ProcessClose("dd.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = ""
	While 1

		UpdateStatusNoLog(Translate("Creating file for persistence") & " ( " & Round(FileGetSize($file_to_create) / 1048576, 0) & "/" & Round($size, 0) & " Mo )")
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$line &= StderrRead($foo)
		If @error Then ExitLoop
		Sleep(500)
	WEnd
	UpdateLog($line)
	SendReport("End-Create_Empty_File")
EndFunc   ;==>Create_Empty_File


Func EXT2_Format_File($persistence_file)
	Local $line,$line_temp
	If ProcessExists("mke2fs.exe") > 0 Then ProcessClose("mke2fs.exe")
	$cmd = @ScriptDir & '\tools\mke2fs.exe -b 1024 ' & $persistence_file
	SendReport("Start-EXT2_Format_File ( " & $cmd & " )")
	UpdateLog($cmd)
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	$line_temp = ""
	$line=""
	While 1
		$line_temp = StdoutRead($foo)
		If @error Then ExitLoop
		$line_temp &= StderrRead($foo)
		If @error Then ExitLoop
		$parse_percent = StringRegExp($line_temp, '[0-9]{1,3}%', 1)
		if Ubound($parse_percent)>0 Then UpdateStatusNoLog(Translate("Test :") & " "& $parse_percent)
		$line &=$line_temp
		StdinWrite($foo, "{ENTER}")
		If @error Then ExitLoop
		Sleep(500)
	WEnd
	UpdateLog($line)
	SendReport("End-EXT2_Format_File")
EndFunc   ;==>EXT2_Format_File

Func RunWait3($soft, $arg1, $arg2)
	SendReport("Start-RunWait3 ( " & $soft & " )")
	Local $line
	UpdateLog($soft)
	$foo = Run($soft, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = ""
	While True
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$line &= StderrRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog("                   " & $line)
	SendReport("End-RunWait3")
EndFunc   ;==>RunWait3


Func Run2($soft, $arg1, $arg2)
	SendReport("Start-Run2 ( " & $soft & " )")
	Local $line
	UpdateLog($soft)
	$foo = Run($soft, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = ""
	While True
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$line &= StderrRead($foo)
		If @error Then ExitLoop
		StdinWrite($foo, @CR & @LF & @CRLF)
		If @error Then ExitLoop
		Sleep(300)
	WEnd
	UpdateLog("                   " & $line)
	SendReport("End-Run2")
EndFunc   ;==>Run2

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Disks Management                              ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Refresh_DriveList()
	SendReport("Start-Refresh_DriveList")
	$system_letter = StringLeft(@SystemDir, 2)
	; récupére la liste des disques
	$drive_list = DriveGetDrive("REMOVABLE")
	$all_drives = "|-> " & Translate("Choose a USB Key") & "|"
	If Not @error Then
		Dim $description[100]
		If UBound($drive_list) >= 1 Then
			For $i = 1 To $drive_list[0]
				$label = DriveGetLabel($drive_list[$i])
				$fs = DriveGetFileSystem($drive_list[$i])
				$space = DriveSpaceTotal($drive_list[$i])
				If Not (($fs = "") Or ($space = 0) Or ($drive_list[$i] = $system_letter)) Then
					$all_drives &= StringUpper($drive_list[$i]) & " " & $label & " - " & $fs & " - " & Round($space / 1024, 1) & " " & Translate("GB") & "|"
				EndIf
			Next
		EndIf
	EndIf
	SendReport("Start-Refresh_DriveList-Removable Listed")
	$drive_list = DriveGetDrive("FIXED")
	If Not @error Then
		$all_drives &= "-> " & Translate("Hard drives") & " -------------|"
		Dim $description[100]
		If UBound($drive_list) >= 1 Then
			For $i = 1 To $drive_list[0]
				$label = DriveGetLabel($drive_list[$i])
				$fs = DriveGetFileSystem($drive_list[$i])
				$space = DriveSpaceTotal($drive_list[$i])
				If Not (($fs = "") Or ($space = 0) Or ($drive_list[$i] = $system_letter)) Then
					$all_drives &= StringUpper($drive_list[$i]) & " " & $label & " - " & $fs & " - " & Round($space / 1024, 1) & " " & Translate("GB") & "|"
				EndIf
			Next
		EndIf
	EndIf
	SendReport("Start-Refresh_DriveList-2")
	If $all_drives <> "|-> " & Translate("Choose a USB Key") & "|" Then
		GUICtrlSetData($combo, $all_drives, "-> " & Translate("Choose a USB Key"))
		GUICtrlSetState($combo, $GUI_ENABLE)
	Else
		GUICtrlSetData($combo, "|-> " & Translate("No key found"), "-> " & Translate("No key found"))
		GUICtrlSetState($combo, $GUI_DISABLE)
	EndIf
	SendReport("End-Refresh_DriveList")
EndFunc   ;==>Refresh_DriveList

Func SpaceAfterLinuxLiveMB($disk)
	SendReport("Start-SpaceAfterLinuxLiveMB (Disk: " & $disk & " )")
	Local $install_size

	If ReleaseGetCodename($release_number) = "default" Then
		$install_size = Round(FileGetSize($file_set) / 1048576) + 20
	Else
		$install_size = ReleasegetInstallSize($release_number)
	EndIf

	If GUICtrlRead($virtualbox) == $GUI_CHECKED Then
		; Need 140MB for VirtualBox
		$install_size = $install_size + 140
	EndIf

	If GUICtrlRead($formater) == $GUI_CHECKED Then
		$spacefree = DriveSpaceTotal($disk) - $install_size
		If $spacefree >= 0 And $spacefree <= 4000 Then
			Return Round($spacefree / 100, 0) * 100
		ElseIf $spacefree >= 0 And $spacefree > 4000 Then
			SendReport("End-SpaceAfterLinuxLiveGB (Free : 4000MB )")
			Return (4000)
		Else
			SendReport("End-SpaceAfterLinuxLiveGB (Free : 0MB )")
			Return 0
		EndIf
	Else
		$spacefree = DriveSpaceFree($disk) - $install_size
		If $spacefree >= 0 And $spacefree <= 4000 Then
			Return Round($spacefree / 100, 0) * 100
		ElseIf $spacefree >= 0 And $spacefree > 4000 Then
			SendReport("End-SpaceAfterLinuxLiveGB (Free : 4000MB )")
			Return (4000)
		Else
			SendReport("End-SpaceAfterLinuxLiveMB (Free : 0MB )")
			Return 0
		EndIf
	EndIf
EndFunc   ;==>SpaceAfterLinuxLiveMB

Func SpaceAfterLinuxLiveGB($disk)
	SendReport("Start-SpaceAfterLinuxLiveGB (Disk: " & $disk & " )")

	If ReleaseGetCodename($release_number) = "default" Then
		$install_size = Round(FileGetSize($file_set) / 1048576) + 20
	Else
		$install_size = ReleasegetInstallSize($release_number)
	EndIf

	If GUICtrlRead($virtualbox) == $GUI_CHECKED Then
		; Need 140MB for VirtualBox
		$install_size = $install_size + 140
	EndIf

	If GUICtrlRead($formater) == $GUI_CHECKED Then
		$spacefree = DriveSpaceTotal($disk) - ReleasegetInstallSize($release_number)
		If $spacefree >= 0 Then
			SendReport("End-SpaceAfterLinuxLiveGB (Free : " & Round($spacefree / 1024, 1) & "GB )")
			Return Round($spacefree / 1024, 1)
		Else
			SendReport("End-SpaceAfterLinuxLiveGB (Free : 0GB )")
			Return 0
		EndIf
	Else
		$spacefree = DriveSpaceFree($disk) - ReleasegetInstallSize($release_number)
		If $spacefree >= 0 Then
			SendReport("End-SpaceAfterLinuxLiveGB (Free : " & Round($spacefree / 1024, 1) & "GB )")
			Return Round($spacefree / 1024, 1)
		Else
			SendReport("End-SpaceAfterLinuxLiveGB (Free : 0GB )")
			Return 0
		EndIf
	EndIf

EndFunc   ;==>SpaceAfterLinuxLiveGB

; returns the physical disk (\\.\PhysicalDiskX) corresponding to a drive letter
Func GiveMePhysicalDisk($drive_letter)
	Local $physical_drive,$g_eventerror

	UpdateLog("GiveMePhysicalDisk of : "&$drive_letter)

	Local $wbemFlagReturnImmediately, $wbemFlagForwardOnly, $objWMIService, $colItems, $objItem, $found_usb, $usb_model, $usb_size
	$wbemFlagReturnImmediately = 0x10
	$wbemFlagForwardOnly = 0x20
	$colItems = ""

	$objWMIService = ObjGet("winmgmts:\\.\root\CIMV2")
	if @error OR $g_eventerror OR NOT IsObj($objWMIService) Then
		UpdateLog("ERROR with WMI : Trying alternate method (WMI impersonation)")
		$g_eventerror =0
		$objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!//.")
	EndIf

	if @error OR $g_eventerror then
		UpdateLog("ERROR with WMI")
	Elseif IsObj($objWMIService) Then
		UpdateLog("WMI seems to work")

		$colItems = $objWMIService.ExecQuery("SELECT Caption, DeviceID FROM Win32_DiskDrive", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

		For $objItem In $colItems

			$colItems2 = $objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" & $objItem.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
			For $objItem2 In $colItems2
				$colItems3 = $objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" & $objItem2.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
				For $objItem3 In $colItems3
					If $objItem3.DeviceID = $drive_letter Then
						$physical_drive = $objItem.DeviceID
					EndIf
				Next
			Next

		Next

	Else
		UpdateLog("ERROR with WMI : object not created")
	endif

	if $physical_drive Then
		UpdateLog("PhysicalDisk is : "& $physical_drive)
		Return StringReplace($physical_drive,"\\.\PHYSICALDRIVE","")
	Else
		Return "ERROR"
	EndIf
EndFunc   ;==>GiveMePhysicalDisk

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Logs and status                               ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Func InitLog()
	Global $logfile
	DirCreate($log_dir)
	$logfile = @ScriptDir & "\logs\" & @MDAY & "-" & @MON & "-" & @YEAR & " (" & @HOUR & "h" & @MIN & "s" & @SEC & ").log"
	UpdateLog(LogSystemConfig())
	SendReport("logfile-" & $logfile)
EndFunc   ;==>InitLog

Func LogSystemConfig()
	SendReport("Start-LogSystemConfig")
	Local $space = -1
	$mem = MemGetStats()
	$line = @CRLF & "--------------------------------  System Config  --------------------------------"
	$line &= @CRLF & "LiLi USB Creator : " & $software_version
	$line &= @CRLF & "OS Type : " & @OSType
	$line &= @CRLF & "OS Version : " & @OSVersion
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
	GUICtrlSetData($label_step6_statut, Translate($status))
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
	GUICtrlSetData($label_step6_statut, Translate($status))
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

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Creating boot menu                             ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func GetKbdCode()
	SendReport("Start-GetKbdCode")
	Select
		Case StringInStr("040c,080c,140c,180c", @OSLang)
			; FR
			UpdateLog(Translate("Detecting keyboard layout") & " : " & Translate("French (France)"))
			SendReport("End-GetKbdCode")
			Return "locale=fr_FR bootkbd=fr-latin1 console-setup/layoutcode=fr console-setup/variantcode=nodeadkeys "

		Case StringInStr("0c0c", @OSLang)
			; CA
			UpdateLog(Translate("Detecting keyboard layout") & " : " & Translate("Français (Canada)"))
			SendReport("End-GetKbdCode")
			Return "locale=fr_CA bootkbd=fr-latin1 console-setup/layoutcode=ca console-setup/variantcode=nodeadkeys "

		Case StringInStr("100c", @OSLang)
			; Suisse FR
			UpdateLog(Translate("Detecting keyboard layout") & " : " & Translate("French (Swiss)"))
			SendReport("End-GetKbdCode")
			Return "locale=fr_CH bootkbd=fr-latin1 console-setup/layoutcode=ch console-setup/variantcode=fr "

		Case StringInStr("0407,0807,0c07,1007,1407", @OSLang)
			; German & dutch
			UpdateLog(Translate("Detecting keyboard layout") & " : " & Translate("Dutch"))
			SendReport("End-GetKbdCode")
			Return "locale=de_DE bootkbd=de console-setup/layoutcode=de console-setup/variantcode=nodeadkeys "

		Case StringInStr("0816", @OSLang)
			; Portugais
			UpdateLog(Translate("Detecting keyboard layout") & " : " & Translate("Portuguese"))
			SendReport("End-GetKbdCode")
			Return "locale=pt_BR bootkbd=qwerty/br-abnt2 console-setup/layoutcode=br console-setup/variantcode=nodeadkeys "

		Case StringInStr("0410,0810", @OSLang)
			; Italien
			UpdateLog(Translate("Detecting keyboard layout") & " : " & Translate("Italian"))
			SendReport("End-GetKbdCode")
			Return "locale=it_IT bootkbd=it console-setup/layoutcode=it console-setup/variantcode=nodeadkeys "
		Case Else
			; US
			UpdateLog(Translate("Detecting keyboard layout") & " : " & Translate("US or other (qwerty)"))
			SendReport("End-GetKbdCode")
			Return "locale=us_us bootkbd=us console-setup/layoutcode=en_US console-setup/variantcode=nodeadkeys "
	EndSelect

EndFunc   ;==>GetKbdCode


Func Get_Disk_UUID($drive_letter)
	SendReport("Start-Get_Disk_UUID ( Drive : " & $drive_letter & " )")
	Local $uuid = "802B-84D8"
	Dim $oWMIService = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	$o_ColListOfProcesses = $oWMIService.ExecQuery("SELECT * FROM Win32_LogicalDisk WHERE Name = '" & $drive_letter & "'")
	For $o_ObjProcess In $o_ColListOfProcesses
		$uuid = $o_ObjProcess.VolumeSerialNumber
	Next
	SendReport("End-Get_Disk_UUID")
	Return StringTrimRight($uuid, 4) & "-" & StringTrimLeft($uuid, 4)
EndFunc   ;==>Get_Disk_UUID


Func TinyCore_WriteTextCFG($selected_drive)
	SendReport("Start-TinyCore_WriteTextCFG ( Drive : " & $selected_drive & " )")
	Local $boot_text = "", $uuid
	$uuid = Get_Disk_UUID($selected_drive)
$boot_text="display boot.msg" _
	& @LF & "default tinycore" _
	& @LF & "label tinycore" _
	& @LF & "	kernel /boot/bzImage" _
	& @LF & "	append initrd=/boot/tinycore.gz max_loop=200 waitusb=5 tce=UUID="&$uuid&" restore=UUID="&$uuid&" home=UUID="&$uuid&" opt=UUID="&$uuid _
	& @LF & "label live" _
	& @LF & "	kernel /boot/bzImage" _
	& @LF & "	append initrd=/boot/tinycore.gz quiet max_loop=255" _
	& @LF & "implicit 0" _
	& @LF & "prompt 1" _
	& @LF & "timeout 300" _
	& @LF & "F1 boot.msg" _
	& @LF & "F2 f2" _
	& @LF & "F3 f3"
	$file = FileOpen($selected_drive & "\boot\syslinux\syslinux.cfg", 2)
	FileWrite($file, $boot_text)
	FileClose($file)
	SendReport("End-TinyCore_WriteTextCFG")
EndFunc


Func Ubuntu_WriteTextCFG($selected_drive, $release_in_list)
	SendReport("Start-Ubuntu_WriteTextCFG (Drive : " & $selected_drive & " -  Codename: " & ReleaseGetCodename($release_in_list) & " )")

	$ubuntu_variant = ReleaseGetVariant($release_in_list)
	$distrib_version = ReleaseGetDistributionVersion($release_in_list)
	$features = ReleaseGetSupportedFeatures($release_in_list)

	; No custom boot menu when using default mode.
	If StringInStr($features,"default") >0 Then Return ""

	#cs
	------------ Old BackTrack compatibility mode
	If $ubuntu_variant = "backtrack" Then
		DirCreate($selected_drive &"\syslinux\")
		FileCopy(@ScriptDir & "\tools\vesamenu.c32", $selected_drive & "\syslinux\vesamenu.c32", 1)
		FileCopy(@ScriptDir & "\tools\bt4-splash.jpg", $selected_drive & "\syslinux\splash.jpg", 1)
		FileCopy(@ScriptDir & "\tools\bt4-isolinux.txt", $selected_drive & "\syslinux\syslinux.cfg", 1)
		Return ""
	EndIf
	#ce

	; Karmic Koala have a renamed initrd file
	If $distrib_version="9.10" OR $distrib_version="10.04" Then
		$initrd_file = "initrd.lz"
	Else
		$initrd_file = "initrd.gz"
	EndIf

	; For official Ubuntu variants, only text.cfg need to be modified
	if $ubuntu_variant="ubuntu" OR StringInStr($ubuntu_variant, "xubuntu") OR StringInStr($ubuntu_variant, "netbook") OR StringInStr($ubuntu_variant, "kubuntu") OR $ubuntu_variant="superos" Then
		$boot_text = Ubuntu_BootMenu($initrd_file,$ubuntu_variant)
		UpdateLog("Creating text.cfg file for Official Ubuntu variants :" & @CRLF & $boot_text)
		$file = FileOpen($selected_drive & "\syslinux\text.cfg", 2)
		FileWrite($file, $boot_text)
		FileClose($file)
	EndIf

	; For Mint, only syslinux.cfg need to be modified
	If $ubuntu_variant = "mint" Then
		$boot_text = "default vesamenu.c32" _
				 & @LF & "timeout 100" _
				 & @LF & "menu background splash.jpg" _
				 & @LF & "menu title Welcome to Linux Mint" _
				 & @LF & "menu color border 0 #00eeeeee #00000000" _
				 & @LF & "menu color sel 7 #ffffffff #33eeeeee" _
				 & @LF & "menu color title 0 #ffeeeeee #00000000" _
				 & @LF & "menu color tabmsg 0 #ffeeeeee #00000000" _
				 & @LF & "menu color unsel 0 #ffeeeeee #00000000" _
				 & @LF & "menu color hotsel 0 #ff000000 #ffffffff" _
				 & @LF & "menu color hotkey 7 #ffffffff #ff000000" _
				 & @LF & "menu color timeout_msg 0 #ffffffff #00000000" _
				 & @LF & "menu color timeout 0 #ffffffff #00000000" _
				 & @LF & "menu color cmdline 0 #ffffffff #00000000" _
				 & @LF & "menu hidden" _
				 & @LF & "menu hiddenrow 5"
		$boot_text &= Ubuntu_BootMenu($initrd_file,"mint")
		UpdateLog("Creating syslinux.cfg file for Mint :" & @CRLF & $boot_text)
		$file = FileOpen($selected_drive & "\syslinux\syslinux.cfg", 2)
		FileWrite($file, $boot_text)
		FileClose($file)
	EndIf

	If $ubuntu_variant = "crunchbang" OR $ubuntu_variant = "kuki" Then
		$boot_text=Ubuntu_BootMenu($initrd_file,"custom") & @LF & "DISPLAY isolinux.txt"& @LF &"TIMEOUT 300"& @LF &"PROMPT 1" & @LF & "default persist"
		UpdateLog("Creating syslinux.cfg file for "&$ubuntu_variant&" :" & @CRLF & $boot_text)
		$file = FileOpen($selected_drive & "\syslinux\syslinux.cfg", 2)
		FileWrite($file, $boot_text)
		FileClose($file)
		FileCopy($selected_drive & "\syslinux\isolinux.txt",$selected_drive & "\syslinux\isolinux-orig.txt")
		FileCopy(@ScriptDir & "\tools\"&$ubuntu_variant&"-isolinux.txt", $selected_drive & "\syslinux\isolinux.txt", 1)
	EndIf

	SendReport("End-Ubuntu_WriteTextCFG")
EndFunc   ;==>Ubuntu_WriteTextCFG

Func Ubuntu_BootMenu($initrd_file,$seed_name)
	Local $kbd_code
	$kbd_code = GetKbdCode()
	$boot_text = @LF& "label persist" & @LF & "menu label ^" & Translate("Persistent Mode") _
		& @LF & "  kernel /casper/vmlinuz" _
		& @LF & "  append  " & $kbd_code & "noprompt cdrom-detect/try-usb=true persistent file=/cdrom/preseed/" & $seed_name & ".seed boot=casper initrd=/casper/" & $initrd_file & " splash--" _
		& @LF & "label live" _
		& @LF & "  menu label ^" & Translate("Live Mode") _
		& @LF & "  kernel /casper/vmlinuz" _
		& @LF & "  append   " & $kbd_code & "noprompt cdrom-detect/try-usb=true file=/cdrom/preseed/" & $seed_name  & ".seed boot=casper initrd=/casper/" & $initrd_file & " splash--" _
		& @LF & "label live-install" _
		& @LF & "  menu label ^" & Translate("Install") _
		& @LF & "  kernel /casper/vmlinuz" _
		& @LF & "  append   " & $kbd_code & "noprompt cdrom-detect/try-usb=true persistent file=/cdrom/preseed/" & $seed_name  & ".seed boot=casper only-ubiquity initrd=/casper/" & $initrd_file & " splash --" _
		& @LF & "label check" _
		& @LF & "  menu label ^" & Translate("File Integrity Check") _
		& @LF & "  kernel /casper/vmlinuz" _
		& @LF & "  append   " & $kbd_code & "noprompt boot=casper integrity-check initrd=/casper/" & $initrd_file & " splash --" _
		& @LF & "label memtest" _
		& @LF & "  menu label ^" & Translate("Memory Test") _
		& @LF & "  kernel /install/mt86plus"
	Return $boot_text
EndFunc

Func Fedora_WriteTextCFG($drive_letter)
	SendReport("Start-Fedora_WriteTextCFG ( Drive : " & $drive_letter & " )")
	Local $boot_text = "", $uuid
	$uuid = Get_Disk_UUID($drive_letter)
	$boot_text &= @LF & "default vesamenu.c32" _
			 & @LF & "timeout 100" _
			 & @LF & "menu background splash.jpg" _
			 & @LF & "menu title Welcome to Fedora !" _
			 & @LF & "menu color border 0 #ffffffff #00000000" _
			 & @LF & "menu color sel 7 #ffffffff #ff000000" _
			 & @LF & "menu color title 0 #ffffffff #00000000" _
			 & @LF & "menu color tabmsg 0 #ffffffff #00000000" _
			 & @LF & "menu color unsel 0 #ffffffff #00000000" _
			 & @LF & "menu color hotsel 0 #ff000000 #ffffffff" _
			 & @LF & "menu color hotkey 7 #ffffffff #ff000000" _
			 & @LF & "menu color timeout_msg 0 #ffffffff #00000000" _
			 & @LF & "menu color timeout 0 #ffffffff #00000000" _
			 & @LF & "menu color cmdline 0 #ffffffff #00000000" _
			 & @LF & "menu hidden" _
			 & @LF & "menu hiddenrow 5" _
			 & @LF & "label linux0" _
			 & @LF & "  menu label " & Translate("Persistent Mode") _
			 & @LF & "  kernel vmlinuz0" _
			 & @LF & "  append initrd=initrd0.img root=UUID=" & $uuid & " rootfstype=vfat rw liveimg overlay=UUID=" & $uuid & " quiet  rhgb " _
			 & @LF & "menu default" _
			 & @LF & "label check0" _
			 & @LF & "  menu label " & Translate("File Integrity Check") _
			 & @LF & "  kernel vmlinuz0" _
			 & @LF & "  append initrd=initrd0.img root=UUID=" & $uuid & " rootfstype=vfat rw liveimg overlay=UUID=" & $uuid & " quiet  rhgb check" _
			 & @LF & "label memtest" _
			 & @LF & " menu label " & Translate("Memory Test") _
			 & @LF & "  kernel memtest" _
			 & @LF & "label local" _
			 & @LF & "  menu label Boot from local drive" _
			 & @LF & "  localboot 0xffff"
	$file = FileOpen($selected_drive & "\syslinux\syslinux.cfg", 2)
	FileWrite($file, $boot_text)
	FileClose($file)
	UpdateLog("IN-Fedora_WriteTextCFG : Creating syslinux config file :" & @CRLF & $boot_text)
	SendReport("End-Fedora_WriteTextCFG")
EndFunc   ;==>Fedora_WriteTextCFG


Func CentOS_WriteTextCFG($drive_letter)
	SendReport("Start-CentOS_WriteTextCFG ( Drive : " & $drive_letter & " )")
	Local $boot_text = "", $uuid
	$uuid = Get_Disk_UUID($drive_letter)
	$boot_text &= @LF & "default vesamenu.c32" _
			 & @LF & "timeout 100" _
			 & @LF & "menu background splash.jpg" _
			 & @LF & "menu title Welcome to CentOS !" _
			 & @LF & "menu color border 0 #ffffffff #00000000" _
			 & @LF & "menu color sel 7 #ffffffff #ff000000" _
			 & @LF & "menu color title 0 #ffffffff #00000000" _
			 & @LF & "menu color tabmsg 0 #ffffffff #00000000" _
			 & @LF & "menu color unsel 0 #ffffffff #00000000" _
			 & @LF & "menu color hotsel 0 #ff000000 #ffffffff" _
			 & @LF & "menu color hotkey 7 #ffffffff #ff000000" _
			 & @LF & "menu color timeout_msg 0 #ffffffff #00000000" _
			 & @LF & "menu color timeout 0 #ffffffff #00000000" _
			 & @LF & "menu color cmdline 0 #ffffffff #00000000" _
			 & @LF & "menu hidden" _
			 & @LF & "menu hiddenrow 5" _
			 & @LF & "label linux0" _
			 & @LF & "  menu label " & Translate("Live Mode") _
			 & @LF & "  kernel vmlinuz0" _
			 & @LF & "  append initrd=initrd0.img root=UUID=" & $uuid & " rootfstype=vfat rw liveimg quiet " _
			 & @LF & "menu default" _
			 & @LF & "label check0" _
			 & @LF & "  menu label " & Translate("File Integrity Check") _
			 & @LF & "  kernel vmlinuz0" _
			 & @LF & "  append initrd=initrd0.img root=UUID=" & $uuid & " rootfstype=vfat rw liveimg quiet check" _
			 & @LF & "label memtest" _
			 & @LF & " menu label " & Translate("Memory Test") _
			 & @LF & "  kernel memtest" _
			 & @LF & "label local" _
			 & @LF & "  menu label Boot from local drive" _
			 & @LF & "  localboot 0xffff"
	$file = FileOpen($selected_drive & "\syslinux\syslinux.cfg", 2)
	FileWrite($file, $boot_text)
	FileClose($file)
	UpdateLog("IN-CentOS_WriteTextCFG : Creating CentOS syslinux config file :" & @CRLF & $boot_text)
	SendReport("End-CentOS_WriteTextCFG")
EndFunc   ;==>CentOS_WriteTextCFG

Func Mandriva_WriteTextCFG($drive_letter)
	SendReport("Start-Mandriva_WriteTextCFG ( Drive : " & $drive_letter & " )")
	Local $boot_text = ""
	$uuid = Get_Disk_UUID($drive_letter)
	$boot_text &= @LF & "default vesamenu.c32" _
			 & @LF & "timeout 100" _
			 & @LF & "menu background splash.jpg" _
			 & @LF & "menu title Welcome to Mandriva !" _
			 & @LF & "menu color border 0 #ffffffff #00000000" _
			 & @LF & "menu color sel 7 #ffffffff #ff000000" _
			 & @LF & "menu color title 0 #ffffffff #00000000" _
			 & @LF & "menu color tabmsg 0 #ffffffff #00000000" _
			 & @LF & "menu color unsel 0 #ffffffff #00000000" _
			 & @LF & "menu color hotsel 0 #ff000000 #ffffffff" _
			 & @LF & "menu color hotkey 7 #ffffffff #ff000000" _
			 & @LF & "menu color timeout_msg 0 #ffffffff #00000000" _
			 & @LF & "menu color timeout 0 #ffffffff #00000000" _
			 & @LF & "menu color cmdline 0 #ffffffff #00000000" _
			 & @LF & "menu hidden" _
			 & @LF & "menu hiddenrow 5" _
			 & @LF & "label linux0" _
			 & @LF & "  menu label " & Translate("Persistent Mode") _
			 & @LF & "  kernel vmlinuz0" _
			 & @LF & "  append initrd=initrd0.img root=UUID=" & $uuid & " rootfstype=vfat rw liveimg overlay=UUID=" & $uuid & " quiet  rhgb " _
			 & @LF & "menu default" _
			 & @LF & "label check0" _
			 & @LF & "  menu label " & Translate("File Integrity Check") _
			 & @LF & "  kernel vmlinuz0" _
			 & @LF & "  append initrd=initrd0.img root=UUID=" & $uuid & " rootfstype=vfat rw liveimg overlay=UUID=" & $uuid & "quiet  rhgb check" _
			 & @LF & "label memtest" _
			 & @LF & " menu label " & Translate("Memory Test") _
			 & @LF & "  kernel memtest" _
			 & @LF & "label local" _
			 & @LF & "  menu label Boot from local drive" _
			 & @LF & "  localboot 0xffff"
	$file = FileOpen($selected_drive & "\syslinux\syslinux.cfg", 2)
	FileWrite($file, $boot_text)
	FileClose($file)
	SendReport("End-Mandriva_WriteTextCFG")
EndFunc   ;==>Mandriva_WriteTextCFG


; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Checking ISO/File MD5 Hashes                  ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func GUI_Show_Check_status($status)
	Global $label_step2_status,$label_step2_status2
	$step2_display_menu=2
	GUI_Hide_Step2_Default_Menu()
	GUI_Show_Back_Button()
	GUICtrlSetState($label_step2_status,$GUI_HIDE)
	$label_step2_status2 = GUICtrlCreateLabel($status, 38 + $offsetx0, 235 + $offsety0, 300, 80)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0xFFFFFF)
EndFunc

Func Check_source_integrity($linux_live_file)
	SendReport("Start-Check_source_integrity (LinuxFile : " & $linux_live_file & " )")

	$shortname = path_to_name($linux_live_file)
	SendReport("distrib-" & $shortname)

	Global $MD5_ISO, $compatible_md5, $compatible_filename,$codenames_list, $release_number = -1


	; Pre-Checking
	If get_extension($linux_live_file) = "img" Then

		Disable_Persistent_Mode()
		Disable_VirtualBox_Option()
		Disable_Hide_Option()

		Step2_Check("good")
		$file_set_mode = "img"

		If DriveSpaceTotal($selected_drive) > Round(FileGetSize($linux_live_file)/(1024*1024)) Then
			Step1_Check("good")
		Else
			Step1_Check("bad")
		EndIf

		GUI_Show_Check_status(Translate("Support for .IMG files is experimental") & @CRLF & Translate("Only Live mode is currently available in step 3, virtualization option has been disabled"))
		SendReport("IN-Check_Source (img selected :" & $linux_live_file & ")")

	Else
		Enable_Persistent_Mode()
		Enable_VirtualBox_Option()
		Enable_Hide_Option()
		SendReport("IN-Check_Source (iso selected :" & $linux_live_file & ")")
		$file_set_mode = "iso"
	EndIf


	; No check if it's an img file or if the user do not want to
	If IniRead($settings_ini, "General", "skip_recognition", "no") == "yes" Or get_extension($linux_live_file) = "img" Then
		Step2_Check("good")
		$temp_index = _ArraySearch($codenames_list, "default")
		$release_number = $temp_index
		Disable_Persistent_Mode()
		SendReport("IN-Check_source_integrity (skipping recognition, using default mode)")
		Return ""
	EndIf


	SendReport("Start-Check_source_integrity-1")
	If Check_if_version_non_grata($shortname) Then Return ""

	; Some files do not need to be checked by MD5 ( Alpha releases ...). Only trusting filename
	$temp_index = _ArraySearch($compatible_filename, $shortname)
	If $temp_index > 0 Then
		If ReleaseGetMD5($temp_index) = "ANY" Then
			;MsgBox(4096, Translate("Verifying") & " OK", Translate("This version is compatible and its integrity was checked"))
			GUI_Show_Check_status(Translate("This version is compatible and its integrity was checked")&@CRLF&Translate("Recognized Linux")&" : "&@CRLF& @CRLF & @TAB &ReleaseGetDescription($temp_index))
			$release_number = $temp_index
			Check_If_Default_Should_Be_Used($release_number)
			SendReport("IN-Check_source_integrity (MD5 set to any, using : " & ReleaseGetCodename($release_number) & " )")
			Return ""
		Else
			$temp_index = 0
		EndIf
	EndIf

	If IniRead($settings_ini, "General", "skip_md5", "no") = "no" Then
		$MD5_ISO = Check_ISO($linux_live_file)
		$temp_index = _ArraySearch($compatible_md5, $MD5_ISO)
	Else
		$MD5_ISO = "123"
		$temp_index = -1
	EndIf

	SendReport("IN-Check_source_integrity- Intelligent Processing")
	If $temp_index > 0 Then
		; Good version -> COMPATIBLE
		GUI_Show_Check_status(Translate("Verifying") & " OK"&@CRLF& Translate("This version is compatible and its integrity was checked")&@CRLF&Translate("Recognized Linux")&" : "&@CRLF& @CRLF & @TAB &ReleaseGetDescription($temp_index))
		Step2_Check("good")
		$release_number = $temp_index
		SendReport("IN-Check_source_integrity (Compatible version found : " & ReleaseGetCodename($release_number) & " )")
	Else
		$temp_index = _ArraySearch($compatible_filename, $shortname)
		If $temp_index > 0 Then
			; Filename is known but MD5 not OK -> COMPATIBLE BUT ERROR
			$release_number = $temp_index
			GUI_Show_Check_status(Translate("You have the right ISO file but it is corrupted or was altered.") &" "&Translate("Please download it again.")&@CRLF&Translate("However, LinuxLive USB Creator will try to use same install parameters as for") & @CRLF & @TAB & @TAB& ReleaseGetDescription($release_number))
			Step2_Check("warning")
			SendReport("IN-Check_source_integrity (MD5 not found but filename found : " & ReleaseGetFilename($release_number) & " )")
		Else
			; Filename is not known but trying to find what it is with its name => INTELLIGENT PROCESSING
			SendReport("IN-Check_source_integrity (start intelligent processing)")

			If ( StringInStr($shortname, "10.04") OR StringInStr($shortname, "lucid") OR StringInStr($shortname, "9.10") ) And StringInStr($shortname, "netbook") Then
				; Ubuntu Karmic (>=9.10) based
				$release_number = _ArraySearch($codenames_list, "ubuntu-netbook-last")
			ElseIf StringInStr($shortname, "grml") Then
				; Grml
				$release_number = _ArraySearch($codenames_list, "grml-last")
			ElseIf StringInStr($shortname, "knoppix") Then
				; Knoppix
				$release_number = _ArraySearch($codenames_list, "knoppix-last")
			ElseIf StringInStr($shortname, "9.10") Or StringInStr($shortname, "lucid") Then
				; Ubuntu Karmic 10.04 based
				$release_number = _ArraySearch($codenames_list, "ubuntu-10.04")
			ElseIf (StringInStr($shortname, "karmic") Or StringInStr($shortname, "buntu")) Then
				; Ubuntu Karmic (>=9.10) based
				$release_number = _ArraySearch($codenames_list, "ubuntu-last")
			ElseIf StringInStr($shortname, "9.04") Then
				; Ubuntu 9.04 based
				$release_number = _ArraySearch($codenames_list, "ubuntu-904")
			ElseIf StringInStr($shortname, "kuki") Then
				; Kuki based (Ubuntu)
				$release_number = _ArraySearch($codenames_list, "kuki-last")
			ElseIf StringInStr($shortname, "fedora") Or StringInStr($shortname, "F10") Or StringInStr($shortname, "F11") OR StringInStr($shortname, "F12") Then
				; Fedora Based
				$release_number = _ArraySearch($codenames_list, "fedora-last")
			ElseIf StringInStr($shortname, "mint") Then
				; Mint Based
				$release_number = _ArraySearch($codenames_list, "mint-last")
			ElseIf StringInStr($shortname, "gnewsense") Then
				; gNewSense Based
				$release_number = _ArraySearch($codenames_list, "gnewsense-last")
			ElseIf StringInStr($shortname, "clonezilla") Then
				; Clonezilla
				$release_number = _ArraySearch($codenames_list, "clonezilla-last")
			ElseIf StringInStr($shortname, "gparted") Then
				; Gparted
				$release_number = _ArraySearch($codenames_list, "gparted-last")
			ElseIf StringInStr($shortname, "debian") Then
				; Debian
				$release_number = _ArraySearch($codenames_list, "debiangnome-last")
			ElseIf StringInStr($shortname, "toutou") Then
				; Toutou Linux
				$release_number = _ArraySearch($codenames_list, "toutou-last")
			ElseIf StringInStr($shortname, "puppy") Or StringInStr($shortname, "pup-") Then
				; Puppy Linux
				$release_number = _ArraySearch($codenames_list, "puppy-last")
				GUI_Show_Check_status(Translate("This ISO is not compatible."))
			ElseIf StringInStr($shortname, "slax") Then
				; Slax
				$release_number = _ArraySearch($codenames_list, "slax-last")
			ElseIf StringInStr($shortname, "centos") Then
				; CentOS
				$release_number = _ArraySearch($codenames_list, "centos-last")
			ElseIf StringInStr($shortname, "pmagic") Then
				; Parted Magic
				$release_number = _ArraySearch($codenames_list, "pmagic-last")
			ElseIf StringInStr($shortname, "pclinuxos") Then
				; PCLinuxOS
				$release_number = _ArraySearch($codenames_list, "pclinuxoskde-last")
			ElseIf StringInStr($shortname, "slitaz") Then
				; Slitaz
				$release_number = _ArraySearch($codenames_list, "slitaz-last")
			ElseIf StringInStr($shortname, "tinycore") Then
				; Tiny Core
				$release_number = _ArraySearch($codenames_list, "tinycore-last")
			ElseIf StringInStr($shortname, "ophcrack") Then
				; OphCrack
				$release_number = _ArraySearch($codenames_list, "ophcrackxp-last")
			ElseIf StringInStr($shortname, "crunch") Then
				; CrunchBang Based
				$release_number = _ArraySearch($codenames_list, "crunchbangstd-last")
			ElseIf StringInStr($shortname, "sabayon") Then
				; Sabayon Linux
				$release_number = _ArraySearch($codenames_list, "sabayonG-last")
			ElseIf StringInStr($shortname, "SystemRescueCd") Then
				; System Rescue CD
				$release_number = _ArraySearch($codenames_list, "systemrescue-last")
			ElseIf StringInStr($shortname, "gentoo") Then
				; Gentoo
				$release_number = _ArraySearch($codenames_list, "gentoo-last")
			ElseIf StringInStr($shortname, "backtrack") OR StringInStr($shortname, "bt") Then
				; BackTrack
				$release_number = _ArraySearch($codenames_list, "backtrack-last")
			Else
				; Any Linux, except those known not to work in Live mode
				$release_number = _ArraySearch($codenames_list, "default")
			EndIf

			GUI_Show_Check_status(Translate("This Linux is not in the compatibility list")& "." & @CRLF &Translate("However, LinuxLive USB Creator will try to use same install parameters as for") & @CRLF & @CRLF & @TAB & ReleaseGetDescription($release_number))

			if ReleaseGetCodename($release_number)<>"default" Then
				SendReport("IN-Check_source_integrity (MD5 not found but keyword found , will use : " & ReleaseGetCodename($release_number) & " )")
			Else
				SendReport("IN-Check_source_integrity (MD5 not found AND keyword not found -> using DEFAULT mode")
			EndIf

			SendReport("IN-Check_source_integrity (end intelligent processing)")
		EndIf
	EndIf
	Check_If_Default_Should_Be_Used($release_number)
	SendReport("End-Check_source_integrity")
EndFunc   ;==>Check_source_integrity


Func Check_If_Default_Should_Be_Used($release_in_list)
	SendReport("Start-Check_If_Default_Should_Be_Used (release : " & $release_in_list & " )")
	#cs $codename= ReleaseGetCodename($release_in_list)
	If StringInStr($variants_using_default_mode,$codename)>0 Then
		Disable_Persistent_Mode()
		SendReport("IN-Check_If_Default_Should_Be_Used ( Disable persistency for " & $codename& " )")
	EndIf
	#ce
	$features=ReleaseGetSupportedFeatures($release_in_list)
	$codename=ReleaseGetCodename($release_in_list)

	if StringInStr($features,"default") Then
		Disable_Persistent_Mode()
		Step2_Check("good")
		SendReport("IN-Check_If_Default_Should_Be_Used ( Disable persistency for " & $codename& " )")
	Elseif StringInStr($features,"persistence") Then
		if StringInStr($features,"builtin") Then
			BuiltIn_Persistent_Mode()
			SendReport("IN-Check_If_Default_Should_Be_Used ( builtin persistency for " & $codename& " )")
		Else
			Enable_Persistent_Mode()
			SendReport("IN-Check_If_Default_Should_Be_Used ( Enable persistency for " & $codename& " )")
		EndIf
		Step2_Check("good")
	EndIf
	SendReport("End-Check_If_Default_Should_Be_Used")
EndFunc   ;==>Check_If_Default_Should_Be_Used

; Check the ISO against black list
Func Check_if_version_non_grata($version_name)
	SendReport("Start-Check_if_version_non_grata (Version : " & $version_name & " )")

	Local $non_grata = 0

	$blacklist = IniRead($blacklist_ini, "Black_List", "black_keywords", "sparc,alternate")
	$blacklist_array = StringSplit($blacklist, ',')

	For $i = 1 To $blacklist_array[0]
		If StringInStr($version_name, $blacklist_array[$i]) Then
			$non_grata = 1
			ExitLoop
		EndIf
	Next

	If $non_grata = 1 Then
		MsgBox(48, Translate("Please read"), Translate("This ISO is not compatible.") & @CRLF & Translate("Please read the compatibility list in user guide"))
		Step2_Check("warning")
		SendReport("End-Check_if_version_non_grata (is Non grata)")
		Return 1
	EndIf
	SendReport("End-Check_if_version_non_grata (is not Non grata)")
EndFunc   ;==>Check_if_version_non_grata

Func Check_ISO($FileToHash)
	SendReport("Start-Check_ISO ( File : " & $FileToHash & " )")
	; Used to avoid redrawing the old elements of Step 2 (ISO, CD and download)
	$step2_display_menu = 2
	GUI_Hide_Step2_Default_Menu()

	$progress_bar = _ProgressCreate(38 + $offsetx0, 238 + $offsety0, 300, 30)
	_ProgressSetImages($progress_bar, @ScriptDir & "\tools\img\progress_green.jpg", @ScriptDir & "\tools\img\progress_background.jpg")
	_ProgressSetFont($progress_bar, "", -1, -1, 0x000000, 0)
	$label_step2_status = GUICtrlCreateLabel(Translate("Checking file")&" : "&path_to_name($FileToHash), 38 + $offsetx0, 231 + $offsety0 + 50, 300, 80)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0xFFFFFF)
	Global $BufferSize = 0x20000
	Global $FileHandle = FileOpen($FileToHash, 16)
	If $FileToHash = "" Then
		SendReport("End-MD5_ISO (no iso)")
		Return "no iso"
	EndIf

	$MD5CTX = _MD5Init()
	$iterations = Ceiling(FileGetSize($FileToHash) / $BufferSize)
	For $i = 1 To $iterations
		_MD5Input($MD5CTX, FileRead($FileHandle, $BufferSize))
		$percent_md5 = Round(100 * $i / $iterations)
		_ProgressSet($progress_bar,$percent_md5 )
		_ProgressSetText($progress_bar, $percent_md5&"%" )
	Next

	$hash = _MD5Result($MD5CTX)
	FileClose($FileHandle)
	_ProgressSet($progress_bar,100 )
	_ProgressSetText($progress_bar, "100%" )
	_ProgressDelete($progress_bar)
	GUI_Show_Back_Button()
	$hexa_hash = StringTrimLeft($hash, 2)
	SendReport("End-MD5_ISO ( Hash : " & $hexa_hash & " )")
	Return $hexa_hash
EndFunc

Func MD5_ISO($FileToHash)

	ProgressOn(Translate("Verifying"), Translate("Integrity + compatibility check"), "0 %", -1, -1, 16)
	Global $BufferSize = 0x20000
	If $FileToHash = "" Then
		SendReport("End-MD5_ISO (no iso)")
		Return "no iso"
	EndIf
	Global $FileHandle = FileOpen($FileToHash, 16)

	$MD5CTX = _MD5Init()
	$iterations = Ceiling(FileGetSize($FileToHash) / $BufferSize)
	For $i = 1 To $iterations
		_MD5Input($MD5CTX, FileRead($FileHandle, $BufferSize))
		$percent_md5 = Round(100 * $i / $iterations)
		ProgressSet($percent_md5, $percent_md5 & " %")
	Next
	$hash = _MD5Result($MD5CTX)
	FileClose($FileHandle)
	ProgressSet(100, "100%", Translate("Check completed"))
	Sleep(500)
	ProgressOff()
	$hexa_hash = StringTrimLeft($hash, 2)
	SendReport("End-MD5_ISO ( Hash : " & $hexa_hash & " )")
	Return $hexa_hash
EndFunc   ;==>MD5_ISO

#cs
	Func Check_folder_integrity($folder)
	SendReport("Start-Check_folder_integrity ( Folder : " & $folder & " )")
	Global $version_in_file, $MD5_FOLDER
	If IniRead($settings_ini, "General", "skip_checking", "no") == "yes" Then
	Step2_Check("good")
	SendReport("End-Check_folder_integrity (skip)")
	Return ""
	EndIf

	$info_file = FileOpen($folder & "\.disk\info", 0)
	If $info_file <> -1 Then
	$version_in_file = FileReadLine($info_file)
	FileClose($info_file)
	If Check_if_version_non_grata($version_in_file) Then
	SendReport("End-Check_folder_integrity (version non grata)")
	Return ""
	EndIf
	EndIf

	Global $progression_foldermd5
	$file = FileOpen($folder & "\md5sum.txt", 0)
	If $file = -1 Then
	MsgBox(0, Translate("Error"), Translate("Unable to open MD5SUM.txt"))
	FileClose($file)
	Step2_Check("warning")
	SendReport("End-Check_folder_integrity (Cannot open MD5SUM.txt)")
	Return ""
	EndIf
	$progression_foldermd5 = ProgressOn(Translate("Verifying"), Translate("Checking integrity"), "0 %", -1, -1, 16)
	$corrupt = 0
	While 1
	$line = FileReadLine($file)
	If @error = -1 Then ExitLoop
	$array_hash = StringSplit($line, '  .', 1)
	$file_to_hash = $folder & StringReplace($array_hash[2], "/", "\")
	$file_md5 = MD5_FOLDER($file_to_hash)
	If ($file_md5 <> $array_hash[1]) Then
	ProgressOff()
	FileClose($file)
	MsgBox(48, Translate("Error"), Translate("This file is corrupted") & " : " & $file_to_hash)
	Step2_Check("warning")
	$corrupt = 1
	$MD5_FOLDER = "bad file :" & $file_to_hash
	ExitLoop
	EndIf
	WEnd
	ProgressSet(100, "100%", Translate("Check completed"))
	Sleep(500)
	ProgressOff()
	If $corrupt = 0 Then
	MsgBox(4096, Translate("Check completed"), Translate("All files have been successfully checked."))
	Step2_Check("good")
	$MD5_FOLDER = "Good"
	EndIf
	FileClose($file)
	SendReport("End-Check_folder_integrity")
	EndFunc   ;==>Check_folder_integrity


	Func MD5_FOLDER($FileToHash)
	SendReport("Start-MD5_FOLDER ( Folder : " & $FileToHash & " )")
	Global $progression_foldermd5
	Global $BufferSize = 0x20000

	If $FileToHash = "" Then
	SendReport("End-MD5_FOLDER (no folder)")
	Return "no iso"
	EndIf

	Global $FileHandle = FileOpen($FileToHash, 16)

	$MD5CTX = _MD5Init()
	$iterations = Ceiling(FileGetSize($FileToHash) / $BufferSize)
	For $i = 1 To $iterations
	_MD5Input($MD5CTX, FileRead($FileHandle, $BufferSize))
	$percent_md5 = Round(100 * $i / $iterations)
	ProgressSet($percent_md5, Translate("Checking file") & " " & path_to_name($FileToHash) & " (" & $percent_md5 & " %)")
	Next
	$hash = _MD5Result($MD5CTX)
	FileClose($FileHandle)
	$folder_hash = StringTrimLeft($hash, 2)
	SendReport("Start-MD5_FOLDER ( Hash : " & $folder_hash & " )")
	Return
	EndFunc   ;==>MD5_FOLDER
#ce

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Statistics                                  ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func SendStats()
	Global $anonymous_id
	SendReport("stats-id=" & $anonymous_id & "&version=" & $software_version & "&os=" & @OSVersion & "-" & @OSArch & "-" & @OSServicePack & "&lang=" & _Language_for_stats())
EndFunc   ;==>SendStats

Func _Language_for_stats()
	Select
		Case StringInStr("0413,0813", @OSLang)
			Return "Dutch"

		Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009, 2409,2809,2c09,3009,3409", @OSLang)
			Return "English"

		Case StringInStr("0407,0807,0c07,1007,1407,0413,0813", @OSLang)
			Return "German"

		Case StringInStr("0410,0810", @OSLang)
			Return "Italian"

		Case StringInStr("0414,0814", @OSLang)
			Return "Norwegian"

		Case StringInStr("0415", @OSLang)
			Return "Polish"

		Case StringInStr("0416,0816", @OSLang)
			Return "Portuguese";

		Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a, 240a,280a,2c0a,300a,340a,380a,3c0a,400a, 440a,480a,4c0a,500a", @OSLang)
			Return "Spanish"

		Case StringInStr("041d,081d", @OSLang)
			Return "Swedish"

		Case StringInStr("040c,080c,0c0c,100c,140c,180c", @OSLang)
			Return "French";remove and return function specifally to oslang
		Case Else
			Return @OSLang
	EndSelect
EndFunc   ;==>_Language_for_stats

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
	GUICtrlSetState($live_mode_only_label, $GUI_SHOW)
	Step3_Check("good")
EndFunc   ;==>Disable_Persistent_Mode

Func Enable_Persistent_Mode()
	GUICtrlSetState($slider, $GUI_SHOW)
	GUICtrlSetState($slider_visual, $GUI_SHOW)
	GUICtrlSetState($label_max, $GUI_SHOW)
	GUICtrlSetState($label_min, $GUI_SHOW)
	GUICtrlSetState($slider_visual_Mo, $GUI_SHOW)
	GUICtrlSetState($slider_visual_mode, $GUI_SHOW)
	GUICtrlSetState($live_mode_only_label, $GUI_HIDE)
EndFunc   ;==>Enable_Persistent_Mode

Func BuiltIn_Persistent_Mode()
	GUICtrlSetState($slider, $GUI_HIDE)
	GUICtrlSetState($slider_visual, $GUI_HIDE)
	GUICtrlSetState($label_max, $GUI_HIDE)
	GUICtrlSetState($label_min, $GUI_HIDE)
	GUICtrlSetState($slider_visual_Mo, $GUI_HIDE)
	GUICtrlSetState($slider_visual_mode, $GUI_HIDE)
	GUICtrlSetState($live_mode_only_label, $GUI_HIDE)
	GUICtrlSetState($builtin_persistence_label,$GUI_SHOW)
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
	If WinActive("LinuxLive USB Creator") Or WinActive("LiLi USB Creator") Then
		SendReport("Start-GUI_Exit")
		If @InetGetActive Then InetGet("abort")
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
		If DriveSpaceTotal($selected_drive) > 700 Then
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
	$source_file = FileOpenDialog(Translate("Choisir l'image ISO d'un CD live de Linux"), @ScriptDir & "\", "ISO / IMG / ZIP (*.iso;*.img;*.zip)", 1)
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
		$temp_index = _ArraySearch($compatible_filename, "regular_linux.iso")
		$release_number = $temp_index
		Step2_Check("warning")
	EndIf
	SendReport("End-GUI_Choose_CD")
EndFunc   ;==>GUI_Choose_CD

Func GUI_Download()
	SendReport("Start-GUI_Download")
	; Used to avoid redrawing the old elements of Step 2 (ISO, CD and download)
	$step2_display_menu = 1
	GUI_Hide_Step2_Default_Menu()

	; Drawing new menu
	$combo_linux = GUICtrlCreateCombo(">> " & Translate("Select your favourite Linux"), 38 + $offsetx0, 240 + $offsety0, 300, -1, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))

	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetOnEvent(-1, "GUI_Select_Linux")

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
	GUICtrlDelete($BACK_AREA)
	$cleaner2 = GUICtrlCreateLabel("", 5 + $offsetx0, 300 + $offsety0, 32, 32)
EndFunc

Func GUI_Hide_Step2_Download_Menu()
	GUICtrlSetState($combo_linux, $GUI_HIDE)
	GUICtrlSetState($download_manual, $GUI_HIDE)
	GUICtrlSetState($download_auto, $GUI_HIDE)
	GUICtrlSetState($label_step2_status, $GUI_HIDE)
	GUICtrlSetState($download_label2, $GUI_HIDE)
	GUICtrlSetState($OR_label, $GUI_HIDE)
	$cleaner = GUICtrlCreateLabel("", 38 + $offsetx0, 238 + $offsety0, 300, 30)
	GUI_Hide_Back_Button()
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
	If @InetGetActive = 1 Then InetGet("abort")
	GUI_Hide_Step2_Download_Menu()
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

	$BACK_AREA = GUICtrlCreateLabel("", 5 + $offsetx0, 300 + $offsety0, 32, 32)
	$DRAW_BACK = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetOnEvent(-1, "GUI_Back_Download")

	$progress_bar = _ProgressCreate(38 + $offsetx0, 238 + $offsety0, 300, 30)
	_ProgressSetImages($progress_bar, @ScriptDir & "\tools\img\progress_green.jpg", @ScriptDir & "\tools\img\progress_background.jpg")
	_ProgressSetFont($progress_bar, "", -1, -1, 0x000000, 0)
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

			$temp_latency = Ping(URLToHostname($mirror))
			$tested_mirrors = $tested_mirrors + 1
			If @error = 0 Then
				$temp_size = Round(InetGetSize($mirror) / 1048576)
				If $temp_size < 5 Or $temp_size > 5000 Then
					$temp_latency = 10000
				EndIf
			Else
				$temp_latency = 10000
			EndIf
			_ProgressSet($progress_bar, $tested_mirrors * 100 / $available_mirrors)
			_ProgressSetText($progress_bar, Translate("Testing mirror") & " : " & URLToHostname($mirror))
		Else
			$temp_latency = 10000
		EndIf
		$latency[$i] = $temp_latency

	Next

	If _ArrayMin($latency, 1, $R_MIRROR1, $R_MIRROR10) = 10000 Then
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
			$inet_success = InetGet($best_mirror, @ScriptDir & "\" & $filename, 1, 1)
			If $inet_success Then
				UpdateStatusStep2(Translate("Downloading") & " " & $filename & @CRLF & Translate("from") & " " & URLToHostname($best_mirror))
				Download_State()
			Else
				UpdateStatusStep2(Translate("Error while trying to download") & @CRLF & Translate("Please check your internet connection or try with another linux"))
			EndIf
		EndIf
	EndIf
	Sleep(3000)
	_ProgressDelete($progress_bar)

	GUI_Back_Download()
	SendReport("End-DownloadRelease")
EndFunc   ;==>DownloadRelease

; Let the user select a mirror
Func DisplayMirrorList($latency_table, $release_in_list)
	Local $hImage, $hListView

	Opt("GUIOnEventMode", 0)

	; Create GUI
	GUICreate("Select the mirror", 350, 250)
	$hListView = GUICtrlCreateListView("  " & Translate("Latency") & "  |  " & Translate("Server Name") & "  | ", 0, 0, 350, 200)
	_GUICtrlListView_SetColumnWidth($hListView, 0, 80)
	_GUICtrlListView_SetColumnWidth($hListView, 1, 230)
	$hImage = _GUIImageList_Create()
	$copy_it = GUICtrlCreateButton(Translate("Copy link"), 30, 210, 120, 30)
	$launch_it = GUICtrlCreateButton(Translate("Launch in my browser"), 180, 210, 150, 30)


	Local $latency_server[$R_MIRROR10 - $R_MIRROR1 + 1][3]
	For $i = $R_MIRROR1 To $R_MIRROR10
		$mirror = $releases[$release_in_list][$i]
		If $mirror <> "NotFound" And $mirror <> "" Then
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
	GUISetState()

	; Loop until user exits
	Do
		$msg = GUIGetMsg()

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

	Until $msg = $GUI_EVENT_CLOSE

	GUIDelete()
	Opt("GUIOnEventMode", 1)
	GUIRegisterMsg($WM_PAINT, "DrawAll")
	WinActivate($for_winactivate)
	GUISetState($GUI_SHOW, $CONTROL_GUI)
EndFunc   ;==>DisplayMirrorList

Func Download_State()
	SendReport("Start-Download_State")
	Local $begin, $oldgetbytesread, $estimated_time = ""

	$begin = TimerInit()
	$oldgetbytesread = @InetGetBytesRead

	$iso_size_mb = RoundForceDecimal($iso_size / (1024 * 1024))
	While @InetGetActive
		$percent_downloaded = Int((100 * @InetGetBytesRead / $iso_size))
		_ProgressSet($progress_bar, $percent_downloaded)
		$dif = TimerDiff($begin)
		If $dif > 1000 Then
			$bytes_per_ms = (@InetGetBytesRead - $oldgetbytesread) / $dif
			$estimated_time = HumanTime(($iso_size - @InetGetBytesRead) / (1000 * $bytes_per_ms))
			$begin = TimerInit()
			$oldgetbytesread = @InetGetBytesRead
		EndIf
		_ProgressSetText($progress_bar, $percent_downloaded & "% ( " & RoundForceDecimal(@InetGetBytesRead / (1024 * 1024)) & " / " & $iso_size_mb & " " & "MB" & " ) " & $estimated_time)
		Sleep(300)
	WEnd

	_ProgressSet($progress_bar, 100)
	_ProgressSetText($progress_bar, "100% ( " & Round($iso_size / (1024 * 1024)) & " / " & Round($iso_size / (1024 * 1024)) & " " & "MB" & " )")

	UpdateStatusStep2(Translate("Download complete") & @CRLF & Translate("Check will begin shortly"))
	Sleep(3000)
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
	SendReport("Start-GUI_Launch_Creation")
	; Disable the controls and re-enable after creation

	$selected_drive = StringLeft(GUICtrlRead($combo), 2)

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
		EndIf

		; Create Autorun menu
		Create_autorun($selected_drive, $release_number)

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

		If GUICtrlRead($virtualbox) == $GUI_CHECKED And $virtualbox_check >= 1 Then Final_check()

		Sleep(1000)


		;Final_Help($selected_drive)
		ShellExecute("http://www.linuxliveusb.com/using-lili.html", "", "", "", 7)
		If isBeta() Then Ask_For_Feedback()
	Else
		UpdateStatus("Please validate step 1 to 3")
	EndIf
	SendReport("End-GUI_Launch_Creation")
EndFunc   ;==>GUI_Launch_Creation

Func Final_Help($selected_drive)
	SendReport("Start-Final_Help (Drive : " & $selected_drive & " )")
	$gui_finish = GUICreate(Translate("Your LinuxLive key is now up and ready !"), 604, 378, -1, -1)
	GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_Events2")
	GUISetOnEvent($GUI_EVENT_MINIMIZE, "GUI_Events2")
	GUISetOnEvent($GUI_EVENT_RESTORE, "GUI_Events2")
	GUICtrlCreatePic(@ScriptDir & "\tools\img\tuto.jpg", 350, 0, 254, 378)
	$printme = @CRLF & @CRLF & @CRLF & @CRLF & "  " & Translate("Your LinuxLive key is now up and ready !") _
			 & @CRLF & @CRLF & "    " & Translate("In order to launch LinuxLive :") _
			 & @CRLF & "    " & Translate("Remove your key and insert it again.") _
			 & @CRLF & "    " & Translate("Go to 'My Computer'") _
			 & @CRLF & "    " & Translate("Right click on you key and select :") & @CRLF

	If FileExists($selected_drive & "\VirtualBox\Virtualize_This_Key.exe") And FileExists($selected_drive & "VirtualBox\VirtualBox.exe") Then
		$printme &= @CRLF & "    " & "-> " & Translate("'LinuxLive!' to launch linux in windows")
		$printme &= @CRLF & "    " & "-> " & Translate("'VirtualBox Interface' to launch VirtualBox full interface")
	EndIf
	$printme &= @CRLF & "    " & "-> " & Translate("'CD Menu' to launch the original CD menu")
	GUICtrlCreateLabel($printme, 0, 0, 350, 378)
	GUICtrlSetBkColor(-1, 0x0ffffff)
	GUICtrlSetFont(-1, 10, 600)
	GUISetState(@SW_SHOW)
	SendReport("End-Final_Help")
EndFunc   ;==>Final_Help

Func Ask_For_Feedback()
	$return = MsgBox(65, "Help me to improve LiLi", "This is a Beta or RC version, click OK to leave a feedback or click Cancel to close this window")
	If $return = 1 Then ShellExecute("http://www.linuxliveusb.com/feedback/index.php", "", "", "", 7)
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
	_About(Translate("About this software"), "LiLi USB Creator", "CopyLeft by Thibaut Lauzière - GPL v3 License", $software_version, Translate("User's Guide"), "http://www.linuxliveusb.com/how-to.html", Translate("Homepage"), "http://www.linuxliveusb.com", Translate("Donate"), "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8297661", @AutoItExe, 0x0000FF, 0xFFFFFF, -1, -1, -1, -1, $CONTROL_GUI)
	SendReport("End-GUI_Help_Step5")
EndFunc   ;==>GUI_Help_Step5

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Locales management                            ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#cs
	Select

	Case StringInStr("0413,0813", @OSLang)

	Return "Dutch"

	Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009," _

	& "2409,2809,2c09,3009,3409", @OSLang)

	Return "English"

	Case StringInStr("040c,080c,0c0c,100c,140c,180c", @OSLang)

	Return "French"

	Case StringInStr("0407,0807,0c07,1007,1407", @OSLang)

	Return "German"

	Case StringInStr("0410,0810", @OSLang)

	Return "Italian"

	Case StringInStr("0414,0814", @OSLang)

	Return "Norwegian"

	Case StringInStr("0415", @OSLang)

	Return "Polish"

	Case StringInStr("0416,0816", @OSLang)

	Return "Portuguese"

	Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a," _

	& "240a,280a,2c0a,300a,340a,380a,3c0a,400a," _
	& "440a,480a,4c0a,500a", @OSLang)

	Return "Spanish"

	Case StringInStr("041d,081d", @OSLang)

	Return "Swedish"

	Case Else

	Return "Other (can't determine with @OSLang directly)"

	EndSelect
#ce

Func _Language()
	SendReport("Start-_Language")
	$force_lang = IniRead($settings_ini, "General", "force_lang", "no")
	If $force_lang <> "no" And (FileExists($lang_ini & $force_lang & ".ini") Or $force_lang = "English") Then
		$lang_ini = $lang_ini & $force_lang & ".ini"
		SendReport("End-_Language (Force Lang=" & $force_lang & ")")
		Return $force_lang
	EndIf
	Select
		Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009,2409,2809,2c09,3009,3409", @OSLang)
			$lang_found = "English"
		Case StringInStr("040c,080c,0c0c,100c,140c,180c", @OSLang)
			$lang_found = "French"
		Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a,240a,280a,2c0a,300a,340a,380a,3c0a,400a,440a,480a,4c0a,500a", @OSLang)
			$lang_found = "Spanish"
		Case StringInStr("0407,0807,0c07,1007,1407", @OSLang)
			$lang_found = "German"
		Case StringInStr("0416,0816", @OSLang)
			$lang_found = "Portuguese"
		Case StringInStr("0410,0810", @OSLang)
			$lang_found = "Italian"
		Case StringInStr("0414,0814", @OSLang)
			$lang_found = "Norwegian"
		Case StringInStr("0411", @OSLang)
			$lang_found = "Japanese"
		Case Else
			$lang_found = "English"
	EndSelect
	$lang_ini = $lang_ini & $lang_found & ".ini"
	SendReport("End-_Language " & $lang_found)
	Return $lang_found
EndFunc   ;==>_Language

Func Translate($txt)
	Return IniRead($lang_ini, $lang, $txt, $txt)
EndFunc   ;==>Translate

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Updates management                            ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Check_for_updates()
	SendReport("Start-Check_for_updates")
	$ping = Ping("www.google.com")
	If Not @error Then
		$check_result = _INetGetSource($check_updates_url & "?version")
		if isBeta() Then $check_result_beta = _INetGetSource($check_updates_url & "?beta-version")
		SendReport("IN-Check_for_updates ( Last version found : " & $check_result & " )")
		if isBeta() AND VersionCompare($check_result_beta, $software_version) = 1 Then
			$return = MsgBox(68, Translate("There is a new Beta version available"), Translate("Your LiLi's version is not up to date.") & @CRLF & @CRLF & Translate("Last beta version is") & " : " & $check_result_beta & @CRLF & Translate("Your version is") & " : " & $software_version & @CRLF & @CRLF & Translate("Do want to download it ?"))
			If $return = 6 Then ShellExecute("http://www.linuxliveusb.com/")
		ElseIf Not $check_result = 0 And VersionCompare($check_result, $software_version) = 1 Then
			$return = MsgBox(68, Translate("There is a new version available"), Translate("Your LiLi's version is not up to date.") & @CRLF & @CRLF & Translate("Last version is") & " : " & $check_result & @CRLF & Translate("Your version is") & " : " & $software_version & @CRLF & @CRLF & Translate("Do want to download it ?"))
			If $return = 6 Then ShellExecute("http://www.linuxliveusb.com/")
		EndIf
	EndIf
	SendReport("End-Check_for_updates")
EndFunc   ;==>Check_for_updates

; Compare 2 versions
;	0 =  Versions are equals
;	1 =  Version 1 is higher
;   2 =  Version 2 is higher
Func VersionCompare($version1, $version2)
	If VersionCode($version1) = VersionCode($version2) Then
		Return 0
	ElseIf VersionCode($version1) > VersionCode($version2) Then
		Return 1
	Else
		Return 2
	EndIf
EndFunc   ;==>VersionCompare

; Transform a label to a number
Func SortVersionLabel($version_label)
	Switch StringLower($version_label)
		Case "alpha"
			Return 0
		Case "beta"
			Return 1
		Case "beta1"
			Return 2
		Case "beta2"
			Return 3
		Case "beta3"
			Return 4
		Case "rc1"
			Return 5
		Case "rc2"
			Return 6
		Case "rc3"
			Return 7
		Case Else
			Return 8
	EndSwitch
EndFunc   ;==>SortVersionLabel

; Transform a version name to a version code to be compared up to 3 digits like "2.3.1 Beta"
Func VersionCode($version)
	$parse_version = StringSplit($version, " ")
	$version_number = StringReplace($parse_version[1], ".", "")
	If StringLen($version_number) = 2 Then $version_number &= "0"
	If $parse_version[0] >= 2 Then
		$version_number &= SortVersionLabel($parse_version[2])
	Else
		$version_number &= "8"
	EndIf
	Return $version_number
EndFunc   ;==>VersionCode

Func isBeta()
	If StringInStr($software_version, "RC") Or StringInStr($software_version, "Beta") Or StringInStr($software_version, "Alpha") Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>isBeta
