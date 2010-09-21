#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=tools\img\lili.ico
#AutoIt3Wrapper_Compression=3
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=Enjoy !
#AutoIt3Wrapper_Res_Description=Easily create a Linux Live USB
#AutoIt3Wrapper_Res_Fileversion=2.6.88.45
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=Y
#AutoIt3Wrapper_Res_LegalCopyright=CopyLeft Thibaut Lauziere a.k.a Slÿm
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_Field=Site|http://www.linuxliveusb.com
#AutoIt3Wrapper_AU3Check_Parameters=-w 4
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// About this software                           ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Author           : Thibaut Lauzière (Slÿm)
; Author's Website : www.slym.fr
; e-Mail           : contact@linuxliveusb.com
; License          : GPL v3.0
; Download         : http://www.linuxliveusb.com
; Support          : http://www.linuxliveusb.com/bugs/
; Compiled with    : AutoIT v3.3.6.1

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Software constants and variables              ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Global constants
Global Const $software_version = "2.6"
Global $lang_folder = @ScriptDir & "\tools\languages\"
Global $lang_ini
Global $verbose_logging
Global Const $settings_ini = @ScriptDir & "\tools\settings\settings.ini"
Global Const $compatibility_ini = @ScriptDir & "\tools\settings\compatibility_list.ini"
Global Const $blacklist_ini = @ScriptDir & "\tools\settings\black_list.ini"
Global Const $log_dir = @ScriptDir & "\logs\"
Global $logfile = $log_dir & @MDAY & "-" & @MON & "-" & @YEAR&".log"
Global Const $check_updates_url = "http://www.linuxliveusb.com/updates/"

; Auto-Clean feature (relative to the usb drive path)
Global Const $autoclean_file = "Remove_LiLi.bat"
Global Const $autoclean_settings = "SmartClean.ini"

; Global that will be set up later
Global $lang, $anonymous_id

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Gui Buttons and Label                         ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; General GUI
Global $GUI, $CONTROL_GUI, $EXIT_BUTTON, $MIN_BUTTON
Global $combo

; Step 1 Graphics
Global $DRAW_CHECK_STEP1,$DRAW_REFRESH,$HELP_STEP1

; Step 2 Graphics
Global $DRAW_CHECK_STEP2,$DRAW_ISO, $DRAW_CD, $DRAW_DOWNLOAD, $DRAW_BACK, $DRAW_BACK_HOVER, $HELP_STEP2, $label_iso, $label_cd, $label_download, $label_step2_status, $download_label2, $OR_label, $ISO_AREA,$CD_AREA,$DOWNLOAD_AREA,$BACK_AREA
Global $combo_linux,$label_step2_status,$label_step2_status2, $download_manual, $download_auto,$progress_bar

; Step 3 Graphics
Global $DRAW_CHECK_STEP3,$HELP_STEP3,$live_mode_label
Global $slider, $slider_visual,$label_max,$label_min,$slider_visual_Mo,$slider_visual_mode

; Step 4 Graphics
Global $HELP_STEP4
Global $virtualbox,$formater,$hide_files

; Step 5 Graphics
Global $DRAW_LAUNCH,$HELP_STEP5
Global $label_step5_status

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Gui Images                                    ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; General
Global $ZEROGraphic, $EXIT_NORM, $EXIT_OVER, $MIN_NORM, $MIN_OVER, $PNG_GUI,$HELP, $BAD, $GOOD, $WARNING
Global $cleaner, $cleaner2

; Step 1 images
Global $REFRESH_AREA

; Step 2 images
Global $CD_PNG, $CD_HOVER_PNG, $ISO_PNG, $ISO_HOVER_PNG, $DOWNLOAD_PNG, $DOWNLOAD_HOVER_PNG, $BACK_PNG, $BACK_HOVER_PNG

; images for step 3 & 4 are integrated into main GUI

; Step 5 images
Global $LAUNCH_PNG, $LAUNCH_HOVER_PNG

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Other Global Variables                        ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Offset alignment for different steps
Global $offsetx0,$offsetx3,$offsetx4
Global $offsety0,$offsety3,$offsety4

; $step2_display_menu = 0 when displaying default menu, 1 when displaying download menu, 2 when displaying checking.
Global $step2_display_menu = 0

; Others Global vars
Global $best_mirror, $iso_size, $filename, $temp_filename
Global $MD5_ISO = "", $compatible_md5, $compatible_filename, $release_number = -1, $files_in_source, $prefetched_linux_list,$current_compatibility_list_version
Global $foo
Global $for_winactivate
Global $current_download

Global $selected_drive,$virtualbox_check,$virtualbox_size,$downloaded_virtualbox_filename
Global $STEP1_OK, $STEP2_OK, $STEP3_OK
Global $MD5_ISO, $version_in_file
Global $variante
Global $already_create_a_key=0

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

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Checking folders / Set up Anonymous ID and Language                       ///////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Checking if Tools folder exists (contains tools and settings)
If DirGetSize(@ScriptDir & "\tools\", 2) <> -1 Then

	If Not FileExists($compatibility_ini) Then
		; If something went bad with auto-updating the compatibility list => trying to put back the old one
		FileMove(@ScriptDir & "\tools\settings\old_compatibility_list.ini",$compatibility_ini)
		If Not FileExists($compatibility_ini) Then
			MsgBox(48, "ERROR", "Compatibility list not found !!!")
			Exit
		EndIf
	EndIf

	If Not FileExists($settings_ini) Then
		MsgBox(48, "ERROR", "Settings file not found !!!")
		Exit
	Else
		; Generate an unique ID for anonymous crash reports and stats
		$anonymous_id=RegRead("HKEY_CURRENT_USER\SOFTWARE\LinuxLive\General", "unique_ID")
		if $anonymous_id = "" OR @error Then
			$anonymous_id=IniRead($settings_ini, "General", "unique_ID","")
			if $anonymous_id ="" Then
				; Unique ID found in settings.ini
				$anonymous_id = Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) _
								& Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1))  _
								& Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1))
				IniWrite($settings_ini,"General","unique_ID",$anonymous_id)
			EndIf
			if IniRead($settings_ini, "Advanced", "lili_portable_mode","")<>"yes" Then RegWrite("HKEY_CURRENT_USER\SOFTWARE\LinuxLive\General", "unique_ID","REG_SZ",$anonymous_id)
		Else
			IniWrite($settings_ini,"General","unique_ID",$anonymous_id)
		EndIf

	EndIf
Else
	MsgBox(48, "ERROR", "Please put the 'tools' directory back")
	Exit
EndIf

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Includes     															  ///////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include-once

; AutoIT native includes
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
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <GuiTreeView.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <Array.au3>
#include <String.au3>
#include <File.au3>
#include <INet.au3>
#include <WinHTTP.au3>
#include <Crypt.au3>

; LiLi's components
#include <Languages.au3>
#include <Updates.au3>
#include <Settings.au3>
#include <Files.au3>
#include <Logs_And_Status.au3>
#include <Automatic_Bug_Report.au3>
#include <Graphics.au3>
#include <External_Tools.au3>
#include <Disks.au3>
#include <Boot_Menus.au3>
#include <Checking_And_Recognizing.au3>
#include <Statistics.au3>
#include <Releases.au3>
#include <LiLis_heart.au3>
#include <GUI_Actions.au3>
#include <Options_Menu.au3>


SplashImageOn("LiLi Splash Screen", @ScriptDir & "\tools\img\logo.jpg",344, 107, -1, -1, 1)

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Proxy settings                                                            ///////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Apply proxy settings
$proxy_mode = ReadSetting( "Proxy", "proxy_mode")
$proxy_url = ReadSetting( "Proxy", "proxy_url")
$proxy_port = ReadSetting( "Proxy", "proxy_port")
$proxy_username = ReadSetting( "Proxy", "proxy_username")
$proxy_password = ReadSetting( "Proxy", "proxy_password")

if $proxy_mode =2 Then
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
	EndIf
Else
	HttpSetProxy($proxy_mode)
EndIf

_SetAsReceiverNoCallback("lili-main")
_SetReceiverFunction("ReceiveFromSecondary")

; Initializing log file for verbose logging
$verbose_logging = ReadSetting( "General", "verbose_logging")
If $verbose_logging = "yes" Then InitLog()

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

GUIRegisterMsg($WM_LBUTTONDOWN, "moveGUI")

SetBitmap($GUI, $PNG_GUI, 255)
GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")

$CONTROL_GUI = GUICreate("LinuxLive USB Creator", 450, 750, 5,7, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD), $GUI)

HotKeySet("{UP}", "GUI_MoveUp")
HotKeySet("{DOWN}", "GUI_MoveDown")
HotKeySet("{LEFT}", "GUI_MoveLeft")
HotKeySet("{RIGHT}", "GUI_MoveRight")

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
;$HELP_STEP5_AREA = GUICtrlCreateLabel("", 335 + $offsetx0, 565 + $offsety0, 20, 20)
;GUICtrlSetCursor(-1, 0)
;GUICtrlSetOnEvent(-1, "GUI_Help_Step5")

GUISetBkColor(0x121314)
_WinAPI_SetLayeredWindowAttributes($CONTROL_GUI, 0x121314)

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
;$HELP_STEP5 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 565 + $offsety0, 20, 20)

; Put the state for the first 3 steps
Step1_Check("bad")
Step2_Check("bad")
Step3_Check("bad")

SendReport("Creating GUI (buttons)")

; Hovering Buttons
AdlibRegister("Control_Hover", 150)

; Text for step 2
GUICtrlCreateLabel(Translate("STEP 2 : CHOOSE A SOURCE"), 28 + $offsetx0, 204 + $offsety0, 400, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")

$label_iso = GUICtrlCreateLabel("ISO / IMG / ZIP", 40 + $offsetx0, 302 + $offsety0, 110, 50)
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
$slider_visual_mode = GUICtrlCreateLabel(Translate("(Live mode only)"), 160 + $offsetx3 + $offsetx0, 258 + $offsety3 + $offsety0, 150, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

$live_mode_label = GUICtrlCreateLabel(Translate("Live Mode"), 55 + $offsetx0, 233 + $offsety3 + $offsety0, 280, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetStyle(-1,$SS_CENTER )
GUICtrlSetFont($live_mode_label, 16)

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
GUICtrlSetOnEvent(-1, "GUI_Check_VirtualBox")
$virtualbox_label = GUICtrlCreateLabel(Translate("Enable launching LinuxLive in Windows (requires internet to install)"), 50 + $offsetx4 + $offsetx0, 325 + $offsety4 + $offsety0, 300, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)


; Text and controls for step 5
GUICtrlCreateLabel(Translate("STEP 5 : CREATE"), 28 + $offsetx0, 371 + $offsety4 + $offsety0, 250, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")

GUICtrlCreateButton(StringUpper(Translate("Options")), 220+28 + $offsetx0, 369 + $offsety4 + $offsety0, 100, 20)
GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")
GUICtrlSetOnEvent(-1, "GUI_Help_Step5")

$label_step5_status = GUICtrlCreateLabel("<- " & Translate("Click the lightning icon to start the installation"), 50 + $offsetx4 + $offsetx0, 410 + $offsety4 + $offsety0, 300, 60)
GUICtrlSetFont($label_step5_status, 9, 800, 0, "Arial")
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; Filling the combo box with drive list

$combo = GUICtrlCreateCombo("-> " & Translate("Choose a USB Key"), 90 + $offsetx0, 145 + $offsety0, 200, -1, 3)
GUICtrlSetOnEvent(-1, "GUI_Choose_Drive")
Refresh_DriveList()

; Sending anonymous statistics
SendStats()
SendReport(LogSystemConfig())

$prefetched_linux_list = Print_For_ComboBox()

GUIRegisterMsg($WM_PAINT, "DrawAll")
WinActivate($for_winactivate)
GUISetState($GUI_SHOW, $CONTROL_GUI)

; Starting to check for updates in the secondary LiLi's process
SendReport("check_for_updates")

SplashOff()
Sleep(100)
GUISetState(@SW_SHOW, $GUI)
GUISetState(@SW_SHOW, $CONTROL_GUI)
Sleep(100)
; LiLi has been restarted due to a language change
If ReadSetting("Internal","restart_language")="yes" Then
	GUI_Options_Menu()
EndIf

; Netbook warning (interface too big). Warning will only appear once
if @DesktopHeight<=600 AND ReadSetting("Advanced","skip_netbook_warning")<>"yes" Then
	$return = MsgBox(64,Translate("Netbook screen detected"),Translate("Your screen vertical resolution is less than 600 pixels")&"."& @CRLF & Translate("Please use the arrow keys (up and down) of your keyboard to move the interface")&".")
	WriteSetting("Advanced","skip_netbook_warning","yes")
EndIf

; Main part
While 1
	; Force retracing the combo box (bugfix)
	If $combo_updated <> 1 Then
		GUICtrlSetData($combo, GUICtrlRead($combo))
		$combo_updated = 1
	EndIf
	Sleep(100)
	;DrawAll()
WEnd

Func MoveGUI($hW)
	_SendMessage($GUI, $WM_SYSCOMMAND, 0xF012, 0)
	ControlFocus("LinuxLive USB Creator", "", $REFRESH_AREA)
EndFunc   ;==>MoveGUI

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
	;$HELP_STEP5 = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $HELP, 0, 0, 20, 20, 335 + $offsetx0, 565 + $offsety0, 20, 20)
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
		If Not @error And IsArray($CursorCtrl) Then
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
					If $step2_display_menu >= 1 Then $DRAW_BACK = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
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
					If $step2_display_menu >= 1 Then $DRAW_BACK_HOVER = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_HOVER_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
			EndSwitch
			$previous_hovered_control = $CursorCtrl[4]
		EndIf
	EndIf
	if IsArray($_Progress_Bars) Then _Paint_Bars_Procedure2()
	_CALLBACKQUEUE()
EndFunc   ;==>Control_Hover


; Received a message from the secondary lili's process
Func ReceiveFromSecondary($message)

	; Compatibility list has been updated => force reloading
	If $message ="compatibility_updated" Then
		; initialize list of compatible releases (load the compatibility_list.ini)
		Get_Compatibility_List()
		$prefetched_linux_list = Print_For_ComboBox()
		UpdateLog("Compatibility list has been successfully updated")
	Else
		UpdateLog("Received message from secondary process ("&$message&")")
	EndIf
EndFunc
