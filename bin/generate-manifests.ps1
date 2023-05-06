#Requires -Version 3

<#
.SYNOPSIS
    Generate manifests of patched fonts provided by nerd fonts repository.
.PARAMETER OverwriteExisting
    Whether to overwrite existing manifests.
.EXAMPLE
    PS BUCKETROOT> .\bin\generate-manifests.ps1
    Generate manifests only if the desired manifest does not exist.
.EXAMPLE
    PS BUCKETROOT> .\bin\generate-manifests.ps1 -OverwriteExisting
    Force re-generate all manifests.
#>
Param (
    [switch]$OverwriteExisting
)

function Export-FontManifest {
    Param (
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [ValidateNotNullOrEmpty()]
        [switch]$IsMono,
        [switch]$OverwriteExisting
    )

    $description = "Nerd Fonts patched '$Name' Font family."
    if ($IsMono) {
        $description += " (Monospace version, Nerd Fonts Symbol/Icon will be always 1 cell wide)"
    } else {
        $description += " (Normal version, Nerd Fonts Symbol/Icon could be 1 or 2 cell wide)"
    }

    $fullName = if ($IsMono) { "$Name-NF-Mono" } else { "$Name-NF" }
    $path = "$PSScriptRoot\..\bucket\$fullName.json"
    $filter = if ($IsMono) { "'*Mono Windows Compatible*'" } else { "'*Complete Windows Compatible*'" }

    $templateData = [ordered]@{
        "version"         = "0.0"
        "description"     = $description
        "homepage"        = "https://github.com/ryanoasis/nerd-fonts"
        "license"         = "MIT"
        "url"             = " "
        "hash"            = " "
        "installer"       = @{
            "script" = @(
                '$currentBuildNumber = [int] (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber',
                '$windows10Version1809BuildNumber = 17763',
                '$isPerUserFontInstallationSupported = $currentBuildNumber -ge $windows10Version1809BuildNumber',
                'if (!$isPerUserFontInstallationSupported -and !$global) {',
                '    scoop uninstall $app',
                '    Write-Host ""',
                '    Write-Host "For Windows version before Windows 10 Version 1809 (OS Build 17763)," -Foreground DarkRed',
                '    Write-Host "Font can only be installed for all users." -Foreground DarkRed',
                '    Write-Host ""',
                '    Write-Host "Please use following commands to install ''$app'' Font for all users." -Foreground DarkRed',
                '    Write-Host ""',
                "    Write-Host ""        scoop install sudo""",
                "    Write-Host ""        sudo scoop install -g `$app""",
                '    Write-Host ""',
                '    exit 1',
                '}',
                '$fontInstallDir = if ($global) { "$env:windir\Fonts" } else { "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" }',
                'if (-not $global) {',
                '    # Ensure user font install directory exists and has correct permission settings',
                '    # See https://github.com/matthewjberger/scoop-nerd-fonts/issues/198#issuecomment-1488996737',
                '    New-Item $fontInstallDir -ItemType Directory -ErrorAction SilentlyContinue | Out-Null',
                '    $accessControlList = Get-Acl $fontInstallDir',
                '    $allApplicationPackagesAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule([System.Security.Principal.SecurityIdentifier]::new("S-1-15-2-1"), "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow")',
                '    $allRestrictedApplicationPackagesAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule([System.Security.Principal.SecurityIdentifier]::new("S-1-15-2-2"), "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow")',
                '    $accessControlList.SetAccessRule($allApplicationPackagesAccessRule)',
                '    $accessControlList.SetAccessRule($allRestrictedApplicationPackagesAccessRule)',
                '    Set-Acl -AclObject $accessControlList $fontInstallDir',
                '}',
                '$registryRoot = if ($global) { "HKLM" } else { "HKCU" }',
                '$registryKey = "${registryRoot}:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"',
                "Get-ChildItem `$dir -Filter $filter | ForEach-Object {",
                '    $value = if ($global) { $_.Name } else { "$fontInstallDir\$($_.Name)" }',
                '    New-ItemProperty -Path $registryKey -Name $_.Name.Replace($_.Extension, '' (TrueType)'') -Value $value -Force | Out-Null',
                '    Copy-Item $_.FullName -Destination $fontInstallDir',
                '}'
            )
        }
        "pre_uninstall" = @(
            '$fontInstallDir = if ($global) { "$env:windir\Fonts" } else { "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" }',
            "Get-ChildItem `$dir -Filter $filter | ForEach-Object {",
            '    Get-ChildItem $fontInstallDir -Filter $_.Name | ForEach-Object {',
            '        try {',
            '            Rename-Item $_.FullName $_.FullName -ErrorVariable LockError -ErrorAction Stop',
            '        } catch {',
            '            Write-Host ""',
            '            Write-Host " Error " -Background DarkRed -Foreground White -NoNewline',
            '            Write-Host ""',
            '            Write-Host " Cannot uninstall ''$app'' font." -Foreground DarkRed',
            '            Write-Host ""',
            '            Write-Host " Reason " -Background DarkCyan -Foreground White -NoNewline',
            '            Write-Host ""',
            '            Write-Host " The ''$app'' font is currently being used by another application," -Foreground DarkCyan',
            '            Write-Host " so it cannot be deleted." -Foreground DarkCyan',
            '            Write-Host ""',
            '            Write-Host " Suggestion " -Background Magenta -Foreground White -NoNewline',
            '            Write-Host ""',
            '            Write-Host " Close all applications that are using ''$app'' font (e.g. vscode)," -Foreground Magenta',
            '            Write-Host " and then try again." -Foreground Magenta',
            '            Write-Host ""',
            '            exit 1',
            '        }',
            '    }',
            '}'
        )
        "uninstaller"     = @{
            "script" = @(
                '$fontInstallDir = if ($global) { "$env:windir\Fonts" } else { "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" }',
                '$registryRoot = if ($global) { "HKLM" } else { "HKCU" }',
                '$registryKey = "${registryRoot}:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"',
                "Get-ChildItem `$dir -Filter $filter | ForEach-Object {",
                '    Remove-ItemProperty -Path $registryKey -Name $_.Name.Replace($_.Extension, '' (TrueType)'') -Force -ErrorAction SilentlyContinue',
                '    Remove-Item "$fontInstallDir\$($_.Name)" -Force -ErrorAction SilentlyContinue',
                '}',
                'if ($cmd -eq "uninstall") {',
                '    Write-Host "The ''$($app.Replace(''-NF'', ''''))'' Font family has been uninstalled and will not be present after restarting your computer." -Foreground Magenta',
                '}'
            )
        }
        "checkver"        = "github"
        "autoupdate"      = @{
            "url" = "https://github.com/ryanoasis/nerd-fonts/releases/download/v`$version/${Name}.zip"
        }
    }

    if (! (Test-Path $path)) {
        # Create the manifest if it doesn't exist
        ConvertTo-Json -InputObject $templateData | Set-Content -LiteralPath $path -Encoding UTF8
    } elseif ($OverwriteExisting) {
        ConvertTo-Json -InputObject $templateData | Set-Content -LiteralPath $path -Encoding UTF8 -Force
    }

    # Use scoop's checkver script to autoupdate the manifest
    & $PSScriptRoot\checkver.ps1 $fullName -u

    # Sleep to avoid 429 errors from github's REST API
    Start-Sleep 1
}

# Tips: $fontNames list can be generated via the following commands:
#
#     scoop install curl
#     scoop install jq
#     scoop install busybox-lean
#
#     curl --silent https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq '.assets[].name' | busybox sed 's/^"/    "/; s/.zip"/",/; /FontPatcher/ d; /NerdFontsSymbolsOnly/ d'
#
# This is useful to keep $fontNames list up to date with nerd-fonts latest release
$fontNames = @(
    '3270',
    'Agave',
    'AnonymousPro',
    'Arimo',
    'AurulentSansMono',
    'BigBlueTerminal',
    'BitstreamVeraSansMono',
    'CascadiaCode',
    'CodeNewRoman',
    'ComicShannsMono',
    'Cousine',
    'DaddyTimeMono',
    'DejaVuSansMono',
    'DroidSansMono',
    'FantasqueSansMono',
    'FiraCode',
    'FiraMono',
    'Go-Mono',
    'Gohu',
    'Hack',
    'Hasklig',
    'HeavyData',
    'Hermit',
    'iA-Writer',
    'IBMPlexMono',
    'Inconsolata',
    'InconsolataGo',
    'InconsolataLGC',
    'Iosevka',
    'IosevkaTerm',
    'JetBrainsMono',
    'Lekton',
    'LiberationMono',
    'Lilex',
    'Meslo',
    'Monofur',
    'Monoid',
    'Mononoki',
    'MPlus',
    'Noto',
    'OpenDyslexic',
    'Overpass',
    'ProFont',
    'ProggyClean',
    'RobotoMono',
    'ShareTechMono',
    'SourceCodePro',
    'SpaceMono',
    'Terminus',
    'Tinos',
    'Ubuntu',
    'UbuntuMono',
    'VictorMono'
)

# Generate manifests
$fontNames | ForEach-Object {
    Export-FontManifest -Name $_ -OverwriteExisting:$OverwriteExisting
    Export-FontManifest -Name $_ -IsMono -OverwriteExisting:$OverwriteExisting
}
