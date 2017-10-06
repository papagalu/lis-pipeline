param(
    [String] $InstanceName = "Instance1"
)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$scriptPath1 = (get-item $scriptPath ).parent.FullName
. "$scriptPath1\backend.ps1"

function Main {
    $backend = [HypervBackend]::new(@("localhost"))
    $instance = [HypervInstance]::new($backend, $InstanceName, $VHDPath)

    $vhdPath = $instance.GetVHDPath()
    $instance.Cleanup()
    $vhdDirectoryPath = $vhdPath | Split-Path

    Remove-Item -Recurse -Force $vhdDirectoryPath
}

Main
