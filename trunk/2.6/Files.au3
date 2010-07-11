; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Files management                      ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func DirRemove2($arg1, $arg2)
	Local $status="Deleting folder : " & $arg1
	If DirRemove($arg1, $arg2) Then
		$status &=" -> " & "Deleted successfully"
	Else
		If DirGetSize($arg1) >= 0 Then
			$status &=" -> " & "Not deleted"
		Else
			Return 1
		EndIf
	EndIf
	UpdateLog($status)
EndFunc   ;==>DirRemove2

Func FileDelete2($arg1)
	Local $status="Deleting file : " & $arg1
	If FileDelete($arg1) == 1 Then
		$status &=" -> " & "Deleted successfully"
	Else
		If FileExists($arg1) Then
			$status &=" -> " & "Not Deleted"
		Else
			Return 1
		EndIf
	EndIf
	UpdateLog($status)
EndFunc   ;==>FileDelete2

Func HideFilesInDir($list_of_files)
	SendReport("Start-HideFilesInDir")
	if (Ubound($list_of_files)=0) Then
		SendReport("End-HideFilesInDir : list of files is not an array !")
		return "ERROR"
	EndIf
	For $file In $list_of_files
		HideFile($selected_drive & "\" & $file)
	Next
EndFunc   ;==>HideFilesInDir

Func isDir($file_to_test)
	Return StringInStr(FileGetAttrib($file_to_test), "D")
EndFunc   ;==>isDir

Func DeleteFilesInDir($list_of_files)
	SendReport("Start-DeleteFilesInDir")
	if (Ubound($list_of_files)=0) Then
		SendReport("End-DeleteFilesInDir : list of files is not an array !")
		return "ERROR"
	EndIf
	For $file In $list_of_files
		If isDir($selected_drive & "\" & $file) Then
			DirRemove2($selected_drive & "\" & $file, 1)
		Else
			FileDelete2($selected_drive & "\" & $file)
		EndIf
	Next
	SendReport("End-DeleteFilesInDir")
EndFunc   ;==>DeleteFilesInDir

Func HideFile($file_or_folder)
	Local $status="Hiding file : " & $file_or_folder

	If FileSetAttrib($file_or_folder, "+SH") == 1 Then
		$status &=" -> " &"Hided successfully"
	Else
		If FileExists($file_or_folder) Then
			$status &=" -> " & "Not hided"
		Else
			return 1
		EndIf
	EndIf
	UpdateLog($status)
EndFunc   ;==>HideFile

Func ShowFile($file_or_folder)
	Local $status="Unhiding file : " & $file_or_folder
	If FileSetAttrib($file_or_folder, "-SH") == 1 Then
		$status &=" -> " &"Unhided successfully"
	Else
		If FileExists($file_or_folder) Then
			$status &=" -> " & "Not hided"
		Else
			return 1
		EndIf
	EndIf
	UpdateLog($status)
EndFunc   ;==>ShowFile

Func FileRename($file1, $file2)
	Local $status="Renaming File : " & $file1 & " in " & $file2
	If FileMove($file1, $file2, 1) == 1 Then
		$status &=" -> " & "File renamed successfully"
	Else
		if FileExists($file1) Then
			$status &=" -> " & "Not renamed"
		Else
			Return 1
		EndIf
	EndIf
	UpdateLog($status)
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
	Local $status="Copying File : " & $arg1 & " to " & $arg2
	If FileCopy($arg1, $arg2,1) Then
		$status &=" -> " &"Copied successfully"
	Else
		if FileExists($arg1) Then
			$status &=" -> " & "Not copied"
		Else
			Return 1
		EndIf
	EndIf
	UpdateLog($status)
EndFunc   ;==>_FileCopy2

Func GetPreviousInstallSizeMB($drive_letter)
	SendReport("Start-GetPreviousInstallSizeMB for drive "&$drive_letter)
	Local $array,$array2
	if FileExists($drive_letter&"\"&$autoclean_settings) Then
		$array=IniReadSection($drive_letter&"\"&$autoclean_settings,"Files")
		$total=0
		if Ubound($array) > 1 Then
			for $i=1 To Ubound($array)-1
				$total+=FileGetSize($drive_letter&"\"&$array[$i][0])
			Next
		EndIf

		$array2=IniReadSection($drive_letter&"\"&$autoclean_settings,"Folders")
		if Ubound($array2) > 1 Then
			for $i=1 To Ubound($array2)-1
				$total+=DirGetSize($drive_letter&"\"&$array2[$i][0]&"\")
			Next
		EndIf
		SendReport("End-GetPreviousInstallSizeMB ( Previous install : "&Round($total/(1024*1024),1)& " MB")
		Return Round($total/(1024*1024),0)
	Else
		Return 0
	EndIf
EndFunc

Func AddToSmartClean($drive_letter,$file_to_smartclean)
	if FileExists($drive_letter&"\"&$file_to_smartclean) AND _ArraySearch($files_in_source,$file_to_smartclean)=-1  Then _ArrayAdd($files_in_source,$file_to_smartclean)
EndFunc

Func SmartCleanPreviousInstall($drive_letter)
	SendReport("Start-AutoCleanPreviousInstall for drive "&$drive_letter)
	Local $array,$i
	if FileExists($drive_letter&"\"&$autoclean_settings) Then
		$installed_linux=IniRead($drive_letter&"\"&$autoclean_settings,"General","Installed_Linux","NotFound")
		$linux_codename=IniRead($drive_letter&"\"&$autoclean_settings,"General","Installed_Linux_Codename","NotFound")
		$install_size=GetPreviousInstallSizeMB($drive_letter)
		$array=IniReadSection($drive_letter&"\"&$autoclean_settings,"Files")
		SendReport("Found a previous install of "&$install_size&"MB to SmartClean : "&$installed_linux&"("&$linux_codename&")")
		SendReport("Found "&(Ubound($array)-1)&" files to delete")
		if Ubound($array) > 1 Then
			for $i=1 To Ubound($array)-1
				if $array[$i][0] <> $autoclean_settings Then FileDelete2($drive_letter&"\"&$array[$i][0])
			Next
		EndIf

		$array=IniReadSection($drive_letter&"\"&$autoclean_settings,"Folders")
		SendReport("Found "&(Ubound($array)-1)&" folders to delete")
		if Ubound($array) > 1 Then
			for $i=1 To Ubound($array)-1
				DirRemove2($drive_letter&"\"&$array[$i][0],1)
			Next
		EndIf
		FileDelete2($drive_letter&"\"&$autoclean_settings)
		SendReport("End-AutoCleanPreviousInstall (found autoclean.ini)")
		Return 1
	Elseif Ubound($files_in_source>0) Then
		DeleteFilesInDir($files_in_source)
		SendReport("End-AutoCleanPreviousInstall (no autoclean.ini -> deleting listed files)")
		Return 0
	Else
		SendReport("End-AutoCleanPreviousInstall : WARNING (no autoclean.ini and no file list)")
		Return 0
	EndIf
EndFunc

Func InitializeFilesInSource($path)
	If isDir($path) == 1 Then
		return InitializeFilesInCD($path)
	Else
		return InitializeFilesInISO($path)
	EndIf
EndFunc   ;==>InitializeFilesInSource


; Analyze the listfile and only select files and folders at the root (will be used to clean previous installs and hide the newly created)
Func AnalyzeFileList()
	SendReport("Start-AnalyzeFileList")
	Local $line, $filelist, $files[1]
	Global $files_in_source
	$filelist = FileOpen(@ScriptDir & "\tools\filelist.txt", 0)
	While 1
		$line = FileReadLine($filelist)
		If @error = -1 Then ExitLoop
		If StringRegExp($line, "^Path = ", 0) And StringInStr($line, "\") == 0 And StringInStr($line, "[BOOT]") == 0 Then
			_ArrayAdd($files, StringReplace($line, "Path = ", ""))
			SendReport("IN-AnalyzeFileList :  Found file : "&StringReplace($line, "Path = ", ""))
		EndIf
	WEnd
	FileClose($filelist)
	FileDelete(@ScriptDir & "\tools\filelist.txt")
	_ArrayDelete($files, 0)
	$files_in_source = $files
	SendReport("End-AnalyzeFileList")
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
