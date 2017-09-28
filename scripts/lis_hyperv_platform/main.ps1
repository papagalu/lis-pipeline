param(
    [String] $VHDPath = "C:\path\to\example.vhdx",
    [String] $ConfigDrivePath = "C:\path\to\configdrive\",
    [String] $UserdataPath = "C:\path\to\userdata.sh",
    [String[]] $KernelURL = @(
        "http://URL/TO/linux-headers.deb",
        "http://URL/TO/linux-image.deb",
        "http://URL/TO/hyperv-daemons.deb"),
    [String] $MkIsoFS = "C:\path\to\mkisofs.exe",
    [String] $InstanceName = "Instance1",
    [String] $KernelVersion = "4.13.2",
    [Int] $VMCheckTimeout = 200
)

$ErrorActionPreference = "Stop"

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$scriptPath\retrieve_ip.ps1"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

& "$scriptPath\setup_env.ps1" $VHDPath $ConfigDrivePath $UserdataPath $KernelURL $InstanceName $MkIsoFS
$ip = Get-IP $InstanceName $VMCheckTimeout
& ssh.exe -tt -o StrictHostKeyChecking=no -i "$scriptPath\$InstanceName-id-rsa" ubuntu@$ip
Start-Sleep 5
& ssh.exe -tt -o StrictHostKeyChecking=no -i "$scriptPath\$InstanceName-id-rsa" ubuntu@$ip
Start-Sleep 5
& ssh.exe -tt -o StrictHostKeyChecking=no -i "$scriptPath\$InstanceName-id-rsa" ubuntu@$ip
Start-Sleep 5
& ssh.exe -tt -o StrictHostKeyChecking=no -i "$scriptPath\$InstanceName-id-rsa" ubuntu@$ip
Start-Sleep 5
& ssh.exe -tt -o StrictHostKeyChecking=no -i "$scriptPath\$InstanceName-id-rsa" ubuntu@$ip
Start-Sleep 5
& ssh.exe -tt -o StrictHostKeyChecking=no -i "$scriptPath\$InstanceName-id-rsa" ubuntu@$ip
Start-Sleep 5
& ssh.exe -tt -o StrictHostKeyChecking=no -i "$scriptPath\$InstanceName-id-rsa" ubuntu@$ip
Start-Sleep 20
& ssh.exe -tt -o StrictHostKeyChecking=no -i "$scriptPath\$InstanceName-id-rsa" ubuntu@$ip
