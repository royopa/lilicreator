; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Checking ISO/File MD5 Hashes + recognizing source ///////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Check_source_integrity($linux_live_file)
	SendReport("Start-Check_source_integrity (LinuxFile : " & $linux_live_file & " )")

	; Used to avoid redrawing the old elements of Step 2 (ISO, CD and download)
	if $step2_display_menu=0 Then GUI_Hide_Step2_Default_Menu()
	if $step2_display_menu=1 Then GUI_Hide_Step2_Download_Menu()
	$step2_display_menu = 2
	GUI_Show_Back_Button()

	GUICtrlSetState($label_step2_status,$GUI_HIDE)
	$cleaner = GUICtrlCreateLabel("", 38 + $offsetx0, 238 + $offsety0, 300, 90)
	GUICtrlSetState($cleaner, $GUI_SHOW)
	GUICtrlSetState($cleaner,$GUI_HIDE)

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
	If IniRead($settings_ini, "Advanced", "skip_recognition", "no") == "yes" Or get_extension($linux_live_file) = "img" Then
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

	If IniRead($settings_ini, "Advanced", "skip_md5", "no") = "no" Then
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

			if ((StringInStr($shortname, "alternate") OR StringInStr($shortname, "server")) AND NOT StringInStr($shortname, "live") ) Then
					; Any Server versions and alternate
					$release_number = _ArraySearch($codenames_list, "default")
			ElseIf ((StringInStr($shortname, "10.04") OR StringInStr($shortname, "lucid") OR StringInStr($shortname, "buntu")) AND NOT StringInStr($shortname, "9.10") AND NOT StringInStr($shortname, "karmic")) Then
				if (StringInStr($shortname, "xubuntu")) Then
					; Xubuntu
					$release_number = _ArraySearch($codenames_list, "xubuntu-last")
				Elseif (StringInStr($shortname, "mythbuntu")) Then
					; Mythbuntu
					$release_number = _ArraySearch($codenames_list, "mythbuntu-last")
				Elseif (StringInStr($shortname, "lubuntu")) Then
					; Lubuntu
					$release_number = _ArraySearch($codenames_list, "lubuntu-last")
				Elseif (StringInStr($shortname, "kubuntu") AND NOT StringInStr($shortname, "netbook") ) Then
					; Kubuntu Desktop
					$release_number = _ArraySearch($codenames_list, "kubuntu-last")
				Elseif (StringInStr($shortname, "kubuntu") AND StringInStr($shortname, "netbook") ) Then
					; Kubuntu Netbook
					$release_number = _ArraySearch($codenames_list, "kubuntu-netbook-last")
				Elseif (StringInStr($shortname, "ubuntu") AND NOT StringInStr($shortname, "netbook") ) Then
					; Ubuntu Desktop
					$release_number = _ArraySearch($codenames_list, "ubuntu-last")
				Elseif (StringInStr($shortname, "ubuntu") AND StringInStr($shortname, "netbook") ) Then
					; Ubuntu NetBook
					$release_number = _ArraySearch($codenames_list, "ubuntu-netbook-last")
				Else
					; Falls back to Ubuntu Desktop
					$release_number = _ArraySearch($codenames_list, "ubuntu-last")
				EndIf
			Elseif ( StringInStr($shortname, "9.10") ) And StringInStr($shortname, "netbook") Then
				; Ubuntu Karmic 9.10 based
				$release_number = _ArraySearch($codenames_list, "ubuntu-netbook-9.10")
			ElseIf ( StringInStr($shortname, "9.10") ) And StringInStr($shortname, "mythbuntu") Then
				; Mythbuntu >=9.10
				$release_number = _ArraySearch($codenames_list, "mythbuntu-9.10")
			ElseIf StringInStr($shortname, "moblin-remix") Then
				; Ubuntu moblin remix
				$release_number = _ArraySearch($codenames_list, "moblin-remix-last")
			ElseIf StringInStr($shortname, "grml") Then
				; Grml
				$release_number = _ArraySearch($codenames_list, "grml-last")
			ElseIf StringInStr($shortname, "knoppix") Then
				; Knoppix
				$release_number = _ArraySearch($codenames_list, "knoppix-last")
			ElseIf (StringInStr($shortname, "karmic") Or StringInStr($shortname, "buntu")) Then
				; Ubuntu Karmic (>=9.10) based
				$release_number = _ArraySearch($codenames_list, "ubuntu-9.10")
			ElseIf StringInStr($shortname, "9.04") Then
				; Ubuntu 9.04 based
				$release_number = _ArraySearch($codenames_list, "ubuntu-904")
			ElseIf StringInStr($shortname, "kuki") Then
				; Kuki based (Ubuntu)
				$release_number = _ArraySearch($codenames_list, "kuki-last")
			ElseIf StringInStr($shortname, "jolicloud") Then
				; Jolicloud (Ubuntu)
				$release_number = _ArraySearch($codenames_list, "jolicloud-last")
			ElseIf StringInStr($shortname, "element") Then
				; Element (Ubuntu)
				$release_number = _ArraySearch($codenames_list, "element-last")
			ElseIf StringInStr($shortname, "android") Then
				; Android x86
				$release_number = _ArraySearch($codenames_list, "android-last")
			ElseIf StringInStr($shortname, "trisquel") Then
				; Trisquel (Ubuntu)
				$release_number = _ArraySearch($codenames_list, "trisquel-last")
			ElseIf StringInStr($shortname, "plop") Then
				if StringInStr($shortname, "-X") Then
					; PLoP Linux with X
					$release_number = _ArraySearch($codenames_list, "plopx-last")
				Else
					; PLoP Linux without X
					$release_number = _ArraySearch($codenames_list, "plop-last")
				EndIf
			ElseIf StringInStr($shortname, "fedora") Or StringInStr($shortname, "F10") Or StringInStr($shortname, "F11") OR StringInStr($shortname, "F12") Then
				; Fedora Based
				$release_number = _ArraySearch($codenames_list, "fedora-last")
			ElseIf StringInStr($shortname, "soas") Then
				; Sugar on a stick
				$release_number = _ArraySearch($codenames_list, "sugar-last")
			ElseIf StringInStr($shortname, "mint") Then
				; Mint variants
				if StringInStr($shortname, "KDE") Then
					$release_number = _ArraySearch($codenames_list, "mintkde-last")
				elseif StringInStr($shortname, "LXDE") Then
					$release_number = _ArraySearch($codenames_list, "mintlxde-last")
				elseif StringInStr($shortname, "Xfce") Then
					$release_number = _ArraySearch($codenames_list, "mintxfce-last")
				else
					$release_number = _ArraySearch($codenames_list, "mint-last")
				EndIf
			ElseIf StringInStr($shortname, "gnewsense") Then
				; gNewSense Based
				$release_number = _ArraySearch($codenames_list, "gnewsense-last")
			ElseIf StringInStr($shortname, "clonezilla") Then
				; Clonezilla
				$release_number = _ArraySearch($codenames_list, "clonezilla-last")
			ElseIf StringInStr($shortname, "gparted-live") Then
				; Gparted
				$release_number = _ArraySearch($codenames_list, "gpartedlive-last")
			ElseIf StringInStr($shortname, "debian") Then
				; Debian
				$release_number = _ArraySearch($codenames_list, "debiangnome-last")
			ElseIf StringInStr($shortname, "toutou") Then
				; Toutou Linux
				$release_number = _ArraySearch($codenames_list, "toutou-last")
			ElseIf StringInStr($shortname, "puppy") Or StringInStr($shortname, "pup-") Then
				; Puppy Linux
				$release_number = _ArraySearch($codenames_list, "puppy-last")
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

				; PCLinuxOS (default to KDE)
				if StringInStr($shortname, "e17") Then
					$release_number = _ArraySearch($codenames_list, "pclinuxose17-last")
				elseif StringInStr($shortname, "LXDE") Then
					$release_number = _ArraySearch($codenames_list, "pclinuxoslxde-last")
				elseif StringInStr($shortname, "Xfce") Then
					$release_number = _ArraySearch($codenames_list, "pclinuxosxfce-last")
				elseif StringInStr($shortname, "gnome") Then
					$release_number = _ArraySearch($codenames_list, "pclinuxosgnome-last")
				else
					$release_number = _ArraySearch($codenames_list, "pclinuxoskde-last")
				EndIf
			ElseIf StringInStr($shortname, "slitaz") Then
				; Slitaz
				$release_number = _ArraySearch($codenames_list, "slitaz-last")
			ElseIf StringInStr($shortname, "tinycore") Then
				; Tiny Core
				$release_number = _ArraySearch($codenames_list, "tinycore-last")
			ElseIf StringInStr($shortname, "ophcrack") Then
				; OphCrack
				$release_number = _ArraySearch($codenames_list, "ophcrackxp-last")
			ElseIf StringInStr($shortname, "chakra") Then
				; Chakra
				$release_number = _ArraySearch($codenames_list, "chakra-last")
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
			ElseIf StringInStr($shortname, "xange") Then
				; Xange variants
				$release_number = _ArraySearch($codenames_list, "xange-last")
			ElseIf StringInStr($shortname, "SimplyMEPIS") Then
				; SimplyMEPIS variants
				$release_number = _ArraySearch($codenames_list, "simplymepis-last")
			ElseIf StringInStr($shortname, "puredyne") Then
				; Puredyne
				$release_number = _ArraySearch($codenames_list, "puredyne-last")
			ElseIf StringInStr($shortname, "64studio") Then
				; 64studio
				$release_number = _ArraySearch($codenames_list, "64studio-last")
			ElseIf StringInStr($shortname, "antix") Then
				; Antix MEPIS variants
				$release_number = _ArraySearch($codenames_list, "antix-last")
			ElseIf StringInStr($shortname, "peasy") Then
				; Easy Peasy
				$release_number = _ArraySearch($codenames_list, "easypeasy-last")
			ElseIf StringInStr($shortname, "elive") Then
				; Elive
				$release_number = _ArraySearch($codenames_list, "elive-last")
			ElseIf StringInStr($shortname, "livehacking") Then
				; Live Hacking CD
				if StringInStr($shortname, "mini") Then
					$release_number = _ArraySearch($codenames_list, "livehackingmini-last")
				Else
					$release_number = _ArraySearch($codenames_list, "livehacking-last")
				EndIf
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

	if $step2_display_menu=0 Then GUI_Hide_Step2_Default_Menu()
	if $step2_display_menu=1 Then GUI_Hide_Step2_Download_Menu()

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
	If IniRead($settings_ini, "Advanced", "skip_checking", "no") == "yes" Then
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
