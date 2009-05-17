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

Opt("GUIOnEventMode", 1)

Dim $linux_user_select, $linux_releases, $linux_release, $linux_filename, $linux_real_size, $linux_size, $linux_need_download, $linux_user_select_file, $linux_path, $linux_no_selection, $linux_choice
Dim $fk_user_select, $fk_releases, $fk_release, $fk_filename, $fk_real_size, $fk_size, $fk_need_download, $fk_user_select_file, $fk_path, $fk_no_selection, $fk_choice
Dim $destination, $download_size, $download_completed, $download_aborted
Global $fk_releases, $linux_releases, $start_process_time, $archive_files_number, $archive_files_count
$lang="en"

$linux_ini="linux.ini"


	Global Const $R_CODE = 0,$R_NAME=1,$R_DISTRIBUTION=2, $R_VERSION_NUMBER=3,$R_FILENAME=4,$R_FILE_MD5=5,$R_RELEASE_DATE=6,$R_WEB=7,$R_DOWNLOAD_PAGE=8,$R_DOWNLOAD_SIZE=9,$R_INSTALL_SIZE=10,$R_DESCRIPTION=11
	Global Const $R_MIRROR1=12,$R_MIRROR2=13,$R_MIRROR3=14,$R_MIRROR4=15,$R_MIRROR5=16,$R_MIRROR6=17,$R_MIRROR7=18,$R_MIRROR8=19,$R_MIRROR9=20,$R_MIRROR10=21
	




$Form2 = GUICreate("FramaGnu beta 2", 533, 520, 269, 144)
GUISetOnEvent($GUI_EVENT_CLOSE, "Form2Close")

$LinuxCombo = GUICtrlCreateCombo("->", 90, 145, 300,-1,3)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetOnEvent($LinuxCombo, "LinuxComboChange")
$LinuxDetailsBtn = GUICtrlCreateButton("Détails", 440, 192, 65, 25, 0)
GUICtrlSetOnEvent($LinuxDetailsBtn, "LinuxDetailsBtnClick")

GUISetState(@SW_SHOW)


LinuxSetData()
LinuxComboChange()

While 1
	Sleep(100)
WEnd

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

Func Form2Close()
 exit
EndFunc