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
	GUICtrlDelete($cleaner)

	$shortname = CleanFilename(path_to_name($linux_live_file))

	Global $MD5_ISO, $compatible_md5, $compatible_filename, $release_number = -1

	; Pre-Checking
	If get_extension($linux_live_file) = "img" AND NOT StringInStr($shortname, "meego") AND ReadSetting("Advanced","force_iso_mode")="no" Then

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
		Disable_Persistent_Mode()
		Enable_VirtualBox_Option()
		Enable_Hide_Option()
		SendReport("IN-Check_Source (iso selected :" & $linux_live_file & ")")
		$file_set_mode = "iso"
	EndIf

	; If user already select to force some install parameters
	If ReadSetting("Install_Parameters","automatic_recognition")<>"yes" Then
		$forced_description=ReadSetting("Install_Parameters","use_same_parameter_as")
		$release_number = FindReleaseFromDescription($forced_description)
		if $release_number <> -1 Then
			Step2_Check("good")
			Sleep(100)
			GUI_Show_Check_status(Translate("Verifying") & " OK"&@CRLF& Translate("This version is compatible and its integrity was checked")&@CRLF&Translate("Recognized Linux")&" : "&@CRLF& @CRLF & @TAB &ReleaseGetDescription($release_number))
			Check_If_Default_Should_Be_Used($release_number)
		EndIf
		SendReport("IN-Check_source_integrity (forced install parameters to : "&$forced_description&" - Release # :"&$release_number&")")
		Return ""
	EndIf

	; No check if it's an img file or if the user do not want to
	If ReadSetting( "Advanced", "skip_recognition") == "yes" OR $file_set_mode="img" Then
		Step2_Check("good")
		$temp_index = FindReleaseFromCodeName("default")
		$release_number = $temp_index
		Disable_Persistent_Mode()
		SendReport("IN-Check_source_integrity (skipping recognition, using default mode)")
		Return ""
	EndIf

	SendReport("IN-Check_source_integrity -> Checking if non grata")
	If Check_if_version_non_grata($shortname) Then Return ""

	; Some files do not need to be checked by MD5 ( Alpha releases ...). Only trusting filename
	$temp_index = FindReleaseFromFileName($shortname)
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

	If ReadSetting( "Advanced", "skip_md5") <> "yes" Then
		$MD5_ISO = Check_ISO($linux_live_file)
		SendReport("distrib-" & $shortname&"#"&$MD5_ISO)
		$temp_index = FindReleaseFromMD5($MD5_ISO)
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
		$temp_index = FindReleaseFromFileName($shortname)
		If $temp_index > 0 Then
			; Filename is known but MD5 not OK -> COMPATIBLE BUT ERROR
			$release_number = $temp_index
			GUI_Show_Check_status(Translate("You have the right ISO file but it is corrupted or was altered") &". "&Translate("Please download it again")&"."&@CRLF&Translate("However, LinuxLive USB Creator will try to use same install parameters as for") & @CRLF & @TAB & @TAB& ReleaseGetDescription($release_number))
			Step2_Check("warning")
			SendReport("IN-Check_source_integrity (MD5 not found but filename found : " & ReleaseGetFilename($release_number) & " )")
		Else
			; Filename is not known but trying to find what it is with its name => INTELLIGENT PROCESSING
			SendReport("IN-Check_source_integrity (start intelligent processing)")

			if ((StringInStr($shortname, "alternate") OR StringInStr($shortname, "server") OR StringInStr($shortname, "ubuntu-studio") ) AND NOT StringInStr($shortname, "live") AND NOT StringInStr($shortname, "windows") AND NOT StringInStr($shortname, "esx") AND NOT StringInStr($shortname, "rhel") AND NOT StringInStr($shortname, "vmware")  ) Then
					; Any Server versions and alternate
					$release_number = FindReleaseFromCodeName( "default")
			ElseIf StringInStr($shortname, "archbang") Then
				; ArchBang
				$release_number = FindReleaseFromCodeName( "archbang-last")
			ElseIf StringInStr($shortname, "archlinux") Then
				; Arch Linux
				$release_number = FindReleaseFromCodeName( "archlinux-last")
			ElseIf StringInStr($shortname, "xbmc") Then
				; XBMC
				$temp_index = FindReleaseFromCodeName( "xbmc-last")
			ElseIf StringInStr($shortname, "buntu") Then

				if StringInStr($shortname, "13.10") OR StringInStr($shortname, "saucy") OR StringInStr($shortname, "salam") Then
					$ubuntu_version = "13.10"
				Elseif StringInStr($shortname, "13.04") OR StringInStr($shortname, "rari") OR StringInStr($shortname, "ring") Then
					$ubuntu_version = "13.04"
				Elseif StringInStr($shortname, "12.10") OR StringInStr($shortname, "quant") OR StringInStr($shortname, "quet") Then
					$ubuntu_version = "12.10"
				Elseif StringInStr($shortname, "12.04") OR StringInStr($shortname, "preci") OR StringInStr($shortname, "pang") Then
					$ubuntu_version = "12.04"
				Elseif StringInStr($shortname, "11.10") OR StringInStr($shortname, "onei") OR StringInStr($shortname, "ocel") Then
					$ubuntu_version = "11.10"
				Elseif StringInStr($shortname, "11.04") OR StringInStr($shortname, "natty") OR StringInStr($shortname, "narw") Then
					$ubuntu_version = "11.04"
				Elseif StringInStr($shortname, "10.10") OR StringInStr($shortname, "mave") OR StringInStr($shortname, "meer") Then
					$ubuntu_version = "10.10"
				Elseif StringInStr($shortname, "10.04") OR StringInStr($shortname, "lucid") OR StringInStr($shortname, "lynx") Then
					$ubuntu_version = "10.04"
				Elseif StringInStr($shortname, "9.10") OR StringInStr($shortname, "karm") OR StringInStr($shortname, "koala") Then
					$ubuntu_version = "9.10"
				Elseif StringInStr($shortname, "9.04") OR StringInStr($shortname, "jaunt") OR StringInStr($shortname, "jacka") Then
					$ubuntu_version = "9.04"
				Else
					$ubuntu_version = ""
				EndIf

				;if (StringInStr($shortname, "beta") OR StringInStr($shortname, "alpha") OR StringInStr($shortname, "-rc"))Then
					; Betas
				;	$release_number = FindReleaseFromCodeName( "ubuntubeta-last")
				;Else

				if (StringInStr($shortname, "xubuntu")) Then
					; Xubuntu
					$ubuntu_variant = "xubuntu"
				Elseif (StringInStr($shortname, "studio" )) Then
					; Ubuntu Studio
					$ubuntu_variant = "ubuntustudio"
				Elseif (StringInStr($shortname, "kubuntu") AND StringInStr($shortname, "netbook") ) Then
					; Kubuntu Netbook (deprecated)
					$ubuntu_variant = "kubuntu-netbook"
				Elseif (StringInStr($shortname, "ubuntu") AND StringInStr($shortname, "netbook") ) Then
					; Ubuntu NetBook (deprecated)
					$ubuntu_variant = "ubuntu-netbook"
				Elseif (StringInStr($shortname, "mythbuntu")) Then
					; Mythbuntu
					$ubuntu_variant = "mythbuntu"
				Elseif (StringInStr($shortname, "lubuntu")) Then
					; Lubuntu
					$ubuntu_variant = "lubuntu"
				Elseif StringInStr($shortname, "kubuntu") Then
					; Kubuntu Desktop
					$ubuntu_variant = "kubuntu"
				Elseif (StringInStr($shortname, "studio")) Then
					; Ubuntu studio
					$ubuntu_variant = "ubuntustudio"
				Else
					; Falls back to Ubuntu Desktop
					$ubuntu_variant = "ubuntu"
				EndIf

				$release_number = FindReleaseFromCodeName( $ubuntu_variant&$ubuntu_version&"-last")
				if ReleaseGetCodename($release_number)="default" Then
					$release_number = FindReleaseFromCodeName( $ubuntu_variant&"-last")
					if ReleaseGetCodename($release_number)="default" Then
						$release_number = FindReleaseFromCodeName("ubuntu-last")
					EndIf
				EndIf
			ElseIf StringInStr($shortname, "grml") Then
				; Grml
				$release_number = FindReleaseFromCodeName( "grml-last")
			ElseIf StringInStr($shortname, "knoppix") Then
				; Knoppix
				$release_number = FindReleaseFromCodeName( "knoppix-last")
			ElseIf StringInStr($shortname, "jolicloud") OR StringInStr($shortname, "joli-os") Then
				; Jolicloud (Ubuntu)
				$release_number = FindReleaseFromCodeName( "jolicloud-last")
			ElseIf StringInStr($shortname, "elementa") Then
				; Elementary OS (Ubuntu)
				$release_number = FindReleaseFromCodeName( "elementary-last")
			ElseIf StringInStr($shortname, "voyage") Then
				; Voyager (Ubuntu)
				$release_number = FindReleaseFromCodeName( "voyager-last")
			ElseIf StringInStr($shortname, "element") Then
				; Element (Ubuntu)
				$release_number = FindReleaseFromCodeName( "element-last")
			ElseIf StringInStr($shortname, "Super_OS") Then
				; Super OS (Ubuntu)
				$release_number = FindReleaseFromCodeName( "superos-last")
			ElseIf StringInStr($shortname, "uberstudent") Then
				; UberStudent (Ubuntu)
				$release_number = FindReleaseFromCodeName( "uberstudent-last")
			ElseIf StringInStr($shortname, "aptosid") OR StringInStr($shortname, "sidux") Then
				; Aptosid (ex-Sidux)
				if StringInStr($shortname, "xfce") Then
					$release_number = FindReleaseFromCodeName( "aptosid-xfce-last")
				Else
					$release_number = FindReleaseFromCodeName( "aptosid-kdelite-last")
				EndIf
			ElseIf StringInStr($shortname, "android-x86") Then
				; Android x86
				$release_number = FindReleaseFromCodeName( "androidx86-last")
			ElseIf StringInStr($shortname, "trisquel") Then
				; Trisquel (Ubuntu)
				$release_number = FindReleaseFromCodeName( "trisquel-last")
			ElseIf StringInStr($shortname, "guada") Then
				; Guadalinex (Ubuntu)
				$release_number = FindReleaseFromCodeName( "guadalinex-last")
			ElseIf StringInStr($shortname, "ultimate-edition") Then
				; Ultimate Edition (Ubuntu)
				$release_number = FindReleaseFromCodeName( "ultimate-last")
			ElseIf StringInStr($shortname, "ylmf") Then
				; Ylmf (Ubuntu)
				$release_number = FindReleaseFromCodeName( "ylmf-last")
			ElseIf StringInStr($shortname, "plop") Then
				if StringInStr($shortname, "-X") Then
					; PLoP Linux with X
					$release_number = FindReleaseFromCodeName( "plopx-last")
				Else
					; PLoP Linux without X
					$release_number = FindReleaseFromCodeName( "plop-last")
				EndIf
			ElseIf StringInStr($shortname, "fedora") Then
				; Fedora Based
				if StringInStr($shortname, "16") Then
					$release_number = FindReleaseFromCodeName( "fedora16-last")
				Elseif StringInStr($shortname, "15") Then
					$release_number = FindReleaseFromCodeName( "fedora15-last")
				Elseif StringInStr($shortname, "14") Then
					$release_number = FindReleaseFromCodeName( "fedora14-last")
				Elseif StringInStr($shortname, "13") Then
					$release_number = FindReleaseFromCodeName( "fedora13-last")
				Else
					$release_number = FindReleaseFromCodeName( "fedora-last")
				EndIf
				if ReleaseGetCodename($release_number)="default" Then
					$release_number = FindReleaseFromCodeName( "fedora-last")
				EndIf
			ElseIf StringInStr($shortname, "soas") Then
				; Sugar on a stick
				$release_number = FindReleaseFromCodeName( "fedorasoas-last")
			ElseIf StringInStr($shortname, "peppermint") Then
				; PepperMint
				if StringInStr($shortname, "ice") Then
					$release_number = FindReleaseFromCodeName( "peppermint-ice-last")
				Else
					$release_number = FindReleaseFromCodeName( "peppermint-one-last")
				EndIf
			ElseIf StringInStr($shortname, "mint") Then
				; Mint variants
				if StringInStr($shortname, "KDE") Then
					$release_number = FindReleaseFromCodeName( "mintkdedvd-last")
				elseif StringInStr($shortname, "LXDE") Then
					$release_number = FindReleaseFromCodeName( "mintlxde-last")
				elseif StringInStr($shortname, "Xfce") Then
					$release_number = FindReleaseFromCodeName( "mintxfce-last")
				elseif StringInStr($shortname, "debian") Then
					$release_number = FindReleaseFromCodeName( "mintdebian-last")
				elseif StringInStr($shortname, "flux") Then
					$release_number = FindReleaseFromCodeName( "mintfluxbox-last")
				else
					$release_number = FindReleaseFromCodeName( "mint-last")
				EndIf
			ElseIf StringInStr($shortname, "gnewsense") Then
				; gNewSense Based
				$release_number = FindReleaseFromCodeName( "gnewsense-last")
			ElseIf StringInStr($shortname, "clonezilla") Then
				; Clonezilla
				$release_number = FindReleaseFromCodeName( "clonezilla-last")
			ElseIf StringInStr($shortname, "gparted-live") Then
				; Gparted
				$release_number = FindReleaseFromCodeName( "gpartedlive-last")
			ElseIf StringInStr($shortname, "hiren") Then
				; Hiren's Boot CD
				$release_number = FindReleaseFromCodeName( "hiren-last")
			ElseIf StringInStr($shortname, "debian") Then
				; Debian Variants
				if StringInStr($shortname, "live") Then
					if StringInStr($shortname,"6.") OR StringInStr($shortname,"sq") Then
						$debian_version=6
					Else
						; last version
						$debian_version=""
					EndIf

					if StringInStr($shortname, "KDE") Then
						$release_number = FindReleaseFromCodeName( "debianlivekde"&$debian_version&"-last")
					elseif StringInStr($shortname, "LXDE") Then
						$release_number = FindReleaseFromCodeName( "debianlivelxde"&$debian_version&"-last")
					elseif StringInStr($shortname, "Xfce") Then
						$release_number = FindReleaseFromCodeName( "debianlivexfce"&$debian_version&"-last")
					elseif StringInStr($shortname, "gnome") Then
						$release_number = FindReleaseFromCodeName( "debianlivegnome"&$debian_version&"-last")
					elseif StringInStr($shortname, "standard") Then
						$release_number = FindReleaseFromCodeName( "debianlivestandard"&$debian_version&"-last")
					else
						$release_number = FindReleaseFromCodeName( "debianlivegnome"&$debian_version&"-last")
					EndIf
				EndIf
			ElseIf StringInStr($shortname, "toutou") Then
				; Toutou Linux
				$release_number = FindReleaseFromCodeName( "toutou-last")
			ElseIf StringInStr($shortname, "mandri") OR StringInStr($shortname, "driva") Then
				; OpenMandriva
				$release_number = FindReleaseFromCodeName( "openmandriva-last")
			ElseIf StringInStr($shortname, "doudou") Then
				; Doudou Linux
				$release_number = FindReleaseFromCodeName( "doudoulinux-last")
			ElseIf StringInStr($shortname, "qrky") Or StringInStr($shortname, "quirky") Then
				; Quirky Linux
				$release_number = FindReleaseFromCodeName( "quirky-last")
			ElseIf StringInStr($shortname, "slax") Then
				; Slax
				$release_number = FindReleaseFromCodeName( "slax-last")
			ElseIf StringInStr($shortname, "centos") Then
				; CentOS
				$release_number = FindReleaseFromCodeName( "centos-last")
			ElseIf StringInStr($shortname, "pmagic") Then
				; Parted Magic
				$release_number = FindReleaseFromCodeName( "pmagic-last")
			ElseIf StringInStr($shortname, "pclinuxos") Then
				; PCLinuxOS (default to KDE)
				if StringInStr($shortname, "e17") OR StringInStr($shortname, "enlight") Then
					$release_number = FindReleaseFromCodeName( "pclinuxose17-last")
				elseif StringInStr($shortname, "LXDE") Then
					$release_number = FindReleaseFromCodeName( "pclinuxoslxde-last")
				elseif StringInStr($shortname, "Xfce") Then
					$release_number = FindReleaseFromCodeName( "pclinuxosxfce-last")
				elseif StringInStr($shortname, "gnome") Then
					$release_number = FindReleaseFromCodeName( "pclinuxosgnome-last")
				else
					$release_number = FindReleaseFromCodeName( "pclinuxoskde-last")
				EndIf
			ElseIf StringInStr($shortname, "slitaz") Then
				; Slitaz
				$release_number = FindReleaseFromCodeName( "slitaz-last")
			ElseIf StringInStr($shortname, "vinux") Then
				; Vinux
				$release_number = FindReleaseFromCodeName( "vinux-last")
			ElseIf StringInStr($shortname, "core") AND StringInStr($shortname, "tiny") Then
				; Tiny Core
				$release_number = FindReleaseFromCodeName( "tinycore-last")
			ElseIf StringInStr($shortname, "core") AND StringInStr($shortname, "plus") Then
				; CorePlus
				$release_number = FindReleaseFromCodeName( "coreplus-last")
			ElseIf StringInStr($shortname, "ophcrack") Then
				; OphCrack
				if StringInStr($shortname, "vista") Then
					$release_number = FindReleaseFromCodeName( "ophcrackxp-last")
				Else
					$release_number = FindReleaseFromCodeName( "ophcrackvista-last")
				EndIf
			ElseIf StringInStr($shortname, "chakra") Then
				; Chakra
				$release_number = FindReleaseFromCodeName( "chakra-last")
			ElseIf StringInStr($shortname, "manjaro") Then
				; Manjaro
				if StringInStr($shortname, "xfce") Then
					$release_number = FindReleaseFromCodeName( "manjaro-xfce-last")
				Else
					$release_number = FindReleaseFromCodeName( "manjaro-openbox-last")
				EndIf
			ElseIf StringInStr($shortname, "crunch") Then
				; CrunchBang Based
				if StringInStr($shortname, "openbox") Then
					$release_number = FindReleaseFromCodeName( "crunchbang-openbox-last")
				Else
					$release_number = FindReleaseFromCodeName( "crunchbang-xfce-last")
				EndIf
			ElseIf StringInStr($shortname, "sabayon") Then
				; Sabayon Linux
				if StringInStr($shortname, "_K") OR StringInStr($shortname, "KDE") Then
					$release_number = FindReleaseFromCodeName( "sabayonK-last")
				elseif StringInStr($shortname, "_G") OR StringInStr($shortname, "Gnome") Then
					$release_number = FindReleaseFromCodeName( "sabayonG-last")
				;elseif StringInStr($shortname, "LXDE") Then
				;	$release_number = FindReleaseFromCodeName( "sabayonL-last")
				elseif StringInStr($shortname, "Xfce") Then
					$release_number = FindReleaseFromCodeName( "sabayonX-last")
				elseif StringInStr($shortname, "MATE") Then
					$release_number = FindReleaseFromCodeName( "sabayonM-last")
				else
					$release_number = FindReleaseFromCodeName( "sabayonK-last")
				EndIf
			ElseIf StringInStr($shortname, "SystemRescue") Then
				; System Rescue CD
				$release_number = FindReleaseFromCodeName( "systemrescue-last")
			ElseIf StringInStr($shortname, "xange") Then
				; Xange variants
				$release_number = FindReleaseFromCodeName( "openxange-last")
			ElseIf StringInStr($shortname, "puredyne") Then
				; Puredyne
				$release_number = FindReleaseFromCodeName( "puredyne-last")
			ElseIf StringInStr($shortname, "64studio") Then
				; 64studio
				$release_number = FindReleaseFromCodeName( "64studio-last")
			ElseIf StringInStr($shortname, "antix") OR StringInStr($shortname, "MEPIS") Then
				; Antix MEPIS variants
				$release_number = FindReleaseFromCodeName( "antix-last")
			ElseIf StringInStr($shortname, "solus") Then
				; SolusOS
				$release_number = FindReleaseFromCodeName( "solusos-last")
			ElseIf StringInStr($shortname, "ylmf") Then
				; Ylmf OS
				$release_number = FindReleaseFromCodeName( "ylmf-last")
			ElseIf StringInStr($shortname, "ipfire") Then
				; IPFire
				$release_number = FindReleaseFromCodeName( "ipfire-last")
			ElseIf StringInStr($shortname, "untangle") Then
				; Untangle
				$release_number = FindReleaseFromCodeName( "untangle-last")
			ElseIf StringInStr($shortname, "wifiway") Then
				; WifiWay
				$release_number = FindReleaseFromCodeName( "wifiway-last")
			ElseIf StringInStr($shortname, "vyatta") Then
				; vyatta
				$release_number = FindReleaseFromCodeName( "vyatta-last")
			ElseIf StringInStr($shortname, "blankon") Then
				; BlankOn
				$release_number = FindReleaseFromCodeName( "blankon-last")
			ElseIf StringInStr($shortname, "redobackup") Then
				; Redo Backup
				$release_number = FindReleaseFromCodeName( "redobackup-last")
			ElseIf StringInStr($shortname, "opensuse") Then
				; OpenSUSE
				if StringInStr($shortname, "11.") Then
					$append=""
				Else
					$append="12.1"
				EndIf

				if StringInStr($shortname, "KDE") Then
					$release_number = FindReleaseFromCodeName( "opensusekde"&$append&"-last")
				Else
					$release_number = FindReleaseFromCodeName( "opensuse"&$append&"-last")
				EndIf
			ElseIf StringInStr($shortname, "geex") Then
				; GeexBox
				$release_number = FindReleaseFromCodeName( "geexbox-last")
			ElseIf StringInStr($shortname, "Pinguy") Then
				; PinguyOS
				$release_number = FindReleaseFromCodeName( "pinguyos-last")
			ElseIf StringInStr($shortname, "avira") Then
				; Avira Antivir
				$release_number = FindReleaseFromCodeName( "antivir-last")
			ElseIf StringInStr($shortname, "bodhi") Then
				; Bodhi Linux
				$release_number = FindReleaseFromCodeName( "bodhi-last")
			ElseIf StringInStr($shortname, "tangostudio") Then
				; TangoStudio
				$release_number = FindReleaseFromCodeName( "tangostudio-last")
			ElseIf StringInStr($shortname, "elive") Then
				; Elive
				$release_number = FindReleaseFromCodeName( "elive-last")
			ElseIf StringInStr($shortname, "sms") Then
				; Superb Mini Server
				$release_number = FindReleaseFromCodeName( "sms-last")
			ElseIf StringInStr($shortname, "vortexbox") Then
				; Vortexbox
				$release_number = FindReleaseFromCodeName( "vortexbox-last")
			ElseIf StringInStr($shortname, "zorin") Then
				; Zorin OS
				$release_number = FindReleaseFromCodeName( "zorin-last")
			ElseIf StringInStr($shortname, "meego") Then
				; Meego
				$release_number = FindReleaseFromCodeName( "meego-last")
			ElseIf StringInStr($shortname, "backbox") Then
				; BackBox
				$release_number = FindReleaseFromCodeName( "backbox-last")
			ElseIf StringInStr($shortname, "finnix") Then
				; Finnix
				$release_number = FindReleaseFromCodeName( "finnix-last")
			ElseIf StringInStr($shortname, "puppeee") OR StringInStr($shortname, "fluppy") Then
				; Puppeee
				if StringInStr($shortname,"atom") Then
					$release_number = FindReleaseFromCodeName( "puppeee-atom-last")
				Else
					$release_number = FindReleaseFromCodeName( "puppeee-celeron-last")
				EndIf
			ElseIf StringInStr($shortname, "livehacking") Then
				; Live Hacking CD
				if StringInStr($shortname, "mini") Then
					$release_number = FindReleaseFromCodeName( "livehackingmini-last")
				Else
					$release_number = FindReleaseFromCodeName( "livehacking-last")
				EndIf
			ElseIf StringInStr($shortname, "vmware") OR StringInStr($shortname, "VMvisor")  OR StringInStr($shortname, "esx") Then
				$clean_name=StringReplace($shortname,".iso","")
				$clean_name=StringReplace($clean_name,".x86_64","")
				; VMware vSphere Hypervisor (ESXi)
				if  StringInStr($clean_name, "5.5") > 0 Then
					$release_number = FindReleaseFromCodeName( "esxi5.5-last")
				Elseif StringInStr($clean_name, "5.1") > 0 Then
					$release_number = FindReleaseFromCodeName( "esxi5.1-last")
				Elseif  StringInStr($clean_name, "5.0") > 0 Then
					$release_number = FindReleaseFromCodeName( "esxi5.0-last")
				Else
					$release_number = FindReleaseFromCodeName( "esxi4-last")
				EndIf
			ElseIf StringInStr($shortname, "matriux") Then
				; Matriux
				$release_number = FindReleaseFromCodeName( "matriux-last")
			ElseIf StringInStr($shortname, "dban") Then
				; Darik's Boot And Nuke (DBAN)
				$release_number = FindReleaseFromCodeName( "dban-last")
			ElseIf StringInStr($shortname, "Gnome_3") Then
				; Gnome 3
				$release_number = FindReleaseFromCodeName( "gnome3-last")
			ElseIf StringInStr($shortname, "macpup") Then
				; MacPup
				$release_number = FindReleaseFromCodeName( "macpup-last")
			ElseIf StringInStr($shortname, "vector") OR StringInStr($shortname, "VL6") OR StringInStr($shortname, "VL7") Then
				; VectorLinux
				$release_number = FindReleaseFromCodeName( "vector-last")
			ElseIf StringInStr($shortname, "zen") AND StringInStr($shortname, "walk") Then
				; ZenWalk
				$release_number = FindReleaseFromCodeName( "zenwalk-last")
			ElseIf StringInStr($shortname, "fuduntu") Then
				; Fuduntu
				$release_number = FindReleaseFromCodeName( "fuduntu-last")
			ElseIf StringInStr($shortname, "netrun") Then
				; Netrunner
				$release_number = FindReleaseFromCodeName( "netrunner-last")
			ElseIf StringInStr($shortname, "zenix") Then
				; Fuduntu
				$release_number = FindReleaseFromCodeName( "zenix-last")
			ElseIf StringInStr($shortname, "porteus") Then
				; Porteus
				$release_number = FindReleaseFromCodeName( "porteus-last")
			ElseIf StringInStr($shortname, "cdlinux") Then
				; CDLinux
				$release_number = FindReleaseFromCodeName( "cdlinux-last")
			ElseIf StringInStr($shortname, "rhel") OR (StringInStr($shortname, "red") AND StringInStr($shortname, "hat"))Then
				; Red Hat Enterprise Linux
				$release_number = FindReleaseFromCodeName( "rhel-last")
			ElseIf StringInStr($shortname, "xen") Then
				; XenServer
				$release_number = FindReleaseFromCodeName( "xenserver-last")
			Elseif StringInStr($shortname, "deepin") Then
				; Deepin Linux
				$release_number = FindReleaseFromCodeName( "deepin-last")
			ElseIf StringInStr($shortname, "gentoo") OR StringInStr($shortname, "livedvd-") Then
				; Gentoo
				$release_number = FindReleaseFromCodeName( "gentoo-last")
			Elseif StringInStr($shortname, "calculate") OR StringInStr($shortname, "cds-") OR StringInStr($shortname, "cld-") or StringInStr($shortname, "cldg-") OR StringInStr($shortname, "cldx-") OR StringInStr($shortname, "cmc-") OR StringInStr($shortname, "css-") Then
				; Calculate Linux
				$release_number = FindReleaseFromCodeName( "calculate-last")
			Elseif StringInStr($shortname, "scientific") OR StringInStr($shortname, "SL-") Then
				; Scientific Linux
				$release_number = FindReleaseFromCodeName( "scientific-last")
			ElseIf StringInStr($shortname, "pear") Then
				; Pear OS
				$release_number = FindReleaseFromCodeName( "pearlinux-last")
			ElseIf StringInStr($shortname, "lps") Then
				; Lightweight Portable Security
				$release_number = FindReleaseFromCodeName( "lps-last")
			ElseIf StringInStr($shortname, "backtrack") OR StringInStr($shortname, "bt") Then
				; BackTrack
				if StringInStr($shortname, "5") AND NOT StringInStr($shortname, "bt4") Then
					$release_number = FindReleaseFromCodeName( "backtrack-last")
				Else
					$release_number = FindReleaseFromCodeName( "backtrack4-last")
				EndIf
			ElseIf StringInStr($shortname, "pure") Then
				; Pure OS
				$release_number = FindReleaseFromCodeName( "pureos-last")
			ElseIf StringInStr($shortname, "kali") Then
				; Kali
				$release_number = FindReleaseFromCodeName( "kali-last")
			ElseIf StringInStr($shortname, "lxle") Then
				; LXLE
				$release_number = FindReleaseFromCodeName( "lxle-last")
			ElseIf StringInStr($shortname, "watt") Then
				; Watt OS
				$release_number = FindReleaseFromCodeName( "wattos-last")
			ElseIf StringInStr($shortname, "puppy") Or StringInStr($shortname, "pup-") Or StringInStr($shortname, "wary") OR  StringInStr($shortname, "lupu-") OR  StringInStr($shortname, "precise-") Then
				; Puppy Linux
				if StringInStr($shortname, "precise-") Then
					; Puppy Ubuntu variants
					$release_number = FindReleaseFromCodeName( "puppyU-last")
				Else
					$release_number = FindReleaseFromCodeName( "puppy-last")
				EndIf
			ElseIf StringInStr($shortname, "win") OR StringInStr($shortname, "microsoft") OR StringInStr($shortname, "seven") OR StringInStr($shortname, "vista") OR StringInStr($shortname, "eight") Then

				if StringInStr($shortname, "2012") and StringInStr($shortname, "R2") Then
					$release_number = FindReleaseFromCodeName( "windows2012r2")
				Elseif StringInStr($shortname, "2012") Then
					$release_number = FindReleaseFromCodeName( "windows2012")
				Elseif StringInStr($shortname, "2008") and StringInStr($shortname, "R2") Then
					$release_number = FindReleaseFromCodeName( "windows2008r2")
				Elseif StringInStr($shortname, "2008") Then
					$release_number = FindReleaseFromCodeName( "windows2008")
				Elseif StringInStr($shortname, "vis") Then
					$release_number = FindReleaseFromCodeName( "windowsvista")
				Elseif  StringInStr($shortname, "windows7") OR StringInStr($shortname, "seven") OR StringInStr($shortname, "win7") Then
					$release_number = FindReleaseFromCodeName( "windows7")
				Elseif  StringInStr($shortname, "windows8") OR StringInStr($shortname, "eight") OR StringInStr($shortname, "win8") Then
					$release_number = FindReleaseFromCodeName( "windows8")
				Else
					$release_number = FindReleaseFromCodeName( "windows8.1")
				EndIf
			Else
				; Any Linux, except those known not to work in Live mode
				$release_number = FindReleaseFromCodeName( "default")
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


	if StringInStr($features,"persistence") Then
		if StringInStr($features,"builtin") Then
			Disable_Persistent_Mode("Built-in Persistency")
			SendReport("IN-Check_If_Default_Should_Be_Used ( builtin persistency for " & $codename& " )")
		Else
			Enable_Persistent_Mode()
			Refresh_Persistence()
			SendReport("IN-Check_If_Default_Should_Be_Used ( Enable persistency for " & $codename& " )")
		EndIf
		Step2_Check("good")
	ElseIf StringInStr($features,"install-only") Then
		Disable_Persistent_Mode("Install only (no Live)")
		Step2_Check("good")
		SendReport("IN-Check_If_Default_Should_Be_Used ( builtin persistency for " & $codename& " )")
	Else
		Disable_Persistent_Mode()
		Step2_Check("good")
		SendReport("IN-Check_If_Default_Should_Be_Used ( Disable persistency for " & $codename& " )")
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
		GUI_Show_Check_status(Translate("This ISO is not compatible") &"."& @CRLF & Translate("Please read the compatibility list in user guide"))
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

	; Check if present in cache
	$hexa_hash=Check_cache($FileToHash)
	if $hexa_hash <> ""  Then
		GUI_Show_Back_Button()
		Return $hexa_hash
	EndIf

	Local $filehandle = FileOpen($FileToHash, 16)
	Local $buffersize=0x20000,$final=0,$hash=""

	If $FileToHash = "" Then
		SendReport("End-Check_ISO (no iso)")
		Return "no iso"
	EndIf

	$progress_bar = _ProgressCreate(38 + $offsetx0, 238 + $offsety0, 300, 30)
	_ProgressSetImages($progress_bar, @ScriptDir & "\tools\img\progress_green.jpg", @ScriptDir & "\tools\img\progress_background.jpg")
	_ProgressSetImages($progress_bar, @ScriptDir & "\tools\img\progress_green.jpg", @ScriptDir & "\tools\img\progress_background.jpg")
	_ProgressSetFont($progress_bar, "", -1, -1, 0x000000, 0)
	$label_step2_status = GUICtrlCreateLabel(Translate("Checking file")&" : "&path_to_name($FileToHash), 38 + $offsetx0, 231 + $offsety0 + 50, 300, 80)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0xFFFFFF)

	SendReport("IN-Check_ISO : Crypto Library Startup")
	_Crypt_Startup()

	$iterations = Ceiling(FileGetSize($FileToHash) / $buffersize)

	For $i = 1 To $iterations
		if $i=$iterations Then $final=1
		$hash=_Crypt_HashData(FileRead($filehandle, $buffersize),0x00008003,$final,$hash)
		$percent_md5 = Round(100 * $i / $iterations)
		$return1 = _ProgressSet($progress_bar,$percent_md5 )
		$return2 = _ProgressSetText($progress_bar, $percent_md5&"%" )
	Next
	FileClose($filehandle)
	_Crypt_Shutdown()

	SendReport("IN-Check_ISO : Closed Crypto Library, hash computed")
	_ProgressSet($progress_bar,100 )
	_ProgressSetText($progress_bar, "100%" )
	Sleep(200)
	_ProgressDelete($progress_bar)
	if @error Then
		SendReport("Could not delete progress bar, trying again")
		_ProgressDelete($progress_bar)
		if @error Then
			SendReport("ERROR Could not delete progress bar (even after retrying!!!)")
		EndIf
	EndIf
	GUI_Show_Back_Button()
	$hexa_hash = StringTrimLeft($hash, 2)
	WriteSetting("Cached_MD5",CleanPathForCache($FileToHash),$hexa_hash&"||"&FileGetSize($FileToHash)&"||"&FileGetTime($FileToHash,0,1)&"||"&FileGetTime($FileToHash,1,1))
	SendReport("End-Check_ISO ( Hash : " & $hexa_hash & " )")
	Return $hexa_hash
EndFunc

Func Check_cache($FileToHash)
	SendReport("Start-Check_Cache for file "&$FileToHash)
	$cached_md5=ReadSetting("Cached_MD5",CleanPathForCache($FileToHash))

	if $cached_md5 = "" Then
		SendReport("End-Check_Cache : no cache for this file")
		Return ""
	Else
		$cached_settings=StringSplit($cached_md5,"||",1)

		if IsArray($cached_settings) AND Ubound($cached_settings)=5 Then
			$file_settings=FileGetSize($FileToHash)&"||"&FileGetTime($FileToHash,0,1)&"||"&FileGetTime($FileToHash,1,1)
			$cache_settings_nomd5=$cached_settings[2]&"||"&$cached_settings[3]&"||"&$cached_settings[4]

			if $file_settings=$cache_settings_nomd5 Then
				SendReport("End-Check_Cache : Hash found ="&$cached_settings[1])
				Return $cached_settings[1]
			Else
				SendReport("End-Check_Cache : file modified "&$file_settings&" <> "&$cache_settings_nomd5)
				Return ""
			EndIf

		Else
			SendReport("End-Check_Cache -> Warning cache error (wrong number of parameters)")
			Return ""
		EndIf
	EndIf
EndFunc

Func CleanPathForCache($filepath)
	; Cleaning leading+ trailing spaces and equal signs
	Return StringStripWS(StringReplace($filepath,"=","--"),3)
EndFunc
#cs
	Func Check_folder_integrity($folder)
	SendReport("Start-Check_folder_integrity ( Folder : " & $folder & " )")
	Global $version_in_file, $MD5_FOLDER
	If ReadSetting( "Advanced", "skip_checking") = "yes" Then
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
	MsgBox(4096, Translate("Check completed"), Translate("All files have been successfully checked")&".")
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
