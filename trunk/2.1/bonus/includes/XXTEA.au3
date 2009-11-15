Func _XXTEA_Encrypt($Data, $Key)
	$Data = Binary($Data)
	Local $DataLen = BinaryLen($Data)
	If $DataLen = 0 Then 
		Return ""
	ElseIf $DataLen < 8 Then
		$DataLen = 8
	EndIf	
	
	Local $Opcode = '0x83EC14B83400000099538B5C2420558B6C242056578B7C9DFCF7FB89C683C606C74424180000000085F68D76FF0F8EEA000000896C24288D4BFF8D549D00894C2410895424148974242081442418B979379E8B4C2418C1E90281E103000000894C241C31F6397424107E568B5424288BCF8B6CB204C1E9058D14AD0000000033CA8BD58BC7C1EA03C1E00433D003CA8B5424188BDE81E303000000335C241C8B4424308B1C9833D533DF03D333CA8B542428010CB28B0CB2463974241089CF7FAA8B5424288BCF8B2AC1E9058D14AD0000000033CA8BD58BC7C1EA03C1E00433D003CA8B5424188BDE81E303000000335C241C8B4424308B1C9833D533DF03D3FF4C242033CA8B542414014AFC8B4AFC8B54242089CF420F8F2DFFFFFF5F31C05E5D5B83C414C21000'
	Local $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]")
	DllStructSetData($CodeBuffer, 1, $Opcode)

	Local $V = DllStructCreate("byte[" & Ceiling($DataLen / 4) * 4 & "]")
	DllStructSetData($V, 1, $Data)

	Local $K = DllStructCreate("byte[16]")
	DllStructSetData($K, 1, $Key)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer), _
													"ptr", DllStructGetPtr($V), _
													"int", Ceiling($DataLen / 4), _
													"ptr", DllStructGetPtr($K), _
													"int", 0)

	Local $Ret = DllStructGetData($V, 1)
	$CodeBuffer = 0
	$V = 0
	$K = 0
	Return $Ret
EndFunc

Func _XXTEA_Decrypt($Data, $Key)
	$Data = Binary($Data)
	Local $DataLen = BinaryLen($Data)
	If $DataLen = 0 Then Return ""

	Local $Opcode = '0x83EC10B83400000099538B5C241C55568B742420578B3EF7FB69D0B979379E81C256DA4CB5895424180F84DD000000897424248D4BFF8D149E894C2410895424148B4C2418C1E90281E103000000894C241C8B742410837C2410007E528B5424248B6CB2FC8BCD8BD7C1E905C1E20233CA8BD78BC5C1EA03C1E00433D003CA8B5424188BDE81E3030000008B44242C33D7335C241C8B1C9833DD03D333CA8B542424290CB28B0CB24E89CF85F67FAE8B5424148B6AFC8BCD8BD7C1E905C1E20233CA8BD78BC5C1EA03C1E00433D003CA8B5424188BDE81E3030000008B44242C33D7335C241C8B1C9833DD03D333CA8B542424290A8B0A89CF814424184786C861837C2418000F8535FFFFFF5F31C05E5D5B83C410C21000'
	Local $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]")
	DllStructSetData($CodeBuffer, 1, $Opcode)

	Local $V = DllStructCreate("byte[" & Ceiling($DataLen / 4) * 4 & "]")
	DllStructSetData($V, 1, $Data)

	Local $K = DllStructCreate("byte[16]")
	DllStructSetData($K, 1, $Key)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer), _
													"ptr", DllStructGetPtr($V), _
													"int", Ceiling($DataLen / 4), _
													"ptr", DllStructGetPtr($K), _
													"int", 0)

	Local $Ret = DllStructGetData($V, 1)
	$CodeBuffer = 0
	$V = 0
	$K = 0
	Return $Ret
EndFunc

Func _XXTEA_Encrypt_Pad($Data, $Key)
	$Data = Binary($Data)
	Local $DataLen = BinaryLen($Data), $DataPad

	Switch(Mod($DataLen, 4))
	Case 0
		$DataPad = Binary("0x80000000")
	Case 1 
		$DataPad = Binary("0x800000")
	Case 2 
		$DataPad = Binary("0x8000")
	Case 3 
		$DataPad = Binary("0x80")
	EndSwitch
	Return _XXTEA_Encrypt($Data & $DataPad, $Key)
EndFunc

Func _XXTEA_Decrypt_Pad($Data, $Key)
	$Data = _XXTEA_Decrypt($Data, $Key)
	Local $DataLen = BinaryLen($Data), $i
	For $i = $DataLen To $DataLen - 8 Step -1
		If BinaryMid($Data, $i, 1) = Binary("0x80") Then
			$Data = BinaryMid($Data, 1, $i - 1)
			ExitLoop			
		EndIf		
	Next	
	Return $Data
EndFunc
