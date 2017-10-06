$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$scriptPathParent = (get-item $scriptPath ).parent.FullName
. "$scriptPathParent\backend.ps1"

function Get-IP {
    $backend = [HypervBackend]::new(@("localhost"))
    $instance = [HypervInstance]::new($backend, $InstanceName, "")

    Start-Sleep 100

    while ($VMCheckTimeout -gt 0) {
        $ip = $instance.GetPublicIP()
        if ([String]::IsNullOrWhiteSpace($ip)) {
            Start-Sleep 5
        } else {
            break
        }
        $VMCheckTimeout = $VMCheckTimeout - 5
    }

    return $ip
}
