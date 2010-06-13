#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=..\tools\img\lili.ico
#AutoIt3Wrapper_Compression=3
#AutoIt3Wrapper_Res_Comment=Enjoy !
#AutoIt3Wrapper_Res_Description=Easily create a Linux Live USB
#AutoIt3Wrapper_Res_Fileversion=2.0.88.5
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=Y
#AutoIt3Wrapper_Res_LegalCopyright=CopyLeft Thibaut Lauziere a.k.a Slÿm
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Site|http://www.linuxliveusb.com
#AutoIt3Wrapper_AU3Check_Parameters=-w 4
#AutoIt3Wrapper_Run_After=upx.exe --best --compress-resources=0 "%out%"
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Crypt.au3>
_Crypt_Startup()

$Filename= FileOpenDialog("Select files to hash", @ScriptDir & "\", "All Files (*.*)", 5)

	If $FileName = "" Then
		Exit
	EndIf

	$multiple_files = StringInStr($FileName, "|")

	if $multiple_files > 0 Then
		$files = StringSplit($FileName, "|")
		$folder= $files[1] &"\"
		$lines="------------------------------- Start "& @MDAY & "-" & @MON & "-" & @YEAR & " (" & @HOUR & "h" & @MIN & "s" & @SEC &") -------------------------------"&@CRLF
		$j=2
		$hashes=""
		While $j < $files[0]+1
			$lines &= $files[$j] & " = " & SHA1($folder & "\" &$files[$j]) & @CRLF
			$hashes &= $files[$j] & " = " & SHA1($folder & "\" &$files[$j]) & @CRLF
			$j=$j+1
		Wend
		$lines &= "------------------------------- End "& @MDAY & "-" & @MON & "-" & @YEAR & " (" & @HOUR & "h" & @MIN & "s" & @SEC &") -------------------------------"&@CRLF
		$file = FileOpen(@ScriptDir &"\SHA1 HASHES.txt", 1)
		FileWrite($file, $lines)
		FileClose($file)
		ClipPut($hashes)
		MsgBox(64, "Result", $hashes & @CRLF & "It has been put in your clipboard, you just have to paste it." )
	Else
		$hash = SHA1($FileName)
		ClipPut($hash)
		MsgBox(64, "Result", "SHA1 hash of file "& $Filename & " is :" & @CRLF & @CRLF & @TAB & $hash & @CRLF & @CRLF & "It has been put in your clipboard, you just have to paste it." )
	EndIf

_Crypt_Shutdown()

Func SHA1($FileToHash)

	Local $filehandle = FileOpen($FileToHash, 16)
	Local $buffersize=0x20000,$final=0,$hash=""

	$iterations = Ceiling(FileGetSize($FileToHash) / $buffersize)

	ProgressOn("Computing hash", "File : " & path_to_name($FileToHash), "0 %", -1, -1, 16)
	For $i = 1 To $iterations
		if $i=$iterations Then $final=1
		$hash=_Crypt_HashData(FileRead($filehandle, $buffersize),$CALG_SHA1,$final,$hash)
		$percent_SHA1 = Round(100 * $i / $iterations)
		ProgressSet($percent_SHA1, $percent_SHA1 & " %")
	Next
	FileClose($filehandle)

	ProgressSet(100, "100%" ,"File hashed")
	ProgressOff()
	Return StringTrimLeft($hash, 2)
EndFunc


Func path_to_name($filepath)
	$short_name = StringSplit($filepath, '\')
	Return ($short_name[$short_name[0]])
EndFunc   ;==>unix_path_to_name

