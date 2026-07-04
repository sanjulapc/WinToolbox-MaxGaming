' ===================================================================
'  Double-click to open the Windows Toolbox GUI with NO console window.
'  Keep this file in the SAME folder as WinToolbox.ps1.
'  It launches PowerShell hidden; the GUI then asks for Administrator
'  once and the elevated window is hidden too - you only see the app.
' ===================================================================
Dim sh, fso, scriptDir, ps1
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1 = scriptDir & "\WinToolbox.ps1"

If Not fso.FileExists(ps1) Then
    MsgBox "WinToolbox.ps1 was not found next to this launcher." & vbCrLf & _
           "Keep both files in the same folder.", vbExclamation, "Windows Toolbox"
    WScript.Quit
End If

sh.Run "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1 & """ -Gui", 0, False
