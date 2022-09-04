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

    $fullName = if ($IsMono) { "$Name-NF-Mono" } else { "$Name-NF" }
    $path = "$PSScriptRoot\..\bucket\$fullName.json"
    $filter = if ($IsMono) { "'*Mono Windows Compatible.*'" } else { "'*Complete Windows Compatible.*'" }

    $templateData = [ordered]@{
        "version"     = "0.0"
        "license"     = "MIT"
        "homepage"    = "https://github.com/ryanoasis/nerd-fonts"
        "url"         = " "
        "hash"        = " "
        "checkver"    = "github"
        "autoupdate"  = @{
            "url" = "https://github.com/ryanoasis/nerd-fonts/releases/download/v`$version/${Name}.zip"
        }
        "installer"   = @{
            "script" = @(
                '$currentBuildNumber = [int] (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber',
                '$windows1809BuildNumber = 17763',
                '$isPerUserFontInstallationSupported = $currentBuildNumber -ge $windows1809BuildNumber',
                '$isFontInstallationForAllUsers = $global -or !$isPerUserFontInstallationSupported',
                'if ($isFontInstallationForAllUsers -and !(is_admin)) {',
                '    error "Administrator rights are required to install $app."',
                '    exit 1',
                '}',
                '$fontInstallDir = if ($isFontInstallationForAllUsers) { "$env:windir\Fonts" } else { "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" }',
                '$registryRoot = if ($isFontInstallationForAllUsers) { "HKLM" } else { "HKCU" }',
                '$registryKey = "${registryRoot}:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"',
                'New-Item $fontInstallDir -ItemType Directory -ErrorAction SilentlyContinue | Out-Null',
                "Get-ChildItem `$dir -Filter $filter | ForEach-Object {",
                '    $value = if ($isFontInstallationForAllUsers) { $_.Name } else { "$fontInstallDir\$($_.Name)" }',
                '    New-ItemProperty -Path $registryKey -Name $_.Name.Replace($_.Extension, '' (TrueType)'') -Value $value -Force | Out-Null',
                '    Copy-Item $_.FullName -Destination $fontInstallDir',
                '}'
            )
        }
        "uninstaller" = @{
            "script" = @(
                '$currentBuildNumber = [int] (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber',
                '$windows1809BuildNumber = 17763',
                '$isPerUserFontInstallationSupported = $currentBuildNumber -ge $windows1809BuildNumber',
                '$isFontInstallationForAllUsers = $global -or !$isPerUserFontInstallationSupported',
                'if ($isFontInstallationForAllUsers -and !(is_admin)) {',
                '    error "Administrator rights are required to uninstall $app."',
                '    exit 1',
                '}',
                '$fontInstallDir = if ($isFontInstallationForAllUsers) { "$env:windir\Fonts" } else { "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" }',
                '$registryRoot = if ($isFontInstallationForAllUsers) { "HKLM" } else { "HKCU" }',
                '$registryKey = "${registryRoot}:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"',
                "Get-ChildItem `$dir -Filter $filter | ForEach-Object {",
                '    Remove-ItemProperty -Path $registryKey -Name $_.Name.Replace($_.Extension, '' (TrueType)'') -Force -ErrorAction SilentlyContinue',
                '    Remove-Item "$fontInstallDir\$($_.Name)" -Force -ErrorAction SilentlyContinue',
                '}',
                'Write-Host "The ''$($app.Replace(''-NF'', ''''))'' Font family has been uninstalled and will not be present after restarting your computer." -Foreground Magenta'
            )
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

$fontNames = @(
    "3270",
    "Agave",
    "AnonymousPro",
    "Arimo",
    "AurulentSansMono",
    "BigBlueTerminal",
    "BitstreamVeraSansMono",
    "CascadiaCode",
    "CodeNewRoman",
    "Cousine",
    "DaddyTimeMono",
    "DejaVuSansMono",
    "DroidSansMono",
    "FantasqueSansMono",
    "FiraCode",
    "FiraMono",
    "Go-Mono",
    "Gohu",
    "Hack",
    "Hasklig",
    "HeavyData",
    "Hermit",
    "iA-Writer",
    "IBMPlexMono",
    "Inconsolata",
    "InconsolataGo",
    "InconsolataLGC",
    "Iosevka",
    "JetBrainsMono",
    "Lekton",
    "LiberationMono",
    "Meslo",
    "Monofur",
    "Monoid",
    "Mononoki",
    "MPlus",
    "Noto",
    "OpenDyslexic",
    "Overpass",
    "ProFont",
    "ProggyClean",
    "RobotoMono",
    "ShareTechMono",
    "SourceCodePro",
    "SpaceMono",
    "Terminus",
    "Tinos",
    "Ubuntu",
    "UbuntuMono",
    "VictorMono"
)

# Generate manifests
$fontNames | ForEach-Object {
    Export-FontManifest -Name $_ -OverwriteExisting:$OverwriteExisting
    Export-FontManifest -Name $_ -IsMono -OverwriteExisting:$OverwriteExisting
}
