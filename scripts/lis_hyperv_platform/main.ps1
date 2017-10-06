param(
    [String] $VHDPath = "C:\path\to\example.vhdx",
    [String] $ConfigDrivePath = "C:\path\to\configdrive\",
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

try {
    net use H: "\\10.7.13.118\lava" /persistent:NO
    $localPath = "C:\var\lib\lava\dispatcher\tmp\"
    $VHDPath = $VHDPath.Replace("/var/lib/lava/dispatcher/tmp", "")
    $path = "H:$VHDPath"
    if (!(Test-Path $path)) {
       throw "Path $path not found"
    }
    $remoteJobFolder = Split-Path -Path $path
    $jobId = Split-Path -Path $remoteJobFolder -Leaf
    $jobFolder = Join-Path $localPath $jobId
    mkdir $jobFolder
    $VHDPath = Join-Path $jobFolder  (Split-Path -Path $path -Leaf)
    Write-Host $VHDPath
    cp $path $VHDPath -Force
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $kernelURlExpanded = @()
    $kernelURlExpanded += "{0}/hyperv-daemons_{1}_amd64.deb" -f @($KernelURL, $KernelVersion)
    $kernelURlExpanded += "{0}/linux-headers-{1}_{1}-10.00.Custom_amd64.deb" -f @($KernelURL, $KernelVersion)
    $kernelURlExpanded += "{0}/linux-image-{1}_{1}-10.00.Custom_amd64.deb" -f @($KernelURL, $KernelVersion)

    $a = & "$scriptPath\setup_env.ps1" $VHDPath $ConfigDrivePath $UserdataPath $kernelURlExpanded $InstanceName $MkIsoFS
    $ip = Get-IP $InstanceName $VMCheckTimeout
    
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
    Write-Host "copying id_rsa from $scriptPath\$InstanceName-id-rsa to $remoteJobFolder\id_rsa "
    
    Copy-Item "$scriptPath\$InstanceName-id-rsa" "$remoteJobFolder\id_rsa"
    Start-Sleep 2
} catch {
    Write-Host $_
    throw
}