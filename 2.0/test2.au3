#include <GuiConstantsEx.au3>
#include <GDIPlus.au3>
#include <Constants.au3>
#include <ProgressConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>


#cs
$line2="100+0 records in"&@CRLF
$line="1829,293,029"&@CRLF
$is = StringRegExp($line, '\A([0-9]*)\,', 0)
if $is =1 Then
	$array= StringRegExp($line, '\A([0-9]*)\,', 3)
	MsgBox(0,"jkjl","OK :"& $array[0])
Else
	MsgBox(0,"jkjl","PAS BON")
EndIf
#ce


WriteBlocksFromIMG()

Func WriteBlocksFromIMG()

	Local $cmd, $foo, $line
	;$cmd = @ScriptDir & '\tools\dd.exe if="'&$img_file&'" of=\\.\'& $selected_drive&'bs=1M --progress'

	$img_file="M:\Backups\Bureau\SVN DEV\trunk\2.0\karmic-netbook-remix-i386.iso"
	;$cmd = @ScriptDir & '\tools\dd.exe if=/dev/zero of=test.test count=100 bs=1M --progress'
ProgressOn("Progress Meter", "Increments every second", "0 percent")
	$cmd = @ScriptDir & '\tools\dd.exe if="'&$img_file&'" of=\\.\G: bs=1M --progress'
	;dd.exe if="M:\Backups\Bureau\SVN DEV\trunk\2.0\karmic-netbook-remix-i386.iso" of=\\.\G: bs=1M --progress
	If ProcessExists("dd.exe") > 0 Then ProcessClose("dd.exe")
	$foo = Run($cmd, @ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)

	$line=@CRLF&@CRLF

		While 1
		;$line &= StdoutRead($foo)
			if StdoutRead($foo,0,True)>0 then $line = StdoutRead($foo)

		If @error Then ExitLoop
		;$str = StringSplit($line,@CR)
		$is_percentage = StringRegExp($line, '\A([0-9]*)\,', 0)
		if $is_percentage =1 Then
			$array= StringRegExp($line, '\A([0-9]*)\,', 3)
			ProgressSet( Ceiling($array[0]/7.50),$array[0] & " MB")
			;$line=@CRLF&@CRLF
		EndIf
		Sleep(500)
		WEnd

	#cs
	While @error=0

		;UpdateStatusNoLog(Translate("Création de la clé à partir du fichier") & " ( " & Round(FileGetSize($file_to_create) / 1048576, 0) & "/" & Round($size, 0) & " Mo )")
		$line = StdoutRead($foo)
		ProgressSet(10, $line)

		$is_percentage = StringRegExp($line, '\s([0-9]{1,3})%', 0)

		if $is_percentage =1 Then
			$array = StringRegExp($line, '\s([0-9]{1,3})%', 3)
			if $array[0] > 0 AND $array[0] < 101 Then ProgressSet( $array[0], $array[0] & " percent")
		EndIf

	WEnd
	#ce
	ProgressOff()

EndFunc


