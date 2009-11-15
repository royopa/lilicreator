#include "crc32.au3"

Global $BufferSize = 0x20000
Global $Filename = FileOpenDialog("Open file", "", "Any file (*.*)")
If $Filename = "" Then Exit

Global $Timer = TimerInit()
Global $FileHandle = FileOpen($Filename, 16)
Global $CRC32 = 0

For $i = 1 To Ceiling(FileGetSize($Filename) / $BufferSize)
	$CRC32 = _CRC32(FileRead($FileHandle, $BufferSize), BitNot($CRC32))
Next

MsgBox (0, "Result", Hex($CRC32, 8) & " in " & Round(TimerDiff($Timer)) & " ms")
