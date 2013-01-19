#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=beta
#AutoIt3Wrapper_Icon=img\lili.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
Opt("TrayOnEventMode",1)
Opt("TrayMenuMode",1)
Opt('GUIOnEventMode', 1)

#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <Constants.au3>
#include "Toast.au3"

Global $ToastOn = False
Global $toast_label
Global $begin,$progressbar,$progressbar_text,$toast_text,$toast_message,$human_time="",$oldgetbytesread

HotKeySet("{ESC}", "GUI_Exit")
TraySetOnEvent($TRAY_EVENT_PRIMARYUP,"SwitchToast")
TraySetOnEvent($TRAY_EVENT_SECONDARYUP,"SwitchToast")
TraySetIcon(@ScriptDir & "\img\downloader\systray-0.ico")
TraySetState()

Global $lilidownloader_ini = @ScriptDir&"\settings\lili-downloader.ini"

If $CmdLine[0] > 1 And StringInStr($CmdLine[1], "://") Then
	Global $download_url = $CmdLine[1]
	Global $destination_file = $CmdLine[2]
	Global $temp_filename = StringReplace($destination_file, unix_path_to_extension($download_url), "lili-download")
	Global $current_dl

Else
	;$download_url="http://ftp.osuosl.org/pub/finnix/102/finnix-102.iso"
	Global $download_url = "http://fr.releases.ubuntu.com/11.10/ubuntu-11.10-desktop-i386.iso"
	Global $destination_file = @DesktopDir & "\tinycore-current.iso"
	Global $temp_filename = StringReplace($destination_file, unix_path_to_extension($download_url), "lili-download")
	Global $current_dl
	;MsgBox(0,"Error","Nothing to download")
	;Exit
EndIf

WriteSetting("url",$download_url)
WriteSetting("status","waiting")
$current_dl = InetGet($download_url, $temp_filename, 3, 1)

Sleep(1000)
If InetGetInfo($current_dl, 4) <> 0 Then
	MsgBox(0, "Error", "Could not start download")
	WriteSetting("status","error")
	Exit
EndIf


Global $current_dl_total_size = InetGetInfo($current_dl, 1)
Global $current_dl_total_size_mb = Round($current_dl_total_size / (1024 * 1024))

CreateToast()
$ToastOn = True
AdlibRegister("UpdateToast",200)
#cs
$name = TrayCreateItem(unix_path_to_name($download_url))
$progress = TrayCreateItem("0% (0MB / " & $current_dl_total_size_mb & "MB)")
$remaining = TrayCreateItem(" ")
TrayCreateItem("")
$exititem = TrayCreateItem("Stop download")
TrayItemSetOnEvent($exititem, "GUI_Exit")
TraySetIcon(@ScriptDir & "\img\downloader\systray-0.ico")
TraySetState()
#ce


While 1
	Sleep(1000)
Wend

Func SwitchToast()
	If $ToastOn Then
		_Toast_Hide2()
		$ToastOn = False
		Return ""
	Else
		_Toast_Show2()
		$ToastOn = True
		Return ""
	EndIf
EndFunc

Func CreateToast()
	$current_dl_size = InetGetInfo($current_dl, 0)
	$current_dl_size_MB = Round($current_dl_size / (1024 * 1024), 0)
	$percent_dl = Percent($current_dl_size, $current_dl_total_size)

	$toast_message = "Downloading "&unix_path_to_name($download_url)&@CRLF&$percent_dl & "% (" & $current_dl_size_MB & "MB / " & $current_dl_total_size_mb & "MB)"&@CRLF&$human_time&@CRLF&@CRLF&@CRLF&@CRLF
	$aRet = _Toast_Show(0, "", $toast_message)
	;$toast_text =  GUICtrlCreateLabel($toast_message,10,10,60,100)
	$progressbar = GUICtrlCreateProgress(10,$aRet[1] - 60, $aRet[0] - 20,20)
	GuiCtrlSetData($progressbar,$percent_dl)
	$progressbar_text = GUICtrlCreateLabel("BIOU",10,$aRet[1] - 60, $aRet[0] - 20,20,$SS_CENTER)
	Guictrlsetbkcolor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlCreateButton("Cancel download",130,$aRet[1]-30,140,25)
	GUICtrlSetOnEvent(-1,"GUI_Exit")

	GUICtrlCreateButton("Hide",30,$aRet[1]-30,50,25)
	GUICtrlSetOnEvent(-1,"SwitchToast")

	;$toast_exit = GUICtrlCreateButton("X",$aRet[1] - 10,$aRet[0] - 20,20,20)
	;GUICtrlSetOnEvent(-1,"GUI_Exit")
	$begin = TimerInit()

	$oldgetbytesread = InetGetInfo($current_dl, 0)
EndFunc

Func UpdateToast()
		WriteSetting("status","downloading-"&InetGetInfo($current_dl, 0))
		$current_dl_size = InetGetInfo($current_dl, 0)
		$current_dl_size_MB = Round($current_dl_size / (1024 * 1024), 0)
		$percent_dl = Percent($current_dl_size, $current_dl_total_size)
		$percent_dl_text=$percent_dl&"%"


		If GUICtrlRead($progressbar_text) <> $percent_dl_text Then
			GUICtrlSetData($progressbar, $percent_dl)
			GUICtrlSetData($progressbar_text,$percent_dl_text)

		Else
			ConsoleWrite("SAME DATA"&@CRLF)
		EndIf

		;TrayItemSetText($progress, $percent_dl & "% (" & $current_dl_size_MB & "MB / " & $current_dl_total_size_mb & "MB)")
		SetProgressIcon($percent_dl)
		$dif = TimerDiff($begin)

		$newgetbytesread = InetGetInfo($current_dl, 0)
		If $dif > 5000 Then
			$bytes_per_ms = ($newgetbytesread - $oldgetbytesread) / $dif
			$human_time=FormatTimeForHuman(($current_dl_total_size - $newgetbytesread) / (1000 * $bytes_per_ms))
			if $bytes_per_ms >= 1000 Then $human_time&=" @ "&AutomaticBitsUnit(1000*$bytes_per_ms,"bps")
			ConsoleWrite(@CRLF&$human_time)
			$begin = TimerInit()
			$oldgetbytesread = $newgetbytesread
		EndIf
		$toast_message = "Downloading "&unix_path_to_name($download_url)&@CRLF&$percent_dl & "% (" & $current_dl_size_MB & "MB / " & $current_dl_total_size_mb & "MB)"&@CRLF&$human_time&@CRLF&@CRLF&@CRLF&@CRLF
		GUICtrlSetData($toast_label,$toast_message&@CRLF&@CRLF&@CRLF)

		if InetGetInfo($current_dl, 3) Then CompleteDownload()
EndFunc

Func _Toast_Show2()
	GUISetState(@SW_SHOW,$hToast_Handle)
EndFunc

Func _Toast_Hide2()
	GUISetState(@SW_HIDE,$hToast_Handle)
EndFunc

Func AutomaticBitsUnit($value, $suffix)
	If $value < 2 ^ 10 Then
		Return $value & " " & $suffix
	ElseIf $value < 2 ^ 20 Then
		Return RoundForce($value / 2 ^ 10, 0) & " k" & $suffix
	ElseIf $value < 2 ^ 30 Then
		Return RoundForce($value / 2 ^ 20, 1) & " M" & $suffix
	ElseIf $value < 2 ^ 40 Then
		Return RoundForce($value / 2 ^ 30, 1) & " G" & $suffix
	ElseIf $value < 2 ^ 50 Then
		Return RoundForce($value / 2 ^ 40, 1) & " T" & $suffix
	ElseIf $value < 2 ^ 60 Then
		Return RoundForce($value / 2 ^ 50, 1) & " P" & $suffix
	ElseIf $value < 2 ^ 70 Then
		Return RoundForce($value / 2 ^ 60, 1) & " E" & $suffix
	ElseIf $value < 2 ^ 80 Then
		Return RoundForce($value / 2 ^ 70, 1) & " Z" & $suffix
	Else
		Return RoundForce($value / 2 ^ 80, 1) & " Y" & $suffix
	EndIf
EndFunc   ;==>AutomaticBitsUnit

Func RoundForce($value,$decimal)
	$rounded = Round($value, $decimal)
	If $decimal =0 Then
		Return $rounded
	Elseif StringInStr($rounded,".") <= 0 Then
		Return $rounded&".0"
	Else
		Return $rounded
	EndIf
EndFunc

Func GUI_Exit()
	InetClose($current_dl)
	FileDelete($temp_filename)
	Exit
EndFunc   ;==>GUI_Exit

Func CompleteDownload()
	FileMove($temp_filename, $destination_file)
	WriteSetting("status","completed")
	MsgBox(0, "LiLi Downloader", "Download is complete")
	GUI_Exit()
EndFunc   ;==>CompleteDownload

Func HumanTime($sec)
	If $sec <= 0 Then Return ""

	$hours = Floor($sec / 3600)
	If $hours > 5 Then Return ""

	$minutes = Floor($sec / 60) - $hours * 60
	$seconds = Floor($sec) - $minutes * 60

	; to avoid displaying bullshit
	If $minutes < 0 Or $hours < 0 Or $seconds < 0 Then Return ""

	If $sec > 3600 Then
		$human_time_temp = $hours & "h " & $minutes & "m "
	ElseIf $sec <= 3600 And $sec > 60 Then
		$human_time_temp = $minutes & "m " & $seconds & "s "
	ElseIf $sec <= 60 Then
		$human_time_temp = $seconds & "s "
	EndIf
	Return $human_time_temp
EndFunc   ;==>HumanTime

Func unix_path_to_name($filepath)
	$short_name = StringSplit($filepath, '/')
	If Not @error And IsArray($short_name) Then
		Return ($short_name[$short_name[0]])
	Else
		Return "ERROR"
	EndIf
EndFunc   ;==>unix_path_to_name

Func unix_path_to_extension($filepath)
	$extension = StringSplit($filepath, '.')
	If Not @error And IsArray($extension) Then
		Return ($extension[$extension[0]])
	Else
		Return "ERROR"
	EndIf
EndFunc   ;==>unix_path_to_extension

Func Percent($value, $total)
	Return Round(100 * $value / $total, 0)
EndFunc   ;==>Percent

Func SetProgressIcon($progress_percent)
	$icon_number = Round($progress_percent / 6.25, 0)
	TraySetIcon(@ScriptDir & "\img\downloader\systray-" & $icon_number & ".ico")
	TraySetState()
EndFunc   ;==>SetProgressIcon

Func WriteSetting($key,$value)
	IniWrite($lilidownloader_ini, "CurrentDownload", $key, $value)
EndFunc

Func ReadSetting($key)
	$val=IniRead($lilidownloader_ini, "CurrentDownload", $key,"")
	Return StringStripWS($val,3)
EndFunc

Func FormatTimeForHuman($Input_Seconds)
	Global $Input = $Input_Seconds
	Global $human_time = ""
	Local $msec = "", $sec = "", $min = "", $hours = "", $days = ""
	Switch Round($Input_Seconds)
		Case 1 To 59
			$sec = GetSeconds()
		Case 60 To 3599
			$min = GetMinutes()
		Case 3600 To 86399
			$hours = GetHours()
			$min = GetMinutes()
		Case Else
			return ""
	EndSwitch

	If StringRight($human_time, 2) == ", " Then
		Return StringTrimRight($human_time, 2)
	EndIf
	Return $human_time
EndFunc   ;==>FormatElapsedTimeForHuman

Func GetDays()
	Global $Input
	$days = Int($Input / 86400)
	$Input -= ($days * 86400)
	If $days <> 0 Then
		$human_time &= $days & Plural("day", $days) & ', '
		Return $days
	Else
		Return ""
	EndIf
EndFunc   ;==>GetDays

Func GetHours()
	Global $Input
	$hours = Int($Input / 3600)
	$Input -= ($hours * 3600)
	If $hours <> 0 Then
		$human_time &= $hours & Plural("hour", $hours) & ', '
		Return $hours
	Else
		Return ""
	EndIf
EndFunc   ;==>GetHours

Func GetMinutes()
	Global $Input
	$Minutes = Int($Input / 60)
	$Input -= ($Minutes * 60)

	If $Minutes <> 0 Then
		$human_time &= $Minutes & Plural("minute", $Minutes) & ', '
		Return $Minutes
	Else
		Return ""
	EndIf
EndFunc   ;==>GetMinutes

Func GetSeconds()
	Global $Input
	$sec = Floor($Input)
	If $sec <> 0 Then
		$human_time &= $sec & Plural("second", $sec) & ', '
		Return $sec
	Else
		Return ""
	EndIf
EndFunc   ;==>GetSeconds

Func GetMilliSeconds()
	Global $Input
	$msec = Round((Round($Input, 3) - Floor($Input)) * 1000)
	If $msec <> 0 Then
		$human_time &= $msec & Plural("millisecond", $msec)
		Return $msec
	Else
		Return ""
	EndIf
EndFunc   ;==>GetMilliSeconds

Func Plural($word, $value)
	If $value > 1 Then
		Return " " & $word & "s"
	Else
		Return " " & $word
	EndIf
EndFunc   ;==>Plural