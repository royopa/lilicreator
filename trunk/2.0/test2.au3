#include <GuiConstantsEx.au3>
#include <GDIPlus.au3>
#include <Constants.au3>
#include <ProgressConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>


#CS

$line2="100+0 records in"&@CRLF
$line="1829,293,029"& @CR& "123,928,93"&@CR&"165,928,93"&@CR&"10,928,93"&@CR&"5,928,92"
$is = StringRegExp($line, '\r([0-9]{1,4}\,[0-9]{1,3}\,[0-9]{1,3})\r', 0)
if $is =1 Then
	$array= StringRegExp($line, '\r([0-9]{1,4}\,[0-9]{1,3}\,[0-9]{1,3})\r', 3)
	MsgBox(0,"jkjl","OK :"& $array[UBound($array)-1])
Else
	MsgBox(0,"jkjl","PAS BON")
EndIf
#CE

WriteBlocksFromIMG()

Func WriteBlocksFromIMG()

	Local $cmd, $foo, $line
	;$cmd = @ScriptDir & '\tools\dd.exe if="'&$img_file&'" of=\\.\'& $selected_drive&'bs=1M --progress'

	$img_file="M:\Backups\Bureau\SVN DEV\trunk\2.0\ubuntu-9.04-netbook-remix-i386.img"
	;$cmd = @ScriptDir & '\tools\dd.exe if=/dev/zero of=test.test count=100 bs=1M --progress'

	$img_size= Ceiling(FileGetSize($img_file)/1048576)
			;MsgBox(0,"hjhk",FileGetSize($img_file))
			;Exit
ProgressOn("Progress Meter", "Increments every second", "0 percent")
	$cmd = @ScriptDir & '\tools\dd.exe if="'&$img_file&'" of=\\.\G: bs=1M --progress'
	;dd.exe if="M:\Backups\Bureau\SVN DEV\trunk\2.0\karmic-netbook-remix-i386.iso" of=\\.\G: bs=1M --progress
	If ProcessExists("dd.exe") > 0 Then ProcessClose("dd.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)

		While 1
		$line &= StdoutRead($foo)


		If @error Then ExitLoop

		$str = StringRight($line,20)


		$is = StringRegExp($line, '\r([0-9]{1,4}\,[0-9]{1,3}\,[0-9]{1,3})\r', 0) ;StringRegExp($str, '\r([0-9]*)\,', 0)
		if $is =1 Then
			$array= StringRegExp($line, '\r([0-9]{1,4}\,[0-9]{1,3}\,[0-9]{1,3})\r', 3)
				$mb_written = Ceiling(StringReplace($array[UBound($array)-1],",","")/1048576)
				$percent_written = Ceiling(100*$mb_written/$img_size)
				ProgressSet( $percent_written , $mb_written & " MB / "&$img_size& "MB ( "&$percent_written&"% )")
				$line=""
		EndIf
		Sleep(500)

		#cs
		if $is_percentage =1 Then
			$array = StringRegExp($line, '\s([0-9]{1,3})%', 3)
			if $array[0] > 0 AND $array[0] < 101 Then ProgressSet( $array[0], $array[0] & " percent")
		EndIf



		;UpdateStatusNoLog(Translate("Création de la clé à partir du fichier") & " ( " & Round(FileGetSize($file_to_create) / 1048576, 0) & "/" & Round($size, 0) & " Mo )")
		$line = StdoutRead($foo)
		ProgressSet(10, $line)

		$is_percentage = StringRegExp($line, '\s([0-9]{1,3})%', 0)

		if $is_percentage =1 Then
			$array = StringRegExp($line, '\s([0-9]{1,3})%', 3)
			if $array[0] > 0 AND $array[0] < 101 Then ProgressSet( $array[0], $array[0] & " percent")
		EndIf
	#ce

	WEnd

	ProgressOff()


EndFunc


