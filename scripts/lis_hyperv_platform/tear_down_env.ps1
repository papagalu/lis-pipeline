param(
    [String] $InstanceName = "Instance1"
)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$scriptPath1 = (get-item $scriptPath ).parent.FullName
. "$scriptPath1\backend.ps1"

function MyTest-Path {
    param(
        [String] $Path
    )
    if (!(Test-Path $Path)) {
        throw "Path $Path not found"
    }

}

function Main {
    $backend = [HypervBackend]::new(@("localhost"))
    $instance = [HypervInstance]::new($backend, $InstanceName, $VHDPath)

    $vhdPath = $instance.GetVHDPath()
    $instance.Cleanup()

    $deployPath = Split-Path $vhdPath 2>&1 | Out-Null
    $jobPath = Split-Path $deployPath 2>&1 | Out-Null

    MyTest-Path $jobPath

    Remove-Item -Force -Recurse $jobPath
}

Main
