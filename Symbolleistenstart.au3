#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <WinAPI.au3>

if not FileExists(@AppDataDir & "\Symbolleiste") then
	ShellExecute(@ScriptDir & "\Symbolleiste.exe")
	exit
endif	

$data=IniReadSectionNames(@AppDataDir & "\Symbolleiste\Symbolleiste.ini")

if not @error then

	if $data[0] > 0 then		
		for $j = 1 to $data[0]
			ShellExecute(@ScriptDir & "\Symbolleiste.exe",$data[$j])
		next	
	EndIf	
EndIf	
