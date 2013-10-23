#NoTrayIcon

#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <WinAPI.au3>

; Parameter:
; kein Parameter -> Öffnet Dialog um Ordner auszuwählen
; Ziffer -> Öffnet Symbolleiste mit Parametern aus Section [Ziffer]
;	Fehler -> Dialog
; Pfad -> Öffnet neue Symbolleiste zu dem Ordner. 
; 	Fehler -> Dialog

if not FileExists(@AppDataDir & "\Symbolleiste") then
	dircreate(@AppDataDir & "\Symbolleiste")
	iniwrite(@AppDataDir & "\Symbolleiste\Symbolleiste.ini","1","state","free")
endif		

Local $Folder=""
Local $IniSection=0
local $FolderSize=0

if $CmdLine[0]>1 Then
	msgbox(1,"Error","zuviele Parameter")
EndIf

if $CmdLine[0]=1 Then
	
	; test, ob Parameter ist ein Sectionsname
	$data=IniReadSectionNames(@AppDataDir & "\Symbolleiste\Symbolleiste.ini")
	
	for $j = 1 to $data[0]
		if $data[$j]=$CmdLine[1] then
			if IniRead(@AppDataDir & "\Symbolleiste\Symbolleiste.ini",$CmdLine[1],"state","free")<>"used" Then
				msgbox(1,"Error in Symbolleisten","No valid date in parameterset in ini.-file " & $j)
				exit
			endif	
			$IniSection=$CmdLine[1]
			$IniFolder=IniRead(@AppDataDir & "\Symbolleiste\Symbolleiste.ini",$CmdLine[1],"folder","nul:") 
			if fileexists($Inifolder) Then	
				$Folder=$inifolder
				exitloop
			Else	
				msgbox(1,"Error in Symbolleisten","Folder in Parameterset in ini.-File do not exist!")
				exit
			endif	
		endif	
	next	
	
	if $IniSection =0 Then   ; Falls Parameter keine Section
		
		if fileexists($CmdLine[1]) then
			; Aufruf mit Dateinamen
			$Folder = _PathFull($CmdLine[1])


			
		Else ; Parameter ist auch kein Dateiname´
			msgbox(1,"Error in Symolleisten","Parameter from Comandline is neither al valid Section nor a valid filename")
			exit
		endif
	endif	
			
	
else ; no Comandlineparameter
			
	$Folder=FileSelectFolder("Choose a folder.", "",0,"G:\Symbolleisten")
	if $Folder= "" then exit

EndIf
	
	
if $Inisection=0 then	; falls Name aus Parametern oder aus dem Dialog
	
	
	; Suchen einer Nummer für die Section
	$i = 1 ; Zähler 
	while 1
		$data=IniReadSection(@AppDataDir & "\Symbolleiste\Symbolleiste.ini",$i)
		if @error<>1 then
			for $j = 1 to $data[0][0]
				; Wenn in den Werten der Section eingetragen ist: state=free, wird dies die Section für diese Symbolleiste
				if $data[$j][0]="state" and $data[$j][1]="free" Then
					$IniSection=$i
					exitloop			; der For-schleife
				endif
			next	
			if $IniSection<>0 Then     ; Falls eine Lücke frei ist
				ExitLoop     ; der while-Schleife
			endif				
		else	
			; Sobald beim hochzählen ein wert erreicht wird, für den keine Section vorhanden ist, wird dies die Section für diese symbolleiste	
			iniwrite(@AppDataDir & "\Symbolleiste\Symbolleiste.ini",$i,"state","free")
			$IniSection=$i
			ExitLoop ; der while-Schleife
		endif
		ConsoleWrite($i)
		$i = $i + 1	
	wend	
	IniWrite(@AppDataDir & "\Symbolleiste\Symbolleiste.ini",$IniSection,"state","used")
	IniWrite(@AppDataDir & "\Symbolleiste\Symbolleiste.ini",$IniSection,"folder", """" & $Folder & """" )

EndIf


local $boxleft, $boxtop, $boxwidth, $boxhight

Local $ListItemPtr[1]=[0]
Local $ListItemName[1]=[0]
Local $ItemAnzahl




$i=0
$search=filefindfirstfile($Folder&"/*.*")
While 1
    $file = FileFindNextFile($search) 
    If @error Then ExitLoop
    $i=$i+1
WEnd

$boxhight = $i*17+17
$boxwidth = 150
$boxleft = (@DesktopWidth-$boxwidth)/2
$boxtop = (@DesktopHeight-$boxhight)/2
if $boxtop<0 then $boxtop=0

$box = ""
; Lesen der Boxposition, falls vorhanden
$data=IniReadSection(@AppDataDir & "\Symbolleiste\Symbolleiste.ini",$IniSection)
for $j = 1 to $data[0][0]
				
	if $data[$j][0]="box" Then
		$box=stringsplit($data[$j][1],",")
		$boxwidth = $box[1]	
		$boxhight = $box[2]	
		$boxleft = $box[3]
		$boxtop = $box[4]
		exitloop			; der For-schleife
	endif
next

if $box = "" Then
	$i=0
	$search=filefindfirstfile($Folder&"/*.*")
	While 1
		$file = FileFindNextFile($search) 
		If @error Then ExitLoop
		$i=$i+1
	WEnd

	$boxhight = $i*17+17
	$boxwidth = 150
	$boxleft = (@DesktopWidth-$boxwidth)/2
	$boxtop = (@DesktopHeight-$boxhight)/2
	if $boxtop<0 then $boxtop=0
		
	IniWrite(@AppDataDir & "\Symbolleiste\Symbolleiste.ini",$IniSection,"box",$boxhight &","& $boxwidth &","& $boxleft &","&	$boxtop )	
endif		


; Create Window

$WinHandel = GUICreate($Folder, $boxwidth, $boxhight, $boxleft, $boxtop, BitOR($GUI_SS_DEFAULT_GUI,$WS_SIZEBOX,$WS_THICKFRAME), _
                      BitOR($WS_EX_ACCEPTFILES,$WS_EX_TOOLWINDOW))

GUISetBkColor(0x464646)



$ListView1 = GUICtrlCreateListView("", 0, 0, $boxwidth, $boxhight, BitOR($GUI_SS_DEFAULT_LISTVIEW,$LVS_SMALLICON), BitOR($WS_EX_ACCEPTFILES,$LVS_EX_TRACKSELECT))
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetBkColor(-1, 0xEBEBEB)
GUICtrlSetResizing(-1, $GUI_DOCKAUTO+$GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKBOTTOM)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)


$ListItemName=_FileListToArray($Folder)


for $i = 1 to $ListItemName[0]
	
	$Showname = $ListItemName[$i]
	if StringRight($Showname,3)="lnk" Then 
		$Showname = StringLeft($Showname,Stringlen($Showname)-4)
	endif
	
	$ListView1_tmp = GUICtrlCreateListViewItem($Showname, $ListView1)
	_ArrayAdd($ListItemPtr,$ListView1_tmp)
	$FileName=$Folder & "\" & $ListItemName[$i]

	AddListViewIcon($ListView1_tmp,$FileName)

next



GUISetState(@SW_SHOW)

$FolderSize=DirGetSize($Folder,2)

AdlibRegister("detectfolderchanges",1000)

OnAutoItExitRegister("OnSymbolleisteExit")



While 1

 $nMsg = GUIGetMsg()
 if $nMsg<>0 then
	$x=_ArraySearch($ListItemPtr,$nMsg)
    if $x<>-1 then
		ShellExecute($Folder & "\" & $ListItemName[$x])

	endif
 endif

Switch $nMsg
	Case $GUI_EVENT_CLOSE
		Exit
	case $GUI_EVENT_SECONDARYUP
		shellexecute($Folder,"","","open")

	case $GUI_EVENT_DROPPED
		; cases:
		; Drive, File, Folder, LAN-Folder , Link on Folder, Link on Files, Link on LAN-Folder, Link on Webpage, Link on Drive, ClickOnce-Apps
		; Legacy -> PIF-Datei
		; multiple of those !
		; -> much work to do!
	
		$Dragname=@GUI_DRAGFILE
		$LinkExt=""
	
		Dim $szDrive, $szDir, $szFName, $szExt
		$SplitPath=_PathSplit($Dragname,$szDrive,$szDir,$szFName,$szExt)
	
	
		if ($SplitPath[4] = ".lnk") or ($SplitPath[4] = ".url") Then 
			$LinkExt=$SplitPath[4]
			$SplitPath[4]=""
		endif	
	
		$Newname=_PathMake("",$Folder,$SplitPath[3],$SplitPath[4])
	
		while FileExists($Newname & ".lnk") OR FileExists($Newname) 
			if StringRight($Newname,1)<>")" then
				$Newname = $Newname & " (2)"
			Elseif StringLeft(StringRight($newname,3),1)="(" and (number(StringRight($newname,2)) > 1) Then
				$Newname = StringLeft($Newname,StringLen($Newname)-2) & (number(StringRight($newname,2))+1) & ")"
			elseif StringLeft(StringRight($newname,4),1)="(" and (number(StringRight($newname,3)) > 9) Then
				$Newname = StringLeft($Newname,StringLen($Newname)-3) & (number(StringRight($newname,3))+1) & ")"
			Else
				$Newname = $Newname & " (2)"
			endif
		wend	
	
		if "D"=FileGetAttrib ( $Dragname ) Then
			consolewrite("D " & $Dragname)
			FileCreateShortcut($Dragname,$Newname,"","","","shell32.dll","",4)
		else	
			if $LinkExt <> "" Then 
				Filecopy($Dragname,$Newname & $LinkExt)
			Else
				FileCreateShortcut($Dragname,$Newname)
			endif	
		Endif
		
		$SplitPath=_PathSplit($Newname & $LinkExt,$szDrive,$szDir,$szFName,$szExt)
		
		$Showname= $SplitPath[3] & $SplitPath[4]
		
		_ArrayAdd($ListItemName,$Showname)
		
		if StringRight($Showname,3)="lnk" or StringRight($Showname,3)="url"Then 
			$Showname = StringLeft($Showname,Stringlen($Showname)-4)
		endif	
		
	
		_ArrayAdd($ListItemName,$Showname)
		
		$ListView1_tmp = GUICtrlCreateListViewItem($Showname, $ListView1)
		
		_ArrayAdd($ListItemPtr,$ListView1_tmp)

		ConsoleWrite("1 "&$Newname & $LinkExt & @LF)
		AddListViewIcon($ListView1_tmp,$Newname & $LinkExt)
		
	
	EndSwitch
WEnd

Func AddListViewIcon($ListView1_tmp,$FileName)
	    ConsoleWrite("2 "&$FileName & @LF)
		
		local $Iconname=""
		local $Iconindex=0
	
		while 1
		if StringRight($FileName,3)<>"lnk" Then         ; wenn kein Shortcur
			if "D"=FileGetAttrib ( $FileName ) Then     ; wenn Direktorie
				GUICtrlSetImage($ListView1_tmp, "shell32.dll", 4,2)
			else
				select
					case StringRight($FileName,3)="url" 
						$Iconname=IniRead($FileName,"InternetShortcut","IconFile","")
						ConsoleWrite("7 "&$Iconindex & @LF)
						ConsoleWrite("8 "&$FileName & @LF)
						$Iconindex=IniRead($FileName,"InternetShortcut","IconIndex","1")
						ConsoleWrite("6 "&$Iconindex & @LF)
						
						ConsoleWrite("3 "&stringmid($Iconname,2,2) & @LF)
						
						if (not FileExists($Iconname)) and (stringmid($Iconname,2,2) = ":\") Then
							$Iconname=""
						endif	
						
						if stringmid($Iconname,2,2) = ":\" then ; local gespeichertes Icon
							ConsoleWrite("5 "&$Iconindex & @LF)
							ConsoleWrite("8 "&$Iconname & @LF)
							if not GUICtrlSetImage($ListView1_tmp, $Iconname,-$Iconindex-1,2) Then
								$Symboldatei=_WinAPI_FindExecutable($FileName)
									ConsoleWrite("4 "&$Symboldatei & @LF)
								if $Symboldatei="" Then
									GUICtrlSetImage($ListView1_tmp, "shell32.dll",0,2)
								else	
									if not GUICtrlSetImage($ListView1_tmp, $Symboldatei,0,2) Then
										GUICtrlSetImage($ListView1_tmp, "shell32.dll",0,2)
									endif	
								endif	
							endif	
						else	
							if $Iconname <> "" Then
								
								$s_TempFile = _TempFile(@TempDir ,"S" & $IniSection & "_")
								$return=InetGet($Iconname,$s_TempFile)
								if $return=0 Then
									filedelete($s_tempFile)
									$Iconname=IniRead($FileName,"InternetShortcut","URL","")&"/favicon.ico"
									$s_TempFile = _TempFile(@TempDir ,"S" & $IniSection & "_")
									$return=InetGet($Iconname,$s_TempFile)
									if $return=0 Then
										filedelete($s_tempFile)
										$Iconname=""
									endif	
								endif
							endif	
							if $Iconname<>"" then
								GUICtrlSetImage($ListView1_tmp, $s_tempFile,-$Iconindex,2)
								filedelete($s_tempFile)
							Else
								$Symboldatei=_WinAPI_FindExecutable($FileName)
								if $Symboldatei="" Then
									GUICtrlSetImage($ListView1_tmp, "shell32.dll",0,2)
								else	
									if not GUICtrlSetImage($ListView1_tmp, $Symboldatei,0,2) Then
										GUICtrlSetImage($ListView1_tmp, "shell32.dll",0,2)
									endif	
								endif	
							endif	
						endif
						
					case else
						$Symboldatei=_WinAPI_FindExecutable($FileName)
						ConsoleWrite("4 "&$Symboldatei & @LF)
						if $Symboldatei="" Then
							GUICtrlSetImage($ListView1_tmp, "shell32.dll",0,2)
						else	
							if not GUICtrlSetImage($ListView1_tmp, $Symboldatei,0,2) Then
								GUICtrlSetImage($ListView1_tmp, "shell32.dll",0,2)
							endif	
						endif	
				endselect		
			endif	
			ExitLoop
		endif	
		
		Local $lnkarray = FileGetShortcut($FileName)
		
		if $lnkarray[4]<>"" Then                ; Shortcut enthält Symbol
 
			GUICtrlSetImage($ListView1_tmp, $lnkarray[4],-$lnkarray[5]-1,2)
			ExitLoop
		endif
		
		$FileName=$lnkarray[0]					; Symbol jetzt suchen, bei dem verlinkten Objekt
		
	wend
	
EndFunc

Func OnSymbolleisteExit()
	; Aufruf am Ende OnAutoItExitRegister("OnSymbolleisteExit")
	; @ExitMethod liefert:
	; 0 Natural closing. 
	; 1 close by Exit function. 
	; 2 close by clicking on exit of the systray. 
	; 3 close by user logoff. 
	; 4 close by Windows shutdown. 
	
	if (@ExitMethod = 3) or (@ExitMethod = 4) Then
		$WinPos=WinGetPos ( $WinHandel)
		
		$boxwidth=$WinPos[2]-8
		$boxhight=$WinPos[3]-26
		$boxleft=$WinPos[0]
		$boxtop=$WinPos[1]

		IniWrite(@AppDataDir & "\Symbolleiste\Symbolleiste.ini",$IniSection,"box",$boxwidth &","& $boxhight &","& $boxleft &","& $boxtop )	
	Else
		Inidelete(@AppDataDir & "\Symbolleiste\Symbolleiste.ini",$IniSection)
	endif	
	
EndFunc

Func detectfolderchanges()
	$newFolderSize=DirGetSize($Folder,2)
	if $FolderSize<>$newFolderSize Then
		$FolderSize=$newFolderSize
		GUICtrlDelete($ListView1)
		$ListView1 = GUICtrlCreateListView("", 0, 0, $boxwidth, $boxhight, BitOR($GUI_SS_DEFAULT_LISTVIEW,$LVS_SMALLICON), BitOR($WS_EX_ACCEPTFILES,$LVS_EX_TRACKSELECT))
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetBkColor(-1, 0xEBEBEB)
GUICtrlSetResizing(-1, $GUI_DOCKAUTO+$GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKBOTTOM)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)


$ListItemName=_FileListToArray($Folder)


for $i = 1 to $ListItemName[0]
	
	$Showname = $ListItemName[$i]
	if StringRight($Showname,3)="lnk" Then 
		$Showname = StringLeft($Showname,Stringlen($Showname)-4)
	endif
	
	$ListView1_tmp = GUICtrlCreateListViewItem($Showname, $ListView1)
	_ArrayAdd($ListItemPtr,$ListView1_tmp)
	$FileName=$Folder & "\" & $ListItemName[$i]

	AddListViewIcon($ListView1_tmp,$FileName)

next
	EndIf	
endfunc	