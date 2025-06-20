# Change the CD-ROM drive letter to Z: if a CD-ROM drive exists

$cdrom = Get-WmiObject -Class Win32_CDROMDrive | Select-Object -First 1
if ($cdrom) {
    $driveLetter = ($cdrom.Drive -replace ':', '')
    if ($driveLetter -ne 'Z') {
        $disk = Get-WmiObject -Class Win32_Volume | Where-Object { $_.DriveLetter -eq $cdrom.Drive }
        if ($disk) {
            $disk.DriveLetter = 'Z:'
            $disk.Put() | Out-Null
            Write-Output "CD-ROM drive letter changed to Z:"
        } else {
            Write-Output "CD-ROM volume not found."
        }
    } else {
        Write-Output "CD-ROM drive is already Z:"
    }
} else {
    Write-Output "No CD-ROM drive found."
}