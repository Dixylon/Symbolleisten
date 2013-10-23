#NoTrayIcon

#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <WinAPI.au3>

Opt("GUICloseOnESC", 0)

; Parameter:
; kein Parameter -> Öffnet Dialog um Ordner auszuwählen
; Ziffer -> Öffnet Symbolleiste mit Parametern aus Section [Ziffer]
;	Fehler -> Dialog
; Pfad -> Öffnet neue Symbolleiste zu dem Ordner.
; 	Fehler -> Dialog


; Begin Sprach-Objekt Schlüssel S
; Funktionen: _SetLanguage($S_prache)
; $_S[$_S_....] für die Textbausteine

Global ENUM $dS=0, _		; Deutsch
	$eS, _					; Englisch
	$xS_last
Global ENUM	$_S_Fehler=0, _
	$_S_zu_viele_Parameter, _
	$_S_keine_gueltigen_Daten, _
	$_S_Datei_existiert_nicht, _
	$_S_Fehler_in_der_Komandozeile, _
	$_S_Ordner_waehlen, _
	$_S_Ordner_oeffnen, _
	$_S_wirklich_loeschen, _
	$_S_neuen_Namen, _
	$_S_Loeschen, _
	$_S_Umbenennen, _
	$_S_Abbrechen, _
	$_S_Info, _
	$_S_Info_Text, _
	$_S_ini_Datei_oeffnen, _
	$_S_neue_Symbolleiste, _
	$_S_Sprachewechsel, _
	$_S_Name_existiert, _
	$_S_Installieren, _
	$_S_neu_zeichnen, _
	$_S_last

Global $_Sx[$xS_last][$_S_last]

$_Sx[$dS][$_S_Fehler]="Fehler"
$_Sx[$eS][$_S_Fehler]="Error"
$_Sx[$dS][$_S_zu_viele_Parameter]="zu viele Parameter"
$_Sx[$eS][$_S_zu_viele_Parameter]="to many parameter"
$_Sx[$dS][$_S_keine_gueltigen_Daten]="Keine gültigen Daten im Parametersatz Nr %s in der ini.-Datei!"
$_Sx[$eS][$_S_keine_gueltigen_Daten]="No valid date in parameterset %s in ini.-file!"
$_Sx[$dS][$_S_Datei_existiert_nicht]="Dateiordner %s im Parametersatz in der ini.-Datei exisitiert nicht!"
$_Sx[$eS][$_S_Datei_existiert_nicht]="Folder %s in the parameterset in ini.-file do not exist!"
$_Sx[$dS][$_S_Fehler_in_der_Komandozeile]="Parameter aus der Komandozeile ist weder ein gültiger Abschnitsname noch ein gültiger Filename!"
$_Sx[$eS][$_S_Fehler_in_der_Komandozeile]="Parameter from Comandline is neither a valid Section nor a valid filename!"

$_Sx[$dS][$_S_Ordner_waehlen]="Bitte einen Ordner wählen!"
$_Sx[$eS][$_S_Ordner_waehlen]="Please choose a folder!"
$_Sx[$dS][$_S_Ordner_oeffnen]="Ordner öffnen"
$_Sx[$eS][$_S_Ordner_oeffnen]="Open Folder"
$_Sx[$dS][$_S_wirklich_loeschen]="wirklich löschen?"
$_Sx[$eS][$_S_wirklich_loeschen]="Do you realy want to delete?"
$_Sx[$dS][$_S_neuen_Namen]="Bitte neuen Namen eingeben!"
$_Sx[$eS][$_S_neuen_Namen]="Please gave a new Name!"
$_Sx[$dS][$_S_Loeschen]="Löschen"
$_Sx[$eS][$_S_Loeschen]="Delete"
$_Sx[$dS][$_S_Umbenennen]="Umbenennen"
$_Sx[$eS][$_S_Umbenennen]="Rename"
$_Sx[$dS][$_S_Abbrechen]="Abbrechen"
$_Sx[$eS][$_S_Abbrechen]="Cancel"
$_Sx[$dS][$_S_Info]="Info"
$_Sx[$eS][$_S_Info]="About"
$_Sx[$dS][$_S_Info_Text]="myToolbar 2.1" & @CRLF & @CRLF & "programmiert von" & @CRLF & "Dirk Schomburg" & @CRLF & "d.schomburg@gmx.net"
$_Sx[$eS][$_S_Info_Text]="myToolbar 2.1" & @CRLF & @CRLF & "programed by" & @CRLF & "Dirk Schomburg" & @CRLF & "d.schomburg@gmx.net"
$_Sx[$dS][$_S_ini_Datei_oeffnen]=".ini-Datei öffnen"
$_Sx[$eS][$_S_ini_Datei_oeffnen]="Open .ini-File"
$_Sx[$dS][$_S_neue_Symbolleiste]="neue Symbolleiste öffnen"
$_Sx[$eS][$_S_neue_Symbolleiste]="Open new Toolbar"
$_Sx[$dS][$_S_Sprachewechsel]="change to english"
$_Sx[$eS][$_S_Sprachewechsel]="wechseln zu Deutsch"
$_Sx[$dS][$_S_Name_existiert]="Name existiert schon"
$_Sx[$eS][$_S_Name_existiert]="Name exist already"
$_Sx[$dS][$_S_Installieren]="Installieren"
$_Sx[$eS][$_S_Installieren]="Install"
$_Sx[$dS][$_S_neu_zeichnen]="neu zeichnen"
$_Sx[$eS][$_S_neu_zeichnen]="repaint"

Global $_S[$_S_last]
Global $_S_GUI_Sprache

Func _S_SetLanguage($Sprache)
	local $i=0
	for $i=0 to $_S_last-1
		$_S[$i]=$_Sx[$Sprache][$i]
	Next
	$_S_GUI_Sprache = $Sprache
EndFunc

; falls ini-file existiert dann
; [optionen]
; language=<Sprache>
; <Sprache> ist de oder en

Func _S_SetLanguage_from_inifile($inifile)
	If FileExists($inifile) Then
		$Sectionnames=IniReadSectionNames ($inifile)
		if -1 <> _ArraySearch($Sectionnames,"options") Then
			switch IniRead ($inifile, "options", "language", "de" )
				case "de"
					_S_SetLanguage($dS)
				case "en"
					_S_SetLanguage($eS)
				case Else
					_S_SetLanguage($eS)
			EndSwitch
		EndIf
	endif
endfunc

Func _S_WriteLanguage_into_inifile($inifile)
	If Not FileExists(@AppDataDir & "\Symbolleiste") Then
		DirCreate(@AppDataDir & "\Symbolleiste")
	EndIf
	switch $_S_GUI_Sprache
		case $dS
			IniWrite($inifile, "options", "language", "de")
		case $eS
			IniWrite($inifile, "options", "language", "en")
	endswitch
endfunc

; Ende Sprach-Objekt

; -----------------------------------
; Beginn Hauptprogramm
; -----------------------------------

_S_SetLanguage($dS)

_S_SetLanguage_from_inifile(@AppDataDir & "\Symbolleiste\Symbolleiste.ini")

; in Win7 @AppDataDir wird ersetzt durch C:\Users\<AnmeldeName>\AppData\Roaming
; in der deutschen Version steht für Users auch Benutzer
If Not FileExists(@AppDataDir & "\Symbolleiste") Then
	DirCreate(@AppDataDir & "\Symbolleiste")
	IniWrite(@AppDataDir & "\Symbolleiste\Symbolleiste.ini", "1", "state", "free")
EndIf

Local $Folder = ""
Local $IniSection = 0
Local $FolderSize = 0

If $CmdLine[0] > 1 Then
	MsgBox(1, $_S[$_S_Fehler], $_S[$_S_zu_viele_Parameter])
EndIf

If $CmdLine[0] = 1 Then

	if $CmdLine[1]="-autorestore" Then
		if not FileExists(@AppDataDir & "\Symbolleiste\Symbolleiste.ini") then ; kein Ini-File
			ShellExecute(@ScriptFullPath)
			exit
		endif

		$data=IniReadSectionNames(@AppDataDir & "\Symbolleiste\Symbolleiste.ini")

		if not @error then
			if $data[0] = 1 Then ; ini-File nur mit option-Section
				if $data[1]="options" Then
					ShellExecute(@ScriptFullPath)
					exit
				EndIf
			endif

			if $data[0] > 0 then ; ini-File mit ToolBar-Sections
				for $j = 1 to $data[0]
					if $data[$j]<>"options" Then
						ShellExecute(@ScriptFullPath,$data[$j])
					endif
				next
			EndIf
		EndIf
		exit
	endif

	; test, ob Parameter ist ein Sectionsname
	$data = IniReadSectionNames(@AppDataDir & "\Symbolleiste\Symbolleiste.ini")

	For $j = 1 To $data[0]
		If $data[$j] = $CmdLine[1] Then
			If IniRead(@AppDataDir & "\Symbolleiste\Symbolleiste.ini", $CmdLine[1], "state", "free") <> "used" Then
				MsgBox(1, $_S[$_S_Fehler], StringFormat($_S[$_S_keine_gueltigen_Daten], $data[$j]))
				Exit
			EndIf
			$IniSection = $CmdLine[1]
			$IniFolder = IniRead(@AppDataDir & "\Symbolleiste\Symbolleiste.ini", $CmdLine[1], "folder", "nul:")
			If FileExists($IniFolder) Then
				$Folder = $IniFolder
				ExitLoop
			Else
				MsgBox(1, $_S[$_S_Fehler], StringFormat($_S[$_S_Datei_existiert_nicht],$IniFolder))
				Exit
			EndIf
		EndIf
	Next

	If $IniSection = 0 Then ; Falls Parameter keine Section


		If myFileExists($CmdLine[1]) Then
			; Aufruf mit Dateinamen
			$Folder = _PathFull($CmdLine[1])

		Else ; Parameter ist auch kein Dateiname´

				MsgBox(1, $_S[$_S_Fehler], $_S[$_S_Fehler_in_der_Komandozeile])
				Exit

		EndIf
	EndIf


Else ; no Comandlineparameter

	$PickstartFolder="G:\Symbolleisten"

	If Not myFileExists($PickstartFolder) Then
		$PickstartFolder=@ScriptDir
	endif

	$Folder = FileSelectFolder($_S[$_S_Ordner_waehlen], "", 0, $PickstartFolder)
	If $Folder = "" Then Exit

EndIf


If $IniSection = 0 Then ; falls Name aus Parametern oder aus dem Dialog


	; Suchen einer Nummer für die Section
	$i = 1 ; Zähler
	While 1
		$data = IniReadSection(@AppDataDir & "\Symbolleiste\Symbolleiste.ini", $i)
		If @error <> 1 Then
			For $j = 1 To $data[0][0]
				; Wenn in den Werten der Section eingetragen ist: state=free, wird dies die Section für diese Symbolleiste
				If $data[$j][0] = "state" And $data[$j][1] = "free" Then
					$IniSection = $i
					ExitLoop ; der For-schleife
				EndIf
			Next
			If $IniSection <> 0 Then ; Falls eine Lücke frei ist
				ExitLoop ; der while-Schleife
			EndIf
		Else
			; Sobald beim hochzählen ein wert erreicht wird, für den keine Section vorhanden ist, wird dies die Section für diese symbolleiste
			IniWrite(@AppDataDir & "\Symbolleiste\Symbolleiste.ini", $i, "state", "free")
			$IniSection = $i
			ExitLoop ; der while-Schleife
		EndIf
		ConsoleWrite($i)
		$i = $i + 1
	WEnd
	IniWrite(@AppDataDir & "\Symbolleiste\Symbolleiste.ini", $IniSection, "state", "used")
	IniWrite(@AppDataDir & "\Symbolleiste\Symbolleiste.ini", $IniSection, "folder", """" & $Folder & """")

EndIf


Local $boxleft, $boxtop, $boxwidth, $boxhight

Local $ListItemPtr[1] = [0]
Local $ListItemDelete[1] = [0]
Local $ListItemRename[1] = [0]
Local $ListItemName[1] = [0]
Local $ItemAnzahl

local $ListView1=0


$i = 0
$search = FileFindFirstFile($Folder & "\*.*")
While 1
	$file = FileFindNextFile($search)
	If @error Then ExitLoop
	$i = $i + 1
WEnd

$boxhight = $i * 17 + 17
$boxwidth = 150
$boxleft = (@DesktopWidth - $boxwidth) / 2
$boxtop = (@DesktopHeight - $boxhight) / 2
If $boxtop < 0 Then $boxtop = 0

$box = ""
; Lesen der Boxposition, falls vorhanden
$data = IniReadSection(@AppDataDir & "\Symbolleiste\Symbolleiste.ini", $IniSection)
For $j = 1 To $data[0][0]

	If $data[$j][0] = "box" Then
		$box = StringSplit($data[$j][1], ",")
		$boxwidth = $box[1]
		$boxhight = $box[2]
		$boxleft = $box[3]
		$boxtop = $box[4]
		ExitLoop ; der For-schleife
	EndIf
Next

If $box = "" Then
	$i = 0
	$search = FileFindFirstFile($Folder & "\*.*")
	While 1
		$file = FileFindNextFile($search)
		If @error Then ExitLoop
		$i = $i + 1
	WEnd

	$boxhight = $i * 17 + 17
	$boxwidth = 150
	$boxleft = (@DesktopWidth - $boxwidth) / 2
	$boxtop = (@DesktopHeight - $boxhight) / 2
	If $boxtop < 0 Then $boxtop = 0

	IniWrite(@AppDataDir & "\Symbolleiste\Symbolleiste.ini", $IniSection, "box", $boxhight & "," & $boxwidth & "," & $boxleft & "," & $boxtop)
EndIf


; Create Window

Local $szDrive, $szDir, $szFName, $szExt
Local $TestPath = _PathSplit($Folder, $szDrive, $szDir, $szFName, $szExt)

if $szExt <>"" Then
	$szFName=$szFName&"."&$szExt
endif

$WinHandel = GUICreate($szFName, $boxwidth, $boxhight, $boxleft, $boxtop, BitOR($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_THICKFRAME), _
		BitOR($WS_EX_ACCEPTFILES,$WS_EX_TOOLWINDOW)) ; ohne $WS_EX_ACCEPTFILES werden keine Drops akzeptiert
$WinPos = WinGetPos($WinHandel)

$windeltax=$boxwidth - $WinPos[2]
$windeltay=$boxhight - $WinPos[3]

GUISetBkColor(0x464646)

Local $contextmenu = GUICtrlCreateContextMenu()
$mnunewBar=GUICtrlCreateMenuItem($_S[$_S_neue_Symbolleiste], $contextmenu)
			GUICtrlCreateMenuItem("", $contextmenu)
$mnuOpen=GUICtrlCreateMenuItem($_S[$_S_Ordner_oeffnen], $contextmenu)
$mnuiniOpen=GUICtrlCreateMenuItem($_S[$_S_ini_Datei_oeffnen], $contextmenu)
$mnulanguage=GUICtrlCreateMenuItem($_S[$_S_Sprachewechsel], $contextmenu)
			GUICtrlCreateMenuItem("", $contextmenu)
$mnurepaint=GUICtrlCreateMenuItem($_S[$_S_neu_zeichnen], $contextmenu)
$mnuInstall=GUICtrlCreateMenuItem($_S[$_S_Installieren], $contextmenu)
			GUICtrlCreateMenuItem("", $contextmenu)
$mnuAbout=GUICtrlCreateMenuItem($_S[$_S_Info], $contextmenu)




GUISetState(@SW_SHOW)

buildListView()

$FolderSize = DirGetSize($Folder, 2)

GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")

AdlibRegister("detectfolderchanges", 1000)

OnAutoItExitRegister("OnSymbolleisteExit")

While 1

	$nMsg = GUIGetMsg()
	If $nMsg <> 0 Then
		$x = _ArraySearch($ListItemPtr, $nMsg)

		If $x <> -1 Then
			ShellExecute($Folder & "\" & $ListItemName[$x])
			continueloop
		EndIf

		$x = _ArraySearch($ListItemDelete, $nMsg)
		If $x <> -1 Then
			if 1=msgbox(1,$_S[$_S_wirklich_loeschen],$ListItemName[$x]) Then
				FileDelete($Folder & "\" & $ListItemName[$x])
				GUICtrlDelete($ListView1)
				buildListView()
			endif
			Continueloop
		EndIf

		$x = _ArraySearch($ListItemRename, $nMsg)
		If $x <> -1 Then
			$newName=InputBox( $_S[$_S_neuen_Namen], " ", $ListItemName[$x] ,"",300,115)
			if $newName<>"" Then
				if FileExists($Folder & "\" & $newName) Then
					msgbox(0,$_S[$_S_Fehler],$_S[$_S_Name_existiert])
				else
					Filemove($Folder & "\" & $ListItemName[$x],$Folder & "\" & $newName)
					GUICtrlDelete($ListView1)
					buildListView()
				endif
			endif
			continueloop
		EndIf

	EndIf

	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

		case $mnuOpen
			ShellExecute($Folder, "", "", "open")

		case $mnuiniOpen
			ShellExecute( @AppDataDir & "\Symbolleiste\Symbolleiste.ini", "", "", "open")

		case $mnunewBar
			ShellExecute( @ScriptFullPath, "", "", "open")

		case $mnuAbout
			msgbox(0,$_S[$_S_Info],$_S[$_S_Info_Text])

		case $mnulanguage
			if $_S_GUI_Sprache=$dS Then
				_S_SetLanguage($eS)
			else
				_S_SetLanguage($dS)
			endif
			_S_WriteLanguage_into_inifile( @AppDataDir & "\Symbolleiste\Symbolleiste.ini")

			$WinPos = WinGetPos($WinHandel)

			$boxwidth = $WinPos[2] + $windeltax
			$boxhight = $WinPos[3] + $windeltay
			$boxleft = $WinPos[0]
			$boxtop = $WinPos[1]

			IniWrite(@AppDataDir & "\Symbolleiste\Symbolleiste.ini", $IniSection, "box", $boxwidth & "," & $boxhight & "," & $boxleft & "," & $boxtop)

			ShellExecute(@ScriptFullPath,$IniSection)

			Sleep(100)

			$_S_GUI_Sprache = -1

			exit

		case $mnurepaint
			GUICtrlDelete($ListView1)
			buildListView()

		case $mnuInstall

			FileDelete(@StartupDir & "\" & @ScriptName)

			FileCreateShortcut ( @ScriptFullPath , @StartupDir & "\" & @ScriptName , @ScriptDir , "-autorestore")

	;	case $GUI_EVENT_PRIMARYDOWN




		Case $GUI_EVENT_DROPPED
			; cases:
			; Drive, File, Folder, LAN-Folder , Link on Folder, Link on Files, Link on LAN-Folder, Link on Webpage, Link on Drive, ClickOnce-Apps
			; Legacy -> PIF-Datei
			; multiple of those !
			; -> much work to do!

			$Dragname = @GUI_DragFile

			$LinkExt = ""

			Dim $szDrive, $szDir, $szFName, $szExt
			$SplitPath = _PathSplit($Dragname, $szDrive, $szDir, $szFName, $szExt)


			if ($SplitPath[4] = ".lnk") or ($SplitPath[4] = ".url") Then
				$LinkExt = $SplitPath[4]
				$SplitPath[4] = ""
			EndIf

			$Newname = _PathMake("", $Folder, $SplitPath[3], $SplitPath[4])

			While FileExists($Newname & ".lnk") Or FileExists($Newname)
				If StringRight($Newname, 1) <> ")" Then
					$Newname = $Newname & " (2)"
				ElseIf StringLeft(StringRight($Newname, 3), 1) = "(" and (Number(StringRight($Newname, 2)) > 1) Then
					$Newname = StringLeft($Newname, StringLen($Newname) - 2) & (Number(StringRight($Newname, 2)) + 1) & ")"
				ElseIf StringLeft(StringRight($Newname, 4), 1) = "(" and (Number(StringRight($Newname, 3)) > 9) Then
					$Newname = StringLeft($Newname, StringLen($Newname) - 3) & (Number(StringRight($Newname, 3)) + 1) & ")"
				Else
					$Newname = $Newname & " (2)"
				EndIf
			WEnd

			If "D" = FileGetAttrib($Dragname) Then
				ConsoleWrite("D " & $Dragname)
				FileCreateShortcut($Dragname, $Newname, "", "", "", "shell32.dll", "", 4)
			Else
				If $LinkExt <> "" Then
					FileCopy($Dragname, $Newname & $LinkExt)
				Else
					FileCreateShortcut($Dragname, $Newname)
				EndIf
			EndIf

			GUICtrlDelete($ListView1)
			buildListView()

	EndSwitch
WEnd

; Diese Funktion reagiert auf Enter und startet dann die Anwendung zu dem entsprechendem Listeintrag
Func MY_WM_COMMAND($hWnd, $Msg, $wParam, $lParam)
	Local $nNotifyCode = BitShift($wParam, 16)
	Local $nID = BitAND($wParam, 0x0000FFFF)
	Local $hCtrl = $lParam

	If $nID <> 2 And $nNotifyCode = 0 Then ; Check for IDCANCEL - 2
		; Ownerdrawn buttons don't send something by pressing ENTER
		; So IDOK - 1 comes up, now check for the control that has the current focus
		If $nID = 1 Then
			$selected= GUICtrlRead ($ListView1)

			;msgbox(0,"!",$selected)

			$x = _ArraySearch($ListItemPtr,$selected)

			If $x <> -1 Then
				ShellExecute($Folder & "\" & $ListItemName[$x])
		    EndIf
			return 0
		EndIf

	EndIf
	; Proceed the default AutoIt3 internal message commands.
	; You also can complete let the line out.
	; !!! But only 'Return' (without any value) will not proceed
	; the default AutoIt3-message in the future !!!
	Return $GUI_RUNDEFMSG
EndFunc   ;==>MY_WM_COMMAND



Func AddListViewIcon($ListView1_tmp, $FileName)
	ConsoleWrite("2 " & $FileName & @LF)

	Local $Iconname = ""
	Local $Iconindex = 0

	While 1
		If StringRight($FileName, 3) <> "lnk" Then ; wenn kein Shortcur
			If "D" = FileGetAttrib($FileName) Then ; wenn Direktorie
				GUICtrlSetImage($ListView1_tmp, "shell32.dll", 4, 2)
			Else
				Select
					Case StringRight($FileName, 3) = "url"
						$Iconname = IniRead($FileName, "InternetShortcut", "IconFile", "")
						ConsoleWrite("7 " & $Iconindex & @LF)
						ConsoleWrite("8 " & $FileName & @LF)
						$Iconindex = IniRead($FileName, "InternetShortcut", "IconIndex", "1")
						ConsoleWrite("6 " & $Iconindex & @LF)

						ConsoleWrite("3 " & StringMid($Iconname, 2, 2) & @LF)

						if (Not myFileExists($Iconname)) and (StringMid($Iconname, 2, 2) = ":\") Then
							$Iconname = ""
						EndIf

						If StringMid($Iconname, 2, 2) = ":\" Then ; local gespeichertes Icon
							ConsoleWrite("5 " & $Iconindex & @LF)
							ConsoleWrite("8 " & $Iconname & @LF)
							If Not GUICtrlSetImage($ListView1_tmp, $Iconname, -$Iconindex - 1, 2) Then
								$Symboldatei = _WinAPI_FindExecutable($FileName)
								ConsoleWrite("4 " & $Symboldatei & @LF)
								If $Symboldatei = "" Then
									GUICtrlSetImage($ListView1_tmp, "shell32.dll", 0, 2)
								Else
									If Not GUICtrlSetImage($ListView1_tmp, $Symboldatei, 0, 2) Then
										GUICtrlSetImage($ListView1_tmp, "shell32.dll", 0, 2)
									EndIf
								EndIf
							EndIf
						Else
							If $Iconname <> "" Then

								$s_TempFile = _TempFile(@TempDir, "S" & $IniSection & "_")
								$return = InetGet($Iconname, $s_TempFile)
								If $return = 0 Then
									FileDelete($s_TempFile)
									$Iconname = IniRead($FileName, "InternetShortcut", "URL", "") & "/favicon.ico"
									$s_TempFile = _TempFile(@TempDir, "S" & $IniSection & "_")
									$return = InetGet($Iconname, $s_TempFile)
									If $return = 0 Then
										FileDelete($s_TempFile)
										$Iconname = ""
									EndIf
								EndIf
							EndIf
							If $Iconname <> "" Then
								GUICtrlSetImage($ListView1_tmp, $s_TempFile, -$Iconindex, 2)
								FileDelete($s_TempFile)
							Else
								$Symboldatei = _WinAPI_FindExecutable($FileName)
								If $Symboldatei = "" Then
									GUICtrlSetImage($ListView1_tmp, "shell32.dll", 0, 2)
								Else
									If Not GUICtrlSetImage($ListView1_tmp, $Symboldatei, 0, 2) Then
										GUICtrlSetImage($ListView1_tmp, "shell32.dll", 0, 2)
									EndIf
								EndIf
							EndIf
						EndIf

					Case Else
						$Symboldatei = _WinAPI_FindExecutable($FileName)
						ConsoleWrite("4 " & $Symboldatei & @LF)
						If $Symboldatei = "" Then
							GUICtrlSetImage($ListView1_tmp, "shell32.dll", 0, 2)
						Else
							If Not GUICtrlSetImage($ListView1_tmp, $Symboldatei, 0, 2) Then
								GUICtrlSetImage($ListView1_tmp, "shell32.dll", 0, 2)
							EndIf
						EndIf
				EndSelect
			EndIf
			ExitLoop
		EndIf

		Local $lnkarray = FileGetShortcut($FileName)

		If $lnkarray[4] <> "" Then ; Shortcut enthält Symbol

			GUICtrlSetImage($ListView1_tmp, $lnkarray[4], -$lnkarray[5] - 1, 2)
			ExitLoop
		EndIf

		$FileName = $lnkarray[0] ; Symbol jetzt suchen, bei dem verlinkten Objekt

	WEnd

EndFunc   ;==>AddListViewIcon

Func OnSymbolleisteExit()
	; Aufruf am Ende OnAutoItExitRegister("OnSymbolleisteExit")
	; @ExitMethod liefert:
	; 0 Natural closing.
	; 1 close by Exit function.
	; 2 close by clicking on exit of the systray.
	; 3 close by user logoff.
	; 4 close by Windows shutdown.

	if $_S_GUI_Sprache=-1 Then
		Exit
	Else

		if (@exitMethod = 3) or (@exitMethod = 4) Then
			$WinPos = WinGetPos($WinHandel)

			$boxwidth = $WinPos[2] + $windeltax
			$boxhight = $WinPos[3] + $windeltay
			$boxleft = $WinPos[0]
			$boxtop = $WinPos[1]

			IniWrite(@AppDataDir & "\Symbolleiste\Symbolleiste.ini", $IniSection, "box", $boxwidth & "," & $boxhight & "," & $boxleft & "," & $boxtop)
		Else
			IniDelete(@AppDataDir & "\Symbolleiste\Symbolleiste.ini", $IniSection)
		EndIf
	endif

EndFunc   ;==>OnSymbolleisteExit

Func detectfolderchanges()

	$newFolderSize = DirGetSize($Folder, 2)
	If $FolderSize <> $newFolderSize Then
		$FolderSize = $newFolderSize

		GUICtrlDelete($ListView1)
		buildListView()
	endif

endfunc


Func buildListView()

		$WinPos = WinGetPos($WinHandel)
		$boxwidthx = $WinPos[2] - 8
		$boxhightx = $WinPos[3] - 26

		$ListView1 = GUICtrlCreateListView("", 0, 0, $boxwidthx, $boxhightx, BitOR($GUI_SS_DEFAULT_LISTVIEW, $LVS_SMALLICON),0) ; BitOR($WS_EX_ACCEPTFILES, 0)) ; $LVS_EX_TRACKSELECT))
		GUICtrlSetColor(-1, 0x000000)
		GUICtrlSetBkColor(-1, 0xEBEBEB)
		GUICtrlSetResizing(-1, $GUI_DOCKAUTO + $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM)
		GUICtrlSetState(-1, $GUI_DROPACCEPTED)

		$ListItemName = _FileListToArray($Folder)

        dim $ListItemPtr[1] = [0]
        dim $ListItemDelete[1] = [0]
		dim $ListItemRename[1] = [0]

		For $i = 1 To $ListItemName[0]

			$Showname = $ListItemName[$i]
			If StringRight($Showname, 3) = "lnk" Then
				$Showname = StringLeft($Showname, StringLen($Showname) - 4)
			EndIf

			$ListView1_tmp = GUICtrlCreateListViewItem($Showname, $ListView1)
			_ArrayAdd($ListItemPtr, $ListView1_tmp)
			$FileName = $Folder & "\" & $ListItemName[$i]

			AddListViewIcon($ListView1_tmp, $FileName)

			Local $LVcontextmenu = GUICtrlCreateContextMenu($ListView1_tmp)
			$ListView1_tmp_Del=GUICtrlCreateMenuItem($_S[$_S_Loeschen], $LVcontextmenu)
			$ListView1_tmp_Ren=GUICtrlCreateMenuItem($_S[$_S_Umbenennen], $LVcontextmenu)
			_ArrayAdd($ListItemDelete, $ListView1_tmp_Del)
			_ArrayAdd($ListItemRename, $ListView1_tmp_Ren)

		Next



EndFunc   ;==>buildlistview

func myFileExists($Path)
	$drive = Stringleft($Path,2) & "\"
	if "READY" = DriveStatus ($drive) Then
		return fileexists($Path)
	Else
		return False
	EndIf
endfunc

