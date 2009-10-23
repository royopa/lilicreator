#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=tools\img\lili.ico
#AutoIt3Wrapper_Compression=3
#AutoIt3Wrapper_Res_Comment=Enjoy !
#AutoIt3Wrapper_Res_Description=Easily create a Linux Live USB
#AutoIt3Wrapper_Res_Fileversion=2.0.88.9
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y
#AutoIt3Wrapper_Res_LegalCopyright=CopyLeft Thibaut Lauziere a.k.a Sl�m
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Site|http://www.linuxliveusb.com
#AutoIt3Wrapper_Au3Check_Parameters=-w 4
#AutoIt3Wrapper_Run_After=upx.exe --best --compress-resources=0 "%out%"
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; Author           : Thibaut Lauzi�re (Sl�m)
; Author's Website : www.slym.fr
; e-Mail           : contact@linuxliveusb.com
; License          : GPL v3.0
; Version          : 2.0
; Download         : http://www.linuxliveusb.com
; Support          : http://www.linuxliveusb.com/bugs/
; Compiled with    : AutoIT v3.2.12.1



Global $software_version = "2.0"
Global $lang_ini = @ScriptDir & "\tools\settings\langs.ini"
Global $settings_ini = @ScriptDir & "\tools\settings\settings.ini"
Global $blacklist_ini = @ScriptDir & "\tools\settings\black_list.ini"
Global $log_dir = @ScriptDir & "\logs\"
Global $help_file_name = "Help.chm"
Global $help_available_langs = "en,fr,sp"
Global $variants_using_default_mode = "default,gparted,debian,clonezilla,damnsmall"
Global $lang, $anonymous_id
Global $downloaded_virtualbox_filename

; Global variables used for the onEvent Functions
; Globals images and GDI+ elements
Global $GUI, $CONTROL_GUI, $EXIT_BUTTON, $MIN_BUTTON, $DRAW_REFRESH, $DRAW_ISO, $DRAW_CD, $DRAW_DOWNLOAD, $DRAW_BACK, $DRAW_BACK_HOVER, $DRAW_LAUNCH, $HELP_STEP1, $HELP_STEP2, $HELP_STEP3, $HELP_STEP4, $HELP_STEP5, $label_iso, $label_cd, $label_download, $label_step2_status,$live_mode_only_label
Global $ZEROGraphic, $EXIT_NORM, $EXIT_OVER, $MIN_NORM, $MIN_OVER, $PNG_GUI, $CD_PNG, $CD_HOVER_PNG, $ISO_PNG, $ISO_HOVER_PNG, $DOWNLOAD_PNG, $DOWNLOAD_HOVER_PNG, $BACK_PNG, $BACK_HOVER_PNG, $LAUNCH_PNG, $LAUNCH_HOVER_PNG, $HELP, $BAD, $GOOD, $WARNING, $BACK_AREA
Global $download_menu_active = 0, $cleaner, $cleaner2
Global $combo_linux, $download_manual, $download_auto, $slider, $slider_visual
Global $best_mirror, $iso_size, $filename, $progress_bar, $label_step2_status
Global $MD5_ISO, $compatible_md5, $compatible_filename, $release_number = -1,$files_in_source
Global $foo
Global $for_winactivate

; Global variables for Graphical Part
Global Const $LWA_ALPHA = 0x2
Global Const $LWA_COLORKEY = 0x1

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
			$anonymous_id = Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1)) & Chr(Random(Asc("A"), Asc("Z"), 1))
			IniWrite($settings_ini, "General", "unique_ID", $anonymous_id)
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
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <Array.au3>
#include <File.au3>
#include <md5.au3>
#include <INet.au3>
#include <IE.au3>
#include <WinHTTP.au3>

; LiLi's components
#include <About.au3>
#include <Automatic_Bug_Report.au3>
#include <Ressources.au3>
#include <Graphics.au3>
#include <Releases.au3>
#include <LiLis_heart.au3>



; Unlock help file on Vista (because Vista will prevent opening it ... stupid)
UnlockHelp()

SendReport("Starting LiLi USB Creator " & $software_version)

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
If FileExists(@ScriptDir & "\tools\img\GUI_" & $lang & ".png") Then
	$PNG_GUI = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\GUI_" & $lang & ".png")
Else
	$PNG_GUI = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\tools\img\GUI_English.png")
EndIf



SendReport("Creating GUI")

$GUI = GUICreate("LiLi USB Creator", 450, 750, -1, -1, $WS_POPUP, $WS_EX_LAYERED)
GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_Events")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "GUI_Events")
GUISetOnEvent($GUI_EVENT_RESTORE, "GUI_Events")

SetBitmap($GUI, $PNG_GUI, 255)
GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")
GUISetState(@SW_SHOW, $GUI)

; Old offset was 18
$LAYERED_GUI_CORRECTION = GetVertOffset($GUI)
$CONTROL_GUI = GUICreate("CONTROL_GUI", 450, 750, 0, $LAYERED_GUI_CORRECTION, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD), $GUI)

; Offset for applied on every items
$offsetx0 = 27
$offsety0 = 23


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
$label_iso = GUICtrlCreateLabel("ISO / IMG", 50 + $offsetx0, 302 + $offsety0, 50, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)


$label_cd = GUICtrlCreateLabel("CD", 175 + $offsetx0, 302 + $offsety0, 20, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

$label_download = GUICtrlCreateLabel(Translate("T�l�charger"), 262 + $offsetx0, 302 + $offsety0, 70, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; Text and controls for step 3
$offsetx3 = 60
$offsety3 = 150
$label_min = GUICtrlCreateLabel("0 " & Translate("Mo"), 30 + $offsetx3 + $offsetx0, 228 + $offsety3 + $offsety0, 30, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$label_max = GUICtrlCreateLabel("?? " & Translate("Mo"), 250 + $offsetx3 + $offsetx0, 228 + $offsety3 + $offsety0, 50, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$slider = GUICtrlCreateSlider(60 + $offsetx3 + $offsetx0, 225 + $offsety3 + $offsety0, 180, 20)
GUICtrlSetLimit($slider, 0, 0)
GUICtrlSetOnEvent(-1, "GUI_Persistence_Slider")
$slider_visual = GUICtrlCreateInput("0", 90 + $offsetx3 + $offsetx0, 255 + $offsety3 + $offsety0, 40, 20)
GUICtrlSetOnEvent(-1, "GUI_Persistence_Input")
$slider_visual_Mo = GUICtrlCreateLabel(Translate("Mo"), 135 + $offsetx3 + $offsetx0, 258 + $offsety3 + $offsety0, 20, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$slider_visual_mode = GUICtrlCreateLabel(Translate("(Mode Live)"), 160 + $offsetx3 + $offsetx0, 258 + $offsety3 + $offsety0, 100, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$live_mode_only_label = GUICtrlCreateLabel(Translate("Mode Live"), 77 + $offsetx3 + $offsetx0, 233 + $offsety3 + $offsety0, 300, 100)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont($live_mode_only_label, 16)
GUICtrlSetState($live_mode_only_label,$GUI_HIDE)

; Text and controls for step 4
$offsetx4 = 10
$offsety4 = 195
$hide_files = GUICtrlCreateCheckbox("", 30 + $offsetx4 + $offsetx0, 285 + $offsety4 + $offsety0, 13, 13)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$hide_files_label = GUICtrlCreateLabel(Translate("Cacher les fichiers sur la cl�"), 50 + $offsetx4 + $offsetx0, 285 + $offsety4 + $offsety0, 300, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; No more reason to keep that option because menu is integrated on right click of the key
$except_wubi = GUICtrlCreateDummy()
;$except_wubi = GUICtrlCreateCheckbox("", 200 + $offsetx4+$offsetx0, 285 + $offsety4+$offsety0, 13, 13)
;$except_wubi_label = GUICtrlCreateLabel(Translate("(Sauf Umenu.exe)"), 220 + $offsetx4+$offsetx0, 285 + $offsety4+$offsety0, 200, 20)
;GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
;GUICtrlSetColor(-1, 0xFFFFFF)

$formater = GUICtrlCreateCheckbox("", 30 + $offsetx4 + $offsetx0, 305 + $offsety4 + $offsety0, 13, 13)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetOnEvent(-1, "GUI_Format_Key")
$formater_label = GUICtrlCreateLabel(Translate("Formater la cl� en FAT32 (Vos donn�es seront supprim�es!)"), 50 + $offsetx4 + $offsetx0, 305 + $offsety4 + $offsety0, 300, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$virtualbox = GUICtrlCreateCheckbox("", 30 + $offsetx4 + $offsetx0, 325 + $offsety4 + $offsety0, 13, 13)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$virtualbox_label = GUICtrlCreateLabel(Translate("Permettre de lancer LinuxLive directement sous Windows (n�cessite internet)"), 50 + $offsetx4 + $offsetx0, 325 + $offsety4 + $offsety0, 300, 30)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)


; Text and controls for step 5
$label_step6_statut = GUICtrlCreateLabel("<- " & Translate("Cliquer l'�clair pour lancer l'installation"), 50 + $offsetx4 + $offsetx0, 410 + $offsety4 + $offsety0, 300, 60)
GUICtrlSetFont($label_step6_statut, 9, 800, 0, "Arial")
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)


; Filling the combo box with drive list
Global $combo
$combo = GUICtrlCreateCombo("-> " & Translate("Choisir une cl� USB"), 90 + $offsetx0, 145 + $offsety0, 200, -1, 3)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetOnEvent(-1, "GUI_Choose_Drive")
Refresh_DriveList()

; Setting up all global vars and local vars
Global $selected_drive, $logfile, $virtualbox_check, $virtualbox_size
Global $STEP1_OK, $STEP2_OK, $STEP3_OK
Global $DRAW_CHECK_STEP1, $DRAW_CHECK_STEP2, $DRAW_CHECK_STEP3
Global $MD5_FOLDER, $MD5_ISO, $version_in_file
Global $variante

$selected_drive = "->"
$file_set = 0;
$file_set_mode = "none"
$annuler = 0
$sysarg = " "
$combo_updated = 0

$STEP1_OK = 0
$STEP2_OK = 0
$STEP3_OK = 0

$MD5_FOLDER = "none"
$MD5_ISO = "none"
$version_in_file = "none"

; Sending anonymous statistics
SendStats()
SendReport(LogSystemConfig())

; initialize list of compatible releases
Get_Compatibility_List()

; Hovering Buttons
AdlibEnable("Control_Hover", 150)


GUIRegisterMsg($WM_PAINT, "DrawAll")
WinActivate($for_winactivate)
GUISetState($GUI_SHOW, $CONTROL_GUI)

; Main part
While 1
	; Force retracing the combo box (bugfix)
	If $combo_updated <> 1 Then
		GUICtrlSetData($combo, GUICtrlRead($combo))
		$combo_updated = 1
	EndIf
	Sleep(60000)
WEnd

Func DrawAll()
	_WinAPI_RedrawWindow($CONTROL_GUI, 0, 0, $RDW_UPDATENOW)
	$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_NORM, 0, 0, 20, 20, 335 + $offsetx0, -20 + $offsety0, 20, 20)
	$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_NORM, 0, 0, 20, 20, 305 + $offsetx0, -20 + $offsety0, 20, 20)
	$DRAW_REFRESH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $REFRESH_PNG, 0, 0, 20, 20, 300 + $offsetx0, 145 + $offsety0, 20, 20)
	If $download_menu_active = 0 Then
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
	If WinActive("CONTROL_GUI") Or WinActive("LiLi USB Creator") Then

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
					If $download_menu_active = 0 Then $DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38 + $offsetx0, 231 + $offsety0, 75, 75)
				Case $CD_AREA
					If $download_menu_active = 0 Then $DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146 + $offsetx0, 231 + $offsety0, 75, 75)
				Case $DOWNLOAD_AREA
					If $download_menu_active = 0 Then $DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260 + $offsetx0, 230 + $offsety0, 75, 75)
				Case $LAUNCH_AREA
					$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_PNG, 0, 0, 22, 43, 35 + $offsetx0, 600 + $offsety0, 22, 43)
				Case $BACK_AREA
					If $download_menu_active = 1 Then $DRAW_BACK = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
			EndSwitch

			Switch $CursorCtrl[4]
				Case $EXIT_AREA
					If $CursorCtrl[2] = 1 Then GUI_Exit()
					$EXIT_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $EXIT_OVER, 0, 0, 20, 20, 335 + $offsetx0, -20 + $offsety0, 20, 20)
				Case $MIN_AREA
					If $CursorCtrl[2] = 1 Then GUI_Minimize()
					$MIN_BUTTON = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $MIN_OVER, 0, 0, 20, 20, 305 + $offsetx0, -20 + $offsety0, 20, 20)
				Case $ISO_AREA
					If $download_menu_active = 0 Then $DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_HOVER_PNG, 0, 0, 75, 75, 38 + $offsetx0, 231 + $offsety0, 75, 75)
				Case $CD_AREA
					If $download_menu_active = 0 Then $DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_HOVER_PNG, 0, 0, 75, 75, 146 + $offsetx0, 231 + $offsety0, 75, 75)
				Case $DOWNLOAD_AREA
					If $download_menu_active = 0 Then $DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_HOVER_PNG, 0, 0, 75, 75, 260 + $offsetx0, 230 + $offsety0, 75, 75)
				Case $LAUNCH_AREA
					$DRAW_LAUNCH = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $LAUNCH_HOVER_PNG, 0, 0, 22, 43, 35 + $offsetx0, 600 + $offsety0, 22, 43)
				Case $BACK_AREA
					If $download_menu_active = 1 Then $DRAW_BACK_HOVER = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_HOVER_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
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
	FOR $file IN $list_of_files
		HideFile($selected_drive&"\"&$file)
	Next
EndFunc

Func isDir($file_to_test)
	return StringInStr(FileGetAttrib($file_to_test), "D")
EndFunc

Func DeleteFilesInDir($list_of_files)
	FOR $file IN $list_of_files
		if isDir($selected_drive&"\"&$file) Then
			DirRemove2($selected_drive&"\"&$file,1)
		Else
			FileDelete2($selected_drive&"\"&$file)
		EndIf
	Next
EndFunc

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

Func _FileCopy($fromFile, $tofile)
	SendReport("Start-_FileCopy (" & $fromFile & " -> " & $tofile & " )")
	Local $FOF_RESPOND_YES = 16
	Local $FOF_SIMPLEPROGRESS = 256
	$winShell = ObjCreate("shell.application")
	$winShell.namespace($tofile).CopyHere($fromFile, $FOF_RESPOND_YES)
	SendReport("End-_FileCopy")
EndFunc   ;==>_FileCopy

Func _FileCopy2($arg1, $arg2)
	SendReport("Start-_FileCopy2 ( " & $arg1 & " -> " & $arg2 & " )")
	_FileCopy($arg1, $arg2)
	UpdateLog("Copying folder " & $arg1 & " to " & $arg2)
	SendReport("End-_FileCopy2")
EndFunc   ;==>_FileCopy2



Func InitializeFilesInSource($path)
	If isDir($path) == 1  Then
		InitializeFilesInCD($path)
	Else
		InitializeFilesInISO($path)
	EndIf
EndFunc

; Create a list of files in ISO
Func InitializeFilesInISO($iso_to_list)
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	FileDelete(@ScriptDir & "\tools\filelist.txt")
	$foo = RunWait(@ComSpec & " /c " & '7z.exe' & ' l -slt "'&$iso_to_list&'" > filelist.txt', @ScriptDir&"\tools\", @SW_HIDE)
	AnalyzeFileList()
EndFunc

; Analyze the listfile and only select files and folders at the root (will be used to clean previous installs and hide the newly created)
Func AnalyzeFileList()
	Local $line,$filelist, $files[1]
	Global $files_in_source
	$filelist = FileOpen(@ScriptDir & "\tools\filelist.txt", 0)
	While 1
		$line = FileReadLine($filelist)
		If @error = -1 Then ExitLoop
		if StringRegExp($line,"^Path = ",0) AND StringInStr($line,"\")==0  AND StringInStr($line,"[BOOT]")==0 Then
			 _ArrayAdd($files, StringReplace($line,"Path = ",""))
		EndIf
	Wend
	FileClose($filelist)
	FileDelete(@ScriptDir & "\tools\filelist.txt")
	_ArrayDelete($files, 0)
	$files_in_source = $files
EndFunc

Func InitializeFilesInCD($searchdir)
	Local $files[1]
	Global $files_in_source
	If StringRight($searchdir, 1) <> "\" Then $searchdir = $searchdir & "\"

	$search = FileFindFirstFile($searchdir&"*")
	If isDir($searchdir&$search) Then _ArrayAdd($files, $search)

	; Check if the search was successful
	If $search = -1 Then
		MsgBox(0, "Error", "No files/directories matched the search pattern")
		Exit
	EndIf
	$attrib=""
	While 1
		$file = FileFindNextFile($search)
		If @error Then ExitLoop
		 _ArrayAdd($files, $file)
	WEnd
	; Close the search handle
	FileClose($search)
	_ArrayDelete($files, 0)
	$files_in_source = $files
EndFunc





; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Launching third party tools                       ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Run7zip($cmd, $taille)
	Local $percentage, $line
	$initial = DriveSpaceFree($selected_drive)
	SendReport("Start-Run7zip ( Command :" & $cmd & " - Size:" & $taille & " )")

	UpdateLog($cmd)
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD)
	$line = @CRLF

	While ProcessExists($foo) > 0
		$percentage = Round((($initial - DriveSpaceFree($selected_drive)) * 100 / $taille), 0)
		If $percentage > 0 And $percentage < 101 Then
			UpdateStatusNoLog(Translate("D�compression de l'ISO sur la cl�") & " ( � " & $percentage & "% )")
		EndIf
		;If @error Then ExitLoop
		$line &= StdoutRead($foo)
		Sleep(500)
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
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD)
	$line = @CRLF
	While ProcessExists($foo) > 0
		$percentage = Round((($initial - DriveSpaceFree($selected_drive)) * 100 / $taille), 0)
		If $percentage > 0 And $percentage < 101 Then
			UpdateStatusNoLog(Translate("D�compression de VirtualBox sur la cl�") & " ( � " & $percentage & "% )")
		EndIf
		;If @error Then ExitLoop
		$line &= StdoutRead($foo)
		;UpdateStatus2($line)
		Sleep(500)
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
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)
	$line = @CRLF
	While 1

		UpdateStatusNoLog(Translate("Cr�ation du fichier de persistance") & " ( " & Round(FileGetSize($file_to_create) / 1048576, 0) & "/" & Round($size, 0) & " Mo )")
		$line &= StderrRead($foo)
		;UpdateStatus2($line)
		If @error Then ExitLoop
		Sleep(500)
	WEnd
	UpdateLog($line)
	SendReport("End-Create_Empty_File")
EndFunc   ;==>Create_Empty_File


Func EXT2_Format_File($persistence_file)
	Local $line
	If ProcessExists("mke2fs.exe") > 0 Then ProcessClose("mke2fs.exe")
	$cmd = @ScriptDir & '\tools\mke2fs.exe -b 1024 ' & $persistence_file
	SendReport("Start-EXT2_Format_File ( " & $cmd & " )")
	UpdateLog($cmd)
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	$line = @CRLF
	While 1
		$line &= StdoutRead($foo)
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
	$line = @CRLF
	While True
		$line &= StdoutRead($foo)
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
	$line = @CRLF
	While True
		$line = StdoutRead($foo)
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
	; r�cup�re la liste des disques
	$drive_list = DriveGetDrive("REMOVABLE")
	$all_drives = "|-> " & Translate("Choisir une cl� USB") & "|"
	If Not @error Then
		Dim $description[100]
		If UBound($drive_list) >= 1 Then
			For $i = 1 To $drive_list[0]
				$label = DriveGetLabel($drive_list[$i])
				$fs = DriveGetFileSystem($drive_list[$i])
				$space = DriveSpaceTotal($drive_list[$i])
				If ((Not $fs = "") Or (Not $space = 0)) Then
					$all_drives &= StringUpper($drive_list[$i]) & " " & $label & " - " & $fs & " - " & Round($space / 1024, 1) & " " & Translate("Go") & "|"
				EndIf
			Next
		EndIf
	EndIf
	SendReport("Start-Refresh_DriveList-1")
	$drive_list = DriveGetDrive("FIXED")
	If Not @error Then
		$all_drives &= "-> " & Translate("Suite (disques durs)") & " -------------|"
		Dim $description[100]
		If UBound($drive_list) >= 1 Then
			For $i = 1 To $drive_list[0]
				$label = DriveGetLabel($drive_list[$i])
				$fs = DriveGetFileSystem($drive_list[$i])
				$space = DriveSpaceTotal($drive_list[$i])
				If ((Not $fs = "") Or (Not $space = 0)) Then
					$all_drives &= StringUpper($drive_list[$i]) & " " & $label & " - " & $fs & " - " & Round($space / 1024, 1) & " " & Translate("Go") & "|"
				EndIf
			Next
		EndIf
	EndIf
	SendReport("Start-Refresh_DriveList-2")
	If $all_drives <> "|-> " & Translate("Choisir une cl� USB") & "|" Then
		GUICtrlSetData($combo, $all_drives, "-> " & Translate("Choisir une cl� USB"))
		GUICtrlSetState($combo, $GUI_ENABLE)
	Else
		GUICtrlSetData($combo, "|-> " & Translate("Aucune cl� trouv�e"), "-> " & Translate("Aucune cl� trouv�e"))
		GUICtrlSetState($combo, $GUI_DISABLE)
	EndIf
	SendReport("End-Refresh_DriveList")
EndFunc   ;==>Refresh_DriveList

Func SpaceAfterLinuxLiveMB($disk)
	SendReport("Start-SpaceAfterLinuxLiveMB (Disk: " & $disk & " )")
	If GUICtrlRead($formater) == $GUI_CHECKED Then
		$spacefree = DriveSpaceTotal($disk) - 810
		If $spacefree >= 0 And $spacefree <= 4000 Then
			Return Round($spacefree / 100, 0) * 100
		ElseIf $spacefree >= 0 And $spacefree > 4000 Then
			Return (4000)
		Else
			Return 0
		EndIf
	Else
		$spacefree = DriveSpaceFree($disk) - 810
		If $spacefree >= 0 And $spacefree <= 4000 Then
			Return Round($spacefree / 100, 0) * 100
		ElseIf $spacefree >= 0 And $spacefree > 4000 Then
			Return (4000)
		Else
			Return 0
		EndIf
	EndIf
	SendReport("End-SpaceAfterLinuxLiveMB")
EndFunc   ;==>SpaceAfterLinuxLiveMB

Func SpaceAfterLinuxLiveGB($disk)
	SendReport("Start-SpaceAfterLinuxLiveGB (Disk: " & $disk & " )")
	If GUICtrlRead($formater) == $GUI_CHECKED Then
		$spacefree = DriveSpaceTotal($disk) - 810
		If $spacefree >= 0 Then
			Return Round($spacefree / 1024, 1)
		Else
			Return 0
		EndIf
	Else
		$spacefree = DriveSpaceFree($disk) - 810
		If $spacefree >= 0 Then
			Return Round($spacefree / 1024, 1)
		Else
			Return 0
		EndIf
	EndIf
	SendReport("End-SpaceAfterLinuxLiveGB")
EndFunc   ;==>SpaceAfterLinuxLiveGB

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Logs and status                               ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


Func InitLog()
	Global $log_dir, $logfile
	DirCreate($log_dir)
	$logfile = @ScriptDir & "\logs\" & @MDAY & "-" & @MON & "-" & @YEAR & " (" & @HOUR & "h" & @MIN & "s" & @SEC & ").log"
	UpdateLog(LogSystemConfig())
	SendReport("logfile-" & $logfile)
EndFunc   ;==>InitLog

Func LogSystemConfig()
	SendReport("Start-LogSystemConfig")
	$mem = MemGetStats()
	$line = @CRLF & "--------------------------------  System Config  --------------------------------"
	$line &= @CRLF & "LiLi USB Creator : " & $software_version
	$line &= @CRLF & "OS Type : " & @OSType
	$line &= @CRLF & "OS Version : " & @OSVersion
	$line &= @CRLF & "OS Build : " & @OSBuild
	$line &= @CRLF & "OS Service Pack : " & @OSServicePack
	$line &= @CRLF & "Architecture : " & @ProcessorArch
	$line &= @CRLF & "Memory : " & Round($mem[1] / 1024) & "MB  ( with " & (100 - $mem[0]) & "% free = " & Round($mem[2] / 1024) & "MB )"
	$line &= @CRLF & "Language : " & @OSLang
	$line &= @CRLF & "Keyboard : " & @KBLayout
	$line &= @CRLF & "Resolution : " & @DesktopWidth & "x" & @DesktopHeight
	$line &= @CRLF & "Chosen Key : " & GUICtrlRead($combo)
	$line &= @CRLF & "Free space on key : " & Round(DriveSpaceFree($selected_drive)) & "MB"
	If $file_set_mode == "iso" Then
		$line &= @CRLF & "Selected ISO : " & path_to_name($file_set)
		$line &= @CRLF & "ISO Hash : " & $MD5_ISO
	Else
		$line &= @CRLF & "Selected source : " & $file_set
		$line &= @CRLF & "Folder Hash : " & $MD5_FOLDER
		$line &= @CRLF & "Linux Version : " & $version_in_file
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
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Fran�ais (France)"))
			SendReport("End-GetKbdCode")
			Return "locale=fr_FR bootkbd=fr-latin1 console-setup/layoutcode=fr console-setup/variantcode=nodeadkeys "

		Case StringInStr("0c0c", @OSLang)
			; CA
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Fran�ais (Canada)"))
			SendReport("End-GetKbdCode")
			Return "locale=fr_CA bootkbd=fr-latin1 console-setup/layoutcode=ca console-setup/variantcode=nodeadkeys "

		Case StringInStr("100c", @OSLang)
			; Suisse FR
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Fran�ais (Suisse)"))
			SendReport("End-GetKbdCode")
			Return "locale=fr_CH bootkbd=fr-latin1 console-setup/layoutcode=ch console-setup/variantcode=fr "

		Case StringInStr("0407,0807,0c07,1007,1407,0413,0813", @OSLang)
			; German & dutch
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Allemand"))
			SendReport("End-GetKbdCode")
			Return "locale=de_DE bootkbd=de console-setup/layoutcode=de console-setup/variantcode=nodeadkeys "

		Case StringInStr("0816", @OSLang)
			; Portugais
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Portugais"))
			SendReport("End-GetKbdCode")
			Return "locale=pt_BR bootkbd=qwerty/br-abnt2 console-setup/layoutcode=br console-setup/variantcode=nodeadkeys "

		Case StringInStr("0410,0810", @OSLang)
			; Italien
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("Italian"))
			SendReport("End-GetKbdCode")
			Return "locale=it_IT bootkbd=it console-setup/layoutcode=it console-setup/variantcode=nodeadkeys "
		Case Else
			; US
			UpdateLog(Translate("D�tection du clavier") & " : " & Translate("US ou autres (qwerty)"))
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


Func Ubuntu_WriteTextCFG($selected_drive, $variant)
	SendReport("Start-Ubuntu_WriteTextCFG (Drive : " & $selected_drive & " - Variant : " & $variant & " )")
	Local $boot_text, $kbd_code
	$boot_text = ""
	$kbd_code = GetKbdCode()

	$codename = ReleaseGetCodename($release_number)

	; Karmic Koala have a renamed initrd file
	If $codename = "ubuntu910a6" OR $codename = "ubuntu910beta" Then
		$initrd_file = "initrd.lz"
	Else
		$initrd_file = "initrd.gz"
	EndIf

	If $variant = "mint" Then
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
	ElseIf $variant = "custom" Or $variant = "crunchbang" Then
		$boot_text &= "DISPLAY isolinux.txt" _
				 & @LF & "TIMEOUT 300" _
				 & @LF & "PROMPT 1" _
				 & @LF & "default persist"
	Else
		$boot_text &= @LF & "default persist"
	EndIf

	$boot_text &= @LF & "label persist" & @LF & "menu label ^" & Translate("Mode Persistant") _
			 & @LF & "  kernel /casper/vmlinuz" _
			 & @LF & "  append  " & $kbd_code & "noprompt cdrom-detect/try-usb=true persistent file=/cdrom/preseed/" & $variant & ".seed boot=casper initrd=/casper/" & $initrd_file & " splash--" _
			 & @LF & "label live" _
			 & @LF & "  menu label ^" & Translate("Mode Live") _
			 & @LF & "  kernel /casper/vmlinuz" _
			 & @LF & "  append   " & $kbd_code & "noprompt cdrom-detect/try-usb=true file=/cdrom/preseed/" & $variant & ".seed boot=casper initrd=/casper/" & $initrd_file & " splash--" _
			 & @LF & "label live-install" _
			 & @LF & "  menu label ^" & Translate("Installer") _
			 & @LF & "  kernel /casper/vmlinuz" _
			 & @LF & "  append   " & $kbd_code & "noprompt cdrom-detect/try-usb=true persistent file=/cdrom/preseed/" & $variant & ".seed boot=casper only-ubiquity initrd=/casper/" & $initrd_file & " splash --" _
			 & @LF & "label check" _
			 & @LF & "  menu label ^" & Translate("Verification des fichiers") _
			 & @LF & "  kernel /casper/vmlinuz" _
			 & @LF & "  append   " & $kbd_code & "noprompt boot=casper integrity-check initrd=/casper/" & $initrd_file & " splash --" _
			 & @LF & "label memtest" _
			 & @LF & "  menu label ^" & Translate("Test de la RAM") _
			 & @LF & "  kernel /install/mt86plus"
	UpdateLog("Creating syslinux config file :" & @CRLF & $boot_text)
	$file = FileOpen($selected_drive & "\syslinux\text.cfg", 2)
	FileWrite($file, $boot_text)
	FileClose($file)

	If $variant = "kuki" Then
		FileCopy(@ScriptDir & "\tools\kuki-isolinux.txt", $selected_drive & "\syslinux\isolinux.txt", 1)
		FileCopy(@ScriptDir & "\tools\kuki-syslinux.cfg", $selected_drive & "\syslinux\syslinux.cfg", 1)
	ElseIf $variant = "mint" Or $variant = "custom" Then
		$file = FileOpen($selected_drive & "\syslinux\syslinux.cfg", 2)
		FileWrite($file, $boot_text)
		FileClose($file)
	ElseIf $variant = "crunchbang" Then
		FileDelete2($selected_drive & "\syslinux\isolinux.txt")
		FileCopy(@ScriptDir & "\tools\crunchbang-isolinux.txt", $selected_drive & "\syslinux\isolinux.txt", 1)
	EndIf

	If $variant <> "ubuntu" And $variant <> "kuki" Then
		$file = FileOpen($selected_drive & "\syslinux\syslinux.cfg", 2)
		FileWrite($file, $boot_text)
		FileClose($file)
	EndIf

	SendReport("End-Ubuntu_WriteTextCFG")
EndFunc   ;==>Ubuntu_WriteTextCFG

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
			 & @LF & "  menu label " & Translate("Mode Persistant") _
			 & @LF & "  kernel vmlinuz0" _
			 & @LF & "  append initrd=initrd0.img root=UUID=" & $uuid & " rootfstype=vfat rw liveimg overlay=UUID=" & $uuid & " quiet  rhgb " _
			 & @LF & "menu default" _
			 & @LF & "label check0" _
			 & @LF & "  menu label " & Translate("Verification des fichiers") _
			 & @LF & "  kernel vmlinuz0" _
			 & @LF & "  append initrd=initrd0.img root=UUID=" & $uuid & " rootfstype=vfat rw liveimg overlay=UUID=" & $uuid & " quiet  rhgb check" _
			 & @LF & "label memtest" _
			 & @LF & " menu label " & Translate("Test de la RAM") _
			 & @LF & "  kernel memtest" _
			 & @LF & "label local" _
			 & @LF & "  menu label Boot from local drive" _
			 & @LF & "  localboot 0xffff"
	$file = FileOpen($selected_drive & "\syslinux\syslinux.cfg", 2)
	FileWrite($file, $boot_text)
	FileClose($file)
	SendReport("End-Fedora_WriteTextCFG")
EndFunc   ;==>Fedora_WriteTextCFG

Func Mandriva_WriteTextCFG($drive_letter)
	SendReport("Start-Mandriva_WriteTextCFG ( Drive : " & $drive_letter & " )")
	Local $boot_text = ""
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
			 & @LF & "  menu label " & Translate("Mode Persistant") _
			 & @LF & "  kernel vmlinuz0" _
			 & @LF & "  append initrd=initrd0.img root=UUID=" & $uuid & " rootfstype=vfat rw liveimg overlay=UUID=" & $uuid & " quiet  rhgb " _
			 & @LF & "menu default" _
			 & @LF & "label check0" _
			 & @LF & "  menu label " & Translate("Verification des fichiers") _
			 & @LF & "  kernel vmlinuz0" _
			 & @LF & "  append initrd=initrd0.img root=UUID=" & $uuid & " rootfstype=vfat rw liveimg overlay=UUID=" & $uuid & "quiet  rhgb check" _
			 & @LF & "label memtest" _
			 & @LF & " menu label " & Translate("Test de la RAM") _
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

Func Check_source_integrity($linux_live_file)
	SendReport("Start-Check_source_integrity (LinuxFile : " & $linux_live_file & " )")

	$shortname = path_to_name($linux_live_file)
	SendReport("distrib-"&$shortname)

	Global $MD5_ISO, $compatible_md5, $compatible_filename, $release_number = -1


	; Pre-Checking
	If get_extension($linux_live_file) = "img" Then

		Disable_Persistent_Mode()
		Disable_VirtualBox_Option()

		Step2_Check("good")

		$file_set_mode = "img"

		If DriveSpaceTotal($selected_drive) > 700 Then
			Step1_Check("good")
		Else
			Step1_Check("bad")
		EndIf

		SendReport("IN-Check_Source (img selected :" & $linux_live_file & ")")
		MsgBox(64, "", Translate("Les fichiers .IMG sont support�s de fa�on exp�rimentale.") & @CRLF & Translate("Seul le mode Live est actuellement disponible dans l'�tape 3 et l'option de virtualisation est d�sactiv�e."))
	Else
		Enable_Persistent_Mode()
		Enable_VirtualBox_Option()
		SendReport("IN-Check_Source (iso selected :" & $linux_live_file & ")")
		$file_set_mode = "iso"
	EndIf


	; No check if it's an img file or if the user do not want to
	If IniRead($settings_ini, "General", "skip_checking", "no") == "yes" Or get_extension($linux_live_file) = "img" Then
		Step2_Check("good")
		$temp_index = _ArraySearch($compatible_filename, "regular_linux.iso")
		$release_number = $temp_index
		Return ""
	EndIf


	SendReport("Start-Check_source_integrity-1")
	If Check_if_version_non_grata($shortname) Then Return ""

	; Some files do not need to be checked by MD5 ( Alpha releases ...). Only trusting filename
	$temp_index = _ArraySearch($compatible_filename, $shortname)
	If $temp_index > 0 Then
		If ReleaseGetMD5($temp_index) = "ANY" Then
			MsgBox(4096, Translate("V�rification") & " OK", Translate("La version est compatible et le fichier est valide"))
			Step2_Check("good")
			$release_number = $temp_index
			Check_If_Default_Should_Be_Used($release_number)
			Return ""
		Else
			$temp_index = 0
		EndIf
	EndIf

	$MD5_ISO = MD5_ISO($linux_live_file)

	$temp_index = _ArraySearch($compatible_md5, $MD5_ISO)

	SendReport("Start-Check_source_integrity-2")
	If $temp_index > 0 Then
		; Good version -> COMPATIBLE
		MsgBox(4096, Translate("V�rification") & " OK", Translate("La version est compatible et le fichier est valide"))
		Step2_Check("good")
		$release_number = $temp_index
	Else
		$temp_index = _ArraySearch($compatible_filename, $shortname)
		If $temp_index > 0 Then
			; Filename is known but MD5 not OK -> COMPATIBLE BUT ERROR
			MsgBox(48, Translate("Attention"), Translate("Vous avez la bonne version de Linux mais elle est corrompue ou a �t� modifi�e.") & @CRLF & Translate("Merci de la t�l�charger � nouveau"))
			Step2_Check("warning")
			$release_number = $temp_index
		Else
			; Filename is not known but trying to find what it is with its name => INTELLIGENT PROCESSING
			SendReport("Start-Check_source_integrity (start intelligent processing)")

			If StringInStr($shortname, "9.10") Or StringInStr($shortname, "karmic") Then
				; Ubuntu Karmic (>=9.10) based
				$temp_index = _ArraySearch($compatible_filename, "ubuntu-9.10-beta-desktop-i386.iso")
				$release_number = $temp_index
				Step2_Check("warning")
				MsgBox(48, Translate("Attention"), Translate("Cette version de Linux n'est pas compatible avec ce logiciel.") & @CRLF & Translate("LinuxLive USB Creator essaiera quand m�me de l'installer en utilisant les m�me param�tres que pour") & @CRLF & @CRLF & @TAB & ReleaseGetDescription($release_number))
			ElseIf StringInStr($shortname, "9.04") Or StringInStr($shortname, "ubuntu") Or StringInStr($shortname, "netbook-remix") Or StringInStr($shortname, "Fluxbuntu") Or StringInStr($shortname, "gnewsense") Then
				; Ubuntu 9.04 based
				$temp_index = _ArraySearch($compatible_filename, "ubuntu-9.04-desktop-i386.iso")
				$release_number = $temp_index
				Step2_Check("warning")
				MsgBox(48, Translate("Attention"), Translate("Cette version de Linux n'est pas compatible avec ce logiciel.") & @CRLF & Translate("LinuxLive USB Creator essaiera quand m�me de l'installer en utilisant les m�me param�tres que pour") & @CRLF & @CRLF & @TAB & ReleaseGetDescription($release_number))
			ElseIf StringInStr($shortname, "kuki") Then
				; Kuki based (Ubuntu)
				$temp_index = _ArraySearch($compatible_filename, "kuki-2.8-20090829Final.iso")
				$release_number = $temp_index
				Step2_Check("warning")
				MsgBox(48, Translate("Attention"), Translate("Cette version de Linux n'est pas compatible avec ce logiciel.") & @CRLF & Translate("LinuxLive USB Creator essaiera quand m�me de l'installer en utilisant les m�me param�tres que pour") & @CRLF & @CRLF & @TAB & ReleaseGetDescription($release_number))
			ElseIf StringInStr($shortname, "fedora") Or StringInStr($shortname, "F10") Or StringInStr($shortname, "F11") Then
				; Fedora Based
				$temp_index = _ArraySearch($compatible_filename, "Fedora-11-i686-Live.iso")
				$release_number = $temp_index
				Step2_Check("warning")
				MsgBox(48, Translate("Attention"), Translate("Cette version de Linux n'est pas compatible avec ce logiciel.") & @CRLF & Translate("LinuxLive USB Creator essaiera quand m�me de l'installer en utilisant les m�me param�tres que pour") & @CRLF & @CRLF & @TAB & ReleaseGetDescription($release_number))
			ElseIf StringInStr($shortname, "mint") Then
				; Mint Based
				$temp_index = _ArraySearch($compatible_filename, "LinuxMint-7.iso")
				$release_number = $temp_index
				Step2_Check("warning")
				MsgBox(48, Translate("Attention"), Translate("Cette version de Linux n'est pas compatible avec ce logiciel.") & @CRLF & Translate("LinuxLive USB Creator essaiera quand m�me de l'installer en utilisant les m�me param�tres que pour") & @CRLF & @CRLF & @TAB & ReleaseGetDescription($release_number))
			ElseIf StringInStr($shortname, "clonezilla") Then
				; Clonezilla
				$temp_index = _ArraySearch($compatible_filename, "regular_linux.iso")
				$release_number = $temp_index
				Step2_Check("good")
				Disable_Persistent_Mode()
			ElseIf StringInStr($shortname, "gparted") Then
				; Gparted
				$temp_index = _ArraySearch($compatible_filename, "regular_linux.iso")
				$release_number = $temp_index
				Step2_Check("good")
				Disable_Persistent_Mode()
			ElseIf StringInStr($shortname, "debian") Then
				; Debian
				$temp_index = _ArraySearch($compatible_filename, "regular_linux.iso")
				$release_number = $temp_index
				Step2_Check("good")
				Disable_Persistent_Mode()
			ElseIf StringInStr($shortname, "crunch") Then
				; CrunchBang Based
				$temp_index = _ArraySearch($compatible_filename, "crunchbang-9.04.01.i386.iso")
				$release_number = $temp_index
				Step2_Check("warning")
				MsgBox(48, Translate("Attention"), Translate("Cette version de Linux n'est pas compatible avec ce logiciel.") & @CRLF & Translate("LinuxLive USB Creator essaiera quand m�me de l'installer en utilisant les m�me param�tres que pour") & @CRLF & @CRLF & @TAB & ReleaseGetDescription($release_number))
			Else
				; Any Linux, except those known not to work in Live mode
				$temp_index = _ArraySearch($compatible_filename, "regular_linux.iso")
				$release_number = $temp_index
				Step2_Check("warning")
				MsgBox(48, Translate("Attention"), Translate("Cette version de Linux n'est pas compatible avec ce logiciel.") & @CRLF & Translate("LinuxLive USB Creator essaiera quand m�me de l'installer en utilisant les m�me param�tres que pour") & @CRLF & @CRLF & @TAB & ReleaseGetDescription($release_number))
			EndIf
			SendReport("End-Check_source_integrity (end intelligent processing)")
		EndIf
	EndIf
	Check_If_Default_Should_Be_Used($release_number)
	SendReport("End-Check_source_integrity")
EndFunc   ;==>Check_source_integrity


Func Check_If_Default_Should_Be_Used($release_in_list)
	if StringInStr($variants_using_default_mode,ReleaseGetVariant($release_in_list)) Then
		Disable_Persistent_Mode()
	EndIf
EndFunc

; Check the ISO against black list
Func Check_if_version_non_grata($version_name)
	SendReport("Start-Check_if_version_non_grata (Version : " & $version_name & " )")

	Local $non_grata = 0

	$blacklist= IniRead($blacklist_ini, "Black_List", "black_keywords", "sparc,alternate")
	$blacklist_array = StringSplit($blacklist, ',')

	FOR $i = 1 to $blacklist_array[0]
		if StringInStr($version_name, $blacklist_array[$i]) Then
			$non_grata=1
			ExitLoop
		EndIf
	NEXT

	If $non_grata = 1 Then
		MsgBox(48, Translate("Attention"), Translate("Cette version de Linux n'est pas compatible avec ce logiciel.") & @CRLF & Translate("Merci de v�rifier la liste de compatibilit� dans le guide d'utilisation."))
		Step2_Check("warning")
		SendReport("End-Check_if_version_non_grata (is Non grata)")
		Return 1
	EndIf
	SendReport("End-Check_if_version_non_grata (is not Non grata)")
EndFunc   ;==>Check_if_version_non_grata

Func MD5_ISO($FileToHash)
	SendReport("Start-MD5_ISO ( File : " & $FileToHash & " )")
	ProgressOn(Translate("V�rification"), Translate("V�rification de l'int�grit� + compatibilit�"), "0 %", -1, -1, 16)
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
	ProgressSet(100, "100%", Translate("V�rification termin�e"))
	Sleep(500)
	ProgressOff()
	$hexa_hash = StringTrimLeft($hash, 2)
	SendReport("End-MD5_ISO ( Hash : " & $hexa_hash & " )")
	Return $hexa_hash
EndFunc   ;==>MD5_ISO


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
		MsgBox(0, Translate("Erreur"), Translate("Impossible d'ouvrir le fichier md5sum.txt"))
		FileClose($file)
		Step2_Check("warning")
		SendReport("End-Check_folder_integrity (Cannot open MD5SUM.txt)")
		Return ""
	EndIf
	$progression_foldermd5 = ProgressOn(Translate("V�rification"), Translate("V�rification de l'int�grit�"), "0 %", -1, -1, 16)
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
			MsgBox(48, Translate("Erreur"), Translate("Le fichier suivant est corrumpu") & " : " & $file_to_hash)
			Step2_Check("warning")
			$corrupt = 1
			$MD5_FOLDER = "bad file :" & $file_to_hash
			ExitLoop
		EndIf
	WEnd
	ProgressSet(100, "100%", Translate("V�rification termin�e"))
	Sleep(500)
	ProgressOff()
	If $corrupt = 0 Then
		MsgBox(4096, Translate("V�rification termin�e"), Translate("Tous les fichiers sont bons."))
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
		ProgressSet($percent_md5, Translate("V�rification du fichier") & " " & path_to_name($FileToHash) & " (" & $percent_md5 & " %)")
	Next
	$hash = _MD5Result($MD5CTX)
	FileClose($FileHandle)
	$folder_hash = StringTrimLeft($hash, 2)
	SendReport("Start-MD5_FOLDER ( Hash : " & $folder_hash & " )")
	Return
EndFunc   ;==>MD5_FOLDER


; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Statistics                                  ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func SendStats()
	Global $anonymous_id
	SendReport("stats-id=" & $anonymous_id & "&version=" & $software_version & "&os=" & @OSVersion & "-" & @ProcessorArch & "-" & @OSServicePack & "&lang=" & _Language_for_stats())
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
; ///////////////////////////////// Help file management                          ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Unlock help file with vista
Func UnlockHelp()
	SendReport("Start-UnlockHelp")
	Global $help_file_name
	If FileExists($help_file_name) Then
		IniWrite($help_file_name & ":Zone.Identifier", "ZoneTransfer", "ZoneId", 5)
	EndIf
	SendReport("End-UnlockHelp")
EndFunc   ;==>UnlockHelp

; Open help file with right page and locale
Func OpenHelpPage($page)
	SendReport("Start-OpenHelpPage")
	Global $help_file_name, $lang
	$short_lang = StringLower(StringLeft($lang, 2))
	If StringInStr($help_available_langs, $short_lang) == 0 Then $short_lang = "en"

	If FileExists($help_file_name) Then
		Run(@ComSpec & " /c " & 'hh.exe mk:@MSITStore:' & $help_file_name & '::/' & $page & '_' & $short_lang & '.html', "", @SW_HIDE)
	Else
		MsgBox(48, Translate("Erreur"), Translate("Le fichier d'aide n'est pas pr�sent dans le dossier."))
	EndIf
	SendReport("End-OpenHelpPage")
EndFunc   ;==>OpenHelpPage

; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Gui Buttons handling                        ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Disable_Persistent_Mode()
	GUICtrlSetState($slider, $GUI_HIDE)
	GUICtrlSetState($slider_visual, $GUI_HIDE)
	GUICtrlSetState($label_max, $GUI_HIDE)
	GUICtrlSetState($label_min, $GUI_HIDE)
	GUICtrlSetState($slider_visual_Mo,$GUI_HIDE)
	GUICtrlSetState($slider_visual_mode,$GUI_HIDE)
	GUICtrlSetState($live_mode_only_label,$GUI_SHOW)
	Step3_Check("good")
EndFunc

Func Enable_Persistent_Mode()
	GUICtrlSetState($slider, $GUI_SHOW)
	GUICtrlSetState($slider_visual, $GUI_SHOW)
	GUICtrlSetState($label_max, $GUI_SHOW)
	GUICtrlSetState($label_min, $GUI_SHOW)
	GUICtrlSetState($slider_visual_Mo,$GUI_SHOW)
	GUICtrlSetState($slider_visual_mode,$GUI_SHOW)
	GUICtrlSetState($live_mode_only_label,$GUI_HIDE)
EndFunc

Func Disable_VirtualBox_Option()
		GUICtrlSetState($virtualbox, $GUI_UNCHECKED)
		GUICtrlSetState($virtualbox, $GUI_DISABLE)
EndFunc

Func Enable_VirtualBox_Option()
		GUICtrlSetState($virtualbox, $GUI_CHECKED)
		GUICtrlSetState($virtualbox, $GUI_ENABLE)
EndFunc

; Clickable parts of images
Func GUI_Exit()
	SendReport("Start-GUI_Exit")
	InetGet("abort")
	ProcessClose($foo)
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
EndFunc   ;==>GUI_Exit

Func GUI_Minimize()
	GUISetState(@SW_MINIMIZE, $GUI)
EndFunc   ;==>GUI_Minimize

Func GUI_Choose_Drive()
	SendReport("Start-GUI_Choose_Drive")
	$selected_drive = StringLeft(GUICtrlRead($combo), 2)
	If (StringInStr(DriveGetFileSystem($selected_drive), "FAT") >= 1 And SpaceAfterLinuxLiveMB($selected_drive) > 0) Then
		; State is OK ( FAT32 or FAT format and 700MB+ free)
		Step1_Check("good")

		If GUICtrlRead($slider) > 0 Then
			GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
			GUICtrlSetLimit($slider, Round(SpaceAfterLinuxLiveMB($selected_drive) / 10), 0)
			; State is OK ( FAT32 or FAT format and 700MB+ free) and warning for live mode only on step 3
			Step3_Check("good")
		Else
			GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
			GUICtrlSetLimit($slider, Round(SpaceAfterLinuxLiveMB($selected_drive) / 10), 0)
			; State is OK but warning for live mode only on step 3
			Step3_Check("warning")
		EndIf

		SendReport(LogSystemConfig())
	ElseIf (StringInStr(DriveGetFileSystem($selected_drive), "FAT") <= 0 And GUICtrlRead($formater) <> $GUI_CHECKED) Then

		MsgBox(4096, "", Translate("Veuillez choisir un disque format� en FAT32 ou FAT ou cocher l'option de formatage"))

		; State is NOT OK (no selected key)
		GUICtrlSetData($label_max, "?? " & Translate("Mo"))
		Step1_Check("bad")

		; State for step 3 is NOT OK according to step 1
		GUICtrlSetData($label_max, "?? " & Translate("Mo"))
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
			MsgBox(4096, "", Translate("Vous n'avez s�lectionn� aucun disque"))
		EndIf
		; State is NOT OK (no selected key)
		GUICtrlSetData($label_max, "?? " & Translate("Mo"))
		Step1_Check("bad")

		; State for step 3 is NOT OK according to step 1
		GUICtrlSetData($label_max, "?? " & Translate("Mo"))
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
	$source_file = FileOpenDialog(Translate("Choisir l'image ISO d'un CD live de Linux"), @ScriptDir & "\", "ISO / IMG (*.iso;*.img)", 1)
	If @error Then
		SendReport("IN-ISO_AREA (no iso)")
		MsgBox(4096, "", Translate("Vous n'avez s�lectionn� aucun fichier"))
		$file_set = 0;
		Step2_Check("bad")
	Else
		$file_set = $source_file
		Check_source_integrity($file_set)
		SendReport(LogSystemConfig())
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

	$folder_file = FileSelectFolder(Translate("S�lectionner le CD live de Linux ou son r�pertoire"), "")
	If @error Then
		SendReport("IN-CD_AREA (no CD)")
		MsgBox(4096, "", Translate("Vous n'avez s�lectionn� aucun CD ou dossier"))
		Step2_Check("bad")
		$file_set = 0;
	Else
		Disable_Persistent_Mode()
		SendReport("IN-CD_AREA (CD selected :" & $folder_file & ")")
		$file_set = $folder_file;
		$file_set_mode = "folder"
		Check_folder_integrity($folder_file)
		SendReport(LogSystemConfig())
	EndIf
	SendReport("End-GUI_Choose_CD")
EndFunc   ;==>GUI_Choose_CD

Func GUI_Download()
	SendReport("Start-GUI_Download")
	; Used to avoid redrawing the old elements of Step 2 (ISO, CD and download)
	$download_menu_active = 1

	; hiding old elements
	GUICtrlSetState($ISO_AREA, $GUI_HIDE)
	GUICtrlSetState($CD_AREA, $GUI_HIDE)
	GUICtrlSetState($DOWNLOAD_AREA, $GUI_HIDE)
	GUICtrlSetState($label_cd, $GUI_HIDE)
	GUICtrlSetState($label_download, $GUI_HIDE)
	GUICtrlSetState($label_iso, $GUI_HIDE)

	; Drawing new menu
	$combo_linux = GUICtrlCreateCombo(">> " & "Select your favourite Linux", 38 + $offsetx0, 238 + $offsety0, 300, -1, 3)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetOnEvent(-1, "GUI_Select_Linux")
	Get_Compatibility_List()
	GUICtrlSetData($combo_linux, Print_For_ComboBox())

	$download_manual = GUICtrlCreateButton("Download Manually", 38 + $offsetx0, 231 + $offsety0 + 50, 130)
	GUICtrlSetOnEvent(-1, "GUI_Download_Manually")
	GUICtrlSetState(-1, $GUI_DISABLE)

	$download_auto = GUICtrlCreateButton("Download Automatically", 38 + $offsetx0 + 160, 231 + $offsety0 + 50, 130)
	GUICtrlSetOnEvent(-1, "GUI_Download_Automatically")
	GUICtrlSetState(-1, $GUI_DISABLE)

	$BACK_AREA = GUICtrlCreateLabel("", 5 + $offsetx0, 300 + $offsety0, 32, 32)
	$DRAW_BACK = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetOnEvent(-1, "GUI_Back_Download")
	SendReport("End-GUI_Download")
EndFunc   ;==>GUI_Download

Func GUI_Back_Download()
	SendReport("Start-GUI_Back_Download")
	If @InetGetActive = 1 Then InetGet("abort")
	GUICtrlSetState($combo_linux, $GUI_HIDE)
	GUICtrlSetState($download_manual, $GUI_HIDE)
	GUICtrlSetState($download_auto, $GUI_HIDE)
	GUICtrlSetState($label_step2_status, $GUI_HIDE)
	$cleaner = GUICtrlCreateLabel("", 38 + $offsetx0, 238 + $offsety0, 300, 30)
	$cleaner2 = GUICtrlCreateLabel("", 5 + $offsetx0, 300 + $offsety0, 32, 32)

	GUICtrlSetState($cleaner, $GUI_SHOW)


	; Showing old elements again
	GUICtrlSetState($ISO_AREA, $GUI_SHOW)
	GUICtrlSetState($CD_AREA, $GUI_SHOW)
	GUICtrlSetState($DOWNLOAD_AREA, $GUI_SHOW)
	GUICtrlSetState($label_cd, $GUI_SHOW)
	GUICtrlSetState($label_download, $GUI_SHOW)
	GUICtrlSetState($label_iso, $GUI_SHOW)
	GUICtrlSetState($cleaner, $GUI_HIDE)
	GUICtrlSetState($cleaner2, $GUI_HIDE)
	$download_menu_active = 0
	$DRAW_CD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $CD_PNG, 0, 0, 75, 75, 146 + $offsetx0, 231 + $offsety0, 75, 75)
	$DRAW_DOWNLOAD = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $DOWNLOAD_PNG, 0, 0, 75, 75, 260 + $offsetx0, 230 + $offsety0, 75, 75)
	$DRAW_ISO = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $ISO_PNG, 0, 0, 75, 75, 38 + $offsetx0, 231 + $offsety0, 75, 75)
	GUICtrlSetState($cleaner2, $GUI_SHOW)
	SendReport("End-GUI_Back_Download")
EndFunc   ;==>GUI_Back_Download

Func GUI_Select_Linux()
	SendReport("Start-GUI_Select_Linux")
	$selected_linux = GUICtrlRead($combo_linux)
	If StringInStr($selected_linux, ">>") = 0 Then
		GUICtrlSetState($download_manual, $GUI_ENABLE)
		GUICtrlSetState($download_auto, $GUI_ENABLE)
	Else
		MsgBox(48, "Attention", "Please select a linux to continue")
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

	GUICtrlSetState($combo_linux, $GUI_HIDE)
	GUICtrlSetState($download_manual, $GUI_HIDE)
	GUICtrlSetState($download_auto, $GUI_HIDE)
	GUICtrlSetState($BACK_AREA, $GUI_HIDE)

	$progress_bar = _ProgressCreate(38 + $offsetx0, 238 + $offsety0, 300, 30)
	_ProgressSetImages($progress_bar, @ScriptDir & "\tools\img\progress_green.jpg", @ScriptDir & "\tools\img\progress_background.jpg")
	_ProgressSetFont($progress_bar, "", -1, -1, 0x000000, 0)

	$DRAW_BACK = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $BACK_PNG, 0, 0, 32, 32, 5 + $offsetx0, 300 + $offsety0, 32, 32)

	$label_step2_status = GUICtrlCreateLabel("Looking for the fastest mirror", 38 + $offsetx0, 231 + $offsety0 + 50, 300, 80)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0xFFFFFF)
	UpdateStatusStep2("Choosing fastest mirror")


	For $i = $R_MIRROR1 To $R_MIRROR10
		$mirror = $releases[$release_in_list][$i]
		If StringStripWS($mirror, 1) <> "" Then $available_mirrors = $available_mirrors + 1
	Next

	For $i = $R_MIRROR1 To $R_MIRROR10
		$mirror = $releases[$release_in_list][$i]
		If StringStripWS($mirror, 1) <> "" Then
			$temp_latency = Ping(URLToHostname($mirror), 1000)
			If @error = 0 Then
				$tested_mirrors = $tested_mirrors + 1
				_ProgressSet($progress_bar, $tested_mirrors * 100 / $available_mirrors)
				_ProgressSetText($progress_bar, "Testing : " & URLToHostname($mirror))
			Else
				$temp_latency = 10000
			EndIf
		Else
			$temp_latency = 10000
		EndIf
		$latency[$i] = $temp_latency

	Next

	If _ArrayMin($latency, 1, $R_MIRROR1, $R_MIRROR10) = 10000 Then
		UpdateStatusStep2("No online mirror found !" & @CRLF & "Please check your internet connection or try with another linux")
		_ProgressSet($progress_bar, 100)

	Else
		UpdateStatusStep2("Best mirror found" & @CRLF & "Download will start in a few seconds")
		_ProgressSet($progress_bar, 100)
		Sleep(1500)

		$best_mirror = $releases[$release_in_list][_ArrayMinIndex($latency, 1, $R_MIRROR1, $R_MIRROR10)]
		If $automatic_download = 0 Then
			; Download manually
			UpdateStatusStep2("Select this file as the source when download will be completed.")
			Sleep(1000)
			ShellExecute($best_mirror)
			;_Main($latency,$release_in_list)
		Else
			; Download automatically
			$iso_size = InetGetSize($best_mirror)
			$filename = unix_path_to_name($best_mirror)
			$inet_success = InetGet($best_mirror, @ScriptDir & "\" & $filename, 1, 1)
			If $inet_success Then
				UpdateStatusStep2("Downloading " & $filename & @CRLF & "From " & URLToHostname($best_mirror))
				Download_State()
			Else
				UpdateStatusStep2("Error while trying to download, please check you internet connection or try another linux")
			EndIf
		EndIf
	EndIf
	Sleep(3000)
	_ProgressDelete($progress_bar)
	GUICtrlSetState($combo_linux, $GUI_HIDE)
	GUICtrlSetState($download_manual, $GUI_HIDE)
	GUICtrlSetState($download_auto, $GUI_HIDE)
	GUICtrlSetState($label_step2_status, $GUI_HIDE)
	$cleaner = GUICtrlCreateLabel("", 38 + $offsetx0, 238 + $offsety0, 300, 30)
	$cleaner2 = GUICtrlCreateLabel("", 5 + $offsetx0, 300 + $offsety0, 32, 32)
	GUICtrlSetState($cleaner, $GUI_SHOW)
	; Showing old elements again
	GUICtrlSetState($ISO_AREA, $GUI_SHOW)
	GUICtrlSetState($CD_AREA, $GUI_SHOW)
	GUICtrlSetState($DOWNLOAD_AREA, $GUI_SHOW)
	GUICtrlSetState($label_cd, $GUI_SHOW)
	GUICtrlSetState($label_download, $GUI_SHOW)
	GUICtrlSetState($label_iso, $GUI_SHOW)
	GUICtrlSetState($cleaner, $GUI_HIDE)
	GUICtrlSetState($cleaner2, $GUI_HIDE)
	$download_menu_active = 0
	DrawAll()
	SendReport("End-DownloadRelease")
EndFunc   ;==>DownloadRelease

; Will be available in 2.0
Func _Main($latency_table, $release_in_list)
	Local $hImage, $hListView

	Opt("GUIOnEventMode", 0)

	; Create GUI
	GUICreate("Select the mirror", 400, 300)
	$hListView = GUICtrlCreateListView("", 2, 2, 394, 268)
	_GUICtrlListView_SetUnicodeFormat($hListView, False)
	GUISetState()

	; Load images
	$hImage = _GUIImageList_Create()
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0xFF0000, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0x00FF00, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($hListView, 0x0000FF, 16, 16))
	_GUICtrlListView_SetImageList($hListView, $hImage, 1)

	; Add columns
	_GUICtrlListView_InsertColumn($hListView, 0, "Latency", 100)
	_GUICtrlListView_InsertColumn($hListView, 1, "Server Name", 200)

	; Add items
	_GUICtrlListView_AddItem($hListView, $latency_table[$R_MIRROR1], 0)
	_GUICtrlListView_AddSubItem($hListView, 0, URLToHostname($releases[$release_in_list][$R_MIRROR1]), 1, 1)
	_GUICtrlListView_AddItem($hListView, $latency_table[$R_MIRROR2], 1)
	_GUICtrlListView_AddSubItem($hListView, 1, URLToHostname($releases[$release_in_list][$R_MIRROR2]), 1, 1)
	_GUICtrlListView_AddItem($hListView, $latency_table[$R_MIRROR3], 2)
	_GUICtrlListView_AddSubItem($hListView, 2, URLToHostname($releases[$release_in_list][$R_MIRROR3]), 1, 1)

	; Loop until user exits
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
	Opt("GUIOnEventMode", 1)
	GUIRegisterMsg($WM_PAINT, "DrawAll")
	WinActivate($for_winactivate)
	GUISetState($GUI_SHOW, $CONTROL_GUI)
EndFunc   ;==>_Main

Func Download_State()
	SendReport("Start-Download_State")
	Local $begin, $oldgetbytesread, $estimated_time = ""

	$begin = TimerInit()
	$oldgetbytesread = @InetGetBytesRead

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
		_ProgressSetText($progress_bar, $percent_downloaded & "% ( " & RoundForceDecimal(@InetGetBytesRead / (1024 * 1024)) & " / " & RoundForceDecimal($iso_size / (1024 * 1024)) & " " & "MB" & " ) " & $estimated_time)
		Sleep(300)
	WEnd

	_ProgressSet($progress_bar, 100)
	_ProgressSetText($progress_bar, "100% ( " & Round($iso_size / (1024 * 1024)) & " / " & Round($iso_size / (1024 * 1024)) & " " & "MB" & " )")

	UpdateStatusStep2("File has been successfully downloaded, a check will begin in few seconds.")
	Sleep(3000)
	$file_set = @ScriptDir & "\" & $filename
	Check_source_integrity($file_set)
	SendReport(LogSystemConfig())
	SendReport("End-Download_State")
EndFunc   ;==>Download_State

Func HumanTime($sec)
	If $sec <= 0 Then Return ""

	$hours = Floor($sec / 3600)
	If $hours > 5 Then Return ""

	$minutes = Floor($sec / 60) - $hours * 60
	$seconds = Floor($sec) - $minutes * 60

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
		GUICtrlSetData($slider_visual_mode, Translate("(Mode Persistant)"))
		; State is OK (value > 0)
		Step3_Check("good")
	Else
		GUICtrlSetData($slider_visual, GUICtrlRead($slider) * 10)
		GUICtrlSetData($slider_visual_mode, Translate("(Mode Live)"))
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
		GUICtrlSetData($slider_visual_mode, Translate("(Mode Persistant)"))
		; State is  OK (persistent mode)
		Step3_Check("good")
	ElseIf GUICtrlRead($slider_visual) = 0 Then
		GUICtrlSetData($slider_visual_mode, Translate("(Mode Live)"))
		; State is WARNING (live mode only)
		Step3_Check("warning")
	Else
		GUICtrlSetData($slider, 0)
		GUICtrlSetData($slider_visual, 0)
		GUICtrlSetData($slider_visual_mode, Translate("(Mode Live)"))
		; State is WARNING (live mode only)
		Step3_Check("warning")
	EndIf
	SendReport("End-GUI_Persistence_Input")
EndFunc   ;==>GUI_Persistence_Input

Func GUI_Format_Key()
	SendReport("Start-GUI_Format_Key")
	If GUICtrlRead($formater) == $GUI_CHECKED Then
		GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
		GUICtrlSetLimit($slider, SpaceAfterLinuxLiveMB($selected_drive) / 10, 0)
	Else
		GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
		GUICtrlSetLimit($slider, SpaceAfterLinuxLiveMB($selected_drive) / 10, 0)
	EndIf

	If ((StringInStr(DriveGetFileSystem($selected_drive), "FAT") >= 1 Or GUICtrlRead($formater) == $GUI_CHECKED) And SpaceAfterLinuxLiveMB($selected_drive) > 0) Then
		; State is OK ( FAT32 or FAT format and 700MB+ free)
		GUICtrlSetData($label_max, SpaceAfterLinuxLiveMB($selected_drive) & " " & Translate("Mo"))
		GUICtrlSetLimit($slider, Round(SpaceAfterLinuxLiveMB($selected_drive) / 10), 0)
		Step1_Check("good")

	ElseIf (StringInStr(DriveGetFileSystem($selected_drive), "FAT") <= 0 And GUICtrlRead($formater) <> $GUI_CHECKED) Then
		MsgBox(4096, "", Translate("Veuillez choisir un disque format� en FAT32 ou FAT ou cocher l'option de formatage"))
		GUICtrlSetData($label_max, "?? Mo")
		Step1_Check("bad")

	Else
		If (DriveGetFileSystem($selected_drive) = "") Then
			MsgBox(4096, "", Translate("Vous n'avez s�lectionn� aucun disque"))
		EndIf
		;State is NOT OK (no selected key)
		GUICtrlSetData($label_max, "?? " & Translate("Mo"))
		Step1_Check("bad")

	EndIf
	SendReport("End-GUI_Format_Key")
EndFunc   ;==>GUI_Format_Key

Func GUI_Launch_Creation()
	SendReport("Start-GUI_Launch_Creation")
	SendReport(LogSystemConfig())
	; Disable the controls and re-enable after creation

	$selected_drive = StringLeft(GUICtrlRead($combo), 2)

	UpdateStatus("D�but de la cr�ation du LinuxLive USB")

	If $STEP1_OK >= 1 And $STEP2_OK >= 1 And $STEP3_OK >= 1 Then
		$annuler = 0
	Else
		$annuler = 2
		UpdateStatus("Veuillez valider les �tapes 1 � 3")
	EndIf

	; Initializing log file
	InitLog()

	; Format option has been selected
	If (GUICtrlRead($formater) == $GUI_CHECKED) And $annuler <> 2 Then
		$annuler = 0
		$annuler = MsgBox(49, Translate("Attention") & "!!!", Translate("Voulez-vous vraiment continuer et formater le disque suivant ?") & @CRLF & @CRLF & "       " & Translate("Nom") & " : ( " & $selected_drive & " ) " & DriveGetLabel($selected_drive) & @CRLF & "       " & Translate("Taille") & " : " & Round(DriveSpaceTotal($selected_drive) / 1024, 1) & " " & Translate("Go") & @CRLF & "       " & Translate("Formatage") & " : " & DriveGetFileSystem($selected_drive) & @CRLF)
		If $annuler = 1 Then
			Format_FAT32($selected_drive)
		EndIf
	EndIf

	; Starting creation if not cancelled
	If $annuler <> 2 Then

		UpdateStatus("Etape 1 � 3 valides")

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

			Install_boot_sectors($selected_drive)
		EndIf

		If (GUICtrlRead($hide_files) == $GUI_CHECKED) Then Hide_live_files($selected_drive)

		If GUICtrlRead($virtualbox) == $GUI_CHECKED And $virtualbox_check >= 1 Then

			If $virtualbox_check <> 2 Then Check_virtualbox_download()

			; maybe check downloaded file ?

			; Next step : uncompressing vbox on the key
			Uncompress_virtualbox_on_key($selected_drive)

			;UpdateStatus("Configuration de VirtualBox Portable")
			;SetupVirtualBox($selected_drive & "\Portable-VirtualBox", $selected_drive)

			;Run($selected_drive & "\Portable-VirtualBox\Launch_usb.exe", @ScriptDir, @SW_HIDE)

		EndIf

		; Create Autorun menu
		Create_autorun($selected_drive, $release_number)

		; Creation is now done
		UpdateStatus("Votre cl� LinuxLive est maintenant pr�te !")

		If $virtualbox_check >= 1 Then Final_check()

		Sleep(1000)


		;Final_Help($selected_drive)
		ShellExecute("http://www.linuxliveusb.com/using-lili.html", "", "", "", 7)

	Else
		UpdateStatus("Veuillez valider les �tapes 1 � 3")
	EndIf
	SendReport("End-GUI_Launch_Creation")
EndFunc   ;==>GUI_Launch_Creation

Func Final_Help($selected_drive)
	SendReport("Start-Final_Help (Drive : " & $selected_drive & " )")
	$gui_finish = GUICreate(Translate("Votre cl� LinuxLive est maintenant pr�te !"), 604, 378, -1, -1)
	GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_Events2")
	GUISetOnEvent($GUI_EVENT_MINIMIZE, "GUI_Events2")
	GUISetOnEvent($GUI_EVENT_RESTORE, "GUI_Events2")
	GUICtrlCreatePic(@ScriptDir & "\tools\img\tuto.jpg", 350, 0, 254, 378)
	$printme = @CRLF & @CRLF & @CRLF & @CRLF & "  " & Translate("Votre cl� LinuxLive est maintenant pr�te !") _
			 & @CRLF & @CRLF & "    " & Translate("Pour lancer LinuxLive :") _
			 & @CRLF & "    " & Translate("Retirez votre cl� et r�ins�rez-la.") _
			 & @CRLF & "    " & Translate("Allez ensuite dans 'Poste de travail'.") _
			 & @CRLF & "    " & Translate("Faites un clic droit sur votre cl� et s�lectionnez :") & @CRLF

	If FileExists($selected_drive & "\VirtualBox\Virtualize_This_Key.exe") And FileExists($selected_drive & "VirtualBox\VirtualBox.exe") Then
		$printme &= @CRLF & "    " & "-> " & Translate("'LinuxLive!' pour lancer la cl� directement dans windows")
		$printme &= @CRLF & "    " & "-> " & Translate("'VirtualBox Interface' pour lancer l'interface compl�te de VirtalBox")
	EndIf
	$printme &= @CRLF & "    " & "-> " & Translate("'CD Menu' pour lancer le menu original du CD")
	GUICtrlCreateLabel($printme, 0, 0, 350, 378)
	GUICtrlSetBkColor(-1, 0x0ffffff)
	GUICtrlSetFont(-1, 10, 600)
	GUISetState(@SW_SHOW)
	SendReport("End-Final_Help")
EndFunc   ;==>Final_Help

Func GUI_Events()
	SendReport("Start-GUI_Events (GUI_CtrlID=" & @GUI_CtrlId & " )")
	Select
		Case @GUI_CtrlId = $GUI_EVENT_CLOSE
			GUI_Exit()
		Case @GUI_CtrlId = $GUI_EVENT_MINIMIZE
			GUISetState(@SW_MINIMIZE, @GUI_WinHandle)
		Case @GUI_CtrlId = $GUI_EVENT_RESTORE
			WinActivate($for_winactivate)
			GUISetState($GUI_SHOW, $CONTROL_GUI)

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
	ShellExecute("http://www.linuxliveusb.com/en/how-to/63-step1.html")
	;OpenHelpPage("etape1")
EndFunc   ;==>GUI_Help_Step1

Func GUI_Help_Step2()
	ShellExecute("http://www.linuxliveusb.com/en/how-to/63-step1.html")
	;OpenHelpPage("etape2")
EndFunc   ;==>GUI_Help_Step2

Func GUI_Help_Step3()
	;OpenHelpPage("etape3")
EndFunc   ;==>GUI_Help_Step3

Func GUI_Help_Step4()
	;OpenHelpPage("etape4")
EndFunc   ;==>GUI_Help_Step4

Func GUI_Help_Step5()
	SendReport("Start-GUI_Help_Step5")
	_About(Translate("A propos"), "LiLi USB Creator", "CopyLeft by Thibaut Lauzi�re - GPL v3 License", $software_version, Translate("Guide d'utilisation"), "http://www.linuxliveusb.com/how-to.html", Translate("Homepage"), "http://www.linuxliveusb.com", Translate("Faire un don"), "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8297661", @AutoItExe, 0x0000FF, 0xFFFFFF, -1, -1, -1, -1, $CONTROL_GUI)
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
	$temp = IniReadSectionNames($lang_ini)
	$available_langs = _ArrayToString($temp)
	If $force_lang <> "no" And (StringInStr($available_langs, $force_lang) > 0) Then
		SendReport("End-_Language (Force Lang)")
		Return $force_lang
	EndIf
	Select
		Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009,2409,2809,2c09,3009,3409", @OSLang)
			SendReport("End-_Language (English)")
			Return "English"
		Case StringInStr("040c,080c,0c0c,100c,140c,180c", @OSLang)
			SendReport("End-_Language (French)")
			Return "French"
		Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a,240a,280a,2c0a,300a,340a,380a,3c0a,400a,440a,480a,4c0a,500a", @OSLang)
			SendReport("End-_Language (Spanish)")
			Return "Spanish"
		Case StringInStr("0407,0807,0c07,1007,1407", @OSLang)
			SendReport("End-_Language (German)")
			Return "German"
		Case StringInStr("0416,0816", @OSLang)
			SendReport("End-_Language (Portuguese)")
			Return "Portuguese";
		Case StringInStr("0410,0810", @OSLang)
			SendReport("End-_Language (Italian)")
			Return "Italian"
		Case StringInStr("0414,0814", @OSLang)
			SendReport("End-_Language (Norwegian)")
			Return "Norwegian"
		Case Else
			SendReport("End-_Language Default : English")
			Return "English"

	EndSelect
	SendReport("End-_Language")
EndFunc   ;==>_Language

Func Translate($txt)
	Return IniRead($lang_ini, $lang, $txt, $txt)
EndFunc   ;==>Translate
