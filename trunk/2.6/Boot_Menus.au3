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
	$codename = ReleaseGetCodename($release_in_list)

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

	; Ubuntu versions > 9.10 use an initrd.lz instead of initrd.gz file
	If GenericVersionCode($distrib_version) >= 910 Then
		$initrd_file = "initrd.lz"
	Else
		$initrd_file = "initrd.gz"
	EndIf

	UpdateLog("Type of initrd file : " &$initrd_file &"( for Genereic Version Code ="&GenericVersionCode($distrib_version)&" )" )

	; For official Ubuntu variants, only text.cfg need to be modified
	if $ubuntu_variant="ubuntu" OR StringInStr($ubuntu_variant, "xubuntu") OR StringInStr($ubuntu_variant, "lubuntu") OR StringInStr($ubuntu_variant, "netbook") OR StringInStr($ubuntu_variant, "easypeasy") OR StringInStr($ubuntu_variant, "kubuntu") OR $ubuntu_variant="superos" OR StringInStr($ubuntu_variant, "mythbuntu") Then
		if (StringInStr($ubuntu_variant, "easypeasy")) Then
			$boot_text = Ubuntu_BootMenu($initrd_file,"ubuntu-netbook")
		Else
			$boot_text = Ubuntu_BootMenu($initrd_file,$ubuntu_variant)
		EndIf
		UpdateLog("Creating text.cfg file for Ubuntu variants :" & @CRLF & $boot_text)
		$file = FileOpen($selected_drive & "\syslinux\text.cfg", 2)
		FileWrite($file, $boot_text)
		FileClose($file)
	EndIf

	; For Mint, only syslinux.cfg need to be modified
	If $ubuntu_variant = "mint" Then

		; Mint KDE uses a splash.png image
		if StringInStr($codename,"mintkde") Then
			$splash_img="splash.png"
		Else
			$splash_img="splash.jpg"
		EndIf

		$boot_text = "default vesamenu.c32" _
				 & @LF & "timeout 100" _
				 & @LF & "menu background "&$splash_img _
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

	If $ubuntu_variant = "crunchbang" OR $ubuntu_variant = "kuki"  OR $ubuntu_variant = "element" Then
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
			 & @LF & "menu title Welcome to your LinuxLive Key !" _
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
			 & @LF & "label linux1" _
			 & @LF & "  menu label " & Translate("Live Mode") _
			 & @LF & "  kernel vmlinuz0" _
			 & @LF & "  append initrd=initrd0.img root=UUID=" & $uuid & " rootfstype=vfat ro liveimg quiet selinux=0 rhgb  rd_NO_LUKS rd_NO_MD noiswmd" _
			 & @LF & "label linux0" _
			 & @LF & "  menu label " & Translate("Persistent Mode") _
			 & @LF & "  kernel vmlinuz0" _
			 & @LF & "  append initrd=initrd0.img root=UUID=" & $uuid & " rootfstype=vfat rw liveimg overlay=UUID=" & $uuid & " quiet selinux=0 rhgb  rd_NO_LUKS rd_NO_MD noiswmd" _
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



