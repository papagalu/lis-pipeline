param(
    [String] $JobPath = "C:\path\to\job",
    [String] $UserdataPath = "C:\path\to\userdata.sh",
    [String[]] $KernelURL = @(
        "http://URL/TO/linux-headers.deb",
        "http://URL/TO/linux-image.deb",
        "http://URL/TO/hyperv-daemons.deb"),
    [String] $MkIsoFS = "C:\path\to\mkisofs.exe"
)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$scriptPath\config_drive.ps1"

$ErrorActionPreference = "Stop"

function MyTest-Path {
    param(
        [String] $Path
    )
    if (!(Test-Path $Path)) {
       throw "Path $Path not found"
    }

}

function Test-URL {
    param(
        [String] $URL
    )

        $HTTP_Request = [System.Net.WebRequest]::Create($URL)
        $HTTP_Response = $HTTP_Request.GetResponse()
        $HTTP_Status = [int]$HTTP_Response.StatusCode

        if ($HTTP_Status -ne 200) {
            Write-Host "The Site may be down, please check!"
            throw "Kernel URL can't be reached!"
        }

	$HTTP_Response.Close()
}

function Make-ISO {
    param(
        [String] $MkIsoFSPath,
        [String] $TargetPath,
        [String] $OutputPath
    )

    try {
        & $MkIsoFSPath -o $OutputPath -ldots -allow-lowercase -allow-multidot -quiet -J -r -V "config-2" $TargetPath

        if ($LastExitCode) {
            throw
        }
    } catch {
        return
    } finally {
        $Error.Clear()
    }
}

function Update-URL {
    param(
        [String] $UserdataPath,
        [String] $URL
    )
        (Get-Content $UserdataPath).replace("MagicURL", $URL) `
            | Set-Content $UserdataPath
}

function Preserve-Item {
    param (
        [String] $Path
    )

    Copy-Item -Path $Path -Destination "$Path-tmp"
    return "$Path-tmp"
}


function Main {
    MyTest-Path $JobPath
    MyTest-Path $UserdataPath
    foreach ($url in $KernelUrl) {
        Test-URL $url
    }
    
    $UserdataPath = Preserve-Item $UserdataPath
    Update-URL $UserdataPath $KernelURL
    
    & 'ssh-keygen.exe' -t rsa -f "$JobPath/$InstanceName-id-rsa" -q -N "''" -C "debian"
    if ($Error.Count -ne 0) {
        throw $Error[0]
    }

    Write-Host "Creating ConfigDrive"
    $configDrive = [ConfigDrive]::new("configdrive")
    $configDrive.GetProperties("")
    $configDrive.ChangeProperty("hostname", "pipeline")
    $configDrive.ChangeSSHKey("$JobPath/$InstanceName-id-rsa.pub")
    $configDrive.ChangeUserData($UserdataPath)
    $configDrive.SaveToNewConfigDrive("$scriptPath/configdrive-tmp")

    Make-ISO $MkIsoFS "$scriptPath/configdrive-tmp" "$JobPath/configdrive.iso"
    Write-Host "Finished creating ConfigDrive"

    Remove-Item -Force -Recurse -Path "$scriptPath/configdrive-tmp"
    Remove-Item -Force $UserdataPath
}

Main
