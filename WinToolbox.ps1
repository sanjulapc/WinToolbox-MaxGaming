#Requires -Version 5.1
<#
================================================================================
  WinToolbox-Hub.ps1  -  front-door launcher (white "gaming" GUI)
--------------------------------------------------------------------------------
  A tiny bootstrapper that sits in FRONT of the two toolboxes. For each one it
  gives you a DOWNLOAD button (pulls the latest copy from your GitHub repo) and
  a RUN button (launches it). Neither toolbox is modified - this only fetches
  and starts them.

    * WinToolbox            -> WinToolbox.ps1        (30-tool gaming GUI)
    * God Server All-In-One -> GodServer-AllInOne.bat (debloat / tweaks / etc.)

  The hub itself needs NO admin - each toolbox asks for admin on its own when
  you run it.

  Run it:
     double-click  WinToolbox-Hub.vbs
     -- or --      powershell -NoProfile -ExecutionPolicy Bypass -File .\WinToolbox-Hub.ps1
================================================================================
#>

# ==============================  CONFIGURE ME  ==============================
#  Put your GitHub details here ONCE. The Download buttons build URLs like:
#     https://raw.githubusercontent.com/<User>/<Repo>/<Branch>/<file>
$GH = @{
    User   = 'sanjulapc'                 # <-- your GitHub username
    Repo   = 'WinToolbox-MaxGaming'       # <-- your repo
    Branch = 'main'
}
# ===========================================================================

# Files this launcher knows how to download / run.
$Managed = @(
    [pscustomobject]@{
        Key   = 'WinToolbox'
        Title = 'WinToolbox  -  Max Gaming'
        Desc  = '30-tool Windows 10/11 gaming optimizer. Full WinForms GUI, MAX button, all tweaks reversible.'
        File  = 'WinToolbox.ps1'
        Kind  = 'ps1'
    },
    [pscustomobject]@{
        Key   = 'GodServer'
        Title = 'God Server  -  All-In-One'
        Desc  = 'Debloat, EXM tweaks, GOD MODE, process killer & BIOS tweaker in one batch menu.'
        File  = 'GodServer-AllInOne.bat'
        Kind  = 'bat'
    }
)
# Extra files that "Get everything" grabs alongside the two above.
$ExtraFiles = @('WinToolbox-GUI.vbs', 'WinToolbox-Hub.vbs', 'README.md')

# ---------------------------------------------------------------------------
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Colour palette - white / blue "professional gaming"
$C = @{
    FormBg    = [System.Drawing.Color]::FromArgb(241, 245, 249)   # slate-100
    Card      = [System.Drawing.Color]::FromArgb(255, 255, 255)
    CardEdge  = [System.Drawing.Color]::FromArgb(226, 232, 240)   # slate-200
    Shadow    = [System.Drawing.Color]::FromArgb(222, 227, 236)
    HdrTop    = [System.Drawing.Color]::FromArgb(37, 99, 235)      # blue-600
    HdrBot    = [System.Drawing.Color]::FromArgb(29, 62, 156)      # blue-900-ish
    Ink       = [System.Drawing.Color]::FromArgb(15, 23, 42)       # slate-900
    Sub       = [System.Drawing.Color]::FromArgb(100, 116, 139)    # slate-500
    Blue      = [System.Drawing.Color]::FromArgb(37, 99, 235)
    BlueDark  = [System.Drawing.Color]::FromArgb(29, 78, 216)      # blue-700
    BlueTint  = [System.Drawing.Color]::FromArgb(239, 244, 255)
    Green     = [System.Drawing.Color]::FromArgb(22, 163, 74)
    Amber     = [System.Drawing.Color]::FromArgb(217, 119, 6)
    Muted     = [System.Drawing.Color]::FromArgb(226, 232, 240)
    MutedInk  = [System.Drawing.Color]::FromArgb(148, 163, 184)
    Dark      = [System.Drawing.Color]::FromArgb(15, 23, 42)
    LineGray  = [System.Drawing.Color]::FromArgb(203, 213, 225)
    SlateInk  = [System.Drawing.Color]::FromArgb(71, 85, 105)
    White      = [System.Drawing.Color]::White
    FootHover = [System.Drawing.Color]::FromArgb(248, 250, 252)
}

# Shared state so click handlers can reach controls regardless of scope.
$script:Hub = @{ Dir = $null; Status = $null; Cards = @{}; Version = 'v1.0' }

# ---------- small drawing helpers ----------
function New-RoundRect {
    param([int]$x, [int]$y, [int]$w, [int]$h, [int]$r)
    $d = $r * 2
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.AddArc($x, $y, $d, $d, 180, 90)
    $p.AddArc(($x + $w - $d), $y, $d, $d, 270, 90)
    $p.AddArc(($x + $w - $d), ($y + $h - $d), $d, $d, 0, 90)
    $p.AddArc($x, ($y + $h - $d), $d, $d, 90, 90)
    $p.CloseFigure()
    return $p
}

function Set-DoubleBuffered {
    param($ctrl)
    try {
        $pi = [System.Windows.Forms.Control].GetProperty('DoubleBuffered',
              [System.Reflection.BindingFlags]'Instance,NonPublic')
        $pi.SetValue($ctrl, $true, $null)
    } catch {}
}

# ---------- fonts ----------
$F = @{
    Title   = New-Object System.Drawing.Font('Segoe UI', 24, [System.Drawing.FontStyle]::Bold)
    Tag     = New-Object System.Drawing.Font('Segoe UI Semibold', 8.5, [System.Drawing.FontStyle]::Bold)
    Greet   = New-Object System.Drawing.Font('Segoe UI', 11.5)
    Small   = New-Object System.Drawing.Font('Segoe UI', 8.5)
    CardTtl = New-Object System.Drawing.Font('Segoe UI Semibold', 13.5, [System.Drawing.FontStyle]::Bold)
    CardDsc = New-Object System.Drawing.Font('Segoe UI', 9.5)
    Status  = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5, [System.Drawing.FontStyle]::Bold)
    Btn     = New-Object System.Drawing.Font('Segoe UI Semibold', 10.5, [System.Drawing.FontStyle]::Bold)
    Foot    = New-Object System.Drawing.Font('Segoe UI Semibold', 9, [System.Drawing.FontStyle]::Bold)
}

# ===========================================================================
#  Pill button (self-painted panel: rounded, hover, enabled/disabled states)
# ===========================================================================
function New-Pill {
    param(
        [string]$Text, [int]$X, [int]$Y, [int]$W, [int]$H,
        [System.Drawing.Color]$Fill, [System.Drawing.Color]$FillHover,
        [System.Drawing.Color]$Fore, [System.Drawing.Color]$Bg,
        [scriptblock]$OnClick, [switch]$Outline, [System.Drawing.Font]$Font
    )
    if (-not $Font) { $Font = $F.Btn }
    $p = New-Object System.Windows.Forms.Panel
    $p.Location = New-Object System.Drawing.Point($X, $Y)
    $p.Size     = New-Object System.Drawing.Size($W, $H)
    $p.BackColor = $Bg
    $p.Cursor = [System.Windows.Forms.Cursors]::Hand
    Set-DoubleBuffered $p
    $p.Tag = @{
        Text = $Text; Fill = $Fill; Hover = $FillHover; Fore = $Fore; Bg = $Bg
        Outline = [bool]$Outline; Font = $Font; IsHover = $false; Enabled = $true
        Click = $OnClick
    }
    $p.Add_Paint({
        $t = $this.Tag
        $g = $_.Graphics
        $g.SmoothingMode = 'AntiAlias'
        $g.TextRenderingHint = 'ClearTypeGridFit'
        $g.Clear($t.Bg)
        $rect = New-RoundRect 1 1 ($this.Width - 3) ($this.Height - 3) 9
        $rf = New-Object System.Drawing.RectangleF(0, 0, $this.Width, $this.Height)
        $sf = New-Object System.Drawing.StringFormat
        $sf.Alignment = 'Center'; $sf.LineAlignment = 'Center'
        if (-not $t.Enabled) {
            $bg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(226,232,240))
            $g.FillPath($bg, $rect); $bg.Dispose()
            $tb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(148,163,184))
            $g.DrawString($t.Text, $t.Font, $tb, $rf, $sf); $tb.Dispose()
        }
        elseif ($t.Outline) {
            $bg = New-Object System.Drawing.SolidBrush($(if ($t.IsHover) { $t.Hover } else { [System.Drawing.Color]::White }))
            $g.FillPath($bg, $rect); $bg.Dispose()
            $pen = New-Object System.Drawing.Pen($t.Fore, 1.4)
            $g.DrawPath($pen, $rect); $pen.Dispose()
            $tb = New-Object System.Drawing.SolidBrush($t.Fore)
            $g.DrawString($t.Text, $t.Font, $tb, $rf, $sf); $tb.Dispose()
        }
        else {
            $bg = New-Object System.Drawing.SolidBrush($(if ($t.IsHover) { $t.Hover } else { $t.Fill }))
            $g.FillPath($bg, $rect); $bg.Dispose()
            $tb = New-Object System.Drawing.SolidBrush($t.Fore)
            $g.DrawString($t.Text, $t.Font, $tb, $rf, $sf); $tb.Dispose()
        }
        $rect.Dispose()
    })
    $p.Add_MouseEnter({ if ($this.Tag.Enabled) { $this.Tag.IsHover = $true; $this.Invalidate() } })
    $p.Add_MouseLeave({ $this.Tag.IsHover = $false; $this.Invalidate() })
    $p.Add_Click({ if ($this.Tag.Enabled -and $this.Tag.Click) { & $this.Tag.Click } })
    return $p
}

function Set-PillEnabled {
    param($pill, [bool]$on)
    $pill.Tag.Enabled = $on
    $pill.Cursor = if ($on) { [System.Windows.Forms.Cursors]::Hand } else { [System.Windows.Forms.Cursors]::Default }
    $pill.Invalidate()
}

# ===========================================================================
#  Toolbox "card"
# ===========================================================================
function New-Card {
    param([object]$Meta, [int]$X, [int]$Y, [int]$W, [int]$H)
    $card = New-Object System.Windows.Forms.Panel
    $card.Location = New-Object System.Drawing.Point($X, $Y)
    $card.Size     = New-Object System.Drawing.Size($W, $H)
    $card.BackColor = $script:C.FormBg
    Set-DoubleBuffered $card
    $card.Tag = @{ Title = $Meta.Title; Desc = $Meta.Desc; Status = 'Checking...'; StatusCol = $script:C.Sub }
    $card.Add_Paint({
        $t = $this.Tag
        $g = $_.Graphics
        $g.SmoothingMode = 'AntiAlias'
        $g.TextRenderingHint = 'ClearTypeGridFit'
        $g.Clear($script:C.FormBg)
        # soft shadow
        $sh = New-RoundRect 3 5 ($this.Width - 6) ($this.Height - 6) 14
        $shb = New-Object System.Drawing.SolidBrush($script:C.Shadow)
        $g.FillPath($shb, $sh); $shb.Dispose(); $sh.Dispose()
        # white card + border
        $rc = New-RoundRect 1 1 ($this.Width - 5) ($this.Height - 8) 14
        $cb = New-Object System.Drawing.SolidBrush($script:C.Card)
        $g.FillPath($cb, $rc); $cb.Dispose()
        $pen = New-Object System.Drawing.Pen($script:C.CardEdge, 1)
        $g.DrawPath($pen, $rc); $pen.Dispose(); $rc.Dispose()
        # blue accent bar top-left
        $acc = New-RoundRect 22 22 44 5 2
        $ab = New-Object System.Drawing.SolidBrush($script:C.Blue)
        $g.FillPath($ab, $acc); $ab.Dispose(); $acc.Dispose()
        # title
        $tb = New-Object System.Drawing.SolidBrush($script:C.Ink)
        $g.DrawString($t.Title, $script:F.CardTtl, $tb, (New-Object System.Drawing.PointF(21, 36)))
        $tb.Dispose()
        # description (wrapped)
        $db = New-Object System.Drawing.SolidBrush($script:C.Sub)
        $dr = New-Object System.Drawing.RectangleF(22, 70, ($this.Width - 44), 60)
        $g.DrawString($t.Desc, $script:F.CardDsc, $db, $dr)
        $db.Dispose()
        # status line
        $sb = New-Object System.Drawing.SolidBrush($t.StatusCol)
        $g.DrawString($t.Status, $script:F.Status, $sb, (New-Object System.Drawing.PointF(22, 132)))
        $sb.Dispose()
    })

    $dl = New-Pill 'Download' 22 168 150 44 $script:C.Blue $script:C.BlueTint $script:C.Blue $script:C.Card `
        ([scriptblock]::Create("Invoke-HubDownload '$($Meta.Key)'")) -Outline
    $run = New-Pill 'Run' 188 168 150 44 $script:C.Blue $script:C.BlueDark $script:C.White $script:C.Card `
        ([scriptblock]::Create("Invoke-HubRun '$($Meta.Key)'"))
    $card.Controls.Add($dl)
    $card.Controls.Add($run)

    $script:Hub.Cards[$Meta.Key] = @{ Card = $card; Run = $run; Dl = $dl; Meta = $Meta }
    return $card
}

# ===========================================================================
#  Behaviour
# ===========================================================================
function Get-HubRaw { param([string]$file) "https://raw.githubusercontent.com/$($GH.User)/$($GH.Repo)/$($GH.Branch)/$file" }
function Get-HubRepoUrl { "https://github.com/$($GH.User)/$($GH.Repo)" }
function Test-HubConfigured { return ($GH.User -and $GH.User -ne 'YOUR_GITHUB_USERNAME') }

function Set-HubStatus { param([string]$msg) if ($script:Hub.Status) { $script:Hub.Status.Text = $msg; $script:Hub.Status.Refresh() } }

function Update-HubCard {
    param([string]$key)
    $c = $script:Hub.Cards[$key]; if (-not $c) { return }
    $path = Join-Path $script:Hub.Dir $c.Meta.File
    if (Test-Path $path) {
        $when = (Get-Item $path).LastWriteTime.ToString('yyyy-MM-dd HH:mm')
        $c.Card.Tag.Status = "Installed  -  updated $when"
        $c.Card.Tag.StatusCol = $script:C.Green
        Set-PillEnabled $c.Run $true
    } else {
        $c.Card.Tag.Status = 'Not downloaded yet'
        $c.Card.Tag.StatusCol = $script:C.Amber
        Set-PillEnabled $c.Run $false
    }
    $c.Card.Invalidate()
}
function Update-AllCards { foreach ($k in $script:Hub.Cards.Keys) { Update-HubCard $k } }

function Save-HubFile {
    param([string]$file)
    if (-not (Test-HubConfigured)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Open WinToolbox-Hub.ps1 and set your GitHub username in the `$GH block near the top, then try again.",
            'Set your GitHub details', 'OK', 'Information') | Out-Null
        return $false
    }
    $url = Get-HubRaw $file
    $dst = Join-Path $script:Hub.Dir $file
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    } catch {}
    Set-HubStatus "Downloading $file ..."
    try {
        Invoke-WebRequest -Uri $url -OutFile $dst -UseBasicParsing -ErrorAction Stop
        Set-HubStatus "Downloaded $file"
        return $true
    } catch {
        Set-HubStatus "Download failed: $file"
        [System.Windows.Forms.MessageBox]::Show(
            "Couldn't download:`r`n$url`r`n`r`n$($_.Exception.Message)`r`n`r`nCheck the `$GH settings and that the file exists in the repo.",
            'Download failed', 'OK', 'Warning') | Out-Null
        return $false
    }
}

function Invoke-HubDownload {
    param([string]$key)
    $m = ($Managed | Where-Object Key -eq $key)
    if (Save-HubFile $m.File) { Update-HubCard $key }
}

function Invoke-HubRun {
    param([string]$key)
    $m = ($Managed | Where-Object Key -eq $key)
    $path = Join-Path $script:Hub.Dir $m.File
    if (-not (Test-Path $path)) {
        $r = [System.Windows.Forms.MessageBox]::Show(
            "$($m.File) isn't here yet. Download it now?", 'Not downloaded', 'YesNo', 'Question')
        if ($r -ne 'Yes') { return }
        if (-not (Save-HubFile $m.File)) { return }
        Update-HubCard $key
    }
    try {
        if ($m.Kind -eq 'ps1') {
            # WinToolbox.ps1 self-elevates its own GUI; run its console hidden.
            # Path is quoted so folders with spaces still work.
            $psArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$path`" -Gui"
            Start-Process powershell.exe -ArgumentList $psArgs
            Set-HubStatus "Launched $($m.File)  (approve the admin prompt if it appears)"
        } else {
            # God Server is a batch menu - it needs a visible console and self-elevates.
            Start-Process -FilePath $path
            Set-HubStatus "Launched $($m.File)"
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Couldn't start $($m.File):`r`n$($_.Exception.Message)",
            'Launch failed', 'OK', 'Warning') | Out-Null
    }
}

function Invoke-HubGetEverything {
    if (-not (Test-HubConfigured)) { Save-HubFile 'x' | Out-Null; return }  # triggers the config notice
    $all = @($Managed.File) + $ExtraFiles | Select-Object -Unique
    $ok = 0
    foreach ($f in $all) { if (Save-HubFile $f) { $ok++ } }
    Update-AllCards
    Set-HubStatus "Fetched $ok of $($all.Count) files into this folder"
}

# ===========================================================================
#  Greeting + environment
# ===========================================================================
$hh = (Get-Date).Hour
$part = if ($hh -lt 12) { 'Good morning' } elseif ($hh -lt 17) { 'Good afternoon' } else { 'Good evening' }
$who  = if ($env:USERNAME) { $env:USERNAME } else { 'gamer' }
$script:Hub.Greet = "$part, $who"
$script:Hub.Sub   = 'Pick a toolbox below - download the latest, or run it now.'
$osName = 'Windows'
try {
    $rk = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction Stop
    $osName = $rk.ProductName
    # Registry still says "Windows 10" on Win11 - fix by build number.
    if ([System.Environment]::OSVersion.Version.Build -ge 22000) { $osName = $osName -replace 'Windows 10', 'Windows 11' }
    if ($rk.DisplayVersion) { $osName = "$osName $($rk.DisplayVersion)" }
} catch {}
$script:Hub.OS = "$osName  -  build $([System.Environment]::OSVersion.Version.Build)"

# Downloads land in a "WinToolbox" folder on the Desktop (works with OneDrive-
# redirected desktops too). Falls back to LOCALAPPDATA only if that isn't writable.
$desktop = [Environment]::GetFolderPath('DesktopDirectory')
if (-not $desktop) { $desktop = Join-Path $env:USERPROFILE 'Desktop' }
$dir = Join-Path $desktop 'WinToolbox'
try { New-Item -ItemType Directory -Force -Path $dir | Out-Null } catch {}
try {
    $t = Join-Path $dir ('.wtx_' + [guid]::NewGuid().ToString('N') + '.tmp')
    [System.IO.File]::WriteAllText($t, 'x'); Remove-Item $t -Force
} catch {
    $dir = Join-Path $env:LOCALAPPDATA 'WinToolbox'
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
$script:Hub.Dir = $dir

# ===========================================================================
#  Build the window
# ===========================================================================
$form = New-Object System.Windows.Forms.Form
$form.Text = ''
$form.ShowIcon = $false
$form.ClientSize = New-Object System.Drawing.Size(800, 620)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox = $false
$form.BackColor = $C.FormBg
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)

# ---- header (gradient + all text painted on it) ----
$hdr = New-Object System.Windows.Forms.Panel
$hdr.Location = New-Object System.Drawing.Point(0, 0)
$hdr.Size = New-Object System.Drawing.Size(800, 132)
Set-DoubleBuffered $hdr
$hdr.Add_Paint({
    $g = $_.Graphics
    $g.SmoothingMode = 'AntiAlias'
    $g.TextRenderingHint = 'ClearTypeGridFit'
    $rect = New-Object System.Drawing.Rectangle(0, 0, $this.Width, $this.Height)
    $br = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $script:C.HdrTop, $script:C.HdrBot, 55)
    $g.FillRectangle($br, $rect); $br.Dispose()

    # "MAX GAMING" tag pill
    $tag = New-RoundRect 28 22 116 24 11
    $tb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(46, 255, 255, 255))
    $g.FillPath($tb, $tag); $tb.Dispose()
    $tp = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 255, 255, 255), 1)
    $g.DrawPath($tp, $tag); $tp.Dispose(); $tag.Dispose()
    $sfC = New-Object System.Drawing.StringFormat; $sfC.Alignment = 'Center'; $sfC.LineAlignment = 'Center'
    $wb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.DrawString('MAX GAMING', $script:F.Tag, $wb, (New-Object System.Drawing.RectangleF(28, 22, 116, 24)), $sfC)

    # title
    $g.DrawString('GOD SERVER', $script:F.Title, $wb, (New-Object System.Drawing.PointF(26, 48)))
    # greeting
    $lb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(224, 233, 255))
    $g.DrawString($script:Hub.Greet, $script:F.Greet, $lb, (New-Object System.Drawing.PointF(28, 92)))

    # OS line, right aligned
    $sfR = New-Object System.Drawing.StringFormat; $sfR.Alignment = 'Far'
    $g.DrawString($script:Hub.OS, $script:F.Small, $lb, (New-Object System.Drawing.RectangleF(300, 100, 476, 20)), $sfR)
    $wb.Dispose(); $lb.Dispose()
})
$form.Controls.Add($hdr)

# subtitle under header
$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = $script:Hub.Sub
$lblSub.AutoSize = $true
$lblSub.ForeColor = $C.Sub
$lblSub.BackColor = $C.FormBg
$lblSub.Font = New-Object System.Drawing.Font('Segoe UI', 9.5)
$lblSub.Location = New-Object System.Drawing.Point(24, 144)
$form.Controls.Add($lblSub)

# cards
$form.Controls.Add( (New-Card $Managed[0]  24 172 360 250) )
$form.Controls.Add( (New-Card $Managed[1] 416 172 360 250) )

# divider
$div = New-Object System.Windows.Forms.Label
$div.AutoSize = $false
$div.Size = New-Object System.Drawing.Size(752, 1)
$div.BackColor = $C.CardEdge
$div.Location = New-Object System.Drawing.Point(24, 442)
$form.Controls.Add($div)

# status line
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.AutoSize = $false
$lblStatus.Size = New-Object System.Drawing.Size(752, 20)
$lblStatus.ForeColor = $C.SlateInk
$lblStatus.BackColor = $C.FormBg
$lblStatus.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$lblStatus.Location = New-Object System.Drawing.Point(24, 456)
$form.Controls.Add($lblStatus)
$script:Hub.Status = $lblStatus

# footer pills
$footY = 486
$pOpen = New-Pill 'Open folder' 24 $footY 118 36 $C.White $C.FootHover $C.SlateInk $C.FormBg `
    { try { Start-Process explorer.exe $script:Hub.Dir } catch {} } -Outline -Font $F.Foot
$pGet = New-Pill 'Get everything' 150 $footY 132 36 $C.White $C.FootHover $C.SlateInk $C.FormBg `
    { Invoke-HubGetEverything } -Outline -Font $F.Foot
$pGit = New-Pill 'GitHub repo' 290 $footY 118 36 $C.Dark $C.Ink $C.White $C.FormBg `
    {
        if (-not (Test-HubConfigured)) {
            [System.Windows.Forms.MessageBox]::Show('Set your GitHub username in the $GH block first.','GitHub','OK','Information') | Out-Null
            return
        }
        try { Start-Process (Get-HubRepoUrl) } catch {}
    } -Font $F.Foot
$form.Controls.Add($pOpen); $form.Controls.Add($pGet); $form.Controls.Add($pGit)

# version + folder hint
$lblVer = New-Object System.Windows.Forms.Label
$lblVer.AutoSize = $true
$lblVer.ForeColor = $C.MutedInk
$lblVer.BackColor = $C.FormBg
$lblVer.Font = New-Object System.Drawing.Font('Segoe UI', 8)
$lblVer.Text = "God Server $($script:Hub.Version)"
$lblVer.Location = New-Object System.Drawing.Point(24, 540)
$form.Controls.Add($lblVer)

$form.Add_Shown({
    Update-AllCards
    Set-HubStatus "Folder: $($script:Hub.Dir)"
    if (-not (Test-HubConfigured)) {
        Set-HubStatus "Tip: set your GitHub username in the `$GH block (top of WinToolbox-Hub.ps1) so Download works."
    }
})

[void]$form.ShowDialog()
$form.Dispose()
