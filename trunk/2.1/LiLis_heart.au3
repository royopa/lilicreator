

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Format a specified drive letter to FAT32
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Format_FAT32($drive_letter)
	SendReport("Start-Format_FAT32 ( Drive : "& $drive_letter &" )")
	UpdateStatus("Formatage de la clé")
	RunWait3('cmd /c format /Q /X /y /V:MyLinuxLive /FS:FAT32 ' & $drive_letter, @ScriptDir, @SW_HIDE)
	SendReport("End-Format_FAT32")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Clean previous Linux Live installs
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$release_in_list = number of the release in the compatibility list (-1 if not present)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Clean_old_installs($drive_letter,$release_in_list)
	SendReport("Start-Clean_old_installs ( Drive : "& $drive_letter &" - Release : "& $release_in_list &" )")
	If IniRead($settings_ini, "General", "skip_cleaning", "no") == "yes" Then Return 0
	UpdateStatus("Nettoyage des installations précédentes ( 2min )")
	DeleteFilesInDir($files_in_source)
	FileDelete2($drive_letter & "\autorun.inf")
	FileDelete2($drive_letter & "\lili.ico")




	if IniRead($settings_ini, "General", "skip_full_cleaning", "no") <> "yes" Then

		; Common Linux Live files
		DirRemove2($drive_letter & "\isolinux\", 1)
		DirRemove2($drive_letter & "\syslinux\", 1)
		FileDelete2($drive_letter & "\autorun.inf")
		FileDelete2($drive_letter & "\ldlinux.sys")

		; Classic Ubuntu files
		DirRemove2($drive_letter & "\.disk\", 1)
		DirRemove2($drive_letter & "\casper\", 1)
		DirRemove2($drive_letter & "\preseed\", 1)
		DirRemove2($drive_letter & "\dists\", 1)
		DirRemove2($drive_letter & "\install\", 1)
		DirRemove2($drive_letter & "\pics\", 1)
		DirRemove2($drive_letter & "\pool\", 1)
		FileDelete2($drive_letter & "\wubi.exe")
		FileDelete2($drive_letter & "\ubuntu")
		FileDelete2($drive_letter & "\umenu.exe")
		FileDelete2($drive_letter & "\casper-rw")
		FileDelete2($drive_letter & "\md5sum.txt")
		FileDelete2($drive_letter & "\README.diskdefines")

		; Mint files
		FileDelete2($drive_letter & "\lmmenu.exe")
		FileDelete2($drive_letter & "\mint4win.exe")
		DirRemove2($drive_letter & "\drivers\",1)
		FileDelete2($drive_letter & "\.disc_id")

		; Mandriva files
		FileDelete2($drive_letter & "\README.pdf")
		FileDelete2($drive_letter & "\LISEZMOI.pdf")

		DirRemove2($drive_letter & "\loopbacks\",1)
		DirRemove2($drive_letter & "\isolinux\",1)
		DirRemove2($drive_letter & "\autorun\",1)
		DirRemove2($drive_letter & "\boot\",1)

		; Fedora files
		FileDelete2($drive_letter & "\README")
		FileDelete2($drive_letter & "\GPL")
		DirRemove2($drive_letter & "\LiveOS\",1)
		DirRemove2($drive_letter & "\EFI\",1)

		; other files
		FileDelete2($drive_letter & "\Clonezilla-Live-Version")
		FileDelete2($drive_letter & "\COPYING")
		DirRemove2($drive_letter & "\KNOPPIX\",1)
		DirRemove2($drive_letter & "\lamppix\",1)
		DirRemove2($drive_letter & "\ntpasswd\",1)
		DirRemove2($drive_letter & "\bootprog\",1)
		DirRemove2($drive_letter & "\bootdisk\",1)
		FileDelete2($drive_letter & "\sysrcd.dat")
		FileDelete2($drive_letter & "\sysrcd.md5")
		FileDelete2($drive_letter & "\usbstick.htm")
		FileDelete2($drive_letter & "\grldr")
		FileDelete2($drive_letter & "\menu.lst")
		FileDelete2($drive_letter & "\BootCD.txt")
		DirRemove2($drive_letter & "\HBCD\",1)


	EndIf

	SendReport("End-Clean_old_installs")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Download last Portable-VirtualBox as a background task
	Input :
		No input
	Output :
		0 = No Vbox install can be done
		1 = Vbox is being downloaded
		2 = Vbox is already downloaded
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Download_virtualBox()
	SendReport("Start-Download_virtualBox")
				UpdateStatus("Mise en place de la virtualisation")
				$no_internet = 0
				$virtualbox_size = -1

				$VirtualBoxUrl1 = IniRead($settings_ini, "General", "portable_virtualbox_mirror1", "none")
				$VirtualBoxUrl2 = IniRead($settings_ini, "General", "portable_virtualbox_mirror2", "none")


				; Testing download mirrors
				$virtualbox_size1 = InetGetSize($VirtualBoxUrl1)
				$virtualbox_size2 = InetGetSize($VirtualBoxUrl2)

				; Selecting mirror
				Global $virtualbox_size
				If $virtualbox_size1 <= 0 Then
					If $virtualbox_size2 <= 0 Then
						$virtualbox_size = -1
					Else
						$VirtualBoxUrl = $VirtualBoxUrl2
						$virtualbox_size = $virtualbox_size2
					EndIf
				Else
					$VirtualBoxUrl = $VirtualBoxUrl1
					$virtualbox_size = $virtualbox_size1
				EndIf

				SendReport("Start-Download_virtualBox-1")
				UpdateLog("Found Mirror 1 : " & $VirtualBoxUrl1 & " with VirtualBox size : " & $virtualbox_size1 )
				UpdateLog("Found Mirror 2 : " & $VirtualBoxUrl2 & " with VirtualBox size : " & $virtualbox_size2 )

				; No mirror working we should log that
				If $virtualbox_size <= 0 Then
					$no_internet = 1
					UpdateLog("No working mirror !")
					$downloaded_virtualbox_filename = "VirtualBox.zip"
				Else
					$downloaded_virtualbox_filename = unix_path_to_name($VirtualBoxUrl)
				EndIf


				$virtualbox_already_downloaded = 0
				SendReport("Start-Download_virtualBox-2")
				;cs
				; Checking if last version has aleardy been downloaded
				If FileExists(@ScriptDir & "\tools\" & $downloaded_virtualbox_filename) And $virtualbox_size > 0 And $virtualbox_size == FileGetSize(@ScriptDir & "\tools\" & $downloaded_virtualbox_filename) Then
					; Already have last version, no download needed
					UpdateStatus("VirtualBox a déjà été téléchargé")
					Sleep(1000)
					$check_vbox = 2
				ElseIf FileExists(@ScriptDir & "\tools\" & $downloaded_virtualbox_filename) And $virtualbox_size > 0 And $virtualbox_size <> FileGetSize(@ScriptDir & "\tools\" & $downloaded_virtualbox_filename) Then
					; A new version is available, downloading it
					UpdateStatus("Une nouvelle version de VirtualBox est disponible")
					Sleep(1000)
					UpdateStatus("Cette nouvelle version sera téléchargée")
					Sleep(1000)
					UpdateStatus("Téléchargement de VirtualBox en tache de fond")
					Sleep(1000)
					InetGet($VirtualBoxUrl, @ScriptDir & "\tools\" & $downloaded_virtualbox_filename, 1, 1)
					If @InetGetActive Then
						UpdateStatus("Le téléchargement a bien débuté")
						$check_vbox = 1
					Else
						UpdateStatus("Le téléchargement n'a pas pu commencer")
						Sleep(1000)
						UpdateStatus("VirtualBox ne sera pas installé")
						$check_vbox = 0
					EndIf

				ElseIf FileExists(@ScriptDir & "\tools\" & $downloaded_virtualbox_filename) And $virtualbox_size <= 0 Then
					; Alerady downloaded but can't tell if it's last version and if it's good
					UpdateStatus("VirtualBox a déjà été téléchargé")
					Sleep(1000)
					UpdateStatus("L'intégrité de l'archive n'a pas pu être vérifiée")
					Sleep(1000)
					UpdateStatus("L'installation sera tentée")
					$check_vbox = 2

				ElseIf $virtualbox_size > 0 Then
					; Does not have any version, downloading it
					UpdateStatus("Téléchargement de VirtualBox en tache de fond")
					Sleep(1000)
					InetGet($VirtualBoxUrl, @ScriptDir & "\tools\" & $downloaded_virtualbox_filename, 1, 1)
					If @InetGetActive Then
						UpdateStatus("Le téléchargement a bien débuté")
						Sleep(1000)
						$check_vbox = 1
					Else
						; Can't download it => aborted
						UpdateStatus("Le téléchargement n'a pas pu commencer")
						Sleep(1000)
						UpdateStatus("VirtualBox ne sera pas installé")
						$check_vbox = 0
					EndIf

				Else
					; Cannot start download, VirtualBox install is aborted
					UpdateStatus("Probléme de téléchargement")
					Sleep(1000)
					UpdateStatus("VirtualBox ne sera pas installé")
					$check_vbox = 0
				EndIf

				;#ce
				#cs
				$downloaded_virtualbox_filename = "VirtualBox.zip"
				$virtualbox_already_downloaded = 1
				$virtualbox_size = FileGetSize(@ScriptDir & "\tools\VirtualBox.zip")
					UpdateStatus("VirtualBox a déjà été téléchargé")
					Sleep(1000)
					$check_vbox = 2
					#ce

				Sleep(2000)
				SendReport("End-Download_virtualBox")
				Return $check_vbox
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Uncompress ISO directly on the key
	Input :
		$drive_letter =  Letter of the drive (pre-formated like "E:" )
		$iso_file = path to the iso file of a Linux Live CD
		$release_in_list = number of the release in the compatibility list (-1 if not present)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Uncompress_ISO_on_key($drive_letter,$iso_file,$release_in_list)
	SendReport("Start-Uncompress_ISO_on_key ( Drive : "& $drive_letter &" - File : "& $iso_file &" - Release : "& $release_in_list &" )")
	If IniRead($settings_ini, "General", "skip_copy", "no") == "yes" Then Return 0
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	UpdateStatus(Translate("Décompression de l'ISO sur la clé") & " ( 5-10" & Translate("min") & " )")
	$install_size = ReleaseGetInstallSize($release_in_list)

	; Just in case ...
	If $install_size < 5 Then $install_size = 730

	Run7zip('"' & @ScriptDir & '\tools\7z.exe" x "' & $iso_file & '" -x![BOOT] -r -aoa -o' & $drive_letter, $install_size)
	SendReport("End-Uncompress_ISO_on_key")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Creates a bootable USB stick from an IMG file
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$path_to_cd = path to the CD or folder containing the Linux Live CD files
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Create_Stick_From_CD($drive_letter,$path_to_cd)
	SendReport("Start-Create_Stick_From_CD ( Drive : "& $drive_letter &" - CD Folder : "& $path_to_cd &" )")
	If IniRead($settings_ini, "General", "skip_copy", "no") == "yes" Then Return 0
	_FileCopy2($path_to_cd & "\*.*", $drive_letter & "\")
	SendReport("End-Create_Stick_From_CD")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Copy already uncompressed iso or CD files on the key
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$img_file = pimg file containing a USB stick image
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Create_Stick_From_IMG($drive_letter,$img_file)
	SendReport("Start-Create_Stick_From_IMG ( Drive : "& $drive_letter &" - File : "& $img_file & " )")
	Local $cmd, $foo, $line, $img_size
	$img_size= Ceiling(FileGetSize($img_file)/1048576)
	$cmd = @ScriptDir & '\tools\dd.exe if="'&$img_file&'" of=\\.\'& $drive_letter&' bs=1M --progress'
	UpdateLog($cmd)
	If ProcessExists("dd.exe") > 0 Then ProcessClose("dd.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)
		While 1
		$line &= StdoutRead($foo)
		If @error Then ExitLoop

		; Regular Expression to parse progression
		$str = StringRight($line,20)
		$is = StringRegExp($line, '\r([0-9]{1,4}\,[0-9]{1,3}\,[0-9]{1,3})\r', 0)
		if $is =1 Then
			$array= StringRegExp($line, '\r([0-9]{1,4}\,[0-9]{1,3}\,[0-9]{1,3})\r', 3)
				$mb_written = Ceiling(StringReplace($array[UBound($array)-1],",","")/1048576)
				$percent_written = Ceiling(100*$mb_written/$img_size)
				ProgressSet( $percent_written , $mb_written & " MB / "&$img_size& "MB ( "&$percent_written&"% )")
				UpdateStatusNoLog(Translate("Ecriture de l'image sur la clé") & " " & $mb_written & " " & Translate("MB") &" / "&$img_size& Translate("MB") &" ( "&$percent_written&"% )")
				$line=""
		EndIf
		Sleep(500)
	Wend
	SendReport("End-Create_Stick_From_IMG")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func isolinux2syslinux($syslinux_path)
	$syslinux_cfg = FileOpen($syslinux_path&"isolinux.cfg",0)
	If $syslinux_cfg <> -1 Then
		$lines=""
		While 1
			$lines &= FileReadLine($syslinux_cfg)& @CRLF
			If @error = -1 Then ExitLoop
		Wend
		FileClose($syslinux_cfg)
		$lines = StringReplace($lines,"isolinux/","syslinux/")
		$syslinux_cfg = FileOpen($syslinux_path&"syslinux.cfg",2)
		FileWrite ( $syslinux_cfg , $lines )
		FileClose($syslinux_cfg)
	EndIf
EndFunc


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Rename and move some file in order to work on an USB key
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$release_in_list = number of the release in the compatibility list (-1 if not present)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Rename_and_move_files($drive_letter, $release_in_list)
	SendReport("Start-Rename_and_move_files")
	If IniRead($settings_ini, "General", "skip_moving_renaming", "no") == "yes" Then Return 0
	UpdateStatus(Translate("Renommage et déplacement de quelques fichiers"))

	RunWait3("cmd /c rename " & $drive_letter & "\isolinux syslinux", @ScriptDir, @SW_HIDE)
	FileRename( $drive_letter & "\syslinux\text.cfg", $drive_letter & "\syslinux\text.cfg-old")
	if ReleaseGetVariant($release_in_list) = "ubuntu" Then
		FileRename( $drive_letter & "\syslinux\isolinux.cfg", $drive_letter & "\syslinux\syslinux.cfg")
	Elseif StringInStr($variants_using_default_mode,ReleaseGetVariant($release_in_list)) Then
		; Default Linux processing, no intelligence
		RunWait3("cmd /c rename " & $drive_letter & "\boot\isolinux syslinux", @ScriptDir, @SW_HIDE)
		;FileRename( $drive_letter & "\boot\syslinux\isolinux.cfg", $drive_letter & "\boot\syslinux\syslinux.cfg")

		RunWait3("cmd /c rename " & $drive_letter & "\isolinux syslinux", @ScriptDir, @SW_HIDE)
		RunWait3("cmd /c rename " & $drive_letter & "\HBCD\isolinux syslinux", @ScriptDir, @SW_HIDE)
		;FileRename( $drive_letter & "\syslinux\isolinux.cfg", $drive_letter & "\syslinux\syslinux.cfg")

		;FileRename( $drive_letter & "isolinux.cfg", $drive_letter & "syslinux.cfg")
		;FileRename( $drive_letter & "\HBCD\isolinux.cfg", $drive_letter & "syslinux.cfg")

		if FileExists($drive_letter & "\boot\syslinux\isolinux.cfg") Then
			$syslinux_path = $drive_letter & "\boot\syslinux\"
		Elseif FileExists($drive_letter & "\syslinux\isolinux.cfg") Then
			$syslinux_path = $drive_letter & "\syslinux\"
		Elseif FileExists($drive_letter & "\isolinux.cfg") Then
			$syslinux_path = $drive_letter & "\"
		Elseif FileExists($drive_letter & "\HBCD\isolinux.cfg") Then
			$syslinux_path = $drive_letter & "\HBCD\"
		EndIf
		isolinux2syslinux($syslinux_path)

	Else
		FileRename( $drive_letter & "\syslinux\isolinux.cfg", $drive_letter & "\syslinux\isolinux.cfg-old")
	EndIf


	SendReport("End-Rename_and_move_files")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Create files for custom boot menu (including persistence options)
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$release_in_list = number of the release in the compatibility list (-1 if not present)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Create_boot_menu($drive_letter,$release_in_list)
	SendReport("Start-Create_boot_menu")
	If IniRead($drive_letter, "General", "skip_boot_text", "no") == "yes" Then Return 0
	$variant = ReleaseGetVariant($release_in_list)
	$distribution = ReleaseGetDistribution($release_in_list)
	if $distribution == "Ubuntu" Then
		SendReport("IN-Create_boot_menu for Ubuntu")
		Ubuntu_WriteTextCFG($drive_letter,$release_in_list)
	Elseif $distribution == "Fedora" AND $variant ="CentOS" Then
		SendReport("IN-Create_boot_menu for CentOS")
		CentOS_WriteTextCFG($drive_letter)
	Elseif $distribution == "Fedora" Then
		SendReport("IN-Create_boot_menu for Fedora")
		Fedora_WriteTextCFG($drive_letter)
	EndIf
	SendReport("End-Create_boot_menu")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Hide files if user choose to
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Hide_live_files($drive_letter)
	SendReport("Start-Hide_live_files")
	If IniRead($settings_ini, "General", "skip_hiding", "no") == "yes" Then return 0

	UpdateStatus("Masquage des fichiers")
	HideFile($drive_letter & "\syslinux\")
	HideFilesInDir($files_in_source)
	#cs
	; Common Linux Live files
	HideFile($drive_letter & "\isolinux\")
	HideFile($drive_letter & "\syslinux\")
	HideFile($drive_letter & "\autorun.inf")

	; Classic Ubuntu files
	HideFile($drive_letter & "\.disk\")
	HideFile($drive_letter & "\casper\")
	HideFile($drive_letter & "\preseed\")
	HideFile($drive_letter & "\dists\")
	HideFile($drive_letter & "\install\")
	HideFile($drive_letter & "\pics\")
	HideFile($drive_letter & "\pool\")
	HideFile($drive_letter & "\wubi.exe")
	HideFile($drive_letter & "\ubuntu")
	HideFile($drive_letter & "\umenu.exe")
	HideFile($drive_letter & "\casper-rw")
	HideFile($drive_letter & "\md5sum.txt")
	HideFile($drive_letter & "\README.diskdefines")

	; Mint files
	HideFile($drive_letter & "\lmmenu.exe")
	HideFile($drive_letter & "\mint4win.exe")
	HideFile($drive_letter & "\drivers\")
	HideFile($drive_letter & "\.disc_id")

	; Fedora files
	HideFile($drive_letter & "\README")
	HideFile($drive_letter & "\GPL")
	HideFile($drive_letter & "\LiveOS\")
	HideFile($drive_letter & "\EFI\")

	; Mandriva files
	HideFile($drive_letter & "\README.pdf")
	HideFile($drive_letter & "\LISEZMOI.pdf")
	HideFile($drive_letter & "\autorun.inf")
	HideFile($drive_letter & "\loopbacks\")
	HideFile($drive_letter & "\isolinux\")
	HideFile($drive_letter & "\autorun\")
	HideFile($drive_letter & "\boot\")

	; Other distribs

	#ce

EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Create a persistence file
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$release_in_list = number of the release in the compatibility list (-1 if not present)
		$persistence_size = size of persistence file in MB
		$hide_it = state of user checkbox about hiding file or not
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Create_persistence_file($drive_letter,$release_in_list,$persistence_size,$hide_it)
	SendReport("Start-Create_persistence_file")
	If IniRead($settings_ini, "General", "skip_persistence", "no") == "yes" Then Return 0

	; No persistence for default Linux
	If StringInStr($variants_using_default_mode,ReleaseGetVariant($release_in_list)) Then Return 0

	If $persistence_size > 0 Then
		UpdateStatus("Création du fichier de persistance")
		Sleep(1000)

		$distribe = ReleaseGetDistribution($release_in_list)

		if $distribe =="Ubuntu" Then
			$persistence_file= $drive_letter & '\casper-rw'
		Else
			; fedora
			$persistence_file= $drive_letter & '\LiveOS\overlay-' & StringReplace(DriveGetLabel($drive_letter)," ", "_") & '-' & Get_Disk_UUID($drive_letter)
		Endif

		Create_Empty_File($persistence_file, $persistence_size)
		If ( $hide_it == $GUI_CHECKED) Then HideFile($persistence_file)
		$time_to_format=3
		if ($persistence_size >= 1000) Then $time_to_format=6
		if ($persistence_size >= 2000) Then $time_to_format=10
		if ($persistence_size >= 3000) Then $time_to_format=15
		UpdateStatus(Translate("Formatage du fichier de persistance") & " ( ±"& $time_to_format & " " & Translate("min") & " )")
		EXT2_Format_File($persistence_file)
	Else
		UpdateStatus("Mode Live : pas de fichier de persistance")
	EndIf
	SendReport("End-Create_persistence_file")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Build and install boot sectors in order to make the key bootable
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Install_boot_sectors($drive_letter)
	SendReport("Start-Install_boot_sectors")
	If IniRead($settings_ini, "General", "skip_bootsector", "no") == "yes" Then Return 0
		UpdateStatus("Installation des secteurs de boot")
		If (IniRead($settings_ini, "General", "safe_syslinux", "no") == "yes") Then
			$sysarg = " -s"
		Else
			$sysarg = " "
		EndIf
		RunWait3('"' & @ScriptDir & '\tools\syslinux.exe" -m -a' & $sysarg & ' -d ' & $drive_letter & '\syslinux ' & $drive_letter, @ScriptDir, @SW_HIDE)

	SendReport("End-Install_boot_sectors")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Check if VirtualBox download is OK
	Input :
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Check_virtualbox_download()
	SendReport("Start-Check_virtualbox_download")
	Global $virtualbox_size
	While @InetGetActive
		$prog = Int((100 * @InetGetBytesRead / $virtualbox_size))
		UpdateStatusNoLog(Translate("Téléchargement de VirtualBox") & "  : " & $prog & "% ( " & Round(@InetGetBytesRead / (1024 * 1024), 1) & "/" & Round($virtualbox_size / (1024 * 1024), 1) & " " & Translate("Mo") & " )")
		Sleep(300)
	WEnd
	UpdateStatus("Le téléchargement est maintenant fini")
	SendReport("End-Check_virtualbox_download")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Uncompress Portable-Virtualbox directly to the key
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Uncompress_virtualbox_on_key($drive_letter)
	SendReport("Start-Uncompress_virtualbox_on_key")
	; Cleaning previous install of VBox
	UpdateStatus("Nettoyage d'anciennes installations de VirtualBox")
	DirRemove2($drive_letter & "\VirtualBox\", 1)

	; Unzipping to the key
	UpdateStatus(Translate("Décompression de Virtualbox sur la clé") & " ( 4" & Translate("min") & " )")
	Run7zip2('"' & @ScriptDir & '\tools\7z.exe" x "' & @ScriptDir & "\tools\" & $downloaded_virtualbox_filename & '" -r -aoa -o' & $drive_letter, 90)

	; maybe check after ?
	SendReport("End-Uncompress_virtualbox_on_key")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Create Autorun.inf
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$release_in_list = number of the release in the compatibility list (-1 if not present)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Create_autorun($drive_letter,$release_in_list)
	SendReport("Start-Create_autorun")
	If FileExists($drive_letter & "\autorun.inf") Then FileDelete($drive_letter & "\autorun.inf")
	$codename = ReleaseGetCodename($release_in_list)

	; Using LiLi icon
	FileCopy(@ScriptDir & "\tools\img\lili.ico", $drive_letter & "\lili.ico",1)
	RunWait3("cmd /c attrib /D /S +S +H " & $drive_letter & "\lili.ico", @ScriptDir, @SW_HIDE)
	$icon = "lili.ico"


	IniWrite($drive_letter & "\autorun.inf", "autorun", "icon", $icon)
	IniWrite($drive_letter & "\autorun.inf", "autorun", "open", "")
	IniWrite($drive_letter & "\autorun.inf", "autorun", "label", "LinuxLive Key")

	; If virtualbox is installed
	if FileExists($drive_letter & "\VirtualBox\Virtualize_This_Key.exe") OR FileExists($drive_letter & "VirtualBox\VirtualBox.exe") OR GUICtrlRead($virtualbox) == $GUI_CHECKED Then
		IniWrite($drive_letter & "\autorun.inf", "autorun", "shell\linuxlive", "----> LinuxLive!")
		IniWrite($drive_letter & "\autorun.inf", "autorun", "shell\linuxlive\command", "VirtualBox\Virtualize_This_Key.exe")
		IniWrite($drive_letter &"\autorun.inf", "autorun", "shell\linuxlive2", "----> VirtualBox Interface")
		IniWrite($drive_letter & "\autorun.inf", "autorun", "shell\linuxlive2\command", "VirtualBox\VirtualBox.exe")
	EndIf

	$i=3
	for $file in $files_in_source
		if get_extension($file) = "exe" Then
			if $i=3 Then
				IniWrite($drive_letter  & "\autorun.inf", "autorun", "shell\linuxlive"&$i, "----> CD Menu ("& $file &")")
			Else
				IniWrite($drive_letter  & "\autorun.inf", "autorun", "shell\linuxlive"&$i, "----> CD Menu ("& $file &")")
			EndIf
			IniWrite($drive_letter & "\autorun.inf", "autorun", "shell\linuxlive"&$i&"\command", $drive_letter&"\"&$file)
			$i=$i+1
		EndIf
	Next
	HideFile($drive_letter & "\autorun.inf")
	SendReport("End-Create_autorun")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Set the Virtual Machine with the right amount of RAM (=minimum requirement)  for a specific version of Linux
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$linux_version = Pre-formated version of linux (like ubuntu_8.10)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Setup_RAM_for_VM()
		SendReport("Start-Setup_RAM_for_VM")
		SendReport("End-Setup_RAM_for_VM")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Post-install check, will alert user if some requirements are not met
	Input :
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Final_check()
	SendReport("Start-Final_check")
	Local $avert_mem = ""
	Local $avert_admin = ""
	$mem = MemGetStats()


	; If not admin and virtaulbox option has been selected => WARNING
	If Not IsAdmin() Then $avert_admin = Translate("Vous n'avez pas les droits suffisants pour démarrer VirtualBox sur cette machine.") & @CRLF & Translate("Enregistrez-vous sur le compte administrateur ou lancez le logiciel avec les droits d'administrateur pour qu'il fonctionne.")

	; If not enough RAM => WARNING
	If Round($mem[2] / 1024) < 256 Then $avert_mem = Translate("Vous avez moins de 256Mo de mémoire vive disponible.") & @CRLF & Translate("Cela ne suffira pas pour lancer LinuxLive directement sous windows.")

	If $avert_admin <> "" Or $avert_mem <> "" Then MsgBox(64, Translate("Attention"), $avert_admin & @CRLF & $avert_mem)
	SendReport("End-Final_check")
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Open a GUI with the final help
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$linux_version = Pre-formated version of linux (like ubuntu_8.10)
	Output :
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Finish_Help($drive_letter)
	SendReport("Start-Finish_Help")
	Opt("GUIOnEventMode", 1)

	SendReport("End-Finish_Help")
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
