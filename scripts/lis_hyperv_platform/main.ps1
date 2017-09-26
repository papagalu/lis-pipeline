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

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

& "$scriptPath./setup_env.ps1" $VHDPath $ConfigDrivePath $UserdataPath $KernelURL $InstanceName $MkIsoFS
& "$scriptPath./check_kernel.ps1" $InstanceName $KernelVersion $VMCheckTimeout
& "$scriptPath./tear_down_env.ps1" $InstanceName $ConfigDrivePath
