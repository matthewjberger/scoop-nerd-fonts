function Export-FontManifest {
    Param (
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [switch]$OverwriteExisting
    )

    $templateData = [ordered]@{
        "version"    = "0.0"
        "license"    = "MIT"
        "homepage"   = "https://github.com/ryanoasis/nerd-fonts"
        "url"        = " "
        "hash"       = " "
        "checkver"   = "github"
        "depends"    = "sudo"
        "autoupdate" = @{
            "url"    = "https://github.com/ryanoasis/nerd-fonts/releases/download/v`$version/${Name}.zip"
        }
        "installer"  = @{
            "script" =
@'
                if(!(is_admin)) { error "Admin rights are required, please run 'sudo scoop install $app'"; exit 1 }
                Get-ChildItem $dir -filter '*Windows Compatible.*' | ForEach-Object {
                    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -Name $_.Name.Replace($_.Extension, ' (TrueType)') -Value $_.Name -Force | Out-Null
                    Copy-Item $_.FullName -destination "$env:windir\Fonts"
                }
'@
        }
        "uninstaller" = @{
            "script"  =
@'
                if(!(is_admin)) { error "Admin rights are required, please run 'sudo scoop uninstall $app'"; exit 1 }
                Get-ChildItem $dir -filter '*Windows Compatible.*' | ForEach-Object {
                    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -Name $_.Name.Replace($_.Extension, ' (TrueType)') -Force -ErrorAction SilentlyContinue
                    Remove-Item "$env:windir\Fonts\$($_.Name)" -Force -ErrorAction SilentlyContinue
                }
                Write-Host "The '$($app.Replace('-NF', ''))' Font family has been uninstalled and will not be present after restarting your computer." -Foreground Magenta
'@
        }
    }

    if (! (Test-Path $Path)) {
        ConvertTo-Json -InputObject $templateData | Set-Content -LiteralPath $Path -Encoding UTF8
    } elseif ($OverwriteExisting) {
        ConvertTo-Json -InputObject $templateData | Set-Content -LiteralPath $Path -Encoding UTF8 -Force
    }
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
    # Create the manifest if it doesn't exist
    Export-FontManifest -Name $_ -Path "$PSScriptRoot\..\bucket\$_-NF.json"

    # Use scoop's checkver script to autoupdate the manifest
    & $psscriptroot\checkver.ps1 "$_-NF" -u

    # Sleep to avoid 429 errors from github's REST API
    Start-Sleep 1
}
