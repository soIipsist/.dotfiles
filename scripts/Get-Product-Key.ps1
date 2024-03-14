$WshShell = New-Object -ComObject "WScript.Shell"
$Key = $WshShell.RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DigitalProductId")

Function ConvertToKey($Key) {
    $KeyOffset = 52
    $i = 28
    $Chars = "BCDFGHJKMPQRTVWXY2346789"
    $KeyOutput = ""

    Do {
        $Cur = 0
        $x = 14

        Do {
            $Cur = $Cur * 256
            $Cur = $Key[$x + $KeyOffset] + $Cur
            $Key[$x + $KeyOffset] = [math]::Floor($Cur / 24)
            $Cur = $Cur % 24
            $x--
        } While ($x -ge 0)

        $i--
        $KeyOutput = $Chars.Substring($Cur, 1) + $KeyOutput

        If (((29 - $i) % 6) -eq 0 -and $i -ne -1) {
            $i--
            $KeyOutput = "-" + $KeyOutput
        }
    } While ($i -ge 0)

    return $KeyOutput
}

ConvertToKey $Key
