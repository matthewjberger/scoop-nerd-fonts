#TODO: Make file downloads asynchronous

$templateString = @"
{
    "version":  "v1.1.0",
    "license":  "MIT",
    "homepage":  "https://github.com/ryanoasis/nerd-fonts",
    "url":  [
        "%url",
        "%installationScriptUrl",
        "%uninstallationScriptUrl"
    ],
    "hash":  [
        "%hash",
        "%installationScriptHash",
        "%uninstallationScriptHash"
    ],
    "checkver": "github",
    "autoupdate": "https://github.com/ryanoasis/nerd-fonts/releases/download/`$version/%name.zip",
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

Write-Host "Downloading $installationScriptUrl to $installationScriptFilePath" -ForegroundColor Blue
$client.DownloadFile($installationScriptUrl, $installationScriptFilePath)
$installationScriptHash = (Get-FileHash $installationScriptFilePath).Hash.ToLower()
Write-Host "Generated installation script hash" -ForegroundColor Green

Write-Host "Downloading $uninstallationScriptUrl to $uninstallationScriptFilePath" -ForegroundColor Blue
$client.DownloadFile($uninstallationScriptUrl, $uninstallationScriptFilePath)
$uninstallationScriptHash = (Get-FileHash $uninstallationScriptFilePath).Hash.ToLower()
Write-Host "Generated uninstallation script hash`n" -ForegroundColor Green

$fontNames | ForEach-Object {
    $font = $_
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/$font.zip"

    $outputFilePath = "$filesDir\$font.zip"

    Write-Host "Downloading $url to `n$outputFilePath" -ForegroundColor Blue
    $client.DownloadFile($url, $outputFilePath)

    $fontZipFileHash = (Get-FileHash $outputFilePath).Hash.ToLower()

    $output = $templateString -replace "%name", $font
    $output = $output -replace "%url", $url
    $output = $output -replace "%installationScriptUrl", $installationScriptUrl
    $output = $output -replace "%uninstallationScriptUrl", $uninstallationScriptUrl
    $output = $output -replace "%hash", $fontZipFileHash
    $output = $output -replace "%installationScriptHash", $installationScriptHash
    $output = $output -replace "%uninstallationScriptHash", $uninstallationScriptHash
    $output | Out-File -FilePath "$manifestDir\$font-NF.json" -Encoding utf8

    Remove-Item $outputFilePath

    Write-Host "Generated manifest for font: $font`n" -ForegroundColor Green
}

Remove-Item $filesDir -Force -Recurse