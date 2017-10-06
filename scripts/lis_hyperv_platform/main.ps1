param(
    [String] $SharedStoragePath = "\\shared\storage\path",
    [String] $VHDPath = "C:\path\to\example.vhdx",
    [String] $UserdataPath = "C:\path\to\userdata.sh",
    [String] $KernelURL = "kernel_url",
    [String] $MkIsoFS = "C:\path\to\mkisofs.exe",
    [String] $InstanceName = "Instance1",
    [String] $KernelVersion = "4.13.2",
    [Int] $VMCheckTimeout = 200
)

$ErrorActionPreference = "Stop"

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$scriptPath\retrieve_ip.ps1"

function Prepare-LocalEnv {
    param(
        [String] $SharedStoragePath,
        [String] $VHDPath
    )

    $SharedStoragePath = $SharedStoragePath.Replace("\\", "\")
    try {
        net use H: /d 2>&1 | Out-Null
    } catch {
        throw $Error[0]
    } finally {
        $Error.Clear()
    }
    net use H: $SharedStoragePath /persistent:NO 2>&1 | Out-Null
    if ($LastExitCode) {
        throw
    }

    $localPath = "C:\var\lib\lava\dispatcher\tmp\"
    $VHDPath = $VHDPath.Replace("/var/lib/lava/dispatcher/tmp", "")
    $path = "H:$VHDPath"

    if (!(Test-Path $path)) {
       throw "Path $path not found"
    }

    $remoteJobFolder = Split-Path -Path $path
    $jobId = Split-Path -Path $remoteJobFolder -Leaf
    $jobFolder = Join-Path $localPath $jobId
    
    New-Item -Path $jobFolder -ItemType "directory" | Out-Null
    $localVHDPath = Join-Path $jobFolder  (Split-Path -Path $path -Leaf)
    Copy-Item -Path $path -Destination $localVHDPath -Force

    return @($localVHDPath, $remoteJobFolder)
}

function Expand-URL {
    param(
        [String] $KernelUrl,
        [String] $KernelVersion
    )

    $kernelURLExpanded = @()
    $kernelURLExpanded += "{0}/hyperv-daemons_{1}_amd64.deb" -f @($KernelURL, $KernelVersion)
    $kernelURLExpanded += "{0}/linux-headers-{1}_{1}-10.00.Custom_amd64.deb" -f @($KernelURL, $KernelVersion)
    $kernelURLExpanded += "{0}/linux-image-{1}_{1}-10.00.Custom_amd64.deb" -f @($KernelURL, $KernelVersion)

    return $kernelURLExpanded
}

function Main {
    $Error.Clear()

    $return = Prepare-LocalEnv $SharedStoragePath $VHDPath
    $localVHDPath = $return[0]
    $remoteJobFolder = $return[1]

    $expandedURL = Expand-URL $KernelURL $KernelVersion
    $jobPath = Split-Path -Parent $localVHDPath
    
    $setupEnvOutput = & "$scriptPath\setup_env.ps1" $jobPath $localVHDPath $UserdataPath $expandedURL $InstanceName $MkIsoFS
    if ($Error.Count -ne 0) {
        throw $Error[0]
    }
    
    Write-Host "copying id_rsa from $scriptPath\$InstanceName-id-rsa to $remoteJobFolder\id_rsa "
    Copy-Item "$jobPath\$InstanceName-id-rsa" "$remoteJobFolder\id_rsa"

}

Main
