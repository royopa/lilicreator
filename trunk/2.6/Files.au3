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

Func ShowFile($file_or_folder)
	SendReport("Start-HideFile ( " & $file_or_folder & " )")
	UpdateLog("Showing file : " & $file_or_folder)
	If FileSetAttrib($file_or_folder, "-SH") == 1 Then
		UpdateLog("                   " & "File showed")
	Else
		If FileExists($file_or_folder) Then
			UpdateLog("                   " & "File not showed")
		Else
			UpdateLog("                   " & "Error while showing")
		EndIf
	EndIf
	SendReport("End-HideFile")
EndFunc   ;==>ShowFile

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

Func FileCopyShell($fromFile, $tofile)
	SendReport("Start-_FileCopyShell (" & $fromFile & " -> " & $tofile & " )")
	Local $FOF_RESPOND_YES = 16
	Local $FOF_SIMPLEPROGRESS = 256
	$winShell = ObjCreate("shell.application")
	$winShell.namespace($tofile).CopyHere($fromFile, $FOF_RESPOND_YES)
	SendReport("End-_FileCopyShell")
EndFunc   ;==>_FileCopy

Func FileCopy2($arg1, $arg2)
	SendReport("Start-_FileCopy2 ( " & $arg1 & " -> " & $arg2 & " )")
	UpdateLog("Copying file(s) " & $arg1 & " to " & $arg2)
	If FileCopy($arg1, $arg2,1) Then
		UpdateLog("                   File copied successfully")
	Else
		UpdateLog("                   Error : " & $arg1 & " has not been copied")
	EndIf
	SendReport("End-_FileCopy2")
EndFunc   ;==>_FileCopy2



Func InitializeFilesInSource($path)
	If isDir($path) == 1 Then
		InitializeFilesInCD($path)
	Else
		InitializeFilesInISO($path)
	EndIf
EndFunc   ;==>InitializeFilesInSource

; Create a list of files in ISO
Func InitializeFilesInISO($iso_to_list)
	SendReport("Start-InitializeFilesInISO ( " & $iso_to_list &")")
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	FileDelete(@ScriptDir & "\tools\filelist.txt")
	$cmd=@ComSpec & " /c " & '7z.exe' & ' l -slt "' & $iso_to_list & '" > filelist.txt'
	$foo = RunWait($cmd, @ScriptDir & "\tools\", @SW_HIDE)
	SendReport("IN-InitializeFilesInISO : command executed -> " &@CRLF& @ComSpec & " /c " & '7z.exe' & ' l -slt "' & $iso_to_list & '" > filelist.txt')
	AnalyzeFileList()
	SendReport("End-InitializeFilesInISO")
EndFunc   ;==>InitializeFilesInISO

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
