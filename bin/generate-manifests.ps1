$templateString = @"
{
    "version":  "",
    "license":  "MIT",
    "homepage":  "https://github.com/ryanoasis/nerd-fonts",
    "url":  [
        "%url",
        "%installationScriptUrl",
        "%uninstallationScriptUrl"
    ],
    "hash":  [
        "",
        "%installationScriptHash",
        "%uninstallationScriptHash"
    ],
    "checkver": "github",
    "autoupdate": {
        "url": "https://github.com/ryanoasis/nerd-fonts/releases/download/v`$version/%name.zip"
    },
    "installer": {
        "file": "install-nerd-fonts.ps1",
        "args": [
            "`$dir"
        ]
    },
    "uninstaller": {
        "file": "uninstall-nerd-fonts.ps1",
        "args": [
            "`$dir"
        ]
    }
}
"@

$fontNames = @(
    "3270",
    "AnonymousPro",
    "AurulentSansMono",
    "BitstreamVeraSansMono",
    "CodeNewRoman",
    "DejaVuSansMono",
    "DroidSansMono",
    "FantasqueSansMono",
    "FiraCode",
    "FiraMono",
    "Gohu",
    "Hack",
    "Hasklig",
    "HeavyData",
    "Hermit",
    "Inconsolata",
    "InconsolataGo",
    "Iosevka",
    "Lekton",
    "LiberationMono",
    "Meslo",
    "Monofur",
    "Monoid",
    "Mononoki",
    "MPlus",
    "ProFont",
    "ProggyClean",
    "RobotoMono",
    "ShareTechMono",
    "SourceCodePro",
    "SpaceMono",
    "Terminus",
    "Ubuntu",
    "UbuntuMono"
)

$installationScriptUrl="https://raw.githubusercontent.com/matthewjberger/scoop-nerd-fonts/master/bin/install-nerd-fonts.ps1"
$uninstallationScriptUrl="https://raw.githubusercontent.com/matthewjberger/scoop-nerd-fonts/master/bin/uninstall-nerd-fonts.ps1"

$scriptsDir = "$PSScriptRoot"
$manifestDir = "$scriptsDir\.."
$filesDir = "$scriptsDir\font_data"

$installationScriptFilePath = "$filesDir\install-nerd-fonts.ps1"
$uninstallationScriptFilePath = "$filesDir\uninstall-nerd-fonts.ps1"

New-Item $filesDir -type directory -Force | Out-Null

$client = New-Object System.Net.WebClient

# Generate file hash for installation script
Write-Host "Downloading $installationScriptUrl to $installationScriptFilePath" -ForegroundColor Blue
$client.DownloadFile($installationScriptUrl, $installationScriptFilePath)
$installationScriptHash = (Get-FileHash $installationScriptFilePath).Hash.ToLower()
Write-Host "Generated installation script hash" -ForegroundColor Green

# Generate file hash for uninstallation script
Write-Host "Downloading $uninstallationScriptUrl to $uninstallationScriptFilePath" -ForegroundColor Blue
$client.DownloadFile($uninstallationScriptUrl, $uninstallationScriptFilePath)
$uninstallationScriptHash = (Get-FileHash $uninstallationScriptFilePath).Hash.ToLower()
Write-Host "Generated uninstallation script hash" -ForegroundColor Green

Remove-Item $filesDir -Force -Recurse

# Generate manifests
$fontNames | ForEach-Object {
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/$_.zip"
    $output = $templateString -replace "%name", $_
    $output = $output -replace "%url", $url
    $output = $output -replace "%installationScriptUrl", $installationScriptUrl
    $output = $output -replace "%uninstallationScriptUrl", $uninstallationScriptUrl
    $output = $output -replace "%installationScriptHash", $installationScriptHash
    $output = $output -replace "%uninstallationScriptHash", $uninstallationScriptHash
    $output | Out-File -FilePath "$manifestDir\$_-NF.json" -Encoding utf8
}

# Autoupdate the manifests
& ./checkver.ps1 * -u
