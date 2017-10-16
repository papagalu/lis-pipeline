param(
    [String] $SharedStoragePath = "\\shared\storage\path",
    [String] $JobId = "64",
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

function MyTest-Path {
    param(
        [String] $Path
    )
    if (!(Test-Path $Path)) {
       throw "Path $Path not found"
    }

}

function Prepare-LocalEnv {
    param(
        [String] $SharedStoragePath,
        [String] $JobId
    )

    $path = "/var/lib/lava/dispatcher/tmp/$JobId"
    $remotePath = "H:\$JobId"
    $localPath = "C:$path"

    $SharedStoragePath = $SharedStoragePath.Replace("\\", "\")

    net use H: $SharedStoragePath /persistent:NO 2>&1 | Out-Null
    if ($LastExitCode) {
        throw
    }


    MyTest-Path $remotePath

    New-Item -Path $localPath -ItemType "directory" | Out-Null
    Copy-Item -Path "$remotePath/*" -Destination $localPath -Force -Recurse

    $localVHDPath = (Get-ChildItem -Filter "ubuntu-cloud.vhdx" -Path $localPath -Recurse ).FullName
    MyTest-Path $localVHDPath

    $lavaToolDisk = (Get-ChildItem -Filter "lava-guest.vhdx" -Path $localPath -Recurse ).FullName
    MyTest-Path $lavaToolDisk

    $remoteVHDPath = (Get-ChildItem -Filter "ubuntu-cloud.vhdx" -Path $remotePath -Recurse ).FullName
    $remotePath = Split-Path -Parent $remoteVHDPath

    return @($localVHDPath, $lavaToolDisk, $remotePath)
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

    $return = Prepare-LocalEnv $SharedStoragePath $JobId
    $localVHDPath = $return[0]
    $lavaToolDisk = $return[1]
    $remoteJobFolder = $return[2]

    $expandedURL = Expand-URL $KernelURL $KernelVersion
    $jobPath = Split-Path -Parent $localVHDPath
    
    & "$scriptPath\setup_env.ps1" $jobPath $localVHDPath $UserdataPath $expandedURL $InstanceName $MkIsoFS $lavaToolDisk
    if ($Error.Count -ne 0) {
        throw $Error[0]
    }

    $ip = Get-IP $InstanceName $VMCheckTimeout
    
    Write-Host "copying id_rsa from $scriptPath\$InstanceName-id-rsa to $remoteJobFolder\id_rsa "
    Copy-Item "$jobPath\$InstanceName-id-rsa" "$remoteJobFolder\id_rsa"

}

Main
