<powershell>

function run-once-on-login ($taskname, $action) {
    $trigger = New-ScheduledTaskTrigger -AtLogon -RandomDelay $(New-TimeSpan -seconds 30)
    $trigger.Delay = "PT30S"
    $selfDestruct = New-ScheduledTaskAction -Execute powershell.exe -Argument "-WindowStyle Hidden -Command `"Disable-ScheduledTask -TaskName $taskname`""
    Register-ScheduledTask -TaskName $taskname -Trigger $trigger -Action $action,$selfDestruct -RunLevel Highest
}

function install-chocolatey {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco feature enable -n allowGlobalConfirmation
}

function install-parsec-cloud-preparation-tool {
    # https://github.com/parsec-cloud/Parsec-Cloud-Preparation-Tool
    # Fix parsec service: https://www.reddit.com/r/ParsecGaming/comments/cl3pwr/start_parsec_service_when_computer_is_booted_not/
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 
    $ScriptWebArchive = "https://github.com/parsec-cloud/Parsec-Cloud-Preparation-Tool/archive/master.zip"  
    $LocalArchivePath = "$ENV:UserProfile\Downloads\Parsec-Cloud-Preparation-Tool"  
    (New-Object System.Net.WebClient).DownloadFile($ScriptWebArchive, "$LocalArchivePath.zip")  
    Expand-Archive "$LocalArchivePath.zip" -DestinationPath $LocalArchivePath -Force  
    CD $LocalArchivePath\Parsec-Cloud-Preparation-Tool-master\PostInstall
    powershell.exe .\PostInstall.ps1 -DontPromptPasswordUpdateGPU
}

function install-admin-password {
    $password = (Get-SSMParameter -WithDecryption $true -Name '${password_ssm_parameter}').Value
    net user Administrator "$password"
}

function install-autologin {
    Install-Module -Name DSCR_AutoLogon -Force
    Import-Module -Name DSCR_AutoLogon
    $password = (Get-SSMParameter -WithDecryption $true -Name '${password_ssm_parameter}').Value
    $regPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    [microsoft.win32.registry]::SetValue($regPath, "AutoAdminLogon", "1")
    [microsoft.win32.registry]::SetValue($regPath, "DefaultUserName", "Administrator")
    Remove-ItemProperty -Path $regPath -Name "DefaultPassword" -ErrorAction SilentlyContinue
    (New-Object PInvoke.LSAUtil.LSAutil -ArgumentList "DefaultPassword").SetSecret($password)
}

# https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/install-nvidia-driver.html#nvidia-gaming-driver
function download-graphic-driver {
    
    $ExtractionPath = "$home\Desktop\Drivers\NVIDIA"
    $Bucket = ""
    $KeyPrefix = ""
    $InstallerFilter = "*win10*"
    $downloadGraphicDriver = 0

    %{ if regex("^g[0-9]+", var.instance_type) == "g3" }

        # GRID driver for g3
        $Bucket = "ec2-windows-nvidia-drivers"
        $KeyPrefix = "latest"
        $Objects = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -Region us-east-1
        foreach ($Object in $Objects) {
            $LocalFileName = $Object.Key
            if ($LocalFileName -ne '' -and $Object.Size -ne 0) {
                $LocalFilePath = Join-Path $ExtractionPath $LocalFileName
                Copy-S3Object -BucketName $Bucket -Key $Object.Key -LocalFile $LocalFilePath -Region us-east-1
            }
        }

        New-Item -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global" -Name GridLicensing
        New-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\GridLicensing" -Name "NvCplDisableManageLicensePage" -PropertyType "DWord" -Value "1"
        $downloadGraphicDriver = 1

    %{ else }
    %{ if regex("^g[0-9]+", var.instance_type) == "g4" }

        # vGaming driver for g4
        $Bucket = "nvidia-gaming"
        $KeyPrefix = "windows/latest"
        $Objects = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -Region us-east-1
        foreach ($Object in $Objects) {
            $LocalFileName = $Object.Key
            if ($LocalFileName -ne '' -and $Object.Size -ne 0) {
                $LocalFilePath = Join-Path $ExtractionPath $LocalFileName
                Copy-S3Object -BucketName $Bucket -Key $Object.Key -LocalFile $LocalFilePath -Region us-east-1
            }
        }

        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global" -Name "vGamingMarketplace" -PropertyType "DWord" -Value "2"
        Invoke-WebRequest -Uri "https://nvidia-gaming.s3.amazonaws.com/GridSwCert-Archive/GridSwCertWindows_2023_9_22.cert" -OutFile "$Env:PUBLIC\Documents\GridSwCert.txt"
        $downloadGraphicDriver = 1

    %{ endif }
    %{ endif }

    if ($downloadGraphicDriver == 1) {

        # install task to disable second monitor on login
        $trigger = New-ScheduledTaskTrigger -AtLogon
        $action = New-ScheduledTaskAction -Execute displayswitch.exe -Argument "/internal"
        Register-ScheduledTask -TaskName "disable-second-monitor" -Trigger $trigger -Action $action -RunLevel Highest

    }
    else {
        $action = New-ScheduledTaskAction -Execute powershell.exe -Argument "-WindowStyle Hidden -Command `"(New-Object -ComObject Wscript.Shell).Popup('Automatic GPU driver installation is unsupported for this instance type: ${var.instance_type}. Please install them manually.')`""
        run-once-on-login "gpu-driver-warning" $action
    }
}




install-chocolatey
Install-PackageProvider -Name NuGet -Force
choco install awstools.powershell

%{ if var.install_parsec }
install-parsec-cloud-preparation-tool
choco install parsec
%{ endif }

install-admin-password

%{ if var.install_auto_login }
install-autologin
%{ endif }

%{ if var.download_graphic_card_driver }
download-graphic-driver
%{ endif }

# https://otrs.unifei.edu.br/otrs/public.pl?Action=PublicFAQZoom;ItemID=300
choco install vb-cable

%{ if var.install_geforce_experience }
# How To Fix wlanapi.dll is missing error in Windows Server (for GeForce Experience): https://www.youtube.com/watch?v=Mq6xhtiZeKM&t=22s
# https://github.com/tomgrice/cloudgamestream-sunshine?tab=readme-ov-file
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls";Set-ExecutionPolicy Unrestricted;Invoke-WebRequest -Uri https://github.com/tomgrice/cloudgamestream-sunshine/releases/download/June2021a/cloudgamestream-sunshine.zip -OutFile arch.zip;Add-Type -Assembly "System.IO.Compression.Filesystem";$dir = [string](Get-Location);rmdir -r cloudgamestream-master -ErrorAction Ignore;[System.IO.Compression.ZipFile]::ExtractToDirectory($dir + "\arch.zip", $dir);cd cloudgamestream;./Setup.ps1
choco install geforce-experience
%{ endif }

%{ if var.install_steam }
choco install steam
%{ endif }

%{ if var.install_gog_galaxy }
choco install goggalaxy
%{ endif }

%{ if var.install_uplay }
choco install uplay
%{ endif }

%{ if var.install_origin }
choco install origin
%{ endif }

%{ if var.install_epic_games_launcher }
choco install epicgameslauncher
%{ endif }

</powershell>