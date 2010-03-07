#include <Array.au3>
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////// Managing the releases list                    ///////////////////////////////////////////////////////////////////////////////
; ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Set the list for compatibility


; Global variables for releases attributes
Global Const $R_CODE = 0,$R_NAME=1,$R_DISTRIBUTION=2, $R_DISTRIBUTION_VERSION=3,$R_FILENAME=4,$R_FILE_MD5=5,$R_RELEASE_DATE=6,$R_WEB=7,$R_DOWNLOAD_PAGE=8,$R_DOWNLOAD_SIZE=9,$R_INSTALL_SIZE=10,$R_DESCRIPTION=11
Global Const $R_MIRROR1=12,$R_MIRROR2=13,$R_MIRROR3=14,$R_MIRROR4=15,$R_MIRROR5=16,$R_MIRROR6=17,$R_MIRROR7=18,$R_MIRROR8=19,$R_MIRROR9=20,$R_MIRROR10=21,$R_VARIANT=22,$R_VARIANT_VERSION=23,$R_VISIBLE=24,$R_FEATURES=25
Global $releases[5][30],$compatible_md5[5],$compatible_filename[5],$codenames_list[5]
Global $current_compatibility_list_version

Func Get_Compatibility_List()
	$current_compatibility_list_version=IniRead($compatibility_ini, "Compatibility_List", "Version","none")
	$sections = IniReadSectionNames($compatibility_ini)
	If (Not IsArray($sections)) Or (Not FileExists($compatibility_ini)) Then
		MsgBox(32,"Error","Compatibility file "&$compatibility_ini&" was not found.")
		GUI_Exit()
	EndIf

	Global $releases[$sections[0]+1][30],$compatible_md5[$sections[0]+1],$compatible_filename[$sections[0]+1],$codenames_list[$sections[0]+1]

	For $i=1 to $sections[0]
		$releases[$i][$R_CODE]=$sections[$i]
		$codenames_list[$i]=$sections[$i]
		$releases[$i][$R_NAME]=IniRead($compatibility_ini, $sections[$i], "Name","NotFound")
		$releases[$i][$R_DISTRIBUTION]=IniRead($compatibility_ini, $sections[$i], "Distribution","NotFound")
		$releases[$i][$R_DISTRIBUTION_VERSION]=IniRead($compatibility_ini, $sections[$i], "Distribution_Version","NotFound")
		$releases[$i][$R_VARIANT]=IniRead($compatibility_ini, $sections[$i], "Variant","NotFound")
		$releases[$i][$R_VARIANT_VERSION]=IniRead($compatibility_ini, $sections[$i], "Variant_Version","NotFound")
		$releases[$i][$R_FEATURES]=IniRead($compatibility_ini, $sections[$i], "Supported_Features","default")
		$releases[$i][$R_FILENAME]=IniRead($compatibility_ini, $sections[$i], "Filename","NotFound")
		$compatible_filename[$i]=IniRead($compatibility_ini, $sections[$i], "Filename","NotFound")
		$releases[$i][$R_FILE_MD5]=IniRead($compatibility_ini, $sections[$i], "File_MD5","NotFound")
		$compatible_md5[$i]=IniRead($compatibility_ini, $sections[$i], "File_MD5","NotFound")
		$releases[$i][$R_RELEASE_DATE]=IniRead($compatibility_ini, $sections[$i], "Release_Date","NotFound")
		$releases[$i][$R_WEB]=IniRead($compatibility_ini, $sections[$i], "Web","NotFound")
		$releases[$i][$R_DOWNLOAD_PAGE]=IniRead($compatibility_ini, $sections[$i], "Download_page","NotFound")
		$releases[$i][$R_DOWNLOAD_SIZE]=IniRead($compatibility_ini, $sections[$i], "Download_Size","NotFound")
		$releases[$i][$R_INSTALL_SIZE]=IniRead($compatibility_ini, $sections[$i], "Install_Size","800")
		$releases[$i][$R_DESCRIPTION]=IniRead($compatibility_ini, $sections[$i], "Description","NotFound")
		$releases[$i][$R_MIRROR1]=IniRead($compatibility_ini, $sections[$i], "Mirror1","NotFound")
		$releases[$i][$R_MIRROR2]=IniRead($compatibility_ini, $sections[$i], "Mirror2","NotFound")
		$releases[$i][$R_MIRROR3]=IniRead($compatibility_ini, $sections[$i], "Mirror3","NotFound")
		$releases[$i][$R_MIRROR4]=IniRead($compatibility_ini, $sections[$i], "Mirror4","NotFound")
		$releases[$i][$R_MIRROR5]=IniRead($compatibility_ini, $sections[$i], "Mirror5","NotFound")
		$releases[$i][$R_MIRROR6]=IniRead($compatibility_ini, $sections[$i], "Mirror6","NotFound")
		$releases[$i][$R_MIRROR7]=IniRead($compatibility_ini, $sections[$i], "Mirror7","NotFound")
		$releases[$i][$R_MIRROR8]=IniRead($compatibility_ini, $sections[$i], "Mirror8","NotFound")
		$releases[$i][$R_MIRROR9]=IniRead($compatibility_ini, $sections[$i], "Mirror9","NotFound")
		$releases[$i][$R_MIRROR10]=IniRead($compatibility_ini, $sections[$i], "Mirror10","NotFound")
		$releases[$i][$R_VISIBLE]=IniRead($compatibility_ini, $sections[$i], "Visible","NotFound")
	Next
	Return $releases
EndFunc

Func DisplayRelease($release_in_list)
	Global $releases
	if $release_in_list>0 Then
		Msgbox(4096,"Release Details" ,  "Name : " & $releases[$release_in_list][$R_NAME]  & @CRLF  _
		& "Distribution : " & ReleaseGetDistribution($release_in_list) & @CRLF  _
		& "Distribution Version : " & ReleaseGetDistributionVersion($release_in_list) & @CRLF  _
		& "Variant : " & ReleaseGetVariant($release_in_list) & @CRLF  _
		& "Variant Version : " & ReleaseGetVariantVersion($release_in_list) & @CRLF  _
		& "Supported Features : " & ReleaseGetSupportedFeatures($release_in_list) & @CRLF  _
		& "Filename : " & $releases[$release_in_list][$R_FILENAME] & @CRLF  _
		& "MD5 : " & $releases[$release_in_list][$R_FILE_MD5] & @CRLF  _
		& "Release Date : " & $releases[$release_in_list][$R_RELEASE_DATE] & @CRLF  _
		& "WebSite : " & $releases[$release_in_list][$R_WEB] & @CRLF  _
		& "Download Page : " & $releases[$release_in_list][$R_DOWNLOAD_PAGE] & @CRLF _
		& "Download Size : " & $releases[$release_in_list][$R_DOWNLOAD_SIZE] & @CRLF _
		& "Installed Size : " & $releases[$release_in_list][$R_INSTALL_SIZE] & @CRLF  _
		& "Description : " & $releases[$release_in_list][$R_DESCRIPTION] & @CRLF  _
		& "Mirror 1 :"  & $releases[$release_in_list][$R_MIRROR1] & @CRLF  _
		& "Mirror 2 : " & $releases[$release_in_list][$R_MIRROR2] & @CRLF  _
		& "Mirror 3 : " & $releases[$release_in_list][$R_MIRROR3] & @CRLF  _
		& "Mirror 4 : " & $releases[$release_in_list][$R_MIRROR4] & @CRLF  _
		& "Mirror 5 : " & $releases[$release_in_list][$R_MIRROR5] & @CRLF  _
		& "Mirror 6 : " & $releases[$release_in_list][$R_MIRROR6] & @CRLF  _
		& "Mirror 7 : " & $releases[$release_in_list][$R_MIRROR7] & @CRLF  _
		& "Mirror 8 : " & $releases[$release_in_list][$R_MIRROR8] & @CRLF  _
		& "Mirror 9 : " & $releases[$release_in_list][$R_MIRROR9] & @CRLF  _
		& "Mirror 10 : " & $releases[$release_in_list][$R_MIRROR10])
	EndIf
EndFunc

Func Print_For_ComboBox()
	Global $releases
	Local $temp=""
	$sections = IniReadSectionNames($compatibility_ini)
	For $release_in_list=1 to $sections[0]
		if $releases[$release_in_list][$R_VISIBLE]="yes" Then $temp &=  ReleaseGetDescription($release_in_list)&"|"
			;& "// Size : " & $releases[$release_in_list][$R_DOWNLOAD_SIZE] _
			;& " (" & $releases[$release_in_list][$R_RELEASE_DATE] & ") |"
	Next
	Return $temp
EndFunc

Func FindReleaseFromDescription($description)
	Global $releases
	Local $found
	$sections = IniReadSectionNames($compatibility_ini)
	For $i=1 to $sections[0]
		If ReleaseGetDescription($i) = $description Then $found = $i
	Next
	Return $found
EndFunc

Func DisplayAllReleases()
	$sections = IniReadSectionNames($compatibility_ini)
	For $i=1 to $sections[0]
		DisplayRelease($i)
	Next
EndFunc

Func ReleaseGetCodename($release_in_list)
	if $release_in_list <=0 Then Return "default"
	Return $releases[$release_in_list][$R_CODE]
EndFunc

Func ReleaseGetFilename($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return $releases[$release_in_list][$R_FILENAME]
EndFunc

Func ReleaseGetMD5($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return $releases[$release_in_list][$R_FILE_MD5]
EndFunc

Func ReleaseGetDistribution($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return $releases[$release_in_list][$R_DISTRIBUTION]
EndFunc

Func ReleaseGetDistributionVersion($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return $releases[$release_in_list][$R_DISTRIBUTION_VERSION]
EndFunc

Func ReleaseGetVariant($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return $releases[$release_in_list][$R_VARIANT]
EndFunc

Func ReleaseGetVariantVersion($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return $releases[$release_in_list][$R_VARIANT_VERSION]
EndFunc

Func ReleaseGetInstallSize($release_in_list)
	if $release_in_list <=0 Then Return 800
	Return $releases[$release_in_list][$R_INSTALL_SIZE]
EndFunc

Func ReleaseGetDescription($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	if StringInStr(ReleaseGetCodename($release_in_list),"separator")>0 Then
		; This is a separator description
		Return ">>>>>>>>>>>>>>> "&Translate($releases[$release_in_list][$R_DESCRIPTION])&" <<<<<<<<<<<<<<<"
	Else
		; This is Linux description
		Return Translate($releases[$release_in_list][$R_DESCRIPTION])
	Endif

EndFunc

Func ReleaseGetSupportedFeatures($release_in_list)
	if $release_in_list <=0 Then Return "NotFound"
	Return $releases[$release_in_list][$R_FEATURES]
EndFunc

Func ReleaseGetVBoxRAM($release_in_list)
	$features=ReleaseGetSupportedFeatures($release_in_list)
	$feature_list = StringSplit($features,",")
	For $feature IN $feature_list
		if StringInStr($feature,"vboxram-") Then
			$vboxram=StringSplit($feature,"-")
			if $vboxram[0]=2 Then Return $vboxram[2]
		EndIf
	Next
	Return "256"
EndFunc

Func URLToHostname($url)
	if StringInStr($url,"/") >= 3 Then
		$temp = StringSplit($url,"/")
		Return $temp[3]
	Else
		Return ""
	EndIf
EndFunc

Func path_to_name($filepath)
	$short_name = StringSplit($filepath, '\')
	Return ($short_name[$short_name[0]])
EndFunc   ;==>path_to_name

Func unix_path_to_name($filepath)
	$short_name = StringSplit($filepath, '/')
	Return ($short_name[$short_name[0]])
EndFunc   ;==>unix_path_to_name

Func get_extension($filepath)
	$short_name = StringSplit($filepath, '.')
	Return ($short_name[$short_name[0]])
EndFunc   ;==>unix_path_to_name
