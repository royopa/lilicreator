#include "crc32.au3"

; Method 1
$CRC32 = _CRC32("The quick brown fox jumps over the lazy dog")
MsgBox(0, 'Method 1 Result', Hex($CRC32))

; Method 2
$CRC32 = 0
$CRC32 = _CRC32('The quick brown fox ', BitNot($CRC32))
$CRC32 = _CRC32('jumps over the lazy dog', BitNot($CRC32))
MsgBox(0, 'Method 2 Result', Hex($CRC32))

MsgBox(0, '', Hex($crc32))