; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Launching third party tools                       ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Func Run7zip($cmd, $taille)
	Local $percentage, $line
	$initial = DriveSpaceFree($selected_drive)
	SendReport("Start-Run7zip ( Command :" & $cmd & " - Size:" & $taille & " )")

	UpdateLog($cmd)
	If ProcessExists("7z.exe") > 0 Then ProcessClose("7z.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = ""

	While ProcessExists($foo) > 0
		$percentage = Round((($initial - DriveSpaceFree($selected_drive)) * 100 / $taille), 0)
		If $percentage > 0 And $percentage < 101 Then
			UpdateStatusNoLog(Translate("Extracting ISO file on key") & " ( ± " & $percentage & "% )")
		EndIf
		;If @error Then ExitLoop
		Sleep(500)
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$line &= StderrRead($foo)
		If @error Then ExitLoop
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
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = ""
	While ProcessExists($foo) > 0
		$percentage = Round((($initial - DriveSpaceFree($selected_drive)) * 100 / $taille), 0)
		If $percentage > 0 And $percentage < 101 Then
			UpdateStatusNoLog(Translate("Extracting VirtualBox on key") & " ( ± " & $percentage & "% )")
		EndIf
		;If @error Then ExitLoop
		;UpdateStatus2($line)
		Sleep(500)
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$line &= StderrRead($foo)
		If @error Then ExitLoop
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
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = ""
	While 1

		UpdateStatusNoLog(Translate("Creating file for persistence") & " ( " & Round(FileGetSize($file_to_create) / 1048576, 0) & "/" & Round($size, 0) & " Mo )")
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$line &= StderrRead($foo)
		If @error Then ExitLoop
		Sleep(500)
	WEnd
	UpdateLog($line)
	SendReport("End-Create_Empty_File")
EndFunc   ;==>Create_Empty_File


Func EXT2_Format_File($persistence_file)
	Local $line,$line_temp,$errors=""
	If ProcessExists("mke2fs.exe") > 0 Then ProcessClose("mke2fs.exe")
	$cmd = @ScriptDir & '\tools\mke2fs.exe -b 1024 ' & $persistence_file
	SendReport("Start-EXT2_Format_File ( " & $cmd & " )")
	UpdateLog($cmd)
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD + $STDIN_CHILD)
	$line_temp = ""
	$line=""
	While 1
		$line_temp = StdoutRead($foo)
		If @error Then ExitLoop
		;$line_temp &= StderrRead($foo)
		;If @error Then ExitLoop
		;$parse_percent = StringRegExp($line_temp, '[0-9]{1,3}%', 1)
		;if Ubound($parse_percent)>0 Then UpdateStatusNoLog(Translate("Formating persistence file") & " "& $parse_percent[0])
		$line &=$line_temp
		StdinWrite($foo, "{ENTER}")
		If @error Then ExitLoop
		Sleep(500)
	WEnd
	UpdateLog($line)
	While 1
		$errors &= StderrRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog($errors)
	SendReport("End-EXT2_Format_File")
EndFunc   ;==>EXT2_Format_File

Func RunWait3($soft, $arg1, $arg2)
	SendReport("Start-RunWait3 ( " & $soft & " )")
	Local $lines="",$errors=""
	UpdateLog($soft)
	$foo = Run($soft, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	While 1
		$lines &= StdoutRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog($lines)
	While 1
		$errors &= StderrRead($foo)
		If @error Then ExitLoop
	WEnd
	UpdateLog($errors)
	SendReport("End-RunWait3")
EndFunc   ;==>RunWait3


Func Run2($soft, $arg1, $arg2)
	SendReport("Start-Run2 ( " & $soft & " )")
	Local $line
	UpdateLog($soft)
	$foo = Run($soft, @ScriptDir, @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
	$line = ""
	While True
		$line &= StdoutRead($foo)
		If @error Then ExitLoop
		$line &= StderrRead($foo)
		If @error Then ExitLoop
		StdinWrite($foo, @CR & @LF & @CRLF)
		If @error Then ExitLoop
		Sleep(300)
	WEnd
	UpdateLog("                   " & $line)
	SendReport("End-Run2")
EndFunc   ;==>Run2
