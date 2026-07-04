' ===================================================================
'  Double-click to open the WinToolbox HUB with NO console window.
'  Keep this file in the SAME folder as WinToolbox-Hub.ps1.
'  The hub needs no admin - each toolbox asks for admin itself when run.
' ===================================================================
Dim sh, fso, scriptDir, ps1
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1 = scriptDir & "\WinToolbox-Hub.ps1"

If Not fso.FileExists(ps1) Then
    MsgBox "WinToolbox-Hub.ps1 was not found next to this launcher." & vbCrLf & _
           "Keep both files in the same folder.", vbExclamation, "WinToolbox Hub"
    WScript.Quit
End If

sh.Run "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1 & """", 0, False
