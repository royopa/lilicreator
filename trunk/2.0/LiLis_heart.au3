

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
	RunWait3('cmd /c format /Q /X /y /V:MyLinuxLive /FS:FAT32 ' & $drive_letter, @ScriptDir, @SW_HIDE)
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Clean previous Linux Live installs
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
	Output : 
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Clean_old_installs($drive_letter)
	UpdateStatus("Nettoyage des installations précédentes ( 2min )")
	
	; Common Linux Live files
	DirRemove2($drive_letter & "\isolinux\", 1)
	DirRemove2($drive_letter & "\syslinux\", 1)
	FileDelete2($drive_letter & "\autorun.inf")
	
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
	
	; Fedora files
	FileDelete2($drive_letter & "\README")
	FileDelete2($drive_letter & "\GPL")
	DirRemove2($drive_letter & "\LiveOS\",1)
	DirRemove2($drive_letter & "\EFI\",1)
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

				
				UpdateLog("Found Mirror 1 : " & $VirtualBoxUrl1 & " with VirtualBox size : " & $virtualbox_size1 )
				UpdateLog("Found Mirror 2 : " & $VirtualBoxUrl2 & " with VirtualBox size : " & $virtualbox_size2 )
				
				; No mirror working we should log that
				If $virtualbox_size <= 0 Then
					$no_internet = 1
					UpdateLog("No working mirror !")
				EndIf

				
				$downloaded_virtualbox_filename = unix_path_to_name($VirtualBoxUrl)
				$virtualbox_already_downloaded = 0

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
				Sleep(2000)
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
	Output : 
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Uncompress_ISO_on_key()
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Copy already uncompressed iso or CD files on the key
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$path_to_cd = path to the CD or folder containing the Linux Live CD files
	Output : 
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Copy_live_files_on_key()
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Rename and move some file in order to work on an USB key
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$linux_version = Pre-formated version of linux (like ubuntu_8.10)
	Output : 
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Rename_and_move_files()
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Create files for custom boot menu (including persistence options)
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$linux_version = Pre-formated version of linux (like ubuntu_8.10)
	Output : 
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Create_boot_menu()
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
	UpdateStatus("Masquage des fichiers")
	
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
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Create a persistence file
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$linux_version = Pre-formated version of linux (like "ubuntu_8.10")
	Output : 
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Create_persistence_file()
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Format a persistence file
	Input :
		$path_to_persistence_file = path to the persistent file (like "E:\casper-rw")
	Output : 
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Format_persistence_file()
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

Func Install_boot_sectors()
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
	; Cleaning previous install of VBox
	UpdateStatus("Nettoyage d'anciennes installations de VirtualBox")
	DirRemove2($drive_letter & "\VirtualBox\", 1)
	
	; Unzipping to the key
	UpdateStatus(Translate("Décompression de Virtualbox sur la clé") & " ( 4" & Translate("min") & " )")
	Run7zip2('"' & @ScriptDir & '\tools\7z.exe" x "' & @ScriptDir & "\tools\" & '" -r -aoa -o' & $drive_letter, 76)
	
	; maybe check after ?
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Create Autorun.inf
	Input :
		$drive_letter = Letter of the drive (pre-formated like "E:" )
		$linux_version = Pre-formated version of linux (like ubuntu_8.10)
		$virtualbox_installed =  0 or 1 if virtualbox is well installed
	Output : 
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func Create_autorun($drive_letter,$linux_version)
	If FileExists($drive_letter & "\autorun.inf") Then FileDelete($drive_letter & "\autorun.inf")
	
	if $variante == "mint" Then 
		$icon = "lmmenu.exe,0"
		$menu = "lmmenu.exe"
	Elseif $variante=="custom" Then
		FileCopy(@ScriptDir & "\tools\img\lili.ico", $drive_letter & "\lili.ico",1)
		RunWait3("cmd /c attrib /D /S +S +H " & $drive_letter & "\lili.ico", @ScriptDir, @SW_HIDE)
		$icon = "lili.ico"
		$menu = ""
	Elseif $jackalope==1 Then
		$icon = "wubi.exe,0"
		$menu = "wubi.exe --cdmenu"
	Else 
		$icon = "umenu.exe,0"
		$menu = "umenu.exe"
	EndIf
	
	
	IniWrite($drive_letter & "\autorun.inf", "autorun", "icon", $icon)
	IniWrite($drive_letter & "\autorun.inf", "autorun", "open", "")
	IniWrite($drive_letter & "\autorun.inf", "autorun", "label", "LinuxLive Key")
	
	; If virtualbox is installed
	if FileExists($drive_letter & "\VirtualBox\Virtualize_This_Key.exe") AND FileExists($drive_letter & "VirtualBox\VirtualBox.exe") Then
		IniWrite($drive_letter & "\autorun.inf", "autorun", "shell\linuxlive", "----> LinuxLive!")
		IniWrite($drive_letter & "\autorun.inf", "autorun", "shell\linuxlive\command", "VirtualBox\Virtualize_This_Key.exe")
		IniWrite($drive_letter &"\autorun.inf", "autorun", "shell\linuxlive2", "----> VirtualBox Interface")
		IniWrite($drive_letter & "\autorun.inf", "autorun", "shell\linuxlive2\command", "VirtualBox\VirtualBox.exe")
	EndIf
	IniWrite($drive_letter  & "\autorun.inf", "autorun", "shell\linuxlive3", "----> LinuxLive Menu")
	IniWrite($drive_letter & "\autorun.inf", "autorun", "shell\linuxlive3\command", $menu)
	HideFile($drive_letter & "\autorun.inf")
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
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#cs
	Description : Post-install check, will alert user if some requirements are not met
	Input :
		$linux_version = Pre-formated version of linux (like ubuntu_8.10)
		$virtualbox_installed =  0 or 1 if virtualbox is well installed
	Output : 
		0 = sucess
		1 = error see @error
#ce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Final_check()
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




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
	$gui_finish = GUICreate (Translate("Votre clé LinuxLive est maintenant prête !"), 604, 378 , -1, -1)
	GUICtrlCreatePic(@ScriptDir & "\tools\img\tuto.jpg", 350, 0, 254, 378)
	$printme = @CRLF & @CRLF& @CRLF & @CRLF& "  " & Translate("Votre clé LinuxLive est maintenant prête !") _
	& @CRLF & @CRLF & "    "  &Translate("Pour lancer LinuxLive :") _
	& @CRLF & "    " &Translate("Retirez votre clé et réinsérez-la.") _
	& @CRLF & "    " &Translate("Allez ensuite dans 'Poste de travail'.") _
	& @CRLF & "    " &Translate("Faites un clic droit sur votre clé et sélectionnez :") & @CRLF 
	
	if FileExists($drive_letter & "\VirtualBox\Virtualize_This_Key.exe") AND FileExists($drive_letter & "VirtualBox\VirtualBox.exe") then
		$printme &= @CRLF & "    " &"-> "& Translate("'LinuxLive!' pour lancer la clé directement dans windows") 
		$printme &= @CRLF  & "    " & "-> " &Translate("'VirtualBox Interface' pour lancer l'interface complète de VirtalBox") 
	EndIf
	$printme &= @CRLF  & "    " & "-> " &Translate("'CD Menu' pour lancer le menu original du CD")
	GUICtrlCreateLabel($printme, 0, 0, 370, 378)
	GUICtrlSetBkColor(-1, 0x0ffffff) 
	GUICtrlSetFont (-1, 10, 600)

    GUISetState()
    ; Run the GUI until the dialog is closed
    While 1
        $msg_finish = GUIGetMsg($gui_finish)
        If $msg_finish = $GUI_EVENT_CLOSE Then ExitLoop
	WEnd
	GUIDelete($gui_finish)
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;