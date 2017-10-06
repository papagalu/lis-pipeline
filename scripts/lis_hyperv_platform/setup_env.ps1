param (
    [String] $JobPath = 'C:\var\lava\tmp\1',
    [String] $VHDPath = "C:\path\to\example.vhdx",
    [String] $UserdataPath = "C:\path\to\userdata.sh",
    [String[]] $KernelURL = "kernel_url",
    [String] $InstanceName = "Instance1",
    [String] $MkIsoFS = "C:\path\to\mkisofs.exe"
)

$ErrorActionPreference = "Stop"

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$scriptPath1 = (get-item $scriptPath ).parent.FullName
. "$scriptPath1\backend.ps1"

function Main {
    $backend = [HypervBackend]::new(@("localhost"))
    $instance = [HypervInstance]::new($backend, $InstanceName, $VHDPath)

    & "$scriptPath/setup_metadata.ps1" $JobPath $UserdataPath $KernelURL $MkIsoFS
    if ($Error.Count -ne 0) {
        throw $Error[0]
    }

    $instance.CreateInstance()
    $instance.AttachVMDvdDrive("$JobPath\configdrive.iso")
    $instance.StartInstance()
}

Main
