$wmi = Get-WmiObject -Query "SELECT * FROM SoftwareLicensingService"
$wmi.OA3xOriginalProductKey